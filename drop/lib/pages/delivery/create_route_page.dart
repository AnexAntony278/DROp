import 'package:drop/models/delivery_schema.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CreateRoutePage extends StatelessWidget {
  const CreateRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    // final destinations =
    //     ModalRoute.of(context)!.settings.arguments as List<Delivery>;
    final List<Delivery> destinations = Delivery.sampleData;
    return Scaffold(
      appBar: AppBar(
          title: const Text('Delivery Page'),
          backgroundColor: Theme.of(context).primaryColor),
      body: const Center(
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(target: LatLng(0, 0)),
              mapType: MapType.satellite,
            )
          ],
        ),
      ),
    );
  }
}
