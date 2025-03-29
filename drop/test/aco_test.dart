import 'dart:math';
import 'dart:io';
import 'dart:convert';

class ACOOptimizer {
  final List<List<int>> distanceMatrix;
  final int numAnts;
  final int numIterations;
  final double alpha;
  final double beta;
  final double evaporationRate;
  final double q;

  late List<List<double>> pheromones;
  late List<int> _bestRoute;
  double _bestRouteLength = double.infinity;
  final Random random = Random();

  ACOOptimizer({
    required this.distanceMatrix,
    this.numAnts = 10,
    this.numIterations = 100,
    this.alpha = 1.0,
    this.beta = 2.0,
    this.evaporationRate = 0.5,
    this.q = 100.0,
  }) {
    _initializePheromones();
  }

  void _initializePheromones() {
    int n = distanceMatrix.length;
    pheromones = List.generate(n, (_) => List.filled(n, 1.0));
  }

  void run() {
    _bestRoute = [];
    _bestRouteLength = double.infinity;

    for (int iter = 0; iter < numIterations; iter++) {
      for (int i = 0; i < numAnts; i++) {
        List<int> route = _constructSolution();
        double routeLength = _calculateRouteLength(route);
        if (routeLength < _bestRouteLength) {
          _bestRoute = List.from(route);
          _bestRouteLength = routeLength;
        }
      }
      _updatePheromones();
    }
  }

  List<int> _constructSolution() {
    List<int> route = [0];
    Set<int> visited = {0};
    int currentNode = 0;

    while (route.length < distanceMatrix.length) {
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

    for (int j = 0; j < distanceMatrix.length; j++) {
      if (!visited.contains(j)) {
        double pheromone = pow(pheromones[currentNode][j], alpha).toDouble();
        double visibility =
            pow(1.0 / (distanceMatrix[currentNode][j] + 0.0001), beta)
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
      length += distanceMatrix[route[i]][route[i + 1]];
    }
    return length;
  }

  void _updatePheromones() {
    for (int i = 0; i < pheromones.length; i++) {
      for (int j = 0; j < pheromones.length; j++) {
        pheromones[i][j] *= (1 - evaporationRate);
      }
    }

    double depositAmount = q / _bestRouteLength;
    for (int i = 0; i < _bestRoute.length - 1; i++) {
      int from = _bestRoute[i];
      int to = _bestRoute[i + 1];
      pheromones[from][to] += depositAmount;
    }
  }

  List<int> get bestRoute => _bestRoute;
  double get bestRouteLength => _bestRouteLength;
}

List<List<List<int>>> loadTestSamples(String filename) {
  File file = File(filename);
  String jsonString = file.readAsStringSync();
  List<dynamic> decoded = jsonDecode(jsonString);
  return decoded
      .map((matrix) => (matrix as List)
          .map((row) => (row as List).map((e) => e as int).toList())
          .toList())
      .toList();
}

void benchmark() {
  List<List<List<int>>> samples = loadTestSamples('test_samples.json');
  for (var sample in samples) {
    ACOOptimizer optimizer = ACOOptimizer(distanceMatrix: sample);
    optimizer.run();
    print(
        "Size: ${sample.length}, Best Route Length: ${optimizer.bestRouteLength}");
  }
}

void main() {
  benchmark();
}
