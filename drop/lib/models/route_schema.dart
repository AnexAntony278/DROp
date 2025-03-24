import 'package:drop/models/delivery_schema.dart';
import 'package:drop/models/user_schema.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

class DeliveryRoute {
  String id;
  List<Delivery> deliveries;
  final LatLng startLocation;
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

  //TODO: remove sample data after use

  static Future<DeliveryRoute> getSampleData() async {
    DeliveryRoute sampleDeliveryRoute = await DeliveryRoute.create(
      deliveries: Delivery.sampleData,
      startLocation: const LatLng(9.8531117, 76.9477609),
    );
    sampleDeliveryRoute.distanceMatrix = [
      [0, 329105, 145157, 53421, 267619, 120133, 107989, 132755, 181666],
      [327960, 0, 181508, 332746, 175968, 217735, 267014, 312498, 398755],
      [147241, 182150, 0, 154057, 130755, 37016, 86295, 131779, 218036],
      [53427, 333499, 151905, 0, 205734, 126881, 124432, 166382, 223619],
      [267999, 176863, 131392, 207034, 0, 157774, 207054, 252537, 338794],
      [120322, 218749, 34801, 127138, 157264, 0, 59376, 104860, 191117],
      [109104, 268601, 84653, 125602, 207116, 59629, 0, 52730, 138987],
      [133728, 314170, 130222, 168077, 252685, 105198, 52754, 0, 86126],
      [182825, 400154, 216206, 236684, 338668, 191182, 138738, 85926, 0]
    ];
    return sampleDeliveryRoute;
  }
}
