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
  String? note;
  final String locationName;
  late final LatLng locationLatLng;
  int deliveryAttempts = 0;

  Delivery({required this.locationName, this.note}) {
    try {
      id = const Uuid().v4();
      locationLatLng = Geocoding.getLatLng(locationName);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
  Delivery.fromMap(Map<String, dynamic> data)
      : id = data['id'],
        productName = data['productName'],
        ownerName = data['ownerName'],
        phone = data['phone'],
        agentId = data['agentId'] ?? "",
        status = data['status'] ?? "IN_STOCK",
        note = data['note'],
        locationName = data['locationName'],
        deliveryAttempts = data['deliveryAttempts'] ?? 0 {
    if (data['locationLatLng'] is Map<String, dynamic>) {
      locationLatLng =
          LatLng(data['locationLatLng']['lat'], data['locationLatLng']['lng']);
    } else {
      locationLatLng = const LatLng(0.0, 0.0);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productName': productName,
      'ownerName': ownerName,
      'phone': phone,
      'agentId': agentId,
      'status': status,
      'note': note,
      'locationName': locationName,
      'locationLatLng': {
        'lat': locationLatLng.latitude,
        'lng': locationLatLng.longitude,
      },
      'deliveryAttempts': deliveryAttempts,
    };
  }

  void incrementDeliveryAttempts() {
    deliveryAttempts++;
  }
}
