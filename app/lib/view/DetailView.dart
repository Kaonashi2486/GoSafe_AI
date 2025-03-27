import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class CheckboxPage extends StatefulWidget {
  @override
  _CheckboxPageState createState() => _CheckboxPageState();
}

class _CheckboxPageState extends State<CheckboxPage> {
  // List to track the selected state of each checkbox
  List<bool> isSelected = [false, false, false, false];

  @override
  Widget build(BuildContext context) {
    // Getting the screen size for dynamic font sizing
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Map Container (Filling the screen)
          Container(
            height: screenHeight,
            width: screenWidth,
            child: MapWidget(), // MapWidget always present
          ),

          // Widget 2 - Custom Checkboxes positioned on top of the MapWidget
          Positioned(
            top: screenHeight * 0.05, // 20% from the top
            right: screenWidth * 0.1, // 15% from the right
            child: Container(
              child: Column(
                children: [
                  // Custom Checkbox 1
                  customCheckbox('Label 1', 0),
                  // Custom Checkbox 2
                  customCheckbox('Label 2', 1),
                  // Custom Checkbox 3
                  customCheckbox('Label 3', 2),
                  // Custom Checkbox 4
                  customCheckbox('Label 4', 3),
                ],
              ),
            ),
          ),

          // After checkbox selection, show the rendered components
          if (isSelected.any((element) => element))
            Positioned(
              top:
                  screenHeight *
                  0.5, // Start below the checkboxes and map (scrollable area)
              left: 0,
              right: 0,
              bottom: 0,
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(4, (index) {
                    if (isSelected[index]) {
                      return Container(
                        margin: EdgeInsets.symmetric(
                          vertical: 5,
                        ), // Spacing between components
                        width: screenWidth * 0.8, // Container width
                        height: screenHeight * 0.1, // Container height
                        color:
                            Colors
                                .blue
                                .shade50, // Light blue background for containers
                        child: Center(
                          child: Text(
                            'Component ${index + 1}', // Dummy title (Component 1, 2, etc.)
                            style: TextStyle(
                              fontSize: screenWidth * 0.05, // Dynamic font size
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                      );
                    } else {
                      return SizedBox.shrink(); // Return an empty box if the checkbox isn't selected
                    }
                  }),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Custom Checkbox Widget
  Widget customCheckbox(String label, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isSelected[index] = !isSelected[index];
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 10,
        ), // Space around the checkbox
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected[index] ? Colors.black : Colors.grey,
                  width: 2,
                ),
              ),
              child:
                  isSelected[index]
                      ? Icon(Icons.check, size: 20, color: Colors.black)
                      : null, // Display checkmark if selected
            ),
            SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold, // Make text bolder
                fontSize: 24,
                color: Colors.blue.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
