import 'dart:convert';
import 'dart:io';
import 'package:drop/models/route_schema.dart';
import 'package:drop/models/user_schema.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class LocalFileStorage {
  static Future<void> storeRouteFile(
      {required DeliveryRoute deliveryRoute}) async {
    final String userId = User.getCurrentUserId();
    Directory userDirectory = await getApplicationDocumentsDirectory();
    userDirectory = Directory('${userDirectory.path}/$userId/');
    await userDirectory.create(recursive: true);

    File file = File("${userDirectory.path}/${deliveryRoute.id}.json");
    await file.writeAsString(jsonEncode(deliveryRoute.toMap()));
  }

  static Future<void> deleteRouteFile(
      {required DeliveryRoute deliveryRoute}) async {
    final String userId = User.getCurrentUserId();
    Directory userDirectory = await getApplicationDocumentsDirectory();
    userDirectory = Directory("${userDirectory.path}/$userId");

    File file = File("${userDirectory.path}/${deliveryRoute.id}.json");
    await file.delete(recursive: true);
  }

  static Future<List<DeliveryRoute>> getRouteFromFile(
      {required List<String> routeIdList}) async {
    final String userId = User.getCurrentUserId();
    Directory userDirectory = await getApplicationDocumentsDirectory();
    userDirectory = Directory("${userDirectory.path}/$userId");

    List<DeliveryRoute> routes = [];
    for (String routeId in routeIdList) {
      File file = File("${userDirectory.path}/$routeId.json");
      if (await file.exists()) {
        routes
            .add(DeliveryRoute.fromMap(jsonDecode(await file.readAsString())));
      } else {
        debugPrint("Skipping missing route file: ${file.path}");
      }
    }
    return routes;
  }

  static Future<List<DeliveryRoute>> getCurrentUserIdRoutes() async {
    final String userId = User.getCurrentUserId();
    Directory userDirectory = await getApplicationDocumentsDirectory();
    userDirectory = Directory("${userDirectory.path}/$userId");
    List<DeliveryRoute> deliveryRoutes = await getRouteFromFile(
        routeIdList: userDirectory
            .listSync()
            .whereType<File>()
            .map((fileItem) => fileItem.path.split("/").last.split(".").first)
            .toList());
    return deliveryRoutes;
  }
}
