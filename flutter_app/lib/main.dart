import 'package:flutter/material.dart';
import 'package:flutter_app/screens/welcome/welcome_page.dart';
import '../database/database_helper.dart';
import '../screens/auth/auth_wrapper.dart';
import '../services/data_importer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Show loading screen immediately
  runApp(const LoadingApp());

  try {
    // Initialize database
    final databaseHelper = DatabaseHelper();
    await databaseHelper.database;

    // Import initial data
    final dataImporter = DataImporter();
    await dataImporter.importInitialData();

    runApp(const MedicinalPlantsApp());
  } catch (e) {
    debugPrint('Error initializing app: $e');
    runApp(ErrorApp(error: e.toString()));
  }
}

class LoadingApp extends StatelessWidget {
  const LoadingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Initializing Medicinal Plants App...'),
            ],
          ),
        ),
      ),
    );
  }
}

class MedicinalPlantsApp extends StatelessWidget {
  const MedicinalPlantsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medicinal Plants',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF2E7D3),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF499265),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF499265),
        ),
      ),
      home: WelcomePage(),
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 20),
                const Text(
                  'App Initialization Failed',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text(error, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // You could attempt to reinitialize here
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}