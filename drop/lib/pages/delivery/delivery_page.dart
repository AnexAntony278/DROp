import 'package:drop/models/route_schema.dart';
import 'package:drop/services/connectivity.dart';
import 'package:drop/services/local_file_storage.dart';
import 'package:drop/services/maps_api_services.dart';
import 'package:drop/services/route_optimization.dart';
import 'package:drop/widgets/numbered_marker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class DeliveryPage extends StatefulWidget {
  const DeliveryPage({super.key});

  @override
  State<DeliveryPage> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
  late DeliveryRoute deliveryRoute;

  List<Polyline> polyLines = [];
  Set<Marker> markers = {};
  final PageController pageController = PageController();
  late GoogleMapController mapController;
  bool _isCardExpanded = false;
  bool _isLoading = true;
  bool _isEditMode = false;
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _initializeData());
  }

  Future<void> _initializeData() async {
    deliveryRoute = ModalRoute.of(context)!.settings.arguments as DeliveryRoute;
    await _setRecentRoute();
    if (!await InternetServices.checkInternet() && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("No internet connection. Check connectivity")),
      );
    }
    while (!await InternetServices.checkInternet()) {
      if (!mounted) return;
      await Future.delayed(const Duration(seconds: 3));
    }

    await Future.wait([
      _getRoute(),
      _loadMarkers(),
    ]);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getRoute() async {
    List<Future<List<LatLng>>> routeFutures = [];
    List<Polyline> tempPolylines = [];
    routeFutures.add(PolyLinePointList.getPolyLineRoute(
      start: deliveryRoute.startLocation,
      end: deliveryRoute.deliveries.first.locationLatLng,
    ));
    for (var i = 0; i < deliveryRoute.deliveries.length - 1; i++) {
      routeFutures.add(PolyLinePointList.getPolyLineRoute(
        start: deliveryRoute.deliveries[i].locationLatLng,
        end: deliveryRoute.deliveries[i + 1].locationLatLng,
      ));
    }
    routeFutures.add(PolyLinePointList.getPolyLineRoute(
      start: deliveryRoute.deliveries.last.locationLatLng,
      end: deliveryRoute.startLocation,
    ));
    List<List<LatLng>> routePoints = await Future.wait(routeFutures);
    tempPolylines.add(Polyline(
      polylineId: const PolylineId("start"),
      points: routePoints[0],
      color: Colors.blueAccent,
      width: 4,
      zIndex: 1,
    ));

    for (var i = 1; i < routePoints.length - 1; i++) {
      tempPolylines.add(Polyline(
        polylineId: PolylineId("routefrom${i - 1} to$i"),
        points: routePoints[i],
        color: Colors.lightBlue,
        width: 1,
        zIndex: 0,
      ));
    }

    tempPolylines.add(Polyline(
      polylineId: const PolylineId("last"),
      points: routePoints.last,
      color: Colors.lightBlue,
      width: 1,
      zIndex: 0,
    ));

    polyLines.insertAll(0, tempPolylines);
  }

  void _updatePolylineColors(int selectedIndex) {
    if (selectedIndex < 0 || selectedIndex >= polyLines.length) return;

    polyLines[selectedIndex] = polyLines[selectedIndex]
        .copyWith(colorParam: Colors.blueAccent, widthParam: 4, zIndexParam: 1);

    if (selectedIndex < polyLines.length - 1) {
      polyLines[selectedIndex + 1] = polyLines[selectedIndex + 1].copyWith(
          colorParam: Colors.lightBlue, widthParam: 1, zIndexParam: 0);
    }

    if (selectedIndex > 0) {
      polyLines[selectedIndex - 1] = polyLines[selectedIndex - 1].copyWith(
          colorParam: Colors.lightBlue, widthParam: 1, zIndexParam: 0);
    }
  }

  Future<void> _loadMarkers() async {
    List<Future<Marker>> markerFutures = [];

    for (int i = 0; i < deliveryRoute.deliveries.length; i++) {
      markerFutures
          .add(createNumberedMarker(i + 1, Colors.white).then((markerIcon) {
        return Marker(
          icon: markerIcon,
          markerId: MarkerId((i + 1).toString()),
          position: deliveryRoute.deliveries[i].locationLatLng,
        );
      }));
    }
    var newMarkers = await Future.wait(markerFutures);
    newMarkers.add(Marker(
        icon: await createFlutterIconMarker(Icons.warehouse, Colors.red, 60),
        markerId: const MarkerId("user"),
        position: deliveryRoute.startLocation,
        zIndex: 2));
    if (mounted) {
      setState(() {
        markers = newMarkers.toSet();
      });
    }
  }

  Future<void> _setRecentRoute() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("recentRouteId", deliveryRoute.id);
  }

  _handleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  Future<void> _deleteDelivery() async {
    if (deliveryRoute.deliveries.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cannot delete the last delivery."),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    bool? confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: Text(
              "Are you sure you want to delete delivery #${pageController.page!.round() + 1}?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
    debugPrint("$confirmDelete and ${pageController.page}");
    if (confirmDelete == true && pageController.page != null) {
      deliveryRoute.deliveries.removeAt(pageController.page!.round().toInt());
    }
    setState(() {});
  }

  _optimizeRoute() async {
    setState(() {
      _isLoading = true;
    });

    if (!await InternetServices.checkInternet()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No internet connection.')),
        );
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final userLocation = await LocationServices().getCurrentLocation();
    deliveryRoute.startLocation = userLocation;

    deliveryRoute.distanceMatrix =
        await DistanceMatrixServices.getDistanceMatrix(
      deliveryRoute: deliveryRoute,
    );

    ACOOptimizer(deliveryRoute: deliveryRoute).optimize();

    await Future.wait([
      _getRoute(),
      _loadMarkers(),
    ]);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleDeliveryStatus(int i) {
    setState(() {
      if (deliveryRoute.deliveries[i].status == "IN_STOCK") {
        deliveryRoute.deliveries[i].status = "DELIVERED";
        pageController.animateToPage(i + 1,
            duration: const Duration(milliseconds: 800),
            curve: Curves.linearToEaseOut);
      } else {
        deliveryRoute.deliveries[i].status = "IN_STOCK";
      }
    });
  }

  void _toggleCardSize() {
    setState(() {
      _isCardExpanded = !_isCardExpanded;
    });
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

        if (!mounted || !shouldPop) return;
        await LocalFileStorage.storeRouteFile(deliveryRoute: deliveryRoute);
        Future.delayed(const Duration(milliseconds: 500), () {
          if (context.mounted) {
            Navigator.popAndPushNamed(context, 'homepage');
          }
        });
      },
      child: Scaffold(
        appBar: (MediaQuery.of(context).orientation == Orientation.portrait)
            ? AppBar(
                title: const Text(
                  'Delivery Page',
                ),
                backgroundColor: Theme.of(context).primaryColor,
                actions: [
                  Text((_isEditMode) ? "Confirm" : "Edit"),
                  IconButton(
                      onPressed: () async => _handleEditMode(),
                      icon: Icon((_isEditMode)
                          ? Icons.check
                          : Icons.edit_location_alt_sharp)),
                  const SizedBox(
                    width: 10,
                  )
                ],
              )
            : null,
        body: SafeArea(
          child: FutureBuilder(
            future: Future.delayed(Duration.zero, () {
              if (context.mounted) {
                return ModalRoute.of(context)!.settings.arguments
                    as DeliveryRoute;
              }
            }),
            builder: (context, snapshot) => (snapshot.hasData)
                ? Center(
                    child: Stack(
                      children: <Widget>[
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : GoogleMap(
                                polylines: Set<Polyline>.of(polyLines),
                                markers: markers,
                                initialCameraPosition: CameraPosition(
                                    target: deliveryRoute.startLocation,
                                    zoom: 15),
                                mapType: MapType.normal,
                                myLocationEnabled: true,
                                trafficEnabled: false,
                                indoorViewEnabled: false,
                                mapToolbarEnabled: false,
                                minMaxZoomPreference:
                                    const MinMaxZoomPreference(2, 20),
                                onMapCreated: (GoogleMapController controller) {
                                  mapController = controller;
                                }),
                        if (MediaQuery.of(context).orientation ==
                            Orientation.portrait)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  (_isEditMode)
                                      ? IconButton(
                                          onPressed: () => _deleteDelivery(),
                                          icon: const Icon(
                                            Icons.delete_forever,
                                            color: Colors.white,
                                            shadows: [
                                              Shadow(
                                                  color: Color.fromARGB(
                                                      218, 0, 0, 0),
                                                  blurRadius: 20)
                                            ],
                                            size: 40,
                                          ),
                                        )
                                      : IconButton(
                                          tooltip: "Re optimize",
                                          onPressed: () => _optimizeRoute(),
                                          icon: const Icon(
                                            Icons.replay_circle_filled_outlined,
                                            color: Colors.white,
                                            shadows: [
                                              Shadow(
                                                  color: Color.fromARGB(
                                                      218, 0, 0, 0),
                                                  blurRadius: 20)
                                            ],
                                            size: 40,
                                          ),
                                        ),
                                ],
                              ),
                              const SizedBox(),
                              Column(
                                children: <Widget>[
                                  IconButton(
                                    padding: const EdgeInsets.all(0),
                                    constraints:
                                        const BoxConstraints(maxHeight: 30),
                                    icon: (_isCardExpanded)
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
                                      duration:
                                          const Duration(milliseconds: 200),
                                      height: (_isCardExpanded)
                                          ? MediaQuery.of(context).size.height /
                                              2.9
                                          : MediaQuery.of(context).size.height /
                                              4.2,
                                      child: PageView.builder(
                                          itemCount:
                                              deliveryRoute.deliveries.length +
                                                  1,
                                          controller: pageController,
                                          itemBuilder:
                                              (context, index) => Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 8,
                                                        horizontal: 10),
                                                    child: Card(
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 234, 234, 234),
                                                        elevation: 10,
                                                        child: (!_isLoading)
                                                            ? Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        20.0),
                                                                child: (index ==
                                                                        deliveryRoute
                                                                            .deliveries
                                                                            .length)
                                                                    ? Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: <Widget>[
                                                                          Text(
                                                                            "DELIVERED: ${deliveryRoute.deliveries.fold(
                                                                              0,
                                                                              (previousValue, element) => previousValue + ((element.status == "DELIVERED") ? 1 : 0),
                                                                            )} / ${deliveryRoute.deliveries.length}",
                                                                            style:
                                                                                const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                                                                          ),
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceAround,
                                                                            children: <Widget>[
                                                                              const Text(
                                                                                "Mark delivery as completed ?",
                                                                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                                                              ),
                                                                              SizedBox(
                                                                                height: 25,
                                                                                width: 35,
                                                                                child: GestureDetector(
                                                                                  onTap: () {
                                                                                    setState(() {
                                                                                      deliveryRoute.status == "INCOMPLETE" ? deliveryRoute.status = "COMPLETE" : deliveryRoute.status = "INCOMPLETE";
                                                                                    });
                                                                                  },
                                                                                  child: Container(
                                                                                    decoration: BoxDecoration(
                                                                                      color: deliveryRoute.status == "INCOMPLETE" ? Colors.red : Colors.green,
                                                                                      shape: BoxShape.rectangle,
                                                                                      borderRadius: BorderRadius.circular(4),
                                                                                    ),
                                                                                    child: Center(
                                                                                      child: Icon(
                                                                                        (deliveryRoute.status == "INCOMPLETE") ? Icons.close_rounded : Icons.check_rounded,
                                                                                        color: Colors.white,
                                                                                        size: 20,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          )
                                                                        ],
                                                                      )
                                                                    : Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: <Widget>[
                                                                          Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            children: <Widget>[
                                                                              IntrinsicHeight(
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: <Widget>[
                                                                                    Text(
                                                                                      "#${index + 1}",
                                                                                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                                                                                    ),
                                                                                    Row(
                                                                                      children: <Widget>[
                                                                                        const Text("DELIVERED :  "),
                                                                                        SizedBox(
                                                                                          height: 25,
                                                                                          width: 35,
                                                                                          child: GestureDetector(
                                                                                            onTap: () => _toggleDeliveryStatus(index),
                                                                                            child: Container(
                                                                                              decoration: BoxDecoration(
                                                                                                color: deliveryRoute.deliveries[index].status == "IN_STOCK" ? Colors.red : Colors.green,
                                                                                                shape: BoxShape.rectangle,
                                                                                                borderRadius: BorderRadius.circular(4),
                                                                                              ),
                                                                                              child: Center(
                                                                                                child: Icon(
                                                                                                  (deliveryRoute.deliveries[index].status == "IN_STOCK") ? Icons.close_rounded : Icons.check_rounded,
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
                                                                                color: Color.fromARGB(50, 128, 128, 128),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              crossAxisAlignment: CrossAxisAlignment.end,
                                                                              children: <Widget>[
                                                                                const Icon(
                                                                                  Icons.location_on_rounded,
                                                                                  color: Color.fromRGBO(64, 64, 64, 1),
                                                                                ),
                                                                                Expanded(
                                                                                    flex: 2,
                                                                                    child: Text(
                                                                                      deliveryRoute.deliveries[index].locationName,
                                                                                      style: const TextStyle(
                                                                                        fontSize: 18,
                                                                                        fontWeight: FontWeight.w700,
                                                                                        color: Color.fromRGBO(64, 64, 64, 1),
                                                                                      ),
                                                                                      textAlign: TextAlign.right,
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                      maxLines: 3,
                                                                                    ))
                                                                              ]),
                                                                          if (_isCardExpanded &&
                                                                              (deliveryRoute.deliveries[index].ownerName ?? '').isNotEmpty)
                                                                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                                                                              const Icon(
                                                                                Icons.person,
                                                                                color: Colors.black,
                                                                              ),
                                                                              Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                                                children: <Widget>[
                                                                                  Text(
                                                                                    deliveryRoute.deliveries[index].ownerName ?? "",
                                                                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
                                                                                  ),
                                                                                  ElevatedButton(
                                                                                    onPressed: () {
                                                                                      launchUrl(Uri.parse('tel:${deliveryRoute.deliveries[index].phone}'));
                                                                                    },
                                                                                    child: const Row(
                                                                                      children: <Widget>[
                                                                                        Icon(Icons.call),
                                                                                        Text(" CALL")
                                                                                      ],
                                                                                    ),
                                                                                  )
                                                                                ],
                                                                              )
                                                                            ]),
                                                                          if (deliveryRoute.deliveries[index].note != null &&
                                                                              deliveryRoute.deliveries[index].note!.isNotEmpty)
                                                                            Flexible(
                                                                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, spacing: 40, children: <Widget>[
                                                                                const Icon(
                                                                                  Icons.note_alt,
                                                                                  color: Color.fromRGBO(64, 64, 64, 1),
                                                                                ),
                                                                                Expanded(
                                                                                  flex: 2,
                                                                                  child: Text(
                                                                                    deliveryRoute.deliveries[index].note!,
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                    maxLines: (_isCardExpanded) ? 5 : 2,
                                                                                    textAlign: TextAlign.right,
                                                                                  ),
                                                                                )
                                                                              ]),
                                                                            ),
                                                                        ],
                                                                      ),
                                                              )
                                                            : null),
                                                  ),
                                          onPageChanged: (value) {
                                            mapController
                                                .animateCamera(
                                                    CameraUpdate.newLatLng(
                                              deliveryRoute
                                                  .deliveries[value %
                                                      deliveryRoute
                                                          .deliveries.length]
                                                  .locationLatLng,
                                            ))
                                                .then((_) {
                                              if (mounted) {
                                                setState(() {
                                                  _updatePolylineColors(value);
                                                });
                                              }
                                            });
                                          }),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  )
                : const Scaffold(),
          ),
        ),
      ),
    );
  }
}
