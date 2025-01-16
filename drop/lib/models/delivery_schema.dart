import 'package:drop/app_services/maps_api_services.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

class Delivery {
  late final String id;
  String? productName;
  String? ownerName;
  String? phone;
  String agentId = "";
  String status = "IN_STOCK";
  String? notes;
  final String locationName;
  late final LatLng locationLatLng;
  int deliveryAttempts = 0;

  Delivery({required this.locationName, this.notes}) {
    try {
      id = const Uuid().v4();
      // GEOCODING
      locationLatLng = Geocoding.getLatLng(locationName);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void incrementDeliveryAttempts() {
    deliveryAttempts++;
  }
}
