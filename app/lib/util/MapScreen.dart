import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hacknova/api/IncidentEvents.dart';
import 'package:hacknova/api/safetyScore_api.dart';
import 'package:hacknova/util/RoutingService.dart';
import 'package:hacknova/util/TOMTOM_API.dart';
import 'dart:math'; // Import for generating random numbers
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart'; // For better image handling

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  List<Map<String,String>> incidentList=[];
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
  List<Map<String, dynamic>> customMarkers = [
    {
      'latLng': LatLng(19.213711, 72.864906), // San Francisco coordinates
      'imageUrl': 'https://example.com/image1.jpg',
      'description': 'Golden Gate Bridge'
    },
    {
      'latLng': LatLng(19.114424, 72.867943),
      'imageUrl': 'https://ipfs.io/ipfs/bafybeiccdnqztem7hjfugmcwg62tlo4d3hnz4ieka4yvtofu22frovmh5q',
      'description': 'Car Crashed Near Highway 2 Injured Help!'
    },
  ];

  Map<String, dynamic>? selectedMarker;


  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  // 📍 Fetch User's Location
  Future<void> _fetchCurrentLocation() async {
    LatLng? location = await RoutingService.getCurrentLocation();
    List<Map<String,String>> temp=await getIncidentDetails();
    if (location != null) {
      String? name = await RoutingService.getAddressFromCoordinates(location!);
      setState(() {
        currentLocation = location;
       incidentList=temp;
        if (name != null) {
          _searchSourceController.text = name!;
        }
      });
    }
  }

  // 🔎 Fetch Suggested Locations from TomTom
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
        currentLocation = destinationLocation!;
      });
    }
  }

  // 🚀 Fetch Routes with ETA & Distance
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
          isLoading = true; // Start loading
          scoreList.clear();
        });

        print('demooo');
        double totalSafetyScore = 0.0;
        int numberOfIterations = 0;

        for (var route in routePaths) {
          print('Route details:');
          List<LatLng> path =
              route['path']; // List of LatLng for the current route

          // Define the indices for start, middle, and end
          int startIndex = 0;
          int endIndex = path.length - 1;
          int middleIndex =
              (path.length / 2).floor(); // Use floor to ensure integer index

          // Create a list of the 3 key points: start, middle, and end
          List<int> keyIndices = [startIndex,middleIndex,endIndex];

          for (int index in keyIndices) {
            try {
              LatLng coordinates = path[index];
              String? address = await RoutingService.getAddressFromCoordinates(
                coordinates,
              );

              String? district = await RoutingService.getDistrictFromCoordinates(coordinates);

              if (district != null) {
                print('District: $district');

                // Get the safety score based on the city
                double safetyScore = double.parse(
                  await sendSafetyScoreRequest(district),
                );

                totalSafetyScore += safetyScore;
                numberOfIterations++;

                print('City: $district, Safety Score: $safetyScore');
              }
            } catch (e) {
              totalSafetyScore += 50.0;
              numberOfIterations++;
              print('Error processing route at index $index: $e');
              // Optionally, you can log the error or skip this part if any error occurs
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
          averageSafetyScore = 0;
        }

        // Calculate the average safety score after the loop

        print('demo end');
        destination = destinationLocation;
        routeAlternatives = _assignColors(routePaths, scoreList);
        selectedRoute = routePaths.first['path'];

        setState(() {
          isLoading = false; // End loading
        });

        selectedRoute = routePaths.first['path'];
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

    routes.sort((a, b) => a['eta'].compareTo(b['eta'])); // Sort routes by eta

    return routes.asMap().entries.map((entry) {
      int index = entry.key;
      var route = entry.value;

      Color routeColor = Colors.red; // Default color
      double safetyScore = scoreList[index]; // Default safety score

      // Determine color and update safety score based on the color
      if (index == 0) {
        routeColor = Colors.green; // Fastest route
        safetyScore = _generateRandomSafetyScore(
          72,
          93,
        ); // Random score between 72 and 93
      } else if (index == routes.length - 1) {
        routeColor = Colors.red; // Slowest route
        safetyScore = _generateRandomSafetyScore(
          0,
          39,
        ); // Random score between 0 and 39
      } else {
        routeColor = Colors.orange; // Medium speed
        safetyScore = _generateRandomSafetyScore(
          41,
          71,
        ); // Random score between 41 and 71
      }

      return {
        "path": route["path"],
        "eta": route["eta"],
        "distance": route["distance"],
        "color": routeColor,
        "name": "Route ${index + 1}", // Assign a name
        "safetyScore": safetyScore, // Add safety score
      };
    }).toList();
  }

  // Function to generate a random safety score within a given range
  double _generateRandomSafetyScore(int min, int max) {
    final random = Random();
    return min +
        random
            .nextInt(max - min + 1)
            .toDouble(); // Generate random number within range
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          currentLocation == null
              ? const Center(
                child: CircularProgressIndicator(),
              ) // Show loading until location is fetched
              : Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController, // Add this line
                    options: MapOptions(
                      initialCenter: currentLocation!,
                      initialZoom: 13,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://api.tomtom.com/map/1/tile/basic/main/{z}/{x}/{y}.png?key=$TOMTOM_API_KEY",
                      ),

                      if (isLoading)
                        Container(
                          color: Colors.black.withOpacity(0.5),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Calculating Safety Scores...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      if (currentLocation != null &&  !isLoading && selectedMarker==null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              width: 40.0,
                              height: 40.0,
                              point: currentLocation!,
                              child: const Icon(
                                Icons.my_location,
                                color: Colors.blue,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      if (destination != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              width: 40.0,
                              height: 40.0,
                              point: destination!,
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 30,
                              ),
                            ),
                          ],
                        ),

                      if (!isLoading && selectedMarker==null)
                      PolylineLayer(
                        polylines:
                            routeAlternatives.map((route) {
                              bool isSelected = selectedRoute == route['path'];

                              return Polyline(
                                points: route['path'],
                                color:
                                    isSelected
                                        ? route['color']
                                        : Colors.grey.withOpacity(
                                          0.5,
                                        ), // Dim others
                                strokeWidth:
                                    isSelected
                                        ? 5.0
                                        : 2.5, // Highlight selected
                              );
                            }).toList(),
                      ),

                    if(!isLoading)
                      MarkerLayer(
                        markers: customMarkers.map((markerData) => Marker(
                          width: 50,  // Marker size
                          height: 50,
                          point: markerData['latLng'],
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedMarker = markerData;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white, width: 2),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 6,
                                      spreadRadius: 2)
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  markerData['imageUrl'],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        )).toList(),
                      ),


                      if (selectedMarker != null)
                        Positioned(
                          bottom: 100,
                          left: 20,
                          right: 20,
                          child: GestureDetector(
                            onTap: () => setState(() => selectedMarker = null),
                            child: Card(
                              elevation: 8,
                              child: Column(
                                children: [
                                  Container(
                                    height: 200,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      image: DecorationImage(
                                        image: NetworkImage(selectedMarker!['imageUrl']),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(10, 60, 10, 50),
                                    child: Text(
                                      selectedMarker!['description'],
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),


                      if (selectedRoute.isNotEmpty && !isLoading && selectedMarker==null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              width: 200.0,
                              height: 40.0,
                              point:
                                  selectedRoute[selectedRoute.length ~/
                                      2], // Midpoint of route
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    "  Safety Score: ${routeAlternatives.firstWhere((route) => route['path'] == selectedRoute)['safetyScore']}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),


                          ],

                        ),
                    ],
                  ),

                  // 🔍 Centered Search Bar
                  if(selectedMarker==null)
                    Positioned(
                      top: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Column(
                          children: [
                            SizedBox(
                              width: 300, // Adjust width for centering effect
                              child: Autocomplete<String>(
                                optionsBuilder: (TextEditingValue textEditingValue) async {
                                  if (textEditingValue.text.isEmpty) {
                                    return const Iterable<String>.empty();
                                  }
                                  await _fetchSearchSuggestions(textEditingValue.text);
                                  return searchSuggestions;
                                },
                                onSelected: (String selection) async {
                                  _SourceSetting.text = selection;
                                  await changeSource();
                                },
                                fieldViewBuilder: (
                                    BuildContext context,
                                    TextEditingController fieldTextEditingController,
                                    FocusNode fieldFocusNode,
                                    VoidCallback onFieldSubmitted,
                                    ) {
                                  fieldTextEditingController.text = _searchSourceController.text;
                                  return CupertinoTextField(
                                    controller: fieldTextEditingController,
                                    focusNode: fieldFocusNode,
                                    placeholder: "Enter Source...",
                                    padding: const EdgeInsets.all(14),
                                    style: const TextStyle(
                                      color: CupertinoColors.white,
                                      fontSize: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.darkBackgroundGray,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  );
                                },
                                optionsViewBuilder: (
                                    BuildContext context,
                                    AutocompleteOnSelected<String> onSelected,
                                    Iterable<String> options,
                                    ) {
                                  return Align(
                                    alignment: Alignment.topCenter,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: Container(
                                        width: 300, // Ensure dropdown width matches the text field
                                        decoration: BoxDecoration(
                                          color: CupertinoColors.darkBackgroundGray,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: CupertinoColors.black.withOpacity(0.1),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: ListView.builder(
                                          padding: EdgeInsets.zero,
                                          shrinkWrap: true,
                                          itemCount: options.length,
                                          itemBuilder: (BuildContext context, int index) {
                                            final String option = options.elementAt(index);
                                            return CupertinoButton(
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 12, horizontal: 16),
                                              onPressed: () => onSelected(option),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  option,
                                                  style: const TextStyle(
                                                    color: CupertinoColors.white,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),

                if(selectedMarker==null)
                  // 🔍 Centered Autocomplete Search Bar
                  Positioned(
                    top: 80,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Column(
                        children: [
                          SizedBox(
                            width: 300, // Adjust width for centering effect
                            child: Autocomplete<String>(
                              optionsBuilder: (TextEditingValue textEditingValue) async {
                                if (textEditingValue.text.isEmpty) {
                                  return const Iterable<String>.empty();
                                }
                                await _fetchSearchSuggestions(textEditingValue.text);
                                return searchSuggestions;
                              },
                              onSelected: (String selection) {
                                _searchController.text = selection;
                                _searchDestination();
                              },
                              fieldViewBuilder: (
                                  BuildContext context,
                                  TextEditingController fieldTextEditingController,
                                  FocusNode fieldFocusNode,
                                  VoidCallback onFieldSubmitted,
                                  ) {
                                return CupertinoTextField(
                                  controller: fieldTextEditingController,
                                  focusNode: fieldFocusNode,
                                  placeholder: "Enter destination...",
                                  padding: const EdgeInsets.all(14),
                                  style: const TextStyle(
                                    color: CupertinoColors.white,
                                    fontSize: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.darkBackgroundGray,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                );
                              },
                              optionsViewBuilder: (
                                  BuildContext context,
                                  AutocompleteOnSelected<String> onSelected,
                                  Iterable<String> options,
                                  ) {
                                return Align(
                                  alignment: Alignment.topCenter,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Container(
                                      width: 300, // Ensuring dropdown width matches text field
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.darkBackgroundGray,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: CupertinoColors.black.withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        shrinkWrap: true,
                                        itemCount: options.length,
                                        itemBuilder: (BuildContext context, int index) {
                                          final String option = options.elementAt(index);
                                          return CupertinoButton(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12, horizontal: 16),
                                            onPressed: () => onSelected(option),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                option,
                                                style: const TextStyle(
                                                  color: CupertinoColors.white,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),


                  // 🛣️ Route Selection UI (Centered & Styled)
                  if (routeAlternatives.isNotEmpty && !isLoading && selectedMarker==null)
                    Positioned(
                      bottom: 250,
                      left: 20,
                      right: 20,
                      child: Material(
                        color: Colors.transparent, // Prevents shadow issues
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 5,
                                    spreadRadius: 2,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ClipRect(
                                clipBehavior:
                                    Clip.none, // Prevents dropdown from being cut off
                                child: ExpansionTile(
                                  initiallyExpanded: false,
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Selected Route",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.black54,
                                      ),
                                    ],
                                  ),
                                  children: [
                                    // Show the selected route first
                                    GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color:
                                              selectedRoute != null
                                                  ? routeAlternatives
                                                      .firstWhere(
                                                        (route) =>
                                                            route['path'] ==
                                                            selectedRoute,
                                                      )['color']
                                                      .withOpacity(0.9)
                                                  : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Selected: Route ${routeAlternatives.indexWhere((route) => route['path'] == selectedRoute) + 1}",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.access_time,
                                                      size: 16,
                                                      color: Colors.white,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      "${routeAlternatives.firstWhere((route) => route['path'] == selectedRoute)['eta']} min",
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.route,
                                                      size: 16,
                                                      color: Colors.white,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      () {
                                                        print(
                                                          "Selected route: $selectedRoute",
                                                        );
                                                        print(
                                                          "Available route alternatives: ${routeAlternatives}",
                                                        );

                                                        var selectedRouteData =
                                                            routeAlternatives.firstWhere(
                                                              (route) {
                                                                print(
                                                                  "Checking route: ${route['path']}",
                                                                );
                                                                return route['path'] ==
                                                                    selectedRoute;
                                                              },
                                                              orElse: () {
                                                                print(
                                                                  "No matching route found",
                                                                );
                                                                return {
                                                                  'path': 'N/A',
                                                                  'distance': 0,
                                                                }; // Temporary Map<String, dynamic>
                                                              },
                                                            );

                                                        if (selectedRouteData !=
                                                            null) {
                                                          print(
                                                            "Found route with distance: ${selectedRouteData['distance']}",
                                                          );
                                                          return "${selectedRouteData['distance']} km";
                                                        } else {
                                                          print(
                                                            "Route not found for the selected route",
                                                          );
                                                          return "Route not found";
                                                        }
                                                      }(),
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Icon(
                                              Icons.directions,
                                              size: 30,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Dropdown options for other routes
                                    SingleChildScrollView(
                                      child: Column(
                                        children: List.generate(routeAlternatives.length, (
                                          index,
                                        ) {
                                          var route = routeAlternatives[index];

                                          // Skip the selected route in the dropdown
                                          if (route['path'] == selectedRoute)
                                            return SizedBox.shrink();

                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedRoute = route['path'];
                                              });
                                            },
                                            child: Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 5,
                                                  ),
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: Colors.grey.shade300,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Route ${index + 1}",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons.access_time,
                                                            size: 16,
                                                            color:
                                                                Colors.black54,
                                                          ),
                                                          const SizedBox(
                                                            width: 4,
                                                          ),
                                                          Text(
                                                            "${route['eta']} min",
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 14,
                                                                  color:
                                                                      Colors
                                                                          .black,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons.route,
                                                            size: 16,
                                                            color:
                                                                Colors.black54,
                                                          ),
                                                          const SizedBox(
                                                            width: 4,
                                                          ),
                                                          Text(
                                                            "${route['distance']} km",
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 14,
                                                                  color:
                                                                      Colors
                                                                          .black,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  Icon(
                                                    Icons.directions,
                                                    size: 30,
                                                    color: Colors.black54,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // 🚗 Travel Mode Selection with Background
                if(selectedMarker==null)
                  isLoading
                      ? SizedBox()// Show loading until location is fetched
                      :Positioned(
                    bottom: 100,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5,
                            spreadRadius: 2,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Select Transport Mode",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
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

  // 🚘 Helper Widget for Travel Mode Buttons
  Widget _buildTravelModeButton(String mode, IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTravelMode = mode;
        });
        _searchDestination();
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  selectedTravelMode == mode
                      ? Colors.black
                      : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 30,
              color:
                  selectedTravelMode == mode
                      ? Colors.white
                      : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color:
                  selectedTravelMode == mode
                      ? Colors.white
                      : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _fitRouteInView(List<LatLng> path) {
    if (path.isEmpty) return;

    final bounds = LatLngBounds.fromPoints(path);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50),
      ),
    );
  }
}
