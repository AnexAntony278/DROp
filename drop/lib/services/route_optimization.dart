import 'dart:math';
import 'package:drop/models/delivery_schema.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// ACO Algorithm adapted for Delivery routing problem
class ACO {
  final int numberOfAnts;
  final int numberOfDeliveries;
  final double alpha; // Pheromone importance
  final double beta; // Distance priority
  final double evaporationRate; // Pheromone evaporation rate
  final double q; // Pheromone deposit factor
  final List<Delivery> deliveries;
  late List<List<double>> distanceMatrix;

  late List<List<double>> pheromones;
  late List<int> bestTour;
  late double bestTourLength;

  ACO({
    required this.numberOfAnts,
    required this.numberOfDeliveries,
    required this.alpha,
    required this.beta,
    required this.evaporationRate,
    required this.q,
    required this.deliveries,
  }) {
    // Calculate distance matrix based on delivery locations.
    distanceMatrix = List.generate(
      numberOfDeliveries,
      (_) => List.filled(numberOfDeliveries, 0.0),
    );
    _calculateDistanceMatrix();

    pheromones = List.generate(
      numberOfDeliveries,
      (_) => List.filled(numberOfDeliveries, 1.0),
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

  // Construct a solution for one ant (delivery route).
  List<int> _constructSolution() {
    List<int> tour = [];
    Set<int> visited = {};

    int startDelivery = Random().nextInt(numberOfDeliveries);
    tour.add(startDelivery);
    visited.add(startDelivery);

    for (int step = 1; step < numberOfDeliveries; step++) {
      int currentDelivery = tour.last;
      int nextDelivery = _selectNextCity(currentDelivery, visited);
      tour.add(nextDelivery);
      visited.add(nextDelivery);
    }

    return tour;
  }

  // Select the next city based on pheromones and distance.
  int _selectNextCity(int currentDelivery, Set<int> visited) {
    List<double> probabilities = [];
    double total = 0.0;

    for (int delivery = 0; delivery < numberOfDeliveries; delivery++) {
      if (visited.contains(delivery)) {
        probabilities.add(0.0);
      } else {
        double pheromone = pheromones[currentDelivery][delivery];
        double distance = distanceMatrix[currentDelivery][delivery];
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

    for (int delivery = 0; delivery < numberOfDeliveries; delivery++) {
      cumulative += probabilities[delivery];
      if (randomValue <= cumulative) {
        return delivery;
      }
    }

    return 0; // Fallback, should not happen
  }

  // Calculate the total length of the tour (delivery route).
  double _calculateTourLength(List<int> tour) {
    double length = 0.0;

    for (int i = 0; i < tour.length - 1; i++) {
      length += distanceMatrix[tour[i]][tour[i + 1]];
    }

    // Return to the starting delivery location
    length += distanceMatrix[tour.last][tour.first];

    return length;
  }

  // Update pheromones based on all ants' tours.
  void _updatePheromones(
      List<List<int>> allTours, List<double> allTourLengths) {
    // Evaporate pheromones
    for (int i = 0; i < numberOfDeliveries; i++) {
      for (int j = 0; j < numberOfDeliveries; j++) {
        pheromones[i][j] *= (1 - evaporationRate);
      }
    }

    // Deposit new pheromones based on each tour
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

  // Calculate distance matrix based on delivery locations.
  void _calculateDistanceMatrix() {
    for (int i = 0; i < numberOfDeliveries; i++) {
      for (int j = i + 1; j < numberOfDeliveries; j++) {
        double distance = _calculateDistance(
            deliveries[i].locationLatLng, deliveries[j].locationLatLng);
        distanceMatrix[i][j] = distanceMatrix[j][i] = distance;
      }
    }
  }

  // Calculate the distance between two coordinates (Haversine formula).
  double _calculateDistance(LatLng a, LatLng b) {
    const R = 6371; // Radius of the Earth in km
    final lat1 = a.latitude * pi / 180;
    final lon1 = a.longitude * pi / 180;
    final lat2 = b.latitude * pi / 180;
    final lon2 = b.longitude * pi / 180;

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final aFormula = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(aFormula), sqrt(1 - aFormula));

    return R * c; // Distance in km
  }
}

void main() {
  // Example delivery locations with coordinates.
  List<Delivery> deliveries = Delivery.sampleData;

  ACO aco = ACO(
    numberOfAnts: 10,
    numberOfDeliveries: deliveries.length,
    alpha: 1.0,
    beta: 2.0,
    evaporationRate: 0.5,
    q: 100.0,
    deliveries: deliveries,
  );

  aco.optimize(20); // Number of iterations
  print("Best Tour: ${aco.bestTour}");
  print("Best Tour Length: ${aco.bestTourLength} km");
}
