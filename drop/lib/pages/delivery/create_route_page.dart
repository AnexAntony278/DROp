import 'dart:convert';
import 'package:drop/models/route_schema.dart';
import 'package:drop/services/connectivity.dart';
import 'package:drop/services/maps_api_services.dart';
import 'package:drop/models/delivery_schema.dart';
import 'package:drop/services/route_optimization.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/local_file_storage.dart';

class CreateRoutePage extends StatefulWidget {
  const CreateRoutePage({super.key});

  @override
  State<CreateRoutePage> createState() => _CreateRoutePageState();
}

class _CreateRoutePageState extends State<CreateRoutePage> {
  final _destinationTextEditingController = TextEditingController();
  final _noteTextEditingController = TextEditingController();
  List<Delivery> deliveries = [];
  List<dynamic> _suggestedDestinations = [];

  bool _internetChecked = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (deliveries.isEmpty) {
          Navigator.popAndPushNamed(context, 'homepage');
          return;
        }
        final bool shouldPop = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: const Text(
                        'Are you sure? All progress will be lost if you exit'),
                    actions: <Widget>[
                      ElevatedButton(
                        child: const Text('Cancel'),
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
          Navigator.popAndPushNamed(context, 'homepage');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text(
            "Create Route",
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          tooltip: "Create delivery route",
          onPressed: () async {
            if (deliveries.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  duration: Duration(seconds: 2),
                  content: Text('Add atleast one delivery to create route')));
            } else {
              final bool sure = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: const Text(
                              'Create route with existing deliveries ?'),
                          actions: <Widget>[
                            ElevatedButton(
                              child: const Text('No'),
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                            ),
                            ElevatedButton(
                              child: const Text('Yes, create'),
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                            ),
                          ],
                        );
                      }) ??
                  false;
              if (!sure) return;
              try {
                //Internet check
                if (!await InternetServices.checkInternet()) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No internet connection.')),
                    );
                  }
                  return;
                }
                if (context.mounted) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const PopScope(
                      canPop: false,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                // Get location and create delivery route
                final userLocation =
                    await LocationServices().getCurrentLocation();
                final deliveryRoute = await DeliveryRoute.create(
                  deliveries: deliveries,
                  startLocation: userLocation,
                );

                // Fetch distance matrix and optimize route
                deliveryRoute.distanceMatrix =
                    await DistanceMatrixServices.getDistanceMatrix(
                        deliveryRoute: deliveryRoute);

                ACOOptimizer(deliveryRoute: deliveryRoute).optimize();

                // Store the file
                await LocalFileStorage.storeRouteFile(
                    deliveryRoute: deliveryRoute);

                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, 'deliverypage',
                      arguments: deliveryRoute);
                }
              } catch (error) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 5),
                      content: Text(error.toString()),
                    ),
                  );
                }
              }
            }
          },
          label: const Text('Create Route'),
          icon: const Icon(Icons.play_arrow_rounded),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: Card(
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Add New Delivery:',
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).primaryColor,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Destination:',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Autocomplete<String>(
                              optionsBuilder: (textEditingValue) async {
                                if (textEditingValue.text.isEmpty) {
                                  return [];
                                } else {
                                  //check internet
                                  if (!await InternetServices.checkInternet()) {
                                    if (context.mounted && !_internetChecked) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'No internet connection.')),
                                      );
                                    }
                                    _internetChecked = true;
                                    return [];
                                  }
                                  _suggestedDestinations =
                                      await MapsAutocomplete.getPredictions(
                                          textEditingValue.text);
                                  return _suggestedDestinations.map(
                                    (e) => e['description'],
                                  );
                                }
                              },
                              fieldViewBuilder: (context, textEditingController,
                                  focusNode, onFieldSubmitted) {
                                textEditingController.text =
                                    _destinationTextEditingController.text;
                                return TextFormField(
                                  controller: textEditingController,
                                  focusNode: focusNode,
                                  onTap: onFieldSubmitted,
                                );
                              },
                              onSelected: (option) {
                                _destinationTextEditingController.text = option;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: const Icon(Icons.qr_code),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => Container(
                                  height: 400,
                                  color: Colors.white,
                                  child: Column(
                                    children: <Widget>[
                                      const SizedBox(height: 10),
                                      const Text(
                                        "Scan QR Code",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Expanded(
                                        child: MobileScanner(
                                          onDetect: (barcode) {
                                            try {
                                              // Ensure barcode data is valid
                                              if (barcode.barcodes.isEmpty ||
                                                  barcode.barcodes.first
                                                          .rawValue ==
                                                      null) {
                                                throw const FormatException(
                                                    "QR Code is empty or unreadable");
                                              }

                                              // Parse JSON safely
                                              final String rawValue = barcode
                                                  .barcodes.first.rawValue!;
                                              late Map<String, dynamic>
                                                  scanInfo;

                                              try {
                                                scanInfo = jsonDecode(rawValue);
                                              } catch (e) {
                                                throw const FormatException(
                                                    "Invalid QR Code format");
                                              }
                                              // Prevent duplicate entries
                                              if (deliveries.any(
                                                  (destination) =>
                                                      destination
                                                          .locationName ==
                                                      scanInfo[
                                                          'locationName'])) {
                                                throw const FormatException(
                                                    "Item already scanned");
                                              }

                                              // Add valid scanned item
                                              setState(() {
                                                deliveries.add(
                                                    Delivery.fromMap(scanInfo));
                                              });

                                              Navigator.pop(context);
                                            } catch (e) {
                                              // Show error BEFORE closing scanner
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  duration: const Duration(
                                                      seconds: 2),
                                                  content: Text(
                                                      'Error: ${e is FormatException ? e.message : "Unknown error"}'),
                                                ),
                                              );

                                              // Delay closing the scanner to allow user to see the error
                                              Future.delayed(
                                                  const Duration(seconds: 2),
                                                  () {
                                                Navigator.pop(context);
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Notes:',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextField(
                        maxLength: 100,
                        style: const TextStyle(fontSize: 15),
                        maxLines: 3,
                        minLines: 2,
                        controller: _noteTextEditingController,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          ElevatedButton(
                            child: const Text('ADD DESTINATION'),
                            onPressed: () async {
                              if (deliveries.any((destination) =>
                                  destination.locationName ==
                                  _destinationTextEditingController.text)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        duration: Duration(seconds: 2),
                                        content:
                                            Text('Location already added')));
                              } else if (_destinationTextEditingController
                                  .text.isNotEmpty) {
                                final delivery = await Delivery.create(
                                    locationName:
                                        _destinationTextEditingController.text,
                                    note: _noteTextEditingController.text);
                                setState(() {
                                  deliveries.add(delivery);
                                  _destinationTextEditingController.clear();
                                  _noteTextEditingController.clear();
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        duration: Duration(seconds: 2),
                                        content: Text(
                                            'Select a destination or scan product QR')));
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: deliveries.length,
                itemBuilder: (context, index) => Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          '#${index + 1}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const VerticalDivider(
                          thickness: 3,
                          endIndent: 10,
                        )
                      ],
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            deliveries[index].locationName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      deliveries[index].note ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                        onPressed: () {
                          setState(() {
                            deliveries.removeAt(index);
                          });
                        },
                        icon: const Icon(Icons.close)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
