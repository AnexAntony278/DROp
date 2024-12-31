import 'package:flutter/material.dart';

class CreateRoutePage extends StatefulWidget {
  const CreateRoutePage({super.key});

  @override
  State<CreateRoutePage> createState() => _CreateRoutePageState();
}

class _CreateRoutePageState extends State<CreateRoutePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(this.context),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text("Create Route"),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Add new delivey:'),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: SearchBar(
                          hintText: "search for destination",
                          elevation: WidgetStateProperty.all(1),
                          shape: WidgetStateProperty.all(LinearBorder.none),
                          trailing: [
                            GestureDetector(
                              child: const Icon(Icons.search),
                              onTap: () {
                                debugPrint('searh');
                              },
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                              child: const Icon(Icons.qr_code),
                              onTap: () {},
                            )
                          ],
                        ),
                      ),
                      Text('Destination'),
                      Text('Notes')
                    ],
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
