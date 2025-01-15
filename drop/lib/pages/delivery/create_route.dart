import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../constants/constants.dart';
import 'package:http/http.dart' as http;

class CreateRoutePage extends StatefulWidget {
  const CreateRoutePage({super.key});

  @override
  State<CreateRoutePage> createState() => _CreateRoutePageState();
}

class _CreateRoutePageState extends State<CreateRoutePage> {
  final _destinationTextEditingController = TextEditingController();
  final _noteTextEditingController = TextEditingController();
  List<Map> destinations = [];
  List<dynamic> _suggestedDestinations = [
    {'description': 'haa'}
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text('Create Route'),
        icon: const Icon(Icons.play_arrow_rounded),
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text("Create Route"),
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
                                await _getPredictions(textEditingValue.text);
                                return _suggestedDestinations.map(
                                  (e) => e['description'],
                                );
                              }
                            },
                            fieldViewBuilder: (context, textEditingController,
                                focusNode, onFieldSubmitted) {
                              return TextFormField(
                                controller: textEditingController,
                                focusNode: focusNode,
                                onTap: onFieldSubmitted,
                              );
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
                                            if (destinations.any(
                                                (destination) =>
                                                    destination['name'] ==
                                                    scanInfo['name'])) {
                                              throw ErrorDescription(
                                                  'Item already scanned');
                                            } else {
                                              setState(() {
                                                destinations.add(scanInfo);
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
                          onPressed: () {
                            setState(() {
                              destinations.add({
                                'name': _destinationTextEditingController.text,
                                if (_noteTextEditingController.text.isNotEmpty)
                                  'note': _noteTextEditingController.text
                              });
                              _destinationTextEditingController.clear();
                              _noteTextEditingController.clear();
                            });
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
              itemCount: destinations.length,
              itemBuilder: (context, index) => Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${destinations[index]['name'] ?? ''}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              destinations.removeAt(index);
                            });
                          },
                          icon: const Icon(Icons.close))
                    ],
                  ),
                  subtitle: Text(destinations[index]['note'] ?? ''),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getPredictions(String? input) async {
    //GET PREDICTIONS
    try {
      var url = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input="$input"&key=$MAPS_API_KEY');
      await http.get(url).then(
        (response) {
          if (response.statusCode == 200) {
            _suggestedDestinations =
                List.from(jsonDecode(response.body)['predictions']);
            setState(() {});
          }
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
