import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

class ImageClassificationWidget extends StatefulWidget {
  const ImageClassificationWidget({Key? key}) : super(key: key);

  @override
  State<ImageClassificationWidget> createState() => _ImageClassificationWidgetState();
}

class _ImageClassificationWidgetState extends State<ImageClassificationWidget> {
  File? _selectedImage;
  late final ImagePicker _picker;
  Interpreter? _interpreter;
  String _predictionResult = 'Aucune image sélectionnée.';
  final int inputSize = 224;

  final List<String> _classNames = [
    'Aloevera', 'Amla', 'Amruthaballi', 'Arali', 'Astma_weed', 'Badipala', 'Balloon_Vine', 'Bamboo',
    'Beans', 'Betel', 'Bhrami', 'Bringaraja', 'Caricature', 'Castor', 'Catharanthus', 'Chakte',
    'Chilly', 'Citron lime (herelikai)', 'Coffee', 'Common rue(naagdalli)', 'Coriender', 'Curry',
    'Doddpathre', 'Drumstick', 'Ekka', 'Eucalyptus', 'Ganigale', 'Ganike', 'Gasagase', 'Ginger',
    'Globe Amarnath', 'Guava', 'Henna', 'Hibiscus', 'Honge', 'Insulin', 'Jackfruit', 'Jasmine',
    'Kambajala', 'Kasambruga', 'Kohlrabi', 'Lantana', 'Lemon', 'Lemongrass', 'Malabar_Nut',
    'Malabar_Spinach', 'Mango', 'Marigold', 'Mint', 'Neem', 'Nelavembu', 'Nerale', 'Nooni', 'Onion',
    'Padri', 'Palak(Spinach)', 'Papaya', 'Parijatha', 'Pea', 'Pepper', 'Pomoegranate', 'Pumpkin',
    'Raddish', 'Rose', 'Sampige', 'Sapota', 'Seethaashoka', 'Seethapala', 'Spinach1', 'Tamarind',
    'Taro', 'Tecoma', 'Thumbe', 'Tomato', 'Tulsi', 'Turmeric', 'ashoka', 'camphor', 'kamakasturi',
    'kepala'
  ];

  @override
  void initState() {
    super.initState();
    _picker = ImagePicker();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/model_compatible1.tflite');
      debugPrint('✅ Modèle chargé avec succès.');
    } catch (e) {
      debugPrint('❌ Erreur de chargement du modèle : $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _predictionResult = '⏳ Prédiction en cours...';
      });
      await _runModelOnImage(_selectedImage!);
    }
  }

  Future<void> _runModelOnImage(File imageFile) async {
    if (_interpreter == null) {
      setState(() => _predictionResult = "❌ Modèle non chargé.");
      return;
    }

    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image == null) {
      setState(() => _predictionResult = "❌ Impossible de lire l'image.");
      return;
    }

    // Redimensionner l'image
    final resizedImage = img.copyResize(image, width: inputSize, height: inputSize);

    // Normaliser et convertir en Float32
    final input = Float32List(inputSize * inputSize * 3);
    int index = 0;
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = resizedImage.getPixel(x, y);
        input[index++] = img.getRed(pixel) / 1.0;
        input[index++] = img.getGreen(pixel) / 1.0;
        input[index++] = img.getBlue(pixel) / 1.0;
      }
    }

    final inputTensor = input.reshape([1, inputSize, inputSize, 3]);

    // Créer un tableau de sortie
    final output = List.filled(_classNames.length, 0.0).reshape([1, _classNames.length]);

    try {
      _interpreter!.run(inputTensor, output);

      final List<double> probabilities = List<double>.from(output[0]);
      final maxProb = probabilities.reduce((a, b) => a > b ? a : b);
      final predictedIndex = probabilities.indexOf(maxProb);
      final predictedClass = _classNames[predictedIndex];

      setState(() {
        _predictionResult =
        "✅ Classe prédite : $predictedClass\n🔍 Confiance : ${(maxProb * 100).toStringAsFixed(2)}%";
      });
    } catch (e) {
      setState(() => _predictionResult = "❌ Erreur d'inférence : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _selectedImage != null
              ? Image.file(_selectedImage!, height: 250)
              : const Text('📷 Veuillez sélectionner une image'),
          const SizedBox(height: 16),
          Text(_predictionResult, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.image),
            label: const Text("Depuis la Galerie"),
            onPressed: () => _pickImage(ImageSource.gallery),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text("Depuis la Caméra"),
            onPressed: () => _pickImage(ImageSource.camera),
          ),
        ],
      ),
    );
  }
}
