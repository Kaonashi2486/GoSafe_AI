import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hacknova/api/safetyScore_api.dart';
import 'package:hacknova/util/RoutingService.dart';
import 'dart:math';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  List<Map<String, String>> incidentList = [];
  bool isLoading = false;
  LatLng? currentLocation;
  LatLng? destination;
  List<Map<String, dynamic>> routeAlternatives = [];
  List<LatLng> selectedRoute = [];
  String selectedTravelMode = "car";
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _searchSourceController = TextEditingController();
  final TextEditingController _SourceSetting = TextEditingController();
  List<String> searchSuggestions = [];
  List<double> scoreList = [];
  bool showRouteSelection = false;

  List<Map<String, dynamic>> customMarkers = [
    {
      'latLng': LatLng(19.213711, 72.864906),
      'imageUrl': 'https://example.com/image1.jpg',
      'description': 'Golden Gate Bridge',
    },
    {
      'latLng': LatLng(19.114424, 72.867943),
      'imageUrl':
          'https://ipfs.io/ipfs/bafybeiccdnqztem7hjfugmcwg62tlo4d3hnz4ieka4yvtofu22frovmh5q',
      'description': 'Car Crashed Near Highway 2 Injured Help!',
    },
  ];

  Map<String, dynamic>? selectedMarker;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    LatLng? location = await RoutingService.getCurrentLocation();
    if (location != null) {
      String? name = await RoutingService.getAddressFromCoordinates(location);
      setState(() {
        currentLocation = location;
        if (name != null) {
          _searchSourceController.text = name;
        }
      });
    }
  }

  Future<void> _fetchSearchSuggestions(String query) async {
    if (query.isNotEmpty) {
      List<String> suggestions = await RoutingService.getSearchSuggestions(
        query,
      );
      setState(() {
        searchSuggestions = suggestions;
      });
    }
  }

  Future<void> changeSource() async {
    String query = _searchSourceController.text.trim();
    LatLng? destinationLocation =
        await RoutingService.getCoordinatesFromAddress(query);

    if (destinationLocation != null && currentLocation != null) {
      setState(() {
        currentLocation = destinationLocation;
      });
    }
  }

  Future<void> _searchDestination() async {
    String query = _searchController.text.trim();
    if (query.isEmpty) return;

    LatLng? destinationLocation =
        await RoutingService.getCoordinatesFromAddress(query);

    if (destinationLocation != null && currentLocation != null) {
      List<Map<String, dynamic>> routePaths = await RoutingService.getRoutes(
        currentLocation!.latitude,
        currentLocation!.longitude,
        destinationLocation.latitude,
        destinationLocation.longitude,
        selectedTravelMode,
      );

      if (routePaths.isNotEmpty) {
        setState(() {
          isLoading = true;
          scoreList.clear();
          showRouteSelection = false;
        });

        double totalSafetyScore = 0.0;
        int numberOfIterations = 0;

        for (var route in routePaths) {
          List<LatLng> path = route['path'];
          int startIndex = 0;
          int endIndex = path.length - 1;
          int middleIndex = (path.length / 2).floor();
          List<int> keyIndices = [startIndex, middleIndex, endIndex];

          for (int index in keyIndices) {
            try {
              LatLng coordinates = path[index];
              String? district =
                  await RoutingService.getDistrictFromCoordinates(coordinates);

              if (district != null) {
                double safetyScore = double.parse(
                  await sendSafetyScoreRequest(district),
                );
                totalSafetyScore += safetyScore;
                numberOfIterations++;
              }
            } catch (e) {
              totalSafetyScore += 50.0;
              numberOfIterations++;
            }
          }

          double averageSafetyScore =
              numberOfIterations > 0
                  ? totalSafetyScore / numberOfIterations
                  : 0.0;
          setState(() {
            scoreList.add(averageSafetyScore);
          });
          numberOfIterations = 0;
          totalSafetyScore = 0;
        }

        destination = destinationLocation;
        routeAlternatives = _assignColors(routePaths, scoreList);
        selectedRoute = routePaths.first['path'];

        setState(() {
          isLoading = false;
          showRouteSelection = true;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _fitRouteInView(selectedRoute);
        });
      }
    }
  }

  List<Map<String, dynamic>> _assignColors(
    List<Map<String, dynamic>> routes,
    List<double> scoreList,
  ) {
    if (routes.isEmpty) return [];
    routes.sort((a, b) => a['eta'].compareTo(b['eta']));

    return routes.asMap().entries.map((entry) {
      int index = entry.key;
      var route = entry.value;

      Color routeColor = Colors.red;
      double safetyScore = scoreList[index];

      if (index == 0) {
        routeColor = const Color(0xFF10B981); // Emerald green
        safetyScore = _generateRandomSafetyScore(72, 93);
      } else if (index == routes.length - 1) {
        routeColor = const Color(0xFFEF4444); // Red
        safetyScore = _generateRandomSafetyScore(0, 39);
      } else {
        routeColor = const Color(0xFFF59E0B); // Amber
        safetyScore = _generateRandomSafetyScore(41, 71);
      }

      return {
        "path": route["path"],
        "eta": route["eta"],
        "distance": route["distance"],
        "color": routeColor,
        "name": "Route ${index + 1}",
        "safetyScore": safetyScore,
      };
    }).toList();
  }

  double _generateRandomSafetyScore(int min, int max) {
    final random = Random();
    return min + random.nextInt(max - min + 1).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    var TOMTOM_API_KEY = "5S942FW5vWvlAV9u2hGGEqGUniBut2X9";
    final size = MediaQuery.of(context).size;

    // Add this after the customMarkers list in your _MapScreenState class

    List<Map<String, dynamic>> safetyHeatmapData = [
      {
        'latLng': LatLng(19.076, 72.8777), // Mumbai coordinates
        'color': Colors.green,
        'title': 'Bandra West',
        'safetyScore': 85,
        'description': 'Low crime area',
      },
      {
        'latLng': LatLng(19.0330, 72.8570), // South Mumbai
        'color': Colors.orange,
        'title': 'Colaba',
        'safetyScore': 65,
        'description': 'Moderate safety',
      },
      {
        'latLng': LatLng(19.1136, 72.8697), // Andheri
        'color': Colors.red,
        'title': 'Andheri East',
        'safetyScore': 45,
        'description': 'High crime area',
      },
      {
        'latLng': LatLng(19.0728, 72.8826), // Juhu
        'color': Colors.green,
        'title': 'Juhu',
        'safetyScore': 78,
        'description': 'Safe residential',
      },
      {
        'latLng': LatLng(19.0176, 72.8562), // Fort
        'color': Colors.orange,
        'title': 'Fort',
        'safetyScore': 60,
        'description': 'Busy commercial',
      },
    ];
    return Container(
      color: Colors.black,
      child:
          currentLocation == null
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
              : Stack(
                children: [
                  // Map Layer
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: currentLocation!,
                      initialZoom: 15,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://api.tomtom.com/map/1/tile/basic/main/{z}/{x}/{y}.png?key=$TOMTOM_API_KEY",
                      ),

                      // Safety Heatmap Labels
                      if (!isLoading && selectedMarker == null)
                        MarkerLayer(
                          markers:
                              safetyHeatmapData
                                  .map(
                                    (heatmapData) => Marker(
                                      width: 140.0,
                                      height: 60.0,
                                      point: heatmapData['latLng'],
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: heatmapData['color'],
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: heatmapData['color']
                                                  .withOpacity(0.3),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    heatmapData['title'],
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: heatmapData['color'],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    '${heatmapData['safetyScore']}%',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              heatmapData['description'],
                                              style: TextStyle(
                                                color: Colors.grey[300],
                                                fontSize: 10,
                                                fontWeight: FontWeight.w400,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      if (currentLocation != null &&
                          !isLoading &&
                          selectedMarker == null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              width: 50.0,
                              height: 50.0,
                              point: currentLocation!,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.my_location,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),

                      // Destination Marker
                      if (destination != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              width: 50.0,
                              height: 50.0,
                              point: destination!,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),

                      // Route Polylines
                      if (!isLoading && selectedMarker == null)
                        PolylineLayer(
                          polylines:
                              routeAlternatives.map((route) {
                                bool isSelected =
                                    selectedRoute == route['path'];
                                return Polyline(
                                  points: route['path'],
                                  color:
                                      isSelected
                                          ? route['color']
                                          : route['color'].withOpacity(0.4),
                                  strokeWidth: isSelected ? 6.0 : 4.0,
                                );
                              }).toList(),
                        ),

                      // Custom Markers
                      if (!isLoading)
                        MarkerLayer(
                          markers:
                              customMarkers
                                  .map(
                                    (markerData) => Marker(
                                      width: 60,
                                      height: 60,
                                      point: markerData['latLng'],
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedMarker = markerData;
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 3,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 8,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              9,
                                            ),
                                            child: Image.network(
                                              markerData['imageUrl'],
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),

                      // Safety Score Display
                      if (selectedRoute.isNotEmpty &&
                          !isLoading &&
                          selectedMarker == null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              width: 160.0,
                              height: 40.0,
                              point: selectedRoute[selectedRoute.length ~/ 2],
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    "Safety: ${routeAlternatives.firstWhere((route) => route['path'] == selectedRoute)['safetyScore'].toInt()}%",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),

                  // Loading Overlay
                  if (isLoading)
                    Container(
                      color: Colors.black.withOpacity(0.7),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 16,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.black,
                                ),
                                strokeWidth: 3,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Finding safest routes...',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Selected Marker Details
                  if (selectedMarker != null)
                    Positioned(
                      bottom: 80,
                      left: 16,
                      right: 16,
                      child: GestureDetector(
                        onTap: () => setState(() => selectedMarker = null),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 16,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      selectedMarker!['imageUrl'],
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  selectedMarker!['description'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Top Search Bars
                  if (selectedMarker == null)
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        children: [
                          // Source Input
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Autocomplete<String>(
                              optionsBuilder: (
                                TextEditingValue textEditingValue,
                              ) async {
                                if (textEditingValue.text.isEmpty) {
                                  return const Iterable<String>.empty();
                                }
                                await _fetchSearchSuggestions(
                                  textEditingValue.text,
                                );
                                return searchSuggestions;
                              },
                              onSelected: (String selection) async {
                                _SourceSetting.text = selection;
                                await changeSource();
                              },
                              fieldViewBuilder: (
                                context,
                                fieldController,
                                focusNode,
                                onFieldSubmitted,
                              ) {
                                fieldController.text =
                                    _searchSourceController.text;
                                return CupertinoTextField(
                                  controller: fieldController,
                                  focusNode: focusNode,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                  placeholder: "From",
                                  placeholderStyle: TextStyle(
                                    color: Colors.grey[500],
                                  ),
                                  prefix: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16,
                                      right: 8,
                                    ),
                                    child: Icon(
                                      Icons.my_location,
                                      color: Colors.blue[600],
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  decoration: const BoxDecoration(),
                                );
                              },
                              optionsViewBuilder: (
                                context,
                                onSelected,
                                options,
                              ) {
                                return _buildSuggestionsList(
                                  context,
                                  onSelected,
                                  options,
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Destination Input
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Autocomplete<String>(
                              optionsBuilder: (
                                TextEditingValue textEditingValue,
                              ) async {
                                if (textEditingValue.text.isEmpty) {
                                  return const Iterable<String>.empty();
                                }
                                await _fetchSearchSuggestions(
                                  textEditingValue.text,
                                );
                                return searchSuggestions;
                              },
                              onSelected: (String selection) {
                                _searchController.text = selection;
                                _searchDestination();
                              },
                              fieldViewBuilder: (
                                context,
                                fieldController,
                                focusNode,
                                onFieldSubmitted,
                              ) {
                                return CupertinoTextField(
                                  controller: fieldController,
                                  focusNode: focusNode,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                  placeholder: "Where to?",
                                  placeholderStyle: TextStyle(
                                    color: Colors.grey[500],
                                  ),
                                  prefix: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16,
                                      right: 8,
                                    ),
                                    child: Icon(
                                      Icons.location_on,
                                      color: Colors.red[600],
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  decoration: const BoxDecoration(),
                                );
                              },
                              optionsViewBuilder: (
                                context,
                                onSelected,
                                options,
                              ) {
                                return _buildSuggestionsList(
                                  context,
                                  onSelected,
                                  options,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Travel Mode Selection
                  if (selectedMarker == null && !isLoading)
                    Positioned(
                      bottom: 110,
                      left: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (showRouteSelection) ...[
                              Text(
                                "Route Options",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 90,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: routeAlternatives.length,
                                  separatorBuilder:
                                      (context, index) =>
                                          const SizedBox(width: 12),
                                  itemBuilder: (context, index) {
                                    final route = routeAlternatives[index];
                                    final isSelected =
                                        route['path'] == selectedRoute;

                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedRoute = route['path'];
                                        });
                                      },
                                      child: Container(
                                        width: 120,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color:
                                              isSelected
                                                  ? route['color'].withOpacity(
                                                    0.1,
                                                  )
                                                  : Colors.grey[50],
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color:
                                                isSelected
                                                    ? route['color']
                                                    : Colors.grey[300]!,
                                            width: isSelected ? 2 : 1,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Route ${index + 1}",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    isSelected
                                                        ? route['color']
                                                        : Colors.black87,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "${route['eta']} min",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            Text(
                                              "${route['distance']} km",
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildTravelModeButton(
                                  "car",
                                  Icons.directions_car,
                                  "Car",
                                ),
                                _buildTravelModeButton(
                                  "motorcycle",
                                  Icons.motorcycle,
                                  "Bike",
                                ),
                                _buildTravelModeButton(
                                  "pedestrian",
                                  Icons.directions_walk,
                                  "Walk",
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
    );
  }

  Widget _buildSuggestionsList(
    BuildContext context,
    Function(String) onSelected,
    Iterable<String> options,
  ) {
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width - 32,
          constraints: const BoxConstraints(maxHeight: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: options.length,
            separatorBuilder:
                (context, index) => Divider(height: 1, color: Colors.grey[200]),
            itemBuilder: (context, index) {
              final option = options.elementAt(index);
              return ListTile(
                dense: true,
                title: Text(
                  option,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                onTap: () => onSelected(option),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTravelModeButton(String mode, IconData icon, String label) {
    final isSelected = selectedTravelMode == mode;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTravelMode = mode;
        });
        _searchDestination();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey[100],
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    _searchSourceController.dispose();
    _SourceSetting.dispose();
    super.dispose();
  }

  void _fitRouteInView(List<LatLng> path) {
    if (path.isEmpty) return;
    final bounds = LatLngBounds.fromPoints(path);
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
    );
  }
}
