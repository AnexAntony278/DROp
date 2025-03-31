import 'package:drop/services/maps_api_services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

class Delivery {
  late final String id;
  String? productName;
  String? ownerName;
  String? phone;
  String status = "IN_STOCK";
  String? note;
  final String locationName;
  late final LatLng locationLatLng;
  int deliveryAttempts = 0;
  DateTime? timeStamp;

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
        status = data['status'] ?? "IN_STOCK",
        note = data['note'],
        locationName = data['locationName'],
        timeStamp = data['timeStamp'] != null
            ? DateTime.parse(data['timeStamp'])
            : null,
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
      'status': status,
      'note': note,
      'locationName': locationName,
      'locationLatLng': {
        'lat': locationLatLng.latitude,
        'lng': locationLatLng.longitude,
      },
      'timeStamp': timeStamp,
      'deliveryAttempts': deliveryAttempts,
    };
  }
}
