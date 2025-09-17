import 'dart:collection';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hacknova/util/RoutingService.dart';
import 'package:hacknova/view/DetailView.dart';
import 'package:hacknova/view/SignIn.dart';
import 'package:image_picker/image_picker.dart' as image_picker;
import 'package:hacknova/view/Homepage.dart';
import 'package:hacknova/model/user_model.dart';
import 'package:hacknova/util/locator.dart';
import 'package:hacknova/Navigation/FloatingBottomNavigationBar.dart';
import 'package:hacknova/view/MapView.dart';
import 'package:hacknova/view/ProfileView.dart';
import 'package:latlong2/latlong.dart';
// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import 'Navigation/CustomAppBar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  runApp(const NavRakshakApp());
}

void setup(username, password) async {
  // MapboxOptions.setAccessToken(
  //   "pk.eyJ1Ijoia2dkNTQ2IiwiYSI6ImNtN2VoczY0MjBlYTkya3B4OTFhaWpnaXUifQ.T9ETlbj8TasSZsjbFpIXGg",
  // );
  var userDataService = locator<UserDataService>();
  await userDataService.setUserData(username, password);
  return;
}

class NavRakshakApp extends StatelessWidget {
  const NavRakshakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'NavRakshak',
      theme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: CupertinoColors.systemBlue,
        scaffoldBackgroundColor: Color(0xFF000000),
        barBackgroundColor: Color(0xFF1C1C1E),
        textTheme: CupertinoTextThemeData(primaryColor: CupertinoColors.white),
      ),
      debugShowCheckedModeBanner: false,
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
  final image_picker.ImagePicker _picker = image_picker.ImagePicker();

  @override
  void initState() {
    setup(widget.username, widget.password);
    super.initState();
    _checkLoginStatus();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    LatLng? location = await RoutingService.getCurrentLocation();
    if (location != null) {
      String? name = await RoutingService.getAddressFromCoordinates(location);
      setState(() {
        currentLocation = location;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      var status = await Permission.camera.request();

      if (status.isGranted) {
        image_picker.XFile? pickedFile = await _picker.pickImage(
          source: image_picker.ImageSource.camera,
          imageQuality: 85,
        );

        if (pickedFile != null) {
          File imageFile = File(pickedFile.path);
          await _processIncidentImage(imageFile);
        }
      } else {
        _showPermissionDeniedDialog();
      }
    } catch (e) {
      _showErrorDialog('Error accessing camera: $e');
    }
  }

  Future<void> _processIncidentImage(File imageFile) async {
    // Show loading indicator
    showCupertinoDialog(
      context: context,
      builder:
          (context) => const CupertinoAlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoActivityIndicator(),
                SizedBox(height: 16),
                Text('Processing incident report...'),
              ],
            ),
          ),
    );

    try {
      // Process the incident image
      // await reportIncident(imageFile, currentLocation!.latitude.toString(),
      //     currentLocation!.longitude.toString(), 'Incident report');

      Navigator.pop(context); // Close loading dialog
      _showSuccessDialog('Incident reported successfully');
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showErrorDialog('Failed to report incident: $e');
    }
  }

  void _showPermissionDeniedDialog() {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: const Text('Camera Permission Required'),
            content: const Text(
              'NavRakshak needs camera access to report incidents. Please enable camera permission in Settings.',
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoDialogAction(
                child: const Text('Open Settings'),
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  void _showSuccessDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: const Text('Success'),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  void onTap(value) {
    setState(() {
      _index = value;
    });
  }

  Future<void> _logout() async {
    var userDataService = locator<UserDataService>();
    await userDataService.logout();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (context) => const SignInPage()),
      );
    }
  }

  Future<void> _checkLoginStatus() async {
    var userDataService = locator<UserDataService>();
    bool isLoggedIn = await userDataService.isLoggedIn();

    if (!isLoggedIn && mounted) {
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (context) => const SignInPage()),
      );
    }
  }

  void _showLogoutDialog() {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: const Text('Sign Out'),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              CupertinoDialogAction(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: const Text('Sign Out'),
                onPressed: () {
                  Navigator.pop(context);
                  _logout();
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: CustomSlidingAppBar(
        title: 'NavRakshak',
        navItems: const ['Home', 'Map', 'Profile'],
        currentIndex: _index,
        onNavChanged: (index) => setState(() => _index = index),
        actions: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _showLogoutDialog,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CupertinoColors.systemRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                CupertinoIcons.square_arrow_right,
                color: CupertinoColors.systemRed,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      extendBody: true,
      body: Stack(
        children: [
          _getBody(),

          // Floating Action Button for Camera (only on Home page)
          if (_index == 0)
            Positioned(
              right: 20,
              bottom: 100,
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBlue,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.systemBlue.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    CupertinoIcons.camera_fill,
                    color: CupertinoColors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: IOSStyleNavBar(
        currentIndex: _index,
        onTap: (index) => setState(() => _index = index),
        items: [
          NavBarItem(icon: CupertinoIcons.house_fill, label: 'Home'),
          NavBarItem(icon: CupertinoIcons.map_fill, label: 'Map'),
          NavBarItem(icon: CupertinoIcons.person_fill, label: 'Profile'),
        ],
      ),
    );
  }

  Widget _getBody() {
    var userData = locator<UserDataService>();
    switch (_index) {
      case 0:
        return HomeView(onTap: onTap);
      case 1:
        return Mapview(onTap: onTap);
      case 2:
        return ProfilePage(userDataService: userData);
      case 3:
      // return CheckboxPage();
      default:
        return HomeView(onTap: onTap);
    }
  }
}
