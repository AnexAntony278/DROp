import 'package:drop/models/delivery_schema.dart';
import 'package:drop/models/user_schema.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

class DeliveryRoute {
  String id;
  List<Delivery> deliveries;
  LatLng startLocation;
  DateTime createdAt;
  final String? agentId;
  late List<List<int>> distanceMatrix;
  String? status = "INCOMPLETE";

  DeliveryRoute._internal({
    required this.deliveries,
    required this.startLocation,
    required this.agentId,
  })  : createdAt = DateTime.now(),
        id = const Uuid().v4();

  static Future<DeliveryRoute> create({
    required List<Delivery> deliveries,
    required LatLng startLocation,
  }) async {
    final agentId = User.getCurrentUserId();
    return DeliveryRoute._internal(
        deliveries: deliveries, startLocation: startLocation, agentId: agentId);
  }

  @override
  String toString() {
    return toMap().toString();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'deliveries': deliveries.map((d) => d.toMap()).toList(),
      'startLocation': {
        'lat': startLocation.latitude,
        'lng': startLocation.longitude
      },
      'createdAt': createdAt.toIso8601String(),
      'agentId': agentId,
      'distanceMatrix': distanceMatrix,
      'status': status
    };
  }

  static DeliveryRoute fromMap(Map<String, dynamic> data) {
    DeliveryRoute deliveryRoute = DeliveryRoute._internal(
        deliveries: List.from((data['deliveries'] as dynamic)
            .map((delivery) => Delivery.fromMap(delivery))),
        startLocation:
            LatLng(data['startLocation']['lat'], data['startLocation']['lng']),
        agentId: data['agentId'])
      ..id = data['id']
      ..createdAt = DateTime.parse(data['createdAt'])
      ..distanceMatrix = (data['distanceMatrix'] as List)
          .map(
            (row) => (row as List)
                .map(
                  (e) => (e as int),
                )
                .toList(),
          )
          .toList();
    return deliveryRoute;
  }
}
