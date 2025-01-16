import 'package:uuid/uuid.dart';

class User {
  late final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;
  final String role; // MANAGER | AGENT
  final String? managerId;
  late final DateTime createdAt;

  User(
      {required this.firstName,
      required this.lastName,
      required this.email,
      required this.phone,
      required this.password,
      required this.role,
      required this.managerId}) {
    id = const Uuid().v4(); // Initializes random UuId
    createdAt = DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "phone": phone,
      "password": password,
      "role": role,
      "managerId": managerId,
      "createdAt": createdAt.toString(),
    };
  }
}
