import 'dart:convert';

import 'package:drop/services/app_preferences_service.dart';
import 'package:flutter/material.dart';

class User {
  late final String id;
  late final String name;
  late final String email;
  late final String phone;
  late final String password;
  late final String role; // MANAGER | AGENT
  String? managerId; // Removed 'late' to allow nullability
  late final DateTime createdAt;

  User({
    required this.name,
    required this.email,
    required this.phone,
  }) {
    createdAt = DateTime.now();
  }

  User.fromMap(Map<String, dynamic> map) {
    id = map['id'] ?? '';
    name = map['firstName'] ?? '';
    email = map['email'] ?? '';
    phone = map['phone'] ?? '';
    password = map['password'] ?? '';
    role = map['role'] ?? 'AGENT';
    managerId = map['managerId'];
    createdAt = DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "phone": phone,
      "password": password,
      "role": role,
      "managerId": managerId,
      "createdAt": createdAt.toString(),
    };
  }

  static String? getCurrentUser() {
    try {
      String? userToken =
          AppPreferencesService.instance.prefs.getString("user_token");
      return (userToken == null) ? null : jsonDecode(userToken)['_id'];
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
