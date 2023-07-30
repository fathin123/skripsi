import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:csv/csv.dart';
import 'package:skripsi/models/disease_model.dart';
import 'package:skripsi/models/feature_model.dart';
import 'package:color/color.dart';

class DistanceCalculator {
  static double euclideanDistance(FeatureModel model1, FeatureModel model2) {
    double distance = sqrt(
      pow(model1.meanH - model2.meanH, 2) +
          pow(model1.meanS - model2.meanS, 2) +
          pow(model1.meanV - model2.meanV, 2) +
          pow(model1.eccentricity - model2.eccentricity, 2),
    );

    return distance;
  }
}

class ClassificationService {
  Future<FeatureModel> extractFeatures(String imagePath) async {
    // Load the image from the file path
    final File imageFile = File(imagePath);
    final List<int> imageBytes = await imageFile.readAsBytes();
    final img.Image? image = img.decodeImage(imageBytes);

    if (image == null) {
      throw Exception('Error loading image.');
    }

    // Extract HSV color features
    double sumH = 0.0;
    double sumS = 0.0;
    double sumV = 0.0;
    int pixelCount = 0;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        // Extract the red, green, and blue components from the pixel value
        int red = img.getRed(pixel);
        int green = img.getGreen(pixel);
        int blue = img.getBlue(pixel);

        final color = RgbColor(
            red, green, blue); // Use color package for RGB to HSV conversion
        final hsv = color.toHsvColor();
        sumH += hsv.h;
        sumS += hsv.s;
        sumV += hsv.v;
        pixelCount++;
      }
    }

    if (pixelCount == 0) {
      throw Exception('No pixels found in the image.');
    }

    double meanH = sumH / pixelCount;
    double meanS = sumS / pixelCount;
    double meanV = sumV / pixelCount;

    // Extract eccentricity feature (assuming the image is grayscale)
    double eccentricity = calculateEccentricity(image);

    // Create a FeatureModel object with the extracted features
    return FeatureModel(
      meanH: meanH,
      meanS: meanS,
      meanV: meanV,
      eccentricity: eccentricity,
      metric: 0.0, // Replace this with an appropriate metric value if needed
    );
  }

  double calculateEccentricity(img.Image image) {
    double maxDistance = 0.0;
    int centerX = image.width ~/ 2;
    int centerY = image.height ~/ 2;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final grayscaleValue = img.getRed(pixel);

        // Assuming the image is grayscale, calculate distance from the center
        final distance = sqrt(pow(x - centerX, 2) + pow(y - centerY, 2));

        // Update maxDistance if the current distance is greater
        if (distance > maxDistance) {
          maxDistance = distance;
        }
      }
    }

    // Calculate eccentricity (ratio of maximum distance to half of the major axis)
    double majorAxis = max(image.width, image.height).toDouble();
    double minorAxis = min(image.width, image.height).toDouble();
    return maxDistance / (majorAxis / 2);
  }

  Future<DiseaseModel?> classifyDisease(String imagePath) async {
    // Extract features from the image
    final FeatureModel featureModel = await extractFeatures(imagePath);

    // Read data from the alhamdullilah.csv file
    final File csvFile = File('alhamdullilah.csv');
    final List<List<dynamic>> csvData = await csvFile.readAsLines().then(
          (lines) => lines.map((line) => line.split(',')).toList(),
        );

    // Parse CSV data into a list of FeatureModel objects
    List<FeatureModel> dataPoints = [];
    for (var row in csvData.skip(1)) {
      if (row.length == 5) {
        double meanH = double.parse(row[0]);
        double meanS = double.parse(row[1]);
        double meanV = double.parse(row[2]);
        double eccentricity = double.parse(row[3]);
        double metric = double.parse(row[4]);

        dataPoints.add(
          FeatureModel(
            meanH: meanH,
            meanS: meanS,
            meanV: meanV,
            eccentricity: eccentricity,
            metric: metric,
          ),
        );
      }
    }

    if (dataPoints.isEmpty) {
      return null; // Return null if no data points are available.
    }

    // Calculate Euclidean distance and find the closest match
    double minDistance = double.infinity;
    DiseaseModel? closestDisease;

    for (var disease in dataPoints) {
      double distance =
          DistanceCalculator.euclideanDistance(featureModel, disease);
      if (distance < minDistance) {
        minDistance = distance;
        closestDisease = DiseaseModel(
          name:
              'Disease Name', // Replace this with the disease name from the CSV file
          description:
              'Disease Description', // Replace this with the disease description from the CSV file
        );
      }
    }

    return closestDisease;
  }
}
