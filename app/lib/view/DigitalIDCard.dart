import 'package:flutter/cupertino.dart';

class DigitalIdCard extends StatelessWidget {
  const DigitalIdCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.darkBackgroundGray,
      child: Center(
        child: Container(
          width: 300,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Icon(
                CupertinoIcons.person_crop_circle,
                size: 60,
                color: CupertinoColors.activeBlue,
              ),
              Text(
                "Temporary Digital ID",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text("Name: John Doe"),
              Text("Nationality: Tourist"),
              SizedBox(height: 15),
              Container(
                height: 100,
                color: CupertinoColors.systemGrey3, // Placeholder for QR
                child: Center(child: Text("QR Code")),
              ),
              SizedBox(height: 15),
              CupertinoButton.filled(
                child: Text("Control Data Sharing"),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
