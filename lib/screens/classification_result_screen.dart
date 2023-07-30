import 'package:flutter/material.dart';
import 'package:skripsi/models/disease_model.dart';
import 'package:skripsi/models/feature_model.dart';
import 'package:skripsi/services/classification_service.dart';
import 'package:skripsi/widgets/custom_button.dart';

class ClassificationResultScreen extends StatefulWidget {
  final String imagePath;

  const ClassificationResultScreen({super.key, required this.imagePath});

  @override
  _ClassificationResultScreenState createState() =>
      _ClassificationResultScreenState();
}

class _ClassificationResultScreenState
    extends State<ClassificationResultScreen> {
  final ClassificationService _classificationService = ClassificationService();
  bool _isLoading = true;
  String _result = '';

  @override
  void initState() {
    super.initState();
    _classifyImage();
  }

  //error disini
  void _classifyImage() async {
    try {
      FeatureModel featureModel =
          await _classificationService.extractFeatures(widget.imagePath);
      DiseaseModel? diseaseModel =
          await _classificationService.classifyDisease(widget.imagePath);
      setState(() {
        _isLoading = false;
        if (diseaseModel != null) {
          _result =
              'Hasil Klasifikasi: ${diseaseModel.name} Hasil Feature : ${featureModel.metric}';
        } else {
          _result = 'Tidak Dapat Mengklasifikasikan Penyakit';
        }
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _result = 'Terjadi kesalahan saat mengklasifikasikan gambar.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hasil Klasifikasi'),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_result),
                  SizedBox(height: 20),
                  CustomButton(
                    text: 'Kembali',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
