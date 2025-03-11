import 'package:drop/models/route_schema.dart';
import 'package:drop/services/local_file_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<DeliveryRoute> userRoutes = [];

  @override
  void initState() {
    initializeData();
    super.initState();
  }

  initializeData() async {
    userRoutes = await LocalFileStorage.getCurrentUserRoutes();
    userRoutes = List.from(userRoutes.reversed);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Column(
                children: [
                  Text('User Name'),
                  ListTile(title: Text("Settings")),
                ],
              ),
            ),
            ListTile(
              title: const Text('Item 1'),
              onTap: () {},
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await Navigator.pushNamed(context, 'createroutepage');
            initializeData();
          },
          label: const Row(
            children: [
              Text(
                "Create New Route",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 5,
              ),
              Icon(
                Icons.add_circle_rounded,
                size: 30,
              ),
            ],
          )),
      body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: ListView.separated(
            itemCount: userRoutes.length,
            itemBuilder: (context, index) {
              if (index == 0 ||
                  !DateUtils.isSameDay(userRoutes[index].createdAt,
                      userRoutes[index - 1].createdAt)) {
                return Column(
                  children: [
                    ListTile(
                      title: Text(
                        DateFormat.yMMMMd().format(userRoutes[index].createdAt),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      tileColor: Colors.blueGrey,
                    ),
                    Dismissible(
                      key: Key(userRoutes[index].id),
                      direction: DismissDirection.startToEnd,
                      background: Container(
                        alignment: Alignment.centerLeft,
                        color: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Confirm Delete"),
                              content: const Text(
                                  "Are you sure you want to delete this route?"),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text("Delete",
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      onDismissed: (direction) async {
                        await LocalFileStorage.deleteRouteFile(
                            deliveryRoute: userRoutes[index]);
                        initializeData();
                      },
                      child: ListTile(
                          title: Text(
                              "From:${userRoutes[index].deliveries.first.locationName} -> ${userRoutes[index].deliveries.last.locationName}"),
                          onTap: () async {
                            await Navigator.pushNamed(context, "deliverypage",
                                arguments: userRoutes[index]);
                            initializeData();
                          }),
                    )
                  ],
                );
              }
              return Dismissible(
                key: Key(userRoutes[index].id),
                direction: DismissDirection.startToEnd,
                background: Container(
                  alignment: Alignment.centerLeft,
                  color: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Confirm Delete"),
                        content: const Text(
                            "Are you sure you want to delete this route?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text("Delete",
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      );
                    },
                  );
                },
                onDismissed: (direction) async {
                  await LocalFileStorage.deleteRouteFile(
                      deliveryRoute: userRoutes[index]);
                  initializeData();
                },
                child: ListTile(
                    title: Text(
                        "From:${userRoutes[index].deliveries.first.locationName} -> ${userRoutes[index].deliveries.last.locationName}"),
                    onTap: () async {
                      await Navigator.pushNamed(context, "deliverypage",
                          arguments: userRoutes[index]);
                      initializeData();
                    }),
              );
            },
            separatorBuilder: (context, index) => const Divider(
              height: 3,
            ),
          )),
    );
  }
}
