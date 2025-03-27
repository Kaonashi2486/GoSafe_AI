import 'dart:collection';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hacknova/util/RoutingService.dart';
import 'package:hacknova/view/DetailView.dart';
import 'package:hacknova/view/SignIn.dart';
import 'package:image_picker/image_picker.dart'
    as image_picker; // Aliased// Assuming SignUpPage is already built
import 'package:hacknova/view/Homepage.dart';
import 'package:hacknova/model/user_model.dart';
import 'package:hacknova/util/locator.dart';
import 'package:hacknova/Navigation/FloatingBottomNavigationBar.dart';
import 'package:hacknova/view/MapView.dart';
import 'package:hacknova/view/ProfileView.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import 'api/IncidentEvents.dart';
import 'api/PhotoDetail.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  runApp(const MyApp());
}

void setup(username, password) async {
  MapboxOptions.setAccessToken(
    "pk.eyJ1Ijoia2dkNTQ2IiwiYSI6ImNtN2VoczY0MjBlYTkya3B4OTFhaWpnaXUifQ.T9ETlbj8TasSZsjbFpIXGg",
  );
  var userDataService = locator<UserDataService>();

  // Set username and password
  await userDataService.setUserData(username, password);
  return;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoSafeAI',
      theme: ThemeData(
        brightness: Brightness.dark, // Dark theme
        primaryColor: Colors.grey.shade900, // Primary color
        scaffoldBackgroundColor:
            Colors.grey.shade900, // Dark blue background color
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF0D47A1), // Darker blue for app bar
          centerTitle: true,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blueGrey,
        ),
        colorScheme: ColorScheme.dark().copyWith(
          primary: Colors.blue.shade300,
          secondary: Colors.deepOrange,
        ),
      ),
      debugShowCheckedModeBanner: false, // Remove the debug banner
      home: const SignInPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String username;
  final String password;
  const MyHomePage({
    super.key,
    required this.title,
    required this.username,
    required this.password,
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _index = 0;
  LatLng? currentLocation;
  final image_picker.ImagePicker _picker =
      image_picker.ImagePicker(); // Use aliased ImagePicker

  Future<void> _fetchCurrentLocation() async {
    LatLng? location = await RoutingService.getCurrentLocation();
    List<Map<String,String>> temp=await getIncidentDetails();
    if (location != null) {
      String? name = await RoutingService.getAddressFromCoordinates(location!);
      setState(() {
        currentLocation = location;
      });
    }
  }

  // Function to open the camera and pick an image
  Future<void> _pickImage() async {
    try {
      // Request camera permission
      var status = await Permission.camera.request();

      if (status.isGranted) {
        // Open the camera to take a picture
        image_picker.XFile? pickedFile = await _picker.pickImage(
          source: image_picker.ImageSource.camera,
        );

        if (pickedFile != null) {
          File imageFile = File(pickedFile.path);
          reportIncident(imageFile, currentLocation!.latitude.toString(),currentLocation!.longitude.toString(), 'temporary addition');
        }
      } else {
        print("Camera permission denied.");
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  // Placeholder for sending the image to the backend
  Future<void> _sendImageToBackend(File imageFile) async {
    // Here you can send the image to the backend
    // For now, we are just printing the path
    print('Image picked: ${imageFile.path}');
  }

  void onTap(value) {
    setState(() {
      _index = value;
    });
  }

  @override
  void initState() {
    setup(widget.username, widget.password);
    super.initState();
    _checkLoginStatus(); // Check login status when app starts
  }

  Future<void> _logout() async {
    var userDataService = locator<UserDataService>();
    await userDataService.logout();
    return;
  }

  // Function to check if user is logged in
  Future<void> _checkLoginStatus() async {
    var userDataService = locator<UserDataService>();

    // Check if the user is logged in
    bool isLoggedIn =
        await userDataService
            .isLoggedIn(); // Assume you have a method to check login status

    if (!isLoggedIn) {
      // If not logged in, redirect to the SignUp page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade800,
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.blue.shade300, fontSize: 35, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        actions: [
          // Logout Icon on the right side of the AppBar
          IconButton(
            icon: Icon(Icons.exit_to_app,size: 30,), // Logout icon
            onPressed: () {
              // Add your logout functionality here
              _logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SignInPage()),
              );
            },
          ),
        ],
      ),
      extendBody: true, // Allow body to go behind bottom nav
      body: _getBody(), // Function to select body content
      floatingActionButton:
          _index == 0
              ? FloatingActionButton(
                onPressed: _pickImage, // Trigger the image picking when clicked
                child: const Icon(CupertinoIcons.camera_fill),
              )
              : null, // If the index is not 0, don't display the FAB
      bottomNavigationBar: IOSStyleNavBar(
        currentIndex: _index,
        onTap: (index) => setState(() => _index = index),
        items: [
          NavBarItem(
            icon: CupertinoIcons.house_fill,
            label: 'Home',
          ),
          NavBarItem(
            icon: CupertinoIcons.map_fill,
            label: 'Map',
          ),
          NavBarItem(
            icon: CupertinoIcons.person_fill,
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _getBody() {
    var userData = locator<UserDataService>();
    switch (_index) {
      case 0:
        return HomeView(onTap: onTap); // Home Screen
      case 1:
        return Mapview(onTap: onTap);
      case 2:
        return ProfilePage(userDataService: userData);
      case 3:
        return CheckboxPage(); // Map Routing Screen
      default:
        return HomeView(onTap: onTap); // Default to Home Screen
    }
  }
}
