import 'dart:convert';
import 'package:drop/app_services/maps_api_services.dart';
import 'package:drop/models/delivery_schema.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class AddDeliveriesPage extends StatefulWidget {
  const AddDeliveriesPage({super.key});

  @override
  State<AddDeliveriesPage> createState() => _AddDeliveriesPageState();
}

class _AddDeliveriesPageState extends State<AddDeliveriesPage> {
  final _destinationTextEditingController = TextEditingController();
  final _noteTextEditingController = TextEditingController();
  List<Delivery> deliveries = [];
  List<dynamic> _suggestedDestinations = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text("Create Route"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          debugPrint(List.from(deliveries.map(
            (e) => e.toMap().toString(),
          )).toString());
        },
        label: const Text('Create Route'),
        icon: const Icon(Icons.play_arrow_rounded),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            child: Card(
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      children: [
                        Expanded(
                          child: Autocomplete<String>(
                            optionsBuilder: (textEditingValue) async {
                              if (textEditingValue.text.isEmpty) {
                                return [];
                              } else {
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
                                  children: [
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
                                            Map<String, dynamic> scanInfo =
                                                jsonDecode(barcode
                                                    .barcodes.first.rawValue
                                                    .toString());
                                            //If scanned item already added to list, show error
                                            if (deliveries.any((destination) =>
                                                destination.locationName ==
                                                scanInfo['locationName'])) {
                                              throw ErrorDescription(
                                                  'Item already scanned');
                                            } else {
                                              setState(() {
                                                deliveries.add(
                                                    Delivery.fromMap(scanInfo));
                                              });
                                            }
                                            Navigator.pop(context);
                                          } catch (e) {
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        'Invalid QR : $e')));
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
                      style: const TextStyle(fontSize: 15),
                      maxLines: 3,
                      minLines: 2,
                      controller: _noteTextEditingController,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          child: const Text('ADD DESTINATION'),
                          onPressed: () async {
                            if (_destinationTextEditingController
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
                                      content: Text(
                                          'Select a destination from the Dropdown')));
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
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FittedBox(
                        fit: BoxFit.fill,
                        child: Text(
                          deliveries[index].locationName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              deliveries.removeAt(index);
                            });
                          },
                          icon: const Icon(Icons.close))
                    ],
                  ),
                  subtitle: Text(deliveries[index].note ?? ''),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
