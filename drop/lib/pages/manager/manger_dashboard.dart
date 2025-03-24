import 'dart:convert';

import 'package:drop/constants/constants.dart';
import 'package:drop/models/user_schema.dart';
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
    final response = await http.post(Uri.parse("$NODE_SERVER_URL/agents"),
        body: jsonEncode({"managerId": User.getCurrentUserId()}),
        headers: {'Content-Type': "application/json"});

    setState(() {
      if (response.statusCode == 200) {
        employees = jsonDecode(response.body)["agents"];
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Request error")));
      }
      _isLoading = false;
    });
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: employees.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(
                              employees[index]["name"],
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
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
