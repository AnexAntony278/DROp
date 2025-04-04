import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:drop/constants/constants.dart';

class AgentStatsPage extends StatefulWidget {
  const AgentStatsPage({super.key});

  @override
  State<AgentStatsPage> createState() => _AgentStatsPageState();
}

class _AgentStatsPageState extends State<AgentStatsPage> {
  Future<Map<String, dynamic>>? agentStats;
  late Map<String, dynamic> agent;

  @override
  void initState() {
    super.initState();
    // Initialize agentStats once agent is assigned in didChangeDependencies.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    if (routeArgs is Map<String, dynamic>) {
      agent = routeArgs;
      setState(() {
        agentStats = fetchAgentStats();
      });
    } else {
      agent = {};
    }
  }

  Future<Map<String, dynamic>> fetchAgentStats() async {
    final response = await http.get(
      Uri.parse("$NODE_SERVER_URL/performance?agentId=${agent["_id"]}"),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error fetching data: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Performance Statistics'),
      ),
      body: agentStats == null
          ? const Center(child: Text("No agent data available"))
          : FutureBuilder<Map<String, dynamic>>(
              future: agentStats,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No data available"));
                }

                final stats = snapshot.data!['performanceStats'];
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          "Deliveries Today: ${stats['deliveries']['lastDay']['delivered']} / ${stats['deliveries']['lastDay']['total']}"),
                      Text(
                          "Packages Delivered: ${stats['packages']['delivered']} / ${stats['packages']['total']}"),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
