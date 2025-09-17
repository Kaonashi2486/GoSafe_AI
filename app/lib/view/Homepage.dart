import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:hacknova/util/RoutingService.dart';

class HomeView extends StatefulWidget {
  final Function(int) onTap;

  const HomeView({super.key, required this.onTap});

  @override
  _HomeView createState() => _HomeView();
}

class _HomeView extends State<HomeView> with TickerProviderStateMixin {
  LatLng? currentLocation;
  bool check = false;
  final TextEditingController _searchController = TextEditingController();

  // Feature states
  bool tripMonitoring = false;
  bool geoFenceOn = false;

  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
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
    var TOMTOM_API_KEY = "5S942FW5vWvlAV9u2hGGEqGUniBut2X9";

    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverSafeArea(
              sliver: SliverPadding(
                padding: const EdgeInsets.all(24.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Header Section
                    _buildHeader(screenWidth),
                    const SizedBox(height: 32),

                    // Search Bar
                    _buildSearchBar(screenWidth),
                    const SizedBox(height: 32),

                    // Quick Actions Grid
                    _buildQuickActions(),
                    const SizedBox(height: 32),

                    // Safety Features
                    _buildSafetyFeatures(),
                    const SizedBox(height: 32),

                    // Map Section
                    _buildMapSection(screenHeight, TOMTOM_API_KEY),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stay Safe,',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w300,
                color: Colors.grey[400],
                letterSpacing: -0.5,
              ),
            ),
            const Text(
              'Travel Secure',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar(double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: CupertinoTextField(
        controller: _searchController,
        placeholder: 'Where do you want to go?',
        placeholderStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
        style: const TextStyle(color: Colors.white, fontSize: 16),
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(),
        prefix: Padding(
          padding: const EdgeInsets.only(left: 16, right: 12),
          child: Icon(CupertinoIcons.search, color: Colors.grey[500], size: 20),
        ),
        suffix: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: CupertinoButton(
            padding: const EdgeInsets.all(8),
            minSize: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Go',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            onPressed: () => _navigateToNextPage(),
          ),
        ),
        onSubmitted: (value) => _navigateToNextPage(),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: CupertinoIcons.exclamationmark_triangle_fill,
                title: 'Emergency',
                subtitle: 'SOS Alert',
                color: const Color(0xFFFF3B30),
                onTap: () => _showSosDialog(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                icon: CupertinoIcons.camera_fill,
                title: 'Report',
                subtitle: 'Incident',
                color: const Color(0xFFFF9500),
                onTap: () => _showReportDialog(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Safety Features',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildFeatureToggle(
          title: 'Trip Monitoring',
          subtitle: 'Real-time journey tracking',
          icon: CupertinoIcons.location_fill,
          value: tripMonitoring,
          onChanged: (val) => setState(() => tripMonitoring = val),
        ),
        const SizedBox(height: 12),
        _buildFeatureToggle(
          title: 'Geo-Fence Alerts',
          subtitle: 'Unsafe area notifications',
          icon: CupertinoIcons.shield_fill,
          value: geoFenceOn,
          onChanged: (val) => setState(() => geoFenceOn = val),
        ),
      ],
    );
  }

  Widget _buildFeatureToggle({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
            value
                ? const Color(0xFF007AFF).withOpacity(0.1)
                : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              value
                  ? const Color(0xFF007AFF).withOpacity(0.3)
                  : Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (value ? const Color(0xFF007AFF) : Colors.grey[600]!)
                  .withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: value ? const Color(0xFF007AFF) : Colors.grey[500],
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF007AFF),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection(double screenHeight, String apiKey) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Your Location',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            if (check)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF34C759).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF34C759).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF34C759),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Live',
                      style: TextStyle(
                        color: Color(0xFF34C759),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: screenHeight * 0.25,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child:
                check
                    ? FlutterMap(
                      options: MapOptions(
                        initialCenter: currentLocation!,
                        initialZoom: 15,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              "https://api.tomtom.com/map/1/tile/basic/main/{z}/{x}/{y}.png?key=$apiKey",
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              width: 50,
                              height: 50,
                              point: currentLocation!,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF007AFF),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF007AFF,
                                      ).withOpacity(0.3),
                                      blurRadius: 12,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.my_location,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                    : Container(
                      color: Colors.white.withOpacity(0.05),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CupertinoActivityIndicator(
                              color: Color(0xFF007AFF),
                              radius: 16,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Locating you...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
          ),
        ),
      ],
    );
  }

  void _showSosDialog() {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => CupertinoAlertDialog(
            title: const Text(
              'Emergency SOS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFF3B30),
              ),
            ),
            content: const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Column(
                children: [
                  Icon(
                    CupertinoIcons.exclamationmark_triangle_fill,
                    color: Color(0xFFFF3B30),
                    size: 48,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'This will immediately alert emergency services and your emergency contacts with your current location.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text('Cancel', style: TextStyle(fontSize: 17)),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: const Text(
                  'Send SOS',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _activateSOS();
                },
              ),
            ],
          ),
    );
  }

  void _showReportDialog() {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: const Text('Report Incident'),
            content: const Text(
              'What type of incident would you like to report?',
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text('Accident'),
                onPressed: () {
                  Navigator.pop(context);
                  // Handle accident report
                },
              ),
              CupertinoDialogAction(
                child: const Text('Hazard'),
                onPressed: () {
                  Navigator.pop(context);
                  // Handle hazard report
                },
              ),
              CupertinoDialogAction(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  void _activateSOS() {
    // Implement SOS functionality
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: const Text(
              'SOS Activated',
              style: TextStyle(color: Color(0xFF34C759)),
            ),
            content: const Text('Emergency services have been notified.'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  void _navigateToNextPage() {
    widget.onTap(1);
  }
}
