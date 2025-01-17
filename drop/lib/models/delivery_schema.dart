import 'package:drop/app_services/maps_api_services.dart';
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
    // Normal entry
    {
      'id': '1',
      'productName': 'Laptop',
      'ownerName': 'John Doe',
      'phone': '1234567890',
      'agentId': 'A001',
      'status': 'IN_TRANSIT',
      'note': 'Handle with care',
      'locationName': '1600 Amphitheatre Parkway, Mountain View, CA',
      'locationLatLng': {'lat': 37.4221, 'lng': -122.0841},
      'deliveryAttempts': 1,
    },
    // Edge case: Large text
    {
      'id': '2',
      'productName': 'Mobile Phone',
      'ownerName': 'Jane Doe',
      'phone': '0987654321',
      'agentId': 'A002',
      'status': 'DELIVERED',
      'note': 'This is a very long note that tests how the UI handles lengthy text. ' +
          'It might span multiple lines, and we need to ensure the layout does not break.',
      'locationName':
          'A very long address name that exceeds usual expectations, ' +
              'spanning multiple lines to test text wrapping in the UI',
      'locationLatLng': {'lat': 40.7128, 'lng': -74.0060},
      'deliveryAttempts': 3,
    },
    // Edge case: Missing optional fields
    {
      'id': '3',
      'productName': null,
      'ownerName': null,
      'phone': null,
      'agentId': '',
      'status': 'FAILED',
      'note': null,
      'locationName': '123 Short Street',
      'locationLatLng': {'lat': 51.5074, 'lng': -0.1278},
      'deliveryAttempts': 0,
    },
    // Edge case: Special characters
    {
      'id': '4',
      'productName': 'TV & Sound System',
      'ownerName': 'O\'Connor "The Buyer"',
      'phone': '+1-800-555-0199',
      'agentId': 'A003',
      'status': 'RETURNED',
      'note': r'Fragile! Handle with care @#$%^&*()!',
      'locationName': '456 Special Blvd, @City! #State?',
      'locationLatLng': {'lat': 48.8566, 'lng': 2.3522},
      'deliveryAttempts': 5,
    },
    // Edge case: Extreme lat/long values
    {
      'id': '5',
      'productName': 'Polar Expedition Kit',
      'ownerName': 'Explorer Inc.',
      'phone': '1122334455',
      'agentId': 'A004',
      'status': 'SHIPPED',
      'note': 'Destination is in extreme weather conditions.',
      'locationName': 'North Pole',
      'locationLatLng': {'lat': 90.0, 'lng': 135.0},
      'deliveryAttempts': 2,
    },
  ].map(
    (e) => Delivery.fromMap(e),
  ));
}
