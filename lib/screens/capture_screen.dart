// lib/screens/capture_screen.dart

import 'package:flutter/material.dart';
import 'package:skripsi/screens/classification_result_screen.dart';
import 'package:skripsi/services/camera_service.dart';
import 'package:skripsi/widgets/custom_button.dart';

class CaptureScreen extends StatelessWidget {
  final CameraService _cameraService = CameraService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Capture Gambar'),
      ),
      body: Center(
        child: CustomButton(
          text: 'Ambil Gambar',
          onPressed: () async {
            String imagePath = await _cameraService.captureImage();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ClassificationResultScreen(imagePath: imagePath),
              ),
            );
          },
        ),
      ),
    );
  }
}
