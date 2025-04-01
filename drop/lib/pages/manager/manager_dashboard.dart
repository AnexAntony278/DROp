import 'dart:convert';

import 'package:drop/constants/constants.dart';
import 'package:drop/services/app_preferences_service.dart';
import 'package:drop/services/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class ManagerDashBoard extends StatefulWidget {
  const ManagerDashBoard({super.key});

  @override
  ManagerDashBoardState createState() => ManagerDashBoardState();
}

class ManagerDashBoardState extends State<ManagerDashBoard> {
  List employees = [];
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchAgents();
  }

  Future<void> fetchAgents() async {
    if (!await InternetServices.checkInternet() && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("No internet connection. Check connectivity")));
    }
    while (!await InternetServices.checkInternet()) {
      await Future.delayed(const Duration(seconds: 3));
    }
    try {
      final response = await http.get(
        Uri.parse(
            "$NODE_SERVER_URL/users/agents?managerId=${jsonDecode(AppPreferencesService.instance.prefs.getString("user_token")!)["email"]}"),
        headers: {'Content-Type': "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            employees = data["agents"] ?? [];
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Request error")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    }
  }

  void _makeCall(String phoneNumber) async {
    final Uri url = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Cannot make a call to $phoneNumber")),
        );
      }
    }
  }

  void _inviteWhatsapp() async {
    try {
      final Uri url = Uri.parse(
          "https://wa.me/?text=${Uri.encodeComponent('Join my *DROp* team using link: \n https://drop-website.onrender.com/ \n *User Name:* ${jsonDecode(AppPreferencesService.instance.prefs.getString("user_token") ?? "")["name"]}')}");

      await launchUrl(url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("failed to launch whatsapp link")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manager Dashboard"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Employee List",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: (_isLoading)
                  ? const Center(child: CircularProgressIndicator())
                  : (employees.isEmpty)
                      ? GestureDetector(
                          onTap: _inviteWhatsapp,
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.group_add,
                                  size: 48,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "No delivery agents available\nClick to invite agents to join your team!",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: employees.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: ListTile(
                                onTap: () {
                                  Navigator.pushNamed(context, "agentstatspage",
                                      arguments: employees[index]["_id"]);
                                },
                                leading: const Icon(Icons.person),
                                title: Text(
                                  employees[index]["name"],
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text(employees[index]["email"]),
                                trailing: IconButton(
                                    onPressed: () =>
                                        _makeCall(employees[index]["phone"]),
                                    icon: const Icon(Icons.call)),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
