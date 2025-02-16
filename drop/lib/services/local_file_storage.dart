import 'dart:convert';
import 'dart:io';
import 'package:drop/models/route_schema.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalFileStorage {
  static Future<void> storeRouteAsFile(
      {required DeliveryRoute deliveryRoute}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userId = prefs.getString("user_token") ?? "guest";
    Directory userDirectory = await getApplicationDocumentsDirectory();
    userDirectory = Directory('${userDirectory.path}/$userId/');

    await userDirectory.create(recursive: true);

    File file = File("${userDirectory.path}/${deliveryRoute.id}.json");
    await file.writeAsString(jsonEncode(deliveryRoute.toMap()));
  }

  // static Future<List<DeliveryRoute>> getRouteFromFile(
  //     {required List<String> routeIdList}) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final String userId = prefs.getString("user_token") ?? "guest";
  //   Directory userDirectory = await getApplicationDocumentsDirectory();
  //   userDirectory = Directory("$userDirectory/$userId");
  // }
}
