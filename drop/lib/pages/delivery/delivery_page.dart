import 'package:drop/app_services/maps_api_services.dart';
import 'package:drop/models/delivery_schema.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DeliveryPage extends StatefulWidget {
  const DeliveryPage({super.key});

  @override
  State<DeliveryPage> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
  List<Delivery> destinations = [];
  List<LatLng> routePolyLinePoints = [];

  @override
  void didChangeDependencies() {
    drawRoute().then(
      (value) => debugPrint("routePolyLinePoints.toString()"),
    );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    ///TODO: clean
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
                polylines: {
                  Polyline(
                    polylineId: const PolylineId('value'),
                    points: routePolyLinePoints,
                    color: Colors.lightBlue,
                    width: 5,
                  )
                },
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
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    size: 25,
                                    Icons.location_on,
                                    color: Colors.red,
                                  ),
                                  Text(destinations[index].locationName),
                                ],
                              ),
                              if (destinations[index].note != null &&
                                  destinations[index].note != '')
                                Row(
                                  children: [
                                    const Icon(
                                      size: 25,
                                      Icons.note_rounded,
                                      color: Colors.blue,
                                    ),
                                    Text(destinations[index].note ?? ""),
                                  ],
                                ),
                            ],
                          ),
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

  Future<void> drawRoute() async {
    for (var i = 0; i < destinations.length - 1; i++) {
      await PolyLinePointList.getPolyLineRoute(
              start: destinations[i].locationLatLng,
              end: destinations[i + 1].locationLatLng)
          .then(
        (value) {
          routePolyLinePoints.addAll(value);
        },
      );
    }
    routePolyLinePoints.removeLast();
    setState(() {});
  }
}
