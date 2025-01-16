import 'dart:convert';
import 'package:drop/constants/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

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
    var url = Uri.parse(
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
