import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'package:intl/intl.dart';
// Ajouter ces imports
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'favorites_screen.dart';
import 'plant_details_screen.dart';
import 'ToxicityWarningWidget.dart';
import 'remedies_page.dart';
import 'history_page.dart';
import 'profile_screen.dart';
// Import models and repositories
import '../models/identification_history.dart';
import '../models/plant.dart';
import '../repositories/identification_history_repository.dart';
import '../repositories/plant_repository.dart';



class ImageClassificationWidget extends StatefulWidget {
  final int userId;
  
  const ImageClassificationWidget({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<ImageClassificationWidget> createState() => _ImageClassificationWidgetState();
}

int _currentIndex = 0;



class _ImageClassificationWidgetState extends State<ImageClassificationWidget> {
  File? _selectedImage;
  late final ImagePicker _picker;
  Interpreter? _interpreter;
  String _predictionResult = 'No image selected.';
  final int inputSize = 224;

  // Repositories
  final IdentificationHistoryRepository _historyRepository = IdentificationHistoryRepository();
  final PlantRepository _plantRepository = PlantRepository();


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

  // Ajouter ces variables d'état dans la classe _ImageClassificationWidgetState
  Map<String, dynamic>? _currentPlantData;
  bool _isToxic = false;
  String? _toxicParts;
  List<String> _toxicEffects = [];

// Ajouter cette méthode pour charger les données de toxicité
  Future<void> _loadPlantToxicityData(String plantName) async {
    try {
      final String response = await rootBundle.loadString('assets/plants_data.json');
      final List<dynamic> data = json.decode(response);

      // Rechercher la plante dans les données JSON
      final plantData = data.firstWhere(
            (plant) => plant['name'] == plantName,
        orElse: () => null,
      );

      if (plantData != null) {
        setState(() {
          _currentPlantData = plantData;

          // Extraire les données de toxicité
          final toxicity = plantData['toxicity'];
          _isToxic = toxicity['is_toxic'] ?? false;
          _toxicParts = toxicity['toxic_parts'];
          _toxicEffects = List<String>.from(toxicity['effects'] ?? []);
        });
      } else {
        setState(() {
          _currentPlantData = null;
          _isToxic = false;
          _toxicParts = null;
          _toxicEffects = [];
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading plant data: $e');
      setState(() {
        _currentPlantData = null;
        _isToxic = false;
        _toxicParts = null;
        _toxicEffects = [];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _picker = ImagePicker();
    _loadModel();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0: // Home - already on this page
        break;
      case 1: // Favorites
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FavoritesScreen()),
        );
        break;
      case 2: // History
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HistoryPage()),
        );
        break;
      case 3: // Profile
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen(userId: widget.userId)),
        );
        break;
    }
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/model_compatible1.tflite');
      debugPrint('✅ Model loaded successfully.');
    } catch (e) {
      debugPrint('❌ Error loading model: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _predictionResult = '⏳ Predicting...';
      });
      await _runModelOnImage(_selectedImage!);
    }
  }

  Future<void> _runModelOnImage(File imageFile) async {
    if (_interpreter == null) {
      setState(() => _predictionResult = "❌ Model not loaded.");
      return;
    }

    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image == null) {
      setState(() => _predictionResult = "❌ Couldn't read image.");
      return;
    }

    final resizedImage = img.copyResize(image, width: inputSize, height: inputSize);

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
    final output = List.filled(_classNames.length, 0.0).reshape([1, _classNames.length]);

    try {
      _interpreter!.run(inputTensor, output);

      final List<double> probabilities = List<double>.from(output[0]);
      final maxProb = probabilities.reduce((a, b) => a > b ? a : b);
      final predictedIndex = probabilities.indexOf(maxProb);
      final predictedClass = _classNames[predictedIndex];

      setState(() {
        _predictionResult =
        "✅ Predicted: $predictedClass";
      });
    } catch (e) {
      setState(() => _predictionResult = "❌ Inference error: $e");
    }

    try {
      _interpreter!.run(inputTensor, output);

      final List<double> probabilities = List<double>.from(output[0]);
      final maxProb = probabilities.reduce((a, b) => a > b ? a : b);
      final predictedIndex = probabilities.indexOf(maxProb);
      final predictedClass = _classNames[predictedIndex];

      // Charger les données de toxicité pour la plante identifiée
      await _loadPlantToxicityData(predictedClass);

      setState(() {
        _predictionResult = "✅ Predicted: $predictedClass";
      });
      // --- Save to History ---
      await _saveIdentificationToHistory(predictedClass, imageFile.path);
      // -----------------------

    } catch (e) {
      setState(() => _predictionResult = "❌ Inference error: $e");
    }
  }
  // --- New Method to Save History ---
  Future<void> _saveIdentificationToHistory(String plantName, String imagePath) async {
    debugPrint('--- Attempting to save history for: $plantName ---'); // <-- AJOUTER
    try {
      List<Plant> plants = await _plantRepository.searchPlants(plantName);
      debugPrint('Found plants matching search: ${plants.map((p) => p.commonName).toList()}'); // <-- AJOUTER
      Plant? identifiedPlant;
      if (plants.isNotEmpty) {
        identifiedPlant = plants.firstWhere(
              (p) => p.commonName.toLowerCase() == plantName.toLowerCase(),
          orElse: () {
            debugPrint('Exact match not found, using first result: ${plants.first.commonName}'); // <-- AJOUTER
            return plants.first;
          },
        );
      }

      debugPrint('Identified Plant for history: ${identifiedPlant?.commonName} (ID: ${identifiedPlant?.plantId})'); // <-- AJOUTER

      if (identifiedPlant?.plantId != null) {
        final historyRecord = IdentificationHistory(
          plantId: identifiedPlant!.plantId!,
          imagePath: imagePath,
          identificationDate: DateTime.now().toIso8601String(),
          wasToxic: _isToxic,
        );
        debugPrint('History record to save: ${historyRecord.toMap()}'); // <-- AJOUTER
        await _historyRepository.addHistoryRecord(historyRecord);
        debugPrint('✅ Identification history saved successfully for $plantName.'); // <-- AJOUTER
      } else {
        debugPrint('❌ Plant "$plantName" not found in database. History not saved.'); // <-- Message existant
      }
    } catch (e) {
      debugPrint('❌ Error saving identification history: $e'); // <-- Message existant
    }
    debugPrint('--- Finished attempting to save history for: $plantName ---'); // <-- AJOUTER
  }

// Méthode pour extraire le nom de la plante du résultat de prédiction
  String? _extractPlantName(String predictionResult) {
    // Format attendu: "✅ Predicted: NomPlante"
    if (predictionResult.contains("Predicted:")) {
      return predictionResult.split("Predicted:").last.trim();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2E7D3),
      appBar: AppBar(
        title: const Text(
          'Plant Identification',
          style: TextStyle(
            color: Color(0xFFF2E7D3),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF499265),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                color: const Color(0xFFBCE7B4),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _selectedImage!,
                                height: 250,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate,
                                    size: 64,
                                    color: Color(0xFFAF8447),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Select an image to identify a plant',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFFAF8447),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      const SizedBox(height: 16),
                      Text(
                        _predictionResult,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF499265),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_predictionResult.contains("Predicted:"))
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF499265),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                              minimumSize: const Size(200, 45),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.info_outline),
                            label: const Text(
                              "Plus de détails",
                              style: TextStyle(fontSize: 16),
                            ),
                            onPressed: () {
                              final plantName = _extractPlantName(_predictionResult);
                              if (plantName != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlantDetailsScreen(plantName: plantName),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (_currentPlantData != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ToxicityWarningWidget(
                    isToxic: _isToxic,
                    toxicParts: _toxicParts,
                    effects: _toxicEffects,
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF87CB7C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.image),
                label: const Text(
                  "Choose from Gallery",
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () => _pickImage(ImageSource.gallery),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD9B17D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.camera_alt),
                label: const Text(
                  "Take a Photo",
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () => _pickImage(ImageSource.camera),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF499265),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.healing),
                label: const Text(
                  "Remedies Guide",
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RemediesPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF499265),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.6),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}