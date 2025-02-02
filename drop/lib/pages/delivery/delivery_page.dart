import 'package:drop/services/maps_api_services.dart';
import 'package:drop/constants/constants.dart';
import 'package:drop/models/delivery_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class DeliveryPage extends StatefulWidget {
  const DeliveryPage({super.key});

  @override
  State<DeliveryPage> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
  List<Delivery> destinations = [];
  List<Polyline> polyLines = [];
  LatLng userLocation = const LatLng(0, 0);

  final PageController pageController = PageController();
  late GoogleMapController mapController;
  var cardExpanded = false;

  @override
  void didChangeDependencies() {
    try {
      //TODO : CLEAN
      destinations =
          ModalRoute.of(context)!.settings.arguments as List<Delivery>;
    } catch (e) {
      destinations = Delivery.sampleData;
    }
    _getUserLocation();
    _getRoute();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
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
                  polylines: Set<Polyline>.of(polyLines),
                  markers: Set.from(destinations.map(
                    (e) => Marker(
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueBlue),
                        markerId: MarkerId(e.locationName),
                        position: e.locationLatLng),
                  )),
                  initialCameraPosition: CameraPosition(
                      target: destinations[0].locationLatLng, zoom: 10),
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                  trafficEnabled: false,
                  indoorViewEnabled: false,
                  mapToolbarEnabled: false,
                  minMaxZoomPreference: const MinMaxZoomPreference(2, 20),
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                  }),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: (cardExpanded)
                        ? const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 50,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                  color: Colors.black,
                                  blurRadius: 5,
                                  offset: Offset(0, 0))
                            ],
                          )
                        : const Icon(
                            Icons.keyboard_arrow_up_rounded,
                            size: 50,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                  color: Colors.black,
                                  blurRadius: 5,
                                  offset: Offset(0, 0))
                            ],
                          ),
                    onPressed: () {
                      setState(() {
                        cardExpanded = !cardExpanded;
                      });
                    },
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: (cardExpanded)
                        ? MediaQuery.of(context).size.height / 3
                        : MediaQuery.of(context).size.height / 4,
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
                                  Expanded(
                                    child: Text(
                                      destinations[index].locationName,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          fontStyle: FontStyle.normal),
                                    ),
                                  ),
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

  Future<void> _getRoute() async {
    for (var i = 0; i < destinations.length - 1; i++) {
      await PolyLinePointList.getPolyLineRoute(
              start: destinations[i].locationLatLng,
              end: destinations[i + 1].locationLatLng)
          .then(
        (value) {
          polyLines.add(Polyline(
              polylineId: PolylineId(destinations[i].locationName),
              points: value,
              color: Colors.blue,
              width: 3));
        },
      );
    }
    setState(() {});
  }

  Future<void> _getUserLocation() async {
    final locationservices = LocationServices();
    final hasPermission = await locationservices.checkLocationPermission();
    if (!hasPermission) return;
    final LocationData locationData =
        await locationservices.location.getLocation();
    setState(() {
      userLocation = LatLng(locationData.latitude!, locationData.longitude!);
      destinations.insert(
          0,
          Delivery.fromMap({
            'locationLatLng': userLocation,
          }));
    });

    mapController.animateCamera(CameraUpdate.newLatLng(userLocation!));
  }
}
