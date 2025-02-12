import 'package:drop/models/delivery_schema.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeliveryRoute {
  final List<Delivery> deliveries;
  final LatLng startLocation;
  final DateTime createdAt;
  final String? agentId;

  DeliveryRoute._internal({
    required this.deliveries,
    required this.startLocation,
    required this.agentId,
  }) : createdAt = DateTime.now();

  static Future<DeliveryRoute> create({
    required List<Delivery> deliveries,
    required LatLng startLocation,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final agentId = prefs.getString("user_token");
    return DeliveryRoute._internal(
        deliveries: deliveries, startLocation: startLocation, agentId: agentId);
  }

  @override
  String toString() {
    return 'DeliveryRoute(startLocation: $startLocation, deliveries: ${deliveries.length}, agentId: $agentId, createdAt: $createdAt)';
  }

  //TODO: remove sample data after use

  static Future<DeliveryRoute> getSampleData() async {
    return await DeliveryRoute.create(
      deliveries: Delivery.sampleData,
      startLocation: const LatLng(37.7749, -122.4194),
    );
  }
}
