import 'dart:math';
import 'dart:io';
import 'dart:convert';

List<List<List<int>>> generateTestSamples() {
  List<List<List<int>>> testSamples = [];
  Random random = Random();

  for (int size = 60; size <= 120; size += 10) {
    List<List<int>> matrix = List.generate(
        size,
        (_) => List.generate(
            size,
            (_) =>
                random.nextInt(1000) + 1 // Random distance between 1 and 1000
            ));
    testSamples.add(matrix);
  }

  return testSamples;
}

void saveToFile(List<List<List<int>>> samples, String filename) {
  File file = File(Directory.current.path + Platform.pathSeparator + filename);
  String jsonString = jsonEncode(samples);
  file.writeAsStringSync(jsonString);
}

void main() {
  var samples = generateTestSamples();
  saveToFile(samples, 'test_samples.json');
  print('Test samples saved to test_samples.dart in the current directory.');
}
