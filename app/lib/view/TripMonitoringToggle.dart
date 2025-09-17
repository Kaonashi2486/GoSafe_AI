import 'package:flutter/cupertino.dart';

class TripMonitoring extends StatefulWidget {
  const TripMonitoring({super.key});

  @override
  _TripMonitoringState createState() => _TripMonitoringState();
}

class _TripMonitoringState extends State<TripMonitoring> {
  bool isMonitoring = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text("Trip Monitoring")),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Enable real-time trip tracking?",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            CupertinoSwitch(
              value: isMonitoring,
              onChanged: (value) {
                setState(() => isMonitoring = value);
              },
            ),
            SizedBox(height: 20),
            Text(
              isMonitoring
                  ? "🟢 Monitoring Active – Location Shared"
                  : "🔴 Monitoring Off",
              style: TextStyle(
                color:
                    isMonitoring
                        ? CupertinoColors.activeGreen
                        : CupertinoColors.systemRed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
