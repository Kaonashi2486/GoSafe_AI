import 'package:flutter/material.dart';
import 'package:hacknova/util/MapScreen.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class Mapview extends StatefulWidget {
  final Function(int) onTap;

  const Mapview({super.key, required this.onTap});
  @override
  _MapviewState createState() => _MapviewState();
}

class _MapviewState extends State<Mapview> {
  // Controller for text input

  // Hardcoded destination address
  String destinationAddress = "";

  @override
  Widget build(BuildContext context) {
    // Getting the screen size for dynamic font sizing
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Map Container (Filling 75% of the screen height)
          Container(
            height: screenHeight,
            width: screenWidth,
            child: MapScreen(), // MapWidget always present
          ),
        ],
      ),
    );
  }
}
