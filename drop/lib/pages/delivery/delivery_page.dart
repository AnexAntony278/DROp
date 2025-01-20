import 'package:drop/models/delivery_schema.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DeliveryPage extends StatelessWidget {
  const DeliveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<Delivery> destinations = [];
    try {
      destinations =
          ModalRoute.of(context)!.settings.arguments as List<Delivery>;
    } catch (e) {
      destinations = Delivery.sampleData;
    }
    final PageController pageController = PageController();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        final bool shouldPop = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: const Text('Are you sure you want to exit?'),
                    actions: <Widget>[
                      ElevatedButton(
                        child: const Text('No'),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      ),
                      ElevatedButton(
                        child: const Text('Yes, exit'),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      ),
                    ],
                  );
                }) ??
            false;
        if (context.mounted && shouldPop) {
          Navigator.pop(context);
          Navigator.pushNamed(context, 'homepage');
        }
      },
      child: Scaffold(
        appBar: AppBar(
            title: const Text('Delivery Page'),
            foregroundColor: Colors.white,
            backgroundColor: Theme.of(context).primaryColor),
        body: Center(
          child: Stack(
            children: [
              GoogleMap(
                polylines: {},
                markers: Set.from(destinations.map(
                  (e) => Marker(
                      icon: BitmapDescriptor.defaultMarkerWithHue(12),
                      markerId: MarkerId(e.locationName),
                      position: e.locationLatLng),
                )),
                initialCameraPosition: CameraPosition(
                    target: destinations[0].locationLatLng, zoom: 10),
                mapType: MapType.normal,
                minMaxZoomPreference: const MinMaxZoomPreference(2, 20),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 3.1,
                    child: PageView.builder(
                      itemCount: destinations.length,
                      controller: pageController,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 10),
                        child: Card(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                              child:
                                  Text(destinations[index].toMap().toString())),
                        )),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
