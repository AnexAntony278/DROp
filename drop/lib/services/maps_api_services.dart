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
  static Future<List<List<int>>> getDistanceMatrix(
      {required DeliveryRoute deliveryRoute}) async {
    //Calculate distance matrix
    String destinationsRequestString =
        "${deliveryRoute.startLocation.latitude}%2C${deliveryRoute.startLocation.longitude}";

    for (var deliveryLocation in deliveryRoute.deliveries.map(
      (e) => e.locationLatLng,
    )) {
      destinationsRequestString =
          "$destinationsRequestString%7C${deliveryLocation.latitude}%2C${deliveryLocation.longitude}";
    }
    final response = jsonDecode((await http.post(Uri.parse(
            "https://maps.googleapis.com/maps/api/distancematrix/json?destinations=$destinationsRequestString&origins=$destinationsRequestString&key=$MAPS_API_KEY")))
        .body) as Map<String, dynamic>;

    // extract distance matrix from
    final List<List<int>> distanceMatrix = [];
    var rows = response['rows'] as List?;
    if (rows != null) {
      for (var row in rows) {
        var elements = row['elements'] as List?;
        if (elements == null) continue;
        List<int> distances = [];
        for (var element in elements) {
          if (element['status'] == "OK") {
            distances.add(element['distance']?['value'] as int? ?? 0);
          } else {
            throw Exception("Error getting routes: ${element['status']}");
          }
        }
        if (distances.isNotEmpty) {
          distanceMatrix.add(distances);
        }
      }
    } else {
      throw Exception("HTTP Request error");
    }
    deliveryRoute.distanceMatrix = distanceMatrix;
    return distanceMatrix;
  }
}
