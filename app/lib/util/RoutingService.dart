import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hacknova/util/TOMTOM_API.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class RoutingService {
  // 📍 Get User's Current GPS Location
  static Future<LatLng?> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null; // Permission denied
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print("Error getting location: $e");
      return null;
    }
  }

  static Future<String?> getAddressFromCoordinates(LatLng coordinates) async {
    final String url =
        "https://api.tomtom.com/search/2/reverseGeocode/${coordinates.latitude},${coordinates.longitude}.json?key=$TOMTOM_API_KEY";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['addresses'].isNotEmpty) {
        var address = data['addresses'][0]['address'];
        return address['freeformAddress']; // Or any other field you prefer.
      }
    }
    print(
      "Failed to fetch address for coordinates: ${coordinates.latitude}, ${coordinates.longitude}",
    );
    return null;
  }

  // 🔎 Convert Address to LatLng (Geocoding API)
  // Get Coordinates from Address (Already Present)
  static Future<LatLng?> getCoordinatesFromAddress(String address) async {
    final String url =
        "https://api.tomtom.com/search/2/geocode/$address.json?key=$TOMTOM_API_KEY";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['results'].isNotEmpty) {
        var position = data['results'][0]['position'];
        return LatLng(position['lat'], position['lon']);
      }
    }
    print("Failed to fetch coordinates for: $address");
    return null;
  }

  // Get District from LatLng using TomTom Reverse Geocoding API
  static Future<String?> getDistrictFromCoordinates(LatLng coordinates) async {
    final String url =
        "https://api.tomtom.com/search/2/reverseGeocode/${coordinates.latitude},${coordinates.longitude}.json?key=$TOMTOM_API_KEY";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['addresses'].isNotEmpty) {
          var address = data['addresses'][0]['address'];

          // Extract smaller location details (sub-municipality, neighborhood, localName)
          return address['municipalitySubdivision'] ?? // Subdivision within the district
              address['municipality']; // If none are available, return district
        }
      }
    } catch (e) {
      print("Error fetching local area: $e");
    }
    return null;
  }

  // 🛣️ Fetch Route with Traffic Data

  static Future<List<Map<String, dynamic>>> getRoutes(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
    String travelMode,
  ) async {
    final String url =
        "https://api.tomtom.com/routing/1/calculateRoute/$startLat,$startLng:$endLat,$endLng/json"
        "?routeType=fastest&maxAlternatives=2&traffic=true&travelMode=$travelMode&key=$TOMTOM_API_KEY";

    print("Fetching routes for mode: $travelMode - $url"); // Debugging log

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List<Map<String, dynamic>> routes = [];

        if (data['routes'] != null && data['routes'].isNotEmpty) {
          for (var route in data['routes']) {
            List<LatLng> path = [];
            for (var point in route['legs'][0]['points']) {
              path.add(LatLng(point['latitude'], point['longitude']));
            }

            int duration =
                route['summary']['travelTimeInSeconds']; // ETA in seconds

            // Assign colors based on ETA
            Color routeColor;
            if (duration < 600) {
              routeColor = Colors.green; // <10 min
            } else if (duration < 1800) {
              routeColor = Colors.yellow; // 10-30 min
            } else {
              routeColor = Colors.red; // >30 min
            }

            routes.add({
              "time": duration,
              "path": path,
              "eta": duration ~/ 60, // Convert seconds to minutes
              "color": routeColor,
            });
          }

          print("Fetched ${routes.length} routes successfully!");
        } else {
          print("No routes found");
        }
        return routes;
      } else {
        print("Error ${response.statusCode}: ${response.body}");
        throw Exception("Failed to fetch routes");
      }
    } catch (e) {
      print("Exception: $e");
      throw Exception("Failed to fetch routes");
    }
  }

  static Future<List<String>> getSearchSuggestions(String query) async {
    final String url =
        "https://api.tomtom.com/search/2/search/$query.json?key=$TOMTOM_API_KEY&limit=5";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      List<String> suggestions = [];

      if (data['results'] != null) {
        for (var result in data['results']) {
          suggestions.add(result['address']['freeformAddress']);
        }
      }
      return suggestions;
    } else {
      print("Error fetching search suggestions: ${response.body}");
      return [];
    }
  }
}
