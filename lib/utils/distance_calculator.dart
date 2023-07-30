import 'dart:math';

class DistanceCalculator {
  static double calculateEuclideanDistance(
      List<double> dataPoint1, List<double> dataPoint2) {
    if (dataPoint1.length != dataPoint2.length) {
      throw Exception('Data points must have the same dimension.');
    }

    double sumSquaredDifferences = 0;
    for (int i = 0; i < dataPoint1.length; i++) {
      double difference = dataPoint1[i] - dataPoint2[i];
      sumSquaredDifferences += pow(difference, 2);
    }

    return sqrt(sumSquaredDifferences);
  }
}
