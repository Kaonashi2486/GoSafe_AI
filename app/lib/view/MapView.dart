import 'package:flutter/material.dart';
import 'package:hacknova/util/MapScreen.dart';

class Mapview extends StatefulWidget {
  final Function(int) onTap;

  const Mapview({super.key, required this.onTap});

  @override
  _MapviewState createState() => _MapviewState();
}

class _MapviewState extends State<Mapview> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: MapScreen(), // Removed SafeArea to make it fullscreen
    );
  }
}
