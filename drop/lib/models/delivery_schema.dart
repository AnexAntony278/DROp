import 'package:drop/services/maps_api_services.dart';
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

  Delivery._internal({
    required this.id,
    required this.locationName,
    required this.locationLatLng,
    this.note,
  });

  static Future<Delivery> create({
    required String locationName,
    String? note,
  }) async {
    final locationLatLng = await Geocoding.getLatLng(locationName);
    return Delivery._internal(
      id: const Uuid().v4(),
      locationName: locationName,
      locationLatLng: locationLatLng,
      note: note,
    );
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
    locationLatLng =
        LatLng(data['locationLatLng']['lat'], data['locationLatLng']['lng']);
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

  //DEBUGGING DATA

  static List<Delivery> sampleData = List.from([
    {
      "id": "4",
      "locationName": "Wayanad Forest RSRV",
      "locationLatLng": {"lat": 11.6854, "lng": 76.1320},
      "note": "Delivery only allowed during daytime.",
      "ownerName": "Anandu Dinacharyan H . D",
      "status": "FAILED",
      "deliveryAttempts": 3,
    },
    {
      "id": "1",
      "locationName": "Thrissur Town",
      "locationLatLng": {"lat": 10.5276, "lng": 76.2144},
      "note": "Main delivery hub",
      "status": "IN_STOCK",
      "ownerName": "Anandu Dinacharyan H . D",
      "deliveryAttempts": 0,
    },
    {
      "id": "7",
      "locationName": "Munnar Hill Station - Extra long note for testing",
      "locationLatLng": {"lat": 10.0889, "lng": 77.0595},
      "note": "High-altitude delivery. Confirm weather conditions.",
      "ownerName": "Anandu Dinacharyan H . D",
      "status": "DELIVERED",
      "deliveryAttempts": 1,
    },
    {
      "id": "8",
      "locationName": "Silent Valley National Park",
      "locationLatLng": {"lat": 11.0763, "lng": 76.6084},
      "note": "Remote area. Requires additional charges.",
      "ownerName": "Anandu Dinacharyan H . D",
      "status": "IN_STOCK",
      "deliveryAttempts": 0,
    },
    {
      "id": "2",
      "locationName": "Mala, Thrissur District",
      "locationLatLng": {"lat": 10.2875, "lng": 76.3034},
      "note": "Deliver before 6 PM. Contact: +91 9876543210",
      "status": "OUT_FOR_DELIVERY",
      "deliveryAttempts": 1,
    },
    {
      "id": "3",
      "locationName":
          "Kochi - Long destination name example with special notes",
      "locationLatLng": {"lat": 9.9312, "lng": 76.2673},
      "note": "Fragile items. Handle with care!",
      "status": "DELIVERED",
      "deliveryAttempts": 2,
    },
    {
      "id": "5",
      "locationName": "Alappuzha Beach - End of the street",
      "locationLatLng": {"lat": 9.4981, "lng": 76.3388},
      "note": "Tourist-heavy area, call if not reachable.",
      "status": "IN_STOCK",
      "deliveryAttempts": 0,
    },
    {
      "id": "6",
      "locationName": "Kollam Port",
      "locationLatLng": {"lat": 8.8932, "lng": 76.6141},
      "note": "",
      "status": "OUT_FOR_DELIVERY",
      "deliveryAttempts": 0,
    },
  ].map(
    (e) => Delivery.fromMap(e),
  ));
}
