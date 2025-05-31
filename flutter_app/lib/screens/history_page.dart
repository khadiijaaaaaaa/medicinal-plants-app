import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

// Import models and repositories
import '../models/identification_history.dart';
import '../models/plant.dart';
import '../repositories/identification_history_repository.dart';
import '../repositories/plant_repository.dart';

// Import detail screen for potential navigation
import 'plant_details_screen.dart';

// Helper class to hold combined history data
class HistoryEntry {
  final IdentificationHistory historyRecord;
  final Plant? plant;

  HistoryEntry({required this.historyRecord, this.plant});
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final IdentificationHistoryRepository _historyRepository = IdentificationHistoryRepository();
  final PlantRepository _plantRepository = PlantRepository();
  List<HistoryEntry> _historyEntries = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      // Fetch recent history records (adjust limit as needed)
      // Assuming no user login for now, fetching all history
      // If user login is implemented, use getHistoryForUser(userId)
      final historyRecords = await _historyRepository.getRecentHistory(50);

      final List<HistoryEntry> entries = [];
      for (var record in historyRecords) {
        // Fetch plant details for each record
        final plant = await _plantRepository.getPlantById(record.plantId);
        entries.add(HistoryEntry(historyRecord: record, plant: plant));
      }

      setState(() {
        _historyEntries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load history: ${e.toString()}';
        _isLoading = false;
      });
      debugPrint('❌ Error loading history: $e');
    }
  }

  // Helper to format the date string
  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown date';
    try {
      final dateTime = DateTime.parse(dateString);
      // Format: e.g., "May 31, 2025, 11:15 AM"
      return DateFormat('MMM d, yyyy, hh:mm a').format(dateTime);
    } catch (e) {
      return dateString; // Return original string if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2E7D3), // Match app theme
      appBar: AppBar(
        title: const Text(
          'Identification History',
          style: TextStyle(
            color: Color(0xFFF2E7D3),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF499265), // Match app theme
        iconTheme: const IconThemeData(color: Colors.white), // Back button color
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _errorMessage,
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_historyEntries.isEmpty) {
      return const Center(
        child: Text(
          'No identification history yet.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    // Display history list
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _historyEntries.length,
      itemBuilder: (context, index) {
        final entry = _historyEntries[index];
        final history = entry.historyRecord;
        final plant = entry.plant;
        final imageFile = File(history.imagePath);

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          color: Colors.white, // Card background
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: SizedBox(
              width: 60,
              height: 60,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                // Check if image file exists before attempting to load
                child: imageFile.existsSync()
                    ? Image.file(
                  imageFile,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                )
                    : Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
            title: Text(
              plant?.commonName ?? 'Unknown Plant',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF499265)),
            ),
            subtitle: Text(
              _formatDate(history.identificationDate),
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: history.wasToxic == true
                ? const Tooltip(
              message: 'Identified as potentially toxic',
              child: Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
            )
                : null,
            onTap: plant != null
                ? () {
              // Navigate to plant details if plant data is available
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlantDetailsScreen(plantName: plant.commonName),
                ),
              );
            }
                : null, // Disable tap if plant data is missing
          ),
        );
      },
    );
  }
}