import 'package:flutter/material.dart';
import 'package:hacknova/model/user_model.dart';

class ProfilePage extends StatefulWidget {
  final UserDataService userDataService;

  const ProfilePage({super.key, required this.userDataService});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _usernameController;
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    // Initialize the controllers with the current user data
    _usernameController = TextEditingController(
      text: widget.userDataService.username,
    );
    _locationController = TextEditingController(
      text: 'San Francisco, CA',
    ); // You can set the location dynamically as well
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    _usernameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Profile Photo
            SizedBox(height: screenHeight * 0.08),
            CircleAvatar(
              radius: screenWidth * 0.2, // Dynamic size based on screen width
              backgroundImage: AssetImage(
                'assets/images/lotus_img.jpeg',
              ), // Placeholder photo
            ),
            SizedBox(height: 20),

            // Username
            Text(
              widget.userDataService.username.isEmpty
                  ? 'John Doe' // Default username if empty
                  : widget.userDataService.username, // Dynamic username
              style: TextStyle(
                fontSize: screenWidth * 0.08, // Scalable font size
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),

            // Location
            Text(
              'San Francisco, CA', // Replace with dynamic location if needed
              style: TextStyle(
                fontSize: screenWidth * 0.05, // Scalable font size
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 20),

            // Editable Text Fields for Username and Location
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: _usernameController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white70),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.deepPurpleAccent),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _locationController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Location',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white70),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.deepPurpleAccent),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Save Button to update user data
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // Update the username from the controller value
                        widget.userDataService.setUserData(
                          _usernameController.text,
                          widget
                              .userDataService
                              .password, // Retain the same password
                        );
                      });
                      // Optionally, you can display a confirmation message or perform navigation here
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Profile updated successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: Text('Save Changes'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
