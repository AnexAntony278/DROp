import 'dart:math';
import 'package:drop/models/route_schema.dart';

class ACOOptimizer {
  final DeliveryRoute deliveryRoute;
  final int numAnts;
  final int numIterations;
  final double alpha;
  final double beta;
  final double evaporationRate;
  final double q;

  late List<List<double>> pheromones;
  final Random random = Random();

  ACOOptimizer({
    required this.deliveryRoute,
    this.numAnts = 20,
    this.numIterations = 200,
    this.alpha = 1.0,
    this.beta = 8.0,
    this.evaporationRate = 0.7,
    this.q = 200.0,
  }) {
    _initializePheromones();
  }

  void _initializePheromones() {
    pheromones = List.generate(
      deliveryRoute.distanceMatrix.length,
      (i) => List.filled(deliveryRoute.distanceMatrix.length, 1.0),
    );
  }

  void optimize() {
    List<int> bestRoute = [];
    double bestRouteLength = double.infinity;

    for (int iter = 0; iter < numIterations; iter++) {
      List<List<int>> antRoutes = [];
      List<double> routeLengths = [];

      for (int i = 0; i < numAnts; i++) {
        List<int> route = _constructSolution();
        double routeLength = _calculateRouteLength(route);
        antRoutes.add(route);
        routeLengths.add(routeLength);

        if (routeLength < bestRouteLength) {
          bestRoute = List.from(route);
          bestRouteLength = routeLength;
        }
      }

      _updatePheromones(antRoutes, routeLengths);
    }
    bestRoute.remove(0);
    deliveryRoute.deliveries = bestRoute
        .map(
          (i) => deliveryRoute.deliveries[i - 1],
        )
        .toList();
  }

  List<int> _constructSolution() {
    List<int> route = [0];
    Set<int> visited = {0};
    int currentNode = 0;

    while (route.length < deliveryRoute.distanceMatrix.length) {
      int nextNode = _selectNextNode(currentNode, visited);
      route.add(nextNode);
      visited.add(nextNode);
      currentNode = nextNode;
    }

    return route;
  }

  int _selectNextNode(int currentNode, Set<int> visited) {
    List<double> probabilities = [];
    double total = 0.0;

    for (int j = 0; j < deliveryRoute.distanceMatrix.length; j++) {
      if (!visited.contains(j)) {
        double pheromone = pow(pheromones[currentNode][j], alpha).toDouble();
        double visibility = pow(
                1.0 / (deliveryRoute.distanceMatrix[currentNode][j] + 0.0001),
                beta)
            .toDouble();
        double probability = pheromone * visibility;
        probabilities.add(probability);
        total += probability;
      } else {
        probabilities.add(0);
      }
    }

    double rand = random.nextDouble() * total;
    double cumulative = 0.0;
    for (int j = 0; j < probabilities.length; j++) {
      cumulative += probabilities[j];
      if (rand <= cumulative) {
        return j;
      }
    }

    return probabilities.indexWhere((p) => p > 0);
  }

  double _calculateRouteLength(List<int> route) {
    double length = 0.0;
    for (int i = 0; i < route.length - 1; i++) {
      length += deliveryRoute.distanceMatrix[route[i]][route[i + 1]];
    }
    return length;
  }

  void _updatePheromones(List<List<int>> routes, List<double> routeLengths) {
    for (int i = 0; i < pheromones.length; i++) {
      for (int j = 0; j < pheromones.length; j++) {
        pheromones[i][j] *= (1 - evaporationRate);
      }
    }

    for (int k = 0; k < routes.length; k++) {
      double depositAmount = q / routeLengths[k];
      for (int i = 0; i < routes[k].length - 1; i++) {
        int from = routes[k][i];
        int to = routes[k][i + 1];
        pheromones[from][to] += depositAmount;
      }
    }
  }
}
