import 'dart:math';

class ACO {
  final int numberOfAnts;
  final int numberOfCities;
  final double alpha; // Pheromone importance
  final double beta; // Distance priority
  final double evaporationRate; // Pheromone evaporation rate
  final double q; // Pheromone deposit factor
  final List<List<double>> distanceMatrix;

  late List<List<double>> pheromones;
  late List<int> bestTour;
  late double bestTourLength;

  ACO({
    required this.numberOfAnts,
    required this.numberOfCities,
    required this.alpha,
    required this.beta,
    required this.evaporationRate,
    required this.q,
    required this.distanceMatrix,
  }) {
    pheromones = List.generate(
      numberOfCities,
      (_) => List.filled(numberOfCities, 1.0),
    );
    bestTour = [];
    bestTourLength = double.infinity;
  }

  void optimize(int iterations) {
    for (int iter = 0; iter < iterations; iter++) {
      List<List<int>> allTours = [];
      List<double> allTourLengths = [];

      for (int ant = 0; ant < numberOfAnts; ant++) {
        List<int> tour = _constructSolution();
        double tourLength = _calculateTourLength(tour);

        allTours.add(tour);
        allTourLengths.add(tourLength);

        if (tourLength < bestTourLength) {
          bestTour = tour;
          bestTourLength = tourLength;
        }
      }

      _updatePheromones(allTours, allTourLengths);
      print("Iteration $iter, Best Length: $bestTourLength");
    }
  }

  List<int> _constructSolution() {
    List<int> tour = [];
    Set<int> visited = {};

    int startCity = Random().nextInt(numberOfCities);
    tour.add(startCity);
    visited.add(startCity);

    for (int step = 1; step < numberOfCities; step++) {
      int currentCity = tour.last;
      int nextCity = _selectNextCity(currentCity, visited);
      tour.add(nextCity);
      visited.add(nextCity);
    }

    return tour;
  }

  int _selectNextCity(int currentCity, Set<int> visited) {
    List<double> probabilities = [];
    double total = 0.0;

    for (int city = 0; city < numberOfCities; city++) {
      if (visited.contains(city)) {
        probabilities.add(0.0);
      } else {
        double pheromone = pheromones[currentCity][city];
        double distance = distanceMatrix[currentCity][city];
        double desirability =
            (pow(pheromone, alpha) * pow(1 / distance, beta)).toDouble();

        probabilities.add(desirability);
        total += desirability;
      }
    }

    // Normalize probabilities
    probabilities = probabilities.map((p) => p / total).toList();

    // Roulette wheel selection
    double randomValue = Random().nextDouble();
    double cumulative = 0.0;

    for (int city = 0; city < numberOfCities; city++) {
      cumulative += probabilities[city];
      if (randomValue <= cumulative) {
        return city;
      }
    }

    return 0; // Fallback, should not happen
  }

  double _calculateTourLength(List<int> tour) {
    double length = 0.0;

    for (int i = 0; i < tour.length - 1; i++) {
      length += distanceMatrix[tour[i]][tour[i + 1]];
    }

    // Return to the starting city
    length += distanceMatrix[tour.last][tour.first];

    return length;
  }

  void _updatePheromones(
      List<List<int>> allTours, List<double> allTourLengths) {
    // Evaporate pheromones
    for (int i = 0; i < numberOfCities; i++) {
      for (int j = 0; j < numberOfCities; j++) {
        pheromones[i][j] *= (1 - evaporationRate);
      }
    }

    // Deposit new pheromones
    for (int t = 0; t < allTours.length; t++) {
      List<int> tour = allTours[t];
      double length = allTourLengths[t];

      double pheromoneDeposit = q / length;
      for (int i = 0; i < tour.length - 1; i++) {
        pheromones[tour[i]][tour[i + 1]] += pheromoneDeposit;
        pheromones[tour[i + 1]][tour[i]] +=
            pheromoneDeposit; // For undirected graph
      }

      // Complete the cycle
      pheromones[tour.last][tour.first] += pheromoneDeposit;
      pheromones[tour.first][tour.last] += pheromoneDeposit;
    }
  }
}

void main() {
  // Example: Distance matrix for 4 cities
  List<List<double>> distanceMatrix = [
    [0, 34, 78, 56, 89, 23, 45, 67, 12, 90],
    [34, 0, 47, 58, 90, 21, 34, 88, 50, 65],
    [78, 47, 0, 36, 72, 49, 60, 77, 35, 85],
    [56, 58, 36, 0, 54, 67, 48, 33, 64, 73],
    [89, 90, 72, 54, 0, 43, 22, 55, 88, 41],
    [23, 21, 49, 67, 43, 0, 29, 39, 19, 60],
    [45, 34, 60, 48, 22, 29, 0, 31, 40, 52],
    [67, 88, 77, 33, 55, 39, 31, 0, 28, 47],
    [12, 50, 35, 64, 88, 19, 40, 28, 0, 70],
    [90, 65, 85, 73, 41, 60, 52, 47, 70, 0],
  ];

  ACO aco = ACO(
    numberOfAnts: 10,
    numberOfCities: distanceMatrix.length,
    alpha: 1.0,
    beta: 2.0,
    evaporationRate: 0.5,
    q: 100.0,
    distanceMatrix: distanceMatrix,
  );

  aco.optimize(20); // Number of iterations
  print("Best Tour: ${aco.bestTour}");
  print("Best Tour Length: ${aco.bestTourLength}");
}
