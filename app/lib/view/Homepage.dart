import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hacknova/api/safetyScore_api.dart';
import 'package:hacknova/util/RoutingService.dart';
import 'package:hacknova/util/TOMTOM_API.dart';
import 'package:latlong2/latlong.dart';

class HomeView extends StatefulWidget {
  final Function(int) onTap;

  const HomeView({super.key, required this.onTap});
  @override
  _HomeView createState() => _HomeView();
}

class _HomeView extends State<HomeView> {
  LatLng? currentLocation;
  bool check = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    LatLng? location = await RoutingService.getCurrentLocation();
    if (location != null) {
      setState(() {
        currentLocation = location;
        check = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF2C2C2E), // Dark gray background
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.04),
              // Header
              Text(
                'Travel Safe with\nGoSafe.AI',
                style: TextStyle(
                  fontSize: screenWidth * 0.09,
                  fontWeight: FontWeight.w800,
                  color: CupertinoColors.white,
                  height: 1.2,
                ),
              ),
              SizedBox(height: screenHeight * 0.03),

              // iOS-style Search Bar
              CupertinoSearchTextField(
                controller: _searchController,
                placeholder: 'Enter destination...',
                padding: const EdgeInsets.all(12),
                prefixInsets: const EdgeInsets.only(left: 8),
                backgroundColor: const Color(0xFF3A3A3C), // Slightly lighter gray
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  color: CupertinoColors.white,
                ),
                onSubmitted: (value) => _navigateToNextPage(),
              ),
              SizedBox(height: screenHeight * 0.03),

              // Recent Searches
              Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.systemGrey2,
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              SizedBox(
                height: screenHeight * 0.06,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) => CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFF3A3A3C), // Slightly lighter gray for contrast
                    onPressed: () {},
                    child: Text(
                      'Search ${index + 1}',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: screenWidth * 0.04,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.04),

              // Features Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3A3C), // Card background dark gray
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(CupertinoIcons.shield_fill,
                            color: CupertinoColors.activeBlue, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Why Choose GoSafe.AI',
                          style: TextStyle(
                            fontSize: screenWidth * 0.055,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem('AI-powered Safety Score analysis'),
                    _buildFeatureItem('Real-time crime data updates'),
                    _buildFeatureItem('Weather risk assessment'),
                    _buildFeatureItem('Optimized safe routes'),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.04),

              // Current Location Map
              Text(
                'Current Location',
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.systemGrey2,
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              Container(
                height: screenHeight * 0.25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: check
                      ? FlutterMap(
                    options: MapOptions(
                      initialCenter: currentLocation!,
                      initialZoom: 13,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                        "https://api.tomtom.com/map/1/tile/basic/main/{z}/{x}/{y}.png?key=$TOMTOM_API_KEY",
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 40,
                            height: 40,
                            point: currentLocation!,
                            child: const Icon(
                              CupertinoIcons.location_solid,
                              color: CupertinoColors.activeBlue,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                      : const Center(
                    child: CupertinoActivityIndicator(),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(CupertinoIcons.checkmark_seal_fill,
              color: CupertinoColors.systemGreen, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.04,
                color: CupertinoColors.systemGrey2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToNextPage() {
    widget.onTap(1);
  }
}
