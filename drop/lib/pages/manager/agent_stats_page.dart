import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class AgentStatsPage extends StatefulWidget {
  const AgentStatsPage({super.key});

  @override
  State<AgentStatsPage> createState() => _AgentStatsPageState();
}

class _AgentStatsPageState extends State<AgentStatsPage> {
  late String agentId;
  late Map<String, dynamic> performanceStats;

  String selectedTimeFrame = "lastDay";
  final Map<String, String> timeFrameLabels = {
    "lastDay": "Last Day",
    "lastWeek": "Last Week",
    "lastMonth": "Last Month",
    "lastYear": "Last Year",
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Now it's safe to use ModalRoute.of(context)
    final arguments = ModalRoute.of(context)?.settings.arguments as Map?;
    if (arguments != null) {
      setState(() {
        agentId = arguments['agentId'] ?? '';
      });
      fetchData(agentId); // Fetch data using the agentId
    }
  }

  // Function to fetch data based on the agentId
  void fetchData(String agentId) async {
    // You can replace this with an actual API call
    // Example:
    setState(() {
      performanceStats = {
        "deliveries": {
          "lastDay": {"delivered": 1, "total": 5},
          "lastWeek": {"delivered": 2, "total": 10},
          "lastMonth": {"delivered": 8, "total": 20},
          "lastYear": {"delivered": 30, "total": 50},
        },
        "packages": {"delivered": 23, "total": 132}
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final deliveries = performanceStats['deliveries'] as Map<String, dynamic>;
    final packages = performanceStats['packages'] as Map<String, dynamic>;
    double packagesSuccessRate =
        packages['total'] > 0 ? packages['delivered'] / packages['total'] : 0.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Performance Statistics'),
      ),
      body: performanceStats.isEmpty
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loading indicator while data is being fetched
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
