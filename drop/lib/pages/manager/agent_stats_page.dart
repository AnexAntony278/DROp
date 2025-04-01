import 'dart:convert';
import 'package:drop/services/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../constants/constants.dart';

class AgentStatsPage extends StatefulWidget {
  const AgentStatsPage({super.key});

  @override
  State<AgentStatsPage> createState() => _AgentStatsPageState();
}

class _AgentStatsPageState extends State<AgentStatsPage> {
  String? agentId;
  bool isLoading = true;
  Map<String, dynamic> performanceStats = {
    "performaceStats": {
      "deliveries": {
        "lastDay": {"delivered": 1, "total": 0},
        "lastWeek": {"delivered": 0, "total": 0},
        "lastMonth": {"delivered": 0, "total": 0},
        "lastYear": {"delivered": 0, "total": 0}
      },
      "packages": {"delievered": 0, "total": 0}
    }
  };

  String selectedTimeFrame = "lastDay";
  final Map<String, String> timeFrameLabels = {
    "lastDay": "Last Day",
    "lastWeek": "Last Week",
    "lastMonth": "Last Month",
    "lastYear": "Last Year",
  };

  Map<String, dynamic> deliveries = {};
  Map<String, dynamic> packages = {};
  double packagesSuccessRate = 0.0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _initializeData());
  }

  Future<void> _initializeData() async {
    agentId = ModalRoute.of(context)!.settings.arguments as String?;

    if (!await InternetServices.checkInternet() && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("No internet connection. Check connectivity")),
      );
    }
    while (!await InternetServices.checkInternet()) {
      if (!mounted) return;
      await Future.delayed(const Duration(seconds: 3));
    }

    final response = await http.get(
        Uri.parse(
            "$NODE_SERVER_URL/performance?agentId=${agentId ?? '67eb9bffb16c499eb8697cdc'}"),
        headers: {'Content-Type': 'application/json'});

    if (mounted) {
      setState(() {
        performanceStats = jsonDecode(response.body);
        deliveries = performanceStats['performaceStats']['deliveries'];
        packages = performanceStats['performaceStats']['packages'];
        packagesSuccessRate = packages['total'] > 0
            ? packages['delievered'] / packages['total']
            : 0.0;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Performance Statistics'),
      ),
      body: (performanceStats.isEmpty || isLoading)
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Packages Performance',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${packages['delivered']} delivered / ${packages['total']} total',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Success Rate: ${(packagesSuccessRate * 100).toStringAsFixed(2)}%',
                                  style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          CircularPercentIndicator(
                            radius: 60.0,
                            lineWidth: 30.0,
                            percent: packagesSuccessRate,
                            center: Text(
                                '${(packagesSuccessRate * 100).toStringAsFixed(0)}%'),
                            progressColor: Colors.green,
                            backgroundColor: Colors.grey.shade300,
                            circularStrokeCap: CircularStrokeCap.round,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Deliveries by Time',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      DropdownButton<String>(
                        value: selectedTimeFrame,
                        items: timeFrameLabels.entries.map((entry) {
                          return DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedTimeFrame = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  const Divider(),
                  buildTimeFrameCard(timeFrameLabels[selectedTimeFrame]!,
                      deliveries[selectedTimeFrame], context),
                ],
              ),
            ),
    );
  }

  Widget buildTimeFrameCard(
      String title, Map<String, dynamic> data, BuildContext context) {
    int delivered = data['delivered'];
    int total = data['total'];
    double rate = total > 0 ? delivered / total : 0.0;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Text details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Delivered: $delivered / Total: $total',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Success Rate: ${(rate * 100).toStringAsFixed(2)}%',
                    style: const TextStyle(fontSize: 16, color: Colors.green),
                  ),
                ],
              ),
            ),
            // Circular Progress
            CircularPercentIndicator(
              radius: MediaQuery.of(context).size.height *
                  0.05, // Adjust dynamically
              lineWidth: 20.0, // Thicker border
              percent: rate,
              center: Text(
                '${(rate * 100).toStringAsFixed(0)}%',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              progressColor: Colors.blueAccent,
              backgroundColor: Colors.grey.shade300,
              circularStrokeCap: CircularStrokeCap.round,
            ),
          ],
        ),
      ),
    );
  }
}
