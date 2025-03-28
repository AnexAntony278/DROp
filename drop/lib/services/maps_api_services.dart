import 'dart:convert';
import 'package:drop/constants/constants.dart';
import 'package:drop/models/route_schema.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:flutter/material.dart';

class Geocoding {
  // Geocoding
  static Future<LatLng> getLatLng(String input) async {
    try {
      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?address=$input&key=$MAPS_API_KEY');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        Map locationData = jsonDecode(response.body)['results'][0]['geometry']
            ['location'] as Map<String, dynamic>;
        return LatLng(locationData['lat'], locationData['lng']);
      } else {
        throw Exception("Failed to fetch location data");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return const LatLng(0, 0);
  }
}

class MapsAutocomplete {
  //GET PREDICTIONS
  static Future<List> getPredictions(String? input) async {
    var predications = [];
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input="$input"&key=$MAPS_API_KEY');
    await http.get(url).then(
      (response) {
        if (response.statusCode == 200) {
          predications = (jsonDecode(response.body)['predictions']);
        }
      },
    );
    return predications;
  }
}

class PolyLinePointList {
  static Future<List<LatLng>> getPolyLineRoute(
      {required LatLng start, required LatLng end}) async {
    final List<LatLng> pointList = [];
    PolylinePoints polyLinePoints = PolylinePoints();
    PolylineResult result = await polyLinePoints.getRouteBetweenCoordinates(
        googleApiKey: MAPS_API_KEY,
        request: PolylineRequest(
            origin: PointLatLng(start.latitude, start.longitude),
            destination: PointLatLng(end.latitude, end.longitude),
            mode: TravelMode.driving,
            optimizeWaypoints: true));
    if (result.points.isNotEmpty) {
      for (PointLatLng point in result.points) {
        pointList.add(LatLng(point.latitude, point.longitude));
      }
    }
    return pointList;
  }
}

class LocationServices {
  final Location _location = Location();

  Future<LatLng> getCurrentLocation() async {
    PermissionStatus permission = await _location.requestPermission();
    if (permission == PermissionStatus.denied) {
      permission = await _location.requestPermission();
    }
    if (permission == PermissionStatus.granted) {
      LocationData locationData = await _location.getLocation();
      return LatLng(
          locationData.latitude ?? 0.0, locationData.longitude ?? 0.0);
    } else {
      throw Exception('Location Not accessible');
    }
  }
}

class DistanceMatrixServices {
  static const int maxLocationsPerRequest = 10;

  static Future<List<List<int>>> getDistanceMatrix(
      {required DeliveryRoute deliveryRoute}) async {
    List<LatLng> locations = [
      deliveryRoute.startLocation,
      ...deliveryRoute.deliveries.map((e) => e.locationLatLng)
    ];

    int n = locations.length;
    List<List<int>> distanceMatrix = List.generate(n, (_) => List.filled(n, 0));

    List<Future<void>> requests = [];

    for (int i = 0; i < n; i += maxLocationsPerRequest) {
      for (int j = 0; j < n; j += maxLocationsPerRequest) {
        int endI =
            (i + maxLocationsPerRequest > n) ? n : i + maxLocationsPerRequest;
        int endJ =
            (j + maxLocationsPerRequest > n) ? n : j + maxLocationsPerRequest;

        String origins = _formatLocations(locations.sublist(i, endI));
        String destinations = _formatLocations(locations.sublist(j, endJ));

        // Add API request Future to the list
        requests.add(
            _fetchAndUpdateMatrix(origins, destinations, distanceMatrix, i, j));
      }
    }

    // Execute all API requests in parallel
    await Future.wait(requests);

    deliveryRoute.distanceMatrix = distanceMatrix;
    return distanceMatrix;
  }

  static String _formatLocations(List<LatLng> locations) {
    return locations
        .map((loc) => "${loc.latitude},${loc.longitude}")
        .join("%7C");
  }

  static Future<void> _fetchAndUpdateMatrix(String origins, String destinations,
      List<List<int>> matrix, int startRow, int startCol) async {
    try {
      final response = await http.post(Uri.parse(
          "https://maps.googleapis.com/maps/api/distancematrix/json?origins=$origins&destinations=$destinations&key=$MAPS_API_KEY"));
      var data = jsonDecode(response.body) as Map<String, dynamic>;
      _updateDistanceMatrix(data, matrix, startRow, startCol);
    } catch (e) {
      print("Error fetching distance matrix: $e");
    }
  }

  static void _updateDistanceMatrix(Map<String, dynamic> response,
      List<List<int>> matrix, int startRow, int startCol) {
    var rows = response['rows'] as List?;
    if (rows != null) {
      for (int i = 0; i < rows.length; i++) {
        var elements = rows[i]['elements'] as List?;
        if (elements != null) {
          for (int j = 0; j < elements.length; j++) {
            if (elements[j]['status'] == "OK") {
              matrix[startRow + i][startCol + j] =
                  elements[j]['distance']?['value'] as int? ?? 0;
            }
          }
        }
      }
    }
  }
}
