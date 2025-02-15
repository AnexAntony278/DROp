import 'dart:convert';
import 'package:drop/constants/constants.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

class Geocoding {
  // Geocoding
  static Future<LatLng> getLatLng(String input) async {
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
            mode: TravelMode.driving));
    if (result.points.isNotEmpty) {
      for (PointLatLng point in result.points) {
        pointList.add(LatLng(point.latitude, point.longitude));
      }
    }
    return pointList;
  }
}

class LocationServices {
  final Location location = Location();
  Future<bool> checkLocationPermission() async {
    PermissionStatus permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
    }
    return permission == PermissionStatus.granted;
  }
}
