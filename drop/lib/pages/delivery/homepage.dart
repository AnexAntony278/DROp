import 'package:drop/models/route_schema.dart';
import 'package:drop/services/app_preferences_service.dart';
import 'package:drop/services/local_file_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<DeliveryRoute> userRoutes = [];
  DeliveryRoute? recentRoute;

  @override
  void initState() {
    _getRecentRoute();
    _initializeData();
    super.initState();
  }

  _initializeData() async {
    userRoutes = await LocalFileStorage.getCurrentUserRoutes();
    userRoutes.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );
    setState(() {});
  }

  _getRecentRoute() async {
    String? recentRouteId =
        AppPreferencesService.instance.prefs.getString("recentRouteId");
    if (recentRouteId != null) {
      recentRoute = (await LocalFileStorage.getRouteFromFile(
              routeIdList: [recentRouteId]))
          .first;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (MediaQuery.of(context).orientation == Orientation.portrait)
          ? AppBar(
              backgroundColor: Theme.of(context).primaryColor,
            )
          : null,
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
              trailing: const Icon(Icons.logout),
              title: const Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                AppPreferencesService.instance.prefs.clear();
                Navigator.popUntil(
                    context, ModalRoute.withName("authenticationpage"));
                await Navigator.pushNamed(context, "authenticationpage");
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            Navigator.pop(context);
            await Navigator.pushNamed(context, 'createroutepage');
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
          child: Column(
            children: [
              if (recentRoute != null)
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, 'deliverypage',
                        arguments: recentRoute);
                  },
                  child: Card(
                    elevation: 10,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height / 4.5,
                        width: double.infinity,
                        child: Stack(
                          clipBehavior: Clip.hardEdge,
                          children: [
                            Center(
                              child: Image.asset(
                                'assets/images/delivery_screenshot.jpg',
                                fit: BoxFit.cover,
                                color: const Color.fromARGB(137, 0, 0, 0),
                                colorBlendMode: BlendMode.multiply,
                                width: double.infinity,
                              ),
                            ),
                            const Positioned(
                              top: 10,
                              left: 7,
                              child: Text(
                                "Resume recent route",
                                style: TextStyle(
                                    shadows: [
                                      Shadow(
                                          color: Color.fromARGB(83, 0, 0, 0),
                                          offset: Offset(3, 2),
                                          blurRadius: 3)
                                    ],
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                            Center(
                                child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    maxLines: 4,
                                    overflow: TextOverflow.fade,
                                    "From:${recentRoute!.deliveries.first.locationName} -> ${recentRoute!.deliveries.last.locationName}",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "${recentRoute?.deliveries.fold(
                                          0,
                                          (previousValue, element) =>
                                              previousValue +
                                              ((element.status == "DELIVERED")
                                                  ? 1
                                                  : 0),
                                        )}/ ${recentRoute?.deliveries.length} deliveried",
                                        style: const TextStyle(
                                            color: Color.fromARGB(
                                                255, 58, 247, 203),
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "STATUS: ${recentRoute?.status}",
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700),
                                  )
                                ],
                              ),
                            )),
                            const Positioned(
                              bottom: 10,
                              right: 10,
                              child: Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (userRoutes.isEmpty)
                Expanded(
                  child: SizedBox(
                    height: double.infinity,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 3,
                            child: Lottie.asset(
                                'assets/animations/DeliveryScooterAnimation.json'),
                          ),
                          const Text("Create a route and start delivering",
                              style: TextStyle(fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: ListView.separated(
                      itemCount: userRoutes.length,
                      itemBuilder: (context, index) {
                        {
                          return Column(
                            children: [
                              if (index == 0 ||
                                  !DateUtils.isSameDay(
                                      userRoutes[index].createdAt,
                                      userRoutes[index - 1].createdAt))
                                ListTile(
                                  title: Text(
                                    DateFormat.yMMMMd()
                                        .format(userRoutes[index].createdAt),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  tileColor: Theme.of(context).hintColor,
                                ),
                              Dismissible(
                                key: Key(userRoutes[index].id),
                                direction: DismissDirection.startToEnd,
                                background: Container(
                                  alignment: Alignment.centerLeft,
                                  color: Colors.red,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
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
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: const Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: const Text("Delete",
                                                style: TextStyle(
                                                    color: Colors.red)),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                onDismissed: (direction) async {
                                  await LocalFileStorage.deleteRouteFile(
                                      deliveryRoute: userRoutes[index]);
                                  setState(() {
                                    if (recentRoute?.id ==
                                        userRoutes[index].id) {
                                      recentRoute = null;
                                    }
                                    userRoutes.removeAt(index);
                                  });
                                },
                                child: ListTile(
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "${DateFormat.jm().format(userRoutes[index].createdAt)} ",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "${userRoutes[index].deliveries.fold(
                                                    0,
                                                    (previousValue, element) =>
                                                        previousValue +
                                                        ((element.status ==
                                                                "DELIVERED")
                                                            ? 1
                                                            : 0),
                                                  )} / ${userRoutes[index].deliveries.length}",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                    subtitle: Text(
                                        "From:${userRoutes[index].deliveries.first.locationName} -> ${userRoutes[index].deliveries.last.locationName}"),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      await Navigator.pushNamed(
                                          context, "deliverypage",
                                          arguments: userRoutes[index]);
                                    }),
                              )
                            ],
                          );
                        }
                      },
                      separatorBuilder: (context, index) => const Divider(
                        height: 5,
                      ),
                    ),
                  ),
                ),
            ],
          )),
    );
  }
}
