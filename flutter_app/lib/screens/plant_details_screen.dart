import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/favorite_button.dart'; // Import the button widget
import '../services/local_favorites_service.dart'; // Import the local favorites service

// IMPORTANT: This version uses local storage (shared_preferences) for favorites
// and relies on plantName and remedyTitle for identification.
// It assumes plant data is loaded from the JSON asset.

class PlantDetailsScreen extends StatefulWidget {
  final String plantName; // Using plantName as the identifier

  const PlantDetailsScreen({Key? key, required this.plantName}) : super(key: key);

  @override
  State<PlantDetailsScreen> createState() => _PlantDetailsScreenState();
}

class _PlantDetailsScreenState extends State<PlantDetailsScreen> {
  Map<String, dynamic>? _plantData;
  bool _isLoading = true;
  String? _errorMessage;

  // --- Local Favorites State ---
  final LocalFavoritesService _favoritesService = LocalFavoritesService();
  bool _isPlantFavorite = false;
  // Map to store favorite status for each remedy title within this plant
  Map<String, bool> _remedyFavoriteStatus = {};
  // ---------------------------

  // Define colors from the palette
  static const Color deepGreen = Color(0xFF499265);
  static const Color softBeige = Color(0xFFF2E7D3);
  static const Color earthyBrown = Color(0xFFAF8447);
  static const Color lightLeaf = Color(0xFFBCE7B4);

  @override
  void initState() {
    super.initState();
    _loadDataAndFavoriteStatus();
  }

  Future<void> _loadDataAndFavoriteStatus() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Load plant data from JSON
      final String response = await rootBundle.loadString('assets/plants_data.json');
      final List<dynamic> data = json.decode(response);
      final plantDataFromJson = data.firstWhere(
            (plant) => plant['name'] == widget.plantName,
        orElse: () => null,
      );

      if (plantDataFromJson == null) {
        throw Exception('Plant not found in JSON data.');
      }

      // Load favorite status for the plant
      bool isFavorite = await _favoritesService.isPlantFavorite(widget.plantName);

      // Load favorite status for remedies within this plant
      Map<String, bool> remedyStatus = {};
      if (plantDataFromJson['natural_remedies'] != null) {
        for (var remedy in plantDataFromJson['natural_remedies']) {
          String remedyTitle = remedy['title'] ?? 'Unknown Remedy';
          String remedyIdentifier = _favoritesService.createRemedyIdentifier(widget.plantName, remedyTitle);
          remedyStatus[remedyTitle] = await _favoritesService.isRemedyFavorite(remedyIdentifier);
        }
      }

      if (mounted) {
        setState(() {
          _plantData = plantDataFromJson;
          _isPlantFavorite = isFavorite;
          _remedyFavoriteStatus = remedyStatus;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading plant data or favorite status: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Error loading details: ${e.toString()}";
        });
      }
    }
  }

  Future<void> _togglePlantFavorite() async {
    final newFavoriteStatus = !_isPlantFavorite;
    setState(() {
      _isPlantFavorite = newFavoriteStatus;
    });

    try {
      if (newFavoriteStatus) {
        await _favoritesService.addPlantFavorite(widget.plantName);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to favorites!'), duration: Duration(seconds: 2)),
        );
      } else {
        await _favoritesService.removePlantFavorite(widget.plantName);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from favorites'), duration: Duration(seconds: 2)),
        );
      }
    } catch (e) {
      debugPrint('❌ Error updating plant favorite status: $e');
      // Revert state if operation failed
      setState(() {
        _isPlantFavorite = !newFavoriteStatus;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating favorites'), duration: Duration(seconds: 2)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBeige,
      appBar: AppBar(
        title: Text(
          widget.plantName,
          style: const TextStyle(
            color: softBeige,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: deepGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: softBeige),
        actions: [
          // Add Favorite Button for the Plant
          if (!_isLoading && _plantData != null)
            FavoriteButton(
              isFavorite: _isPlantFavorite,
              onPressed: _togglePlantFavorite,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: deepGreen))
          : _errorMessage != null
          ? Center(child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 16), textAlign: TextAlign.center,)
      ))
          : _plantData == null
          ? const Center(
        child: Text(
          'Plant information not available',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : _buildPlantDetails(),
    );
  }

  Widget _buildPlantDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header...
          Container(
            color: deepGreen,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _plantData!['scientific_name'] ?? 'Scientific Name N/A',
                  style: const TextStyle(
                    color: softBeige,
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildInfoChip(_plantData!['category'] ?? 'Uncategorized'),
                    const SizedBox(width: 8),
                    _buildInfoChip('Origin: ${_plantData!['origin'] ?? 'Unknown'}'),
                  ],
                ),
              ],
            ),
          ),

          // Medicinal Uses Section...
          _buildSection(
            title: 'Medicinal Uses',
            icon: Icons.healing,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ..._buildListItems(_plantData!['medicinal_uses'] ?? []),
              ],
            ),
          ),

          // Growth Environment Section...
          _buildSection(
            title: 'Growth Environment',
            icon: Icons.eco,
            child: Text(
              _plantData!['growth_environment'] ?? 'Information not available',
              style: const TextStyle(fontSize: 16, color: earthyBrown),
            ),
          ),

          // Toxicity Section...
          if (_plantData!['toxicity'] != null && _plantData!['toxicity']['is_toxic'] == true)
            _buildSection(
              title: 'Toxicity',
              icon: Icons.warning_amber_rounded,
              color: const Color(0xFFFFF3CD),
              borderColor: const Color(0xFFFFB74D),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_plantData!['toxicity']['toxic_parts'] != null &&
                      _plantData!['toxicity']['toxic_parts'].isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Toxic parts: ${_plantData!['toxicity']['toxic_parts']}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: earthyBrown),
                      ),
                    ),
                  if (_plantData!['toxicity']['effects'] != null &&
                      (_plantData!['toxicity']['effects'] as List).isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Potential effects:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: earthyBrown),
                        ),
                        const SizedBox(height: 4),
                        ..._buildListItems(_plantData!['toxicity']['effects']),
                      ],
                    ),
                ],
              ),
            ),

          // Natural Remedies Section
          _buildSection(
            title: 'Natural Remedies',
            icon: Icons.spa,
            child: Column(
              children: [
                ...(_plantData!['natural_remedies'] as List<dynamic>? ?? []).map((remedy) {
                  String remedyTitle = remedy['title'] ?? 'Unknown Remedy';
                  return _RemedyCard(
                    plantName: widget.plantName, // Pass plant name
                    remedyData: remedy,
                    remedyTitle: remedyTitle, // Pass remedy title
                    isFavorite: _remedyFavoriteStatus[remedyTitle] ?? false,
                    favoritesService: _favoritesService,
                    onFavoriteChanged: (bool newStatus) {
                      // Update the state map when a remedy's favorite status changes
                      setState(() {
                        _remedyFavoriteStatus[remedyTitle] = newStatus;
                      });
                    },
                  );
                }).toList(),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // --- Helper Widgets (Styling updated) ---
  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
    Color color = Colors.white,
    Color borderColor = Colors.transparent,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Icon(icon, color: deepGreen),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: earthyBrown,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: const TextStyle(color: softBeige, fontSize: 14),
      ),
    );
  }

  List<Widget> _buildListItems(List<dynamic> items) {
    return items.map((item) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16, color: deepGreen)),
          Expanded(
            child: Text(
              item.toString(),
              style: const TextStyle(fontSize: 16, color: earthyBrown),
            ),
          ),
        ],
      ),
    )).toList();
  }
}

// --- Stateful Widget for Remedy Card with Local Favorite Button ---

class _RemedyCard extends StatefulWidget {
  final String plantName;
  final Map<String, dynamic> remedyData;
  final String remedyTitle;
  final bool isFavorite;
  final LocalFavoritesService favoritesService;
  final ValueChanged<bool> onFavoriteChanged; // Callback to update parent state

  const _RemedyCard({
    Key? key,
    required this.plantName,
    required this.remedyData,
    required this.remedyTitle,
    required this.isFavorite,
    required this.favoritesService,
    required this.onFavoriteChanged,
  }) : super(key: key);

  @override
  __RemedyCardState createState() => __RemedyCardState();
}

class __RemedyCardState extends State<_RemedyCard> {
  late bool _isRemedyFavorite;

  // Define colors from the palette
  static const Color deepGreen = Color(0xFF499265);
  static const Color lightLeaf = Color(0xFFBCE7B4);
  static const Color earthyBrown = Color(0xFFAF8447);

  @override
  void initState() {
    super.initState();
    _isRemedyFavorite = widget.isFavorite;
  }

  // Update local state if the initial favorite status changes (e.g., parent reloads)
  @override
  void didUpdateWidget(covariant _RemedyCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFavorite != oldWidget.isFavorite) {
      setState(() {
        _isRemedyFavorite = widget.isFavorite;
      });
    }
  }

  Future<void> _toggleRemedyFavorite() async {
    final newFavoriteStatus = !_isRemedyFavorite;
    final remedyIdentifier = widget.favoritesService.createRemedyIdentifier(widget.plantName, widget.remedyTitle);

    // Optimistically update local UI
    setState(() {
      _isRemedyFavorite = newFavoriteStatus;
    });
    // Notify parent widget of the change
    widget.onFavoriteChanged(newFavoriteStatus);

    try {
      if (newFavoriteStatus) {
        await widget.favoritesService.addRemedyFavorite(remedyIdentifier);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Remedy added to favorites!'), duration: Duration(seconds: 2)),
        );
      } else {
        await widget.favoritesService.removeRemedyFavorite(remedyIdentifier);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Remedy removed from favorites'), duration: Duration(seconds: 2)),
        );
      }
    } catch (e) {
      debugPrint('❌ Error updating remedy favorite status: $e');
      // Revert state if operation failed
      setState(() {
        _isRemedyFavorite = !newFavoriteStatus;
      });
      widget.onFavoriteChanged(!newFavoriteStatus); // Notify parent of revert
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating remedy favorite'), duration: Duration(seconds: 2)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final remedy = widget.remedyData;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.remedyTitle,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: deepGreen,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Favorite button for the remedy
                FavoriteButton(
                  isFavorite: _isRemedyFavorite,
                  onPressed: _toggleRemedyFavorite,
                  iconSize: 24,
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Ingredients:',
              style: TextStyle(fontWeight: FontWeight.w600, color: earthyBrown),
            ),
            const SizedBox(height: 4),
            ..._buildCardListItems(remedy['ingredients'] as List<dynamic>? ?? []),
            const SizedBox(height: 12),
            const Text(
              'Instructions:',
              style: TextStyle(fontWeight: FontWeight.w600, color: earthyBrown),
            ),
            const SizedBox(height: 4),
            Text(
              remedy['instructions'] ?? 'No instructions provided.',
              style: TextStyle(color: earthyBrown.withOpacity(0.9)),
            ),
            const SizedBox(height: 12),
            if (remedy['use_category'] != null)
              Align(
                alignment: Alignment.centerRight,
                child: Chip(
                  label: Text(remedy['use_category']),
                  backgroundColor: lightLeaf,
                  labelStyle: const TextStyle(color: deepGreen, fontWeight: FontWeight.w500),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper to build list items within the card
  List<Widget> _buildCardListItems(List<dynamic> items) {
    return items.map((item) => Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 14, color: deepGreen)),
          Expanded(
            child: Text(
              item.toString(),
              style: const TextStyle(fontSize: 14, color: earthyBrown),
            ),
          ),
        ],
      ),
    )).toList();
  }
}

