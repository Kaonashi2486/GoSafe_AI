import 'package:flutter/cupertino.dart';

class SosScreen extends StatelessWidget {
  const SosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      navigationBar: CupertinoNavigationBar(
        middle: Text("Emergency SOS"),
        backgroundColor: CupertinoColors.destructiveRed.withOpacity(0.2),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Big SOS Button
            CupertinoButton(
              padding: EdgeInsets.all(60),
              color: CupertinoColors.destructiveRed,
              borderRadius: BorderRadius.circular(150),
              child: Text(
                "SOS",
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                // send SOS signal
              },
            ),
            SizedBox(height: 30),
            Text(
              "Tap or Say 'Help' to trigger SOS",
              style: TextStyle(color: CupertinoColors.systemGrey2),
            ),
            SizedBox(height: 20),
            CupertinoButton(
              color: CupertinoColors.activeBlue,
              child: Text("🎙 Enable Voice SOS"),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
