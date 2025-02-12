import 'package:drop/models/route_schema.dart';
import 'package:drop/services/maps_api_services.dart';
import 'package:drop/models/delivery_schema.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DeliveryPage extends StatefulWidget {
  const DeliveryPage({super.key});

  @override
  State<DeliveryPage> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
  late final DeliveryRoute deliveryRoute;

  List<Polyline> polyLines = [];
  final PageController pageController = PageController();
  late GoogleMapController mapController;
  var isCardExpanded = false;

  @override
  void didChangeDependencies() async {
    try {
      //TODO : Clean debug data
      deliveryRoute =
          ModalRoute.of(context)!.settings.arguments as DeliveryRoute;
    } catch (e) {
      deliveryRoute = await DeliveryRoute.getSampleData();
    }
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
                  markers: Set.from(deliveryRoute.deliveries.map(
                    (e) => Marker(
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueBlue),
                        markerId: MarkerId(e.locationName),
                        position: e.locationLatLng),
                  )),
                  initialCameraPosition:
                      CameraPosition(target: deliveryRoute.startLocation),
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
                    padding: const EdgeInsets.all(0),
                    constraints: const BoxConstraints(maxHeight: 30),
                    icon: (isCardExpanded)
                        ? const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 60,
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
                            size: 60,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                  color: Colors.black,
                                  blurRadius: 5,
                                  offset: Offset(0, 0))
                            ],
                          ),
                    onPressed: _toggleCardSize,
                  ),
                  GestureDetector(
                    onTap: _toggleCardSize,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: (isCardExpanded)
                          ? MediaQuery.of(context).size.height / 2.9
                          : MediaQuery.of(context).size.height / 4.2,
                      child: PageView.builder(
                        itemCount: deliveryRoute.deliveries.length,
                        controller: pageController,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 10),
                          child: Card(
                              color: const Color.fromARGB(255, 234, 234, 234),
                              elevation: 10,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        IntrinsicHeight(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "#${index + 1}",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 15),
                                              ),
                                              Row(
                                                children: [
                                                  const Text("DELIVERED :  "),
                                                  SizedBox(
                                                    height: 25,
                                                    width: 35,
                                                    child: GestureDetector(
                                                      onTap: () =>
                                                          _toggleDeliveryStatus(
                                                              index),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: deliveryRoute
                                                                      .deliveries[
                                                                          index]
                                                                      .status ==
                                                                  "IN_STOCK"
                                                              ? Colors.red
                                                              : Colors.green,
                                                          shape: BoxShape
                                                              .rectangle,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  4), // Optional: rounded corners
                                                        ),
                                                        child: Center(
                                                          child: Icon(
                                                            (deliveryRoute
                                                                        .deliveries[
                                                                            index]
                                                                        .status ==
                                                                    "IN_STOCK")
                                                                ? Icons
                                                                    .close_rounded
                                                                : Icons
                                                                    .check_rounded,
                                                            color: Colors.white,
                                                            size: 20,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Divider(
                                          height: 5,
                                          color:
                                              Color.fromARGB(50, 128, 128, 128),
                                        ),
                                      ],
                                    ),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          const Icon(
                                            Icons.location_city,
                                            color:
                                                Color.fromRGBO(64, 64, 64, 1),
                                          ),
                                          Expanded(
                                              flex: 2,
                                              child: Text(
                                                deliveryRoute.deliveries[index]
                                                    .locationName,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color.fromRGBO(
                                                      64, 64, 64, 1),
                                                ),
                                                textAlign: TextAlign.right,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 3,
                                              ))
                                        ]),
                                    if (isCardExpanded &&
                                        (deliveryRoute.deliveries[index]
                                                    .ownerName ??
                                                '')
                                            .isNotEmpty)
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Icon(
                                              Icons.person,
                                              color: Colors.black,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  deliveryRoute
                                                          .deliveries[index]
                                                          .ownerName ??
                                                      "",
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 20),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    launchUrl(Uri.parse(
                                                        'tel:${deliveryRoute.deliveries[index].phone}'));
                                                  },
                                                  child: const Row(
                                                    children: [
                                                      Icon(Icons.call),
                                                      Text(" CALL")
                                                    ],
                                                  ),
                                                )
                                              ],
                                            )
                                          ]),
                                    Flexible(
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          spacing: 40,
                                          children: [
                                            const Icon(
                                              Icons.note_alt,
                                              color:
                                                  Color.fromRGBO(64, 64, 64, 1),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                deliveryRoute.deliveries[index]
                                                        .note ??
                                                    '',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines:
                                                    (isCardExpanded) ? 5 : 2,
                                                textAlign: TextAlign.right,
                                              ),
                                            )
                                          ]),
                                    ),
                                  ],
                                ),
                              )),
                        ),
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
    for (var i = 0; i < deliveryRoute.deliveries.length - 1; i++) {
      await PolyLinePointList.getPolyLineRoute(
              start: deliveryRoute.deliveries[i].locationLatLng,
              end: deliveryRoute.deliveries[i + 1].locationLatLng)
          .then(
        (value) {
          polyLines.add(Polyline(
              polylineId: PolylineId(deliveryRoute.deliveries[i].locationName),
              points: value,
              color: Colors.blue,
              width: 3));
        },
      );
    }
    setState(() {});
  }

  _toggleDeliveryStatus(int i) {
    setState(() {
      if (deliveryRoute.deliveries[i].status == "IN_STOCK") {
        deliveryRoute.deliveries[i].status = "DELIVERED";

        pageController.animateToPage((i + 1),
            duration: const Duration(milliseconds: 800),
            curve: Curves.linearToEaseOut);
      } else {
        deliveryRoute.deliveries[i].status = "IN_STOCK";
      }
    });
  }

  _toggleCardSize() {
    setState(() {
      isCardExpanded = !isCardExpanded;
    });
  }
}
