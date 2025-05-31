import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
// Removed unused import: import '../models/natural_remedy.dart';
import '../services/local_favorites_service.dart'; // Import local favorites service
import '../widgets/favorite_button.dart'; // Import favorite button
import 'plant_details_screen.dart'; // For potential navigation

class RemediesPage extends StatefulWidget {
  const RemediesPage({Key? key}) : super(key: key);

  @override
  _RemediesPageState createState() => _RemediesPageState();
}

class _RemediesPageState extends State<RemediesPage> {
  List<dynamic> _plants = [];
  List<dynamic> _filteredRemedies = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  List<String> _categories = ['All'];

  // --- Local Favorites State ---
  final LocalFavoritesService _favoritesService = LocalFavoritesService();
  Map<String, bool> _remedyFavoriteStatus = {}; // Key: remedyIdentifier, Value: isFavorite
  // ---------------------------

  // Define colors from the palette
  static const Color deepGreen = Color(0xFF499265);
  static const Color softBeige = Color(0xFFF2E7D3);
  static const Color earthyBrown = Color(0xFFAF8447);
  static const Color lightLeaf = Color(0xFFBCE7B4);
  static const Color sandyBrown = Color(0xFFD9B17D);

  @override
  void initState() {
    super.initState();
    _loadRemediesAndFavorites();
  }

  Future<void> _loadRemediesAndFavorites() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Load JSON file
      final String response = await rootBundle.loadString('assets/plants_data.json');
      final List<dynamic> plants = json.decode(response);

      // Extract all remedies and load favorite status
      List<dynamic> allRemedies = [];
      Set<String> categories = {'All'};
      Map<String, bool> remedyStatus = {};

      for (var plant in plants) {
        if (plant.containsKey('natural_remedies')) {
          List<dynamic> remedies = plant['natural_remedies'];
          String plantName = plant['name'] ?? 'Unknown Plant';

          for (var remedy in remedies) {
            // Add plant information to each remedy
            remedy['plant_name'] = plantName;
            remedy['scientific_name'] = plant['scientific_name'];
            remedy['is_toxic'] = plant['toxicity']?['is_toxic'] ?? false;
            remedy['toxic_parts'] = plant['toxicity']?['toxic_parts'] ?? '';
            remedy['toxic_effects'] = plant['toxicity']?['effects'] ?? [];

            allRemedies.add(remedy);

            // Collect unique categories
            if (remedy.containsKey('use_category') && remedy['use_category'] != null) {
              categories.add(remedy['use_category']);
            }

            // Load favorite status for this remedy
            String remedyTitle = remedy['title'] ?? 'Unknown Remedy';
            String remedyIdentifier = _favoritesService.createRemedyIdentifier(plantName, remedyTitle);
            remedyStatus[remedyIdentifier] = await _favoritesService.isRemedyFavorite(remedyIdentifier);
          }
        }
      }

      if (mounted) {
        setState(() {
          _plants = plants;
          _filteredRemedies = allRemedies; // Initially show all
          _categories = categories.toList()..sort();
          _remedyFavoriteStatus = remedyStatus;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Optionally show an error message
        });
      }
    }
  }

  void _filterRemedies() {
    if (_plants.isEmpty) return;

    List<dynamic> results = [];

    for (var plant in _plants) {
      if (plant.containsKey('natural_remedies')) {
        List<dynamic> remedies = plant['natural_remedies'];
        for (var remedy in remedies) {
          // Ensure plant info is present (might be redundant if added during load)
          remedy['plant_name'] = plant['name'];
          remedy['scientific_name'] = plant['scientific_name'];
          // ... (other fields if needed)

          // Filter by search (plant name or remedy title)
          bool matchesSearch = _searchQuery.isEmpty ||
              (plant['name']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
              (remedy['title']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

          // Filter by category
          bool matchesCategory = _selectedCategory == 'All' ||
              remedy['use_category'] == _selectedCategory;

          if (matchesSearch && matchesCategory) {
            results.add(remedy);
          }
        }
      }
    }

    if (mounted) {
      setState(() {
        _filteredRemedies = results;
      });
    }
  }

  // --- Toggle Favorite Logic ---
  Future<void> _toggleRemedyFavorite(String plantName, String remedyTitle) async {
    final remedyIdentifier = _favoritesService.createRemedyIdentifier(plantName, remedyTitle);
    final currentStatus = _remedyFavoriteStatus[remedyIdentifier] ?? false;
    final newStatus = !currentStatus;

    // Optimistically update UI
    setState(() {
      _remedyFavoriteStatus[remedyIdentifier] = newStatus;
    });

    try {
      if (newStatus) {
        await _favoritesService.addRemedyFavorite(remedyIdentifier);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Remedy added to favorites!'), duration: Duration(seconds: 2)),
        );
      } else {
        await _favoritesService.removeRemedyFavorite(remedyIdentifier);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Remedy removed from favorites'), duration: Duration(seconds: 2)),
        );
      }
    } catch (e) {
      print('Error updating remedy favorite: $e');
      // Revert UI on error
      setState(() {
        _remedyFavoriteStatus[remedyIdentifier] = currentStatus;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating favorite status'), duration: Duration(seconds: 2)),
      );
    }
  }
  // ---------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBeige, // Use palette color
      appBar: AppBar(
        title: const Text('Remedies Guide', style: TextStyle(color: softBeige)),
        backgroundColor: deepGreen, // Use palette color
        iconTheme: const IconThemeData(color: softBeige),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: deepGreen))
          : Column(
        children: [
          _buildSearchAndFilterBar(),
          Expanded(
            child: _filteredRemedies.isEmpty
                ? Center(child: Text('No remedies found matching your criteria.', style: TextStyle(color: earthyBrown.withOpacity(0.7), fontSize: 16)))
                : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _filteredRemedies.length,
              itemBuilder: (context, index) {
                final remedy = _filteredRemedies[index];
                // Determine favorite status for this card
                String plantName = remedy['plant_name'] ?? 'Unknown Plant';
                String remedyTitle = remedy['title'] ?? 'Unknown Remedy';
                String remedyIdentifier = _favoritesService.createRemedyIdentifier(plantName, remedyTitle);
                bool isFavorite = _remedyFavoriteStatus[remedyIdentifier] ?? false;

                return _buildRemedyCard(remedy, isFavorite);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      color: lightLeaf.withOpacity(0.3), // Use palette color
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
                hintText: 'Search by plant name or remedy',
                hintStyle: TextStyle(color: earthyBrown.withOpacity(0.7)),
                prefixIcon: Icon(Icons.search, color: earthyBrown),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: deepGreen, width: 2),
                )
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _filterRemedies();
              });
            },
          ),
          const SizedBox(height: 8.0),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(category, style: TextStyle(color: _selectedCategory == category ? Colors.white : deepGreen)),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                        _filterRemedies();
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: deepGreen, // Use palette color
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: deepGreen.withOpacity(0.5))),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Modified to include FavoriteButton
  Widget _buildRemedyCard(dynamic remedy, bool isFavorite) {
    String plantName = remedy['plant_name'] ?? 'Unknown Plant';
    String remedyTitle = remedy['title'] ?? 'Unknown Remedy';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: Colors.white,
      child: ExpansionTile(
        // Add favorite button next to the title
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                remedyTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17.0,
                  color: deepGreen, // Use palette color
                ),
              ),
            ),
            FavoriteButton(
              isFavorite: isFavorite,
              onPressed: () => _toggleRemedyFavorite(plantName, remedyTitle),
              iconSize: 24,
            ),
          ],
        ),
        subtitle: Text(
          'Plant: $plantName (${remedy['scientific_name'] ?? 'N/A'})',
          style: TextStyle(
            color: earthyBrown.withOpacity(0.8),
            fontStyle: FontStyle.italic,
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: lightLeaf.withOpacity(0.5),
          child: Icon(
            Icons.spa, // Changed icon to spa
            color: deepGreen,
          ),
        ),
        // Keep category chip in trailing for consistency
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: lightLeaf.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Text(
            remedy['use_category'] ?? 'Uncategorized',
            style: const TextStyle(
              color: deepGreen,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0, top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Ingredients'),
                _buildIngredientsList(remedy['ingredients'] ?? []),
                const SizedBox(height: 16.0),

                _buildSectionTitle('Preparation'),
                _buildInstructionsText(remedy['instructions'] ?? 'N/A'),
                const SizedBox(height: 16.0),

                if (remedy['is_toxic'] == true)
                  _buildContraindications(remedy),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: earthyBrown, // Use palette color
        ),
      ),
    );
  }

  Widget _buildIngredientsList(List<dynamic> ingredients) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ingredients.map<Widget>((ingredient) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.fiber_manual_record, size: 10.0, color: deepGreen.withOpacity(0.7)),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(ingredient.toString(), style: TextStyle(color: earthyBrown)), // Use palette color
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInstructionsText(String instructions) {
    return Text(
      instructions,
      style: TextStyle(fontSize: 15.0, color: earthyBrown.withOpacity(0.9)), // Use palette color
    );
  }

  Widget _buildContraindications(dynamic remedy) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Contraindications'),
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (remedy['toxic_parts'] != null && remedy['toxic_parts'].isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.orange.shade900, fontSize: 14.0),
                      children: [
                        const TextSpan(
                          text: 'Toxic parts: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: remedy['toxic_parts']),
                      ],
                    ),
                  ),
                ),
              if (remedy['toxic_effects'] != null && (remedy['toxic_effects'] as List).isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Possible side effects:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade900),
                    ),
                    const SizedBox(height: 4.0),
                    ...(remedy['toxic_effects'] as List).map<Widget>((effect) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 2.0, bottom: 2.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.warning_amber, size: 16.0, color: Colors.orange.shade700),
                            const SizedBox(width: 8.0),
                            Expanded(child: Text(effect.toString(), style: TextStyle(color: Colors.orange.shade900))),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

