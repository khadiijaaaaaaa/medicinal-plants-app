import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_app/screens/profile_screen.dart';
import '../services/local_favorites_service.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/favorite_button.dart';
import 'favorites_screen.dart';
import 'history_page.dart';
import 'image_classification_widget.dart';

enum RemediesView { categories, remediesList }

class BodyZoneFilter {
  final String name;
  final IconData icon;
  final List<String> relatedCategories;

  BodyZoneFilter({
    required this.name,
    required this.icon,
    required this.relatedCategories,
  });
}

class RemediesPage extends StatefulWidget {


  //const RemediesPage({Key? key, required this.userId}) : super(key: key);  // Update constructor
  const RemediesPage({Key? key}) : super(key: key);

  @override
  _RemediesPageState createState() => _RemediesPageState();

}

class _RemediesPageState extends State<RemediesPage> {
  int _currentIndex = 1;
  List<dynamic> _plants = [];
  List<dynamic> _allRemedies = [];
  List<dynamic> _filteredRemedies = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedCategory;
  List<String> _allCategories = [];
  List<String> _displayedCategories = [];

  RemediesView _currentView = RemediesView.categories;

  final LocalFavoritesService _favoritesService = LocalFavoritesService();
  Map<String, bool> _remedyFavoriteStatus = {};

  String? _activeBodyZoneFilterName;

  final Map<String, IconData> _categoryIconMap = {
    'Acne Treatment': Icons.face_retouching_natural_outlined,
    'Cardiovascular Health': Icons.monitor_heart_outlined,
    'Diabetes Management': Icons.bloodtype_outlined,
    'Digestive Health': Icons.eco_outlined,
    'Energy Support': Icons.bolt_outlined,
    'General Wellness': Icons.spa_outlined,
    'Gut Health': Icons.bubble_chart_outlined,
    'Hair Care': Icons.grass_outlined,
    'Household Use': Icons.cleaning_services_outlined,
    'Immune Support': Icons.shield_outlined,
    'Mental Well-being': Icons.self_improvement_outlined,
    'Muscle Health': Icons.fitness_center_outlined,
    'Oral Health': Icons.sentiment_very_satisfied_outlined,
    'Pain Relief': Icons.healing_outlined,
    'Respiratory Health': Icons.air_outlined,
    'Skin Health': Icons.spa_outlined,
  };
  final IconData _defaultCategoryIcon = Icons.eco_outlined;

  final List<BodyZoneFilter> _bodyZoneFilters = [
    BodyZoneFilter(
      name: 'Head & Mind',
      icon: Icons.psychology_outlined,
      relatedCategories: ['Mental Well-being', 'Pain Relief', 'Hair Care'],
    ),
    BodyZoneFilter(
      name: 'Respiratory',
      icon: Icons.air_outlined,
      relatedCategories: ['Respiratory Health', 'Immune Support'],
    ),
    BodyZoneFilter(
      name: 'Digestive',
      icon: Icons.eco_outlined,
      relatedCategories: ['Digestive Health', 'Gut Health', 'Pain Relief'],
    ),
    BodyZoneFilter(
      name: 'Skin',
      icon: Icons.healing_outlined,
      relatedCategories: ['Skin Health', 'Acne Treatment'],
    ),
    BodyZoneFilter(
      name: 'Heart',
      icon: Icons.monitor_heart_outlined,
      relatedCategories: ['Cardiovascular Health', 'Energy Support'],
    ),
    BodyZoneFilter(
      name: 'Muscles',
      icon: Icons.fitness_center_outlined,
      relatedCategories: ['Muscle Health', 'Pain Relief'],
    ),
    BodyZoneFilter(
      name: 'General',
      icon: Icons.health_and_safety_outlined,
      relatedCategories: ['General Wellness', 'Immune Support', 'Energy Support', 'Diabetes Management'],
    ),
  ];

  // Theme Colors (Using consistent names)
  static const Color deepGreen = Color(0xFF499265); // Main theme color (for AppBar)
  static const Color softBeige = Color(0xFFF2E7D3); // Page background & AppBar text/icons
  static const Color earthyBrown = Color(0xFFAF8447); // Secondary text
  static const Color lightLeaf = Color(0xFFBCE7B4); // Accent color
  static Color categoryCardBackground = Colors.green.shade100.withOpacity(0.6);
  static Color filterButtonBackground = softBeige.withOpacity(0.9); // Changed filter button background for contrast
  static Color filterActiveColor = Colors.orange.shade300;
  static Color filterButtonTextColor = deepGreen; // Text color for filter button

  @override
  void initState() {
    super.initState();
    _loadRemediesAndFavorites();
  }

  Future<void> _loadRemediesAndFavorites() async {
    // ... loading logic ...
    setState(() { _isLoading = true; });
    try {
      final String response = await rootBundle.loadString('assets/plants_data.json');
      final List<dynamic> plants = json.decode(response);
      List<dynamic> allRemedies = [];
      Set<String> categoriesSet = {};
      Map<String, bool> remedyStatus = {};

      for (var plant in plants) {
        if (plant.containsKey('natural_remedies')) {
          List<dynamic> remedies = plant['natural_remedies'];
          String plantName = plant['name'] ?? 'Unknown Plant';
          for (var remedy in remedies) {
            remedy['plant_name'] = plantName;
            remedy['scientific_name'] = plant['scientific_name'];
            remedy['is_toxic'] = plant['toxicity']?['is_toxic'] ?? false;
            remedy['toxic_parts'] = plant['toxicity']?['toxic_parts'] ?? '';
            remedy['toxic_effects'] = plant['toxicity']?['effects'] ?? [];

            allRemedies.add(remedy);
            if (remedy.containsKey('use_category') && remedy['use_category'] != null) {
              categoriesSet.add(remedy['use_category']);
            }
            String remedyTitle = remedy['title'] ?? 'Unknown Remedy';
            String remedyIdentifier = _favoritesService.createRemedyIdentifier(plantName, remedyTitle);
            remedyStatus[remedyIdentifier] = await _favoritesService.isRemedyFavorite(remedyIdentifier);
          }
        }
      }

      if (mounted) {
        setState(() {
          _plants = plants;
          _allRemedies = allRemedies;
          _allCategories = categoriesSet.toList()..sort();
          _displayedCategories = List.from(_allCategories);
          _remedyFavoriteStatus = remedyStatus;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) { setState(() { _isLoading = false; }); }
    }
  }

  void _applyBodyZoneFilter(String? filterName) {
    // ... filter logic ...
    setState(() {
      _activeBodyZoneFilterName = filterName;
      if (filterName == null) {
        _displayedCategories = List.from(_allCategories);
      } else {
        final selectedFilter = _bodyZoneFilters.firstWhere((f) => f.name == filterName);
        _displayedCategories = _allCategories.where((category) {
          return selectedFilter.relatedCategories.contains(category);
        }).toList();
      }
    });
  }

  void _showBodyZoneFilterSheet() {
    // ... bottom sheet logic ...
    showModalBottomSheet(
      context: context,
      backgroundColor: softBeige,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter by Body Zone',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: deepGreen,
                ),
              ),
              const SizedBox(height: 16.0),
              Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                children: [
                  FilterChip(
                    label: const Text('All Categories'),
                    selected: _activeBodyZoneFilterName == null,
                    onSelected: (selected) {
                      _applyBodyZoneFilter(null);
                      Navigator.pop(context);
                    },
                    backgroundColor: filterButtonBackground,
                    selectedColor: filterActiveColor,
                    labelStyle: TextStyle(color: filterButtonTextColor, fontWeight: FontWeight.w600),
                    checkmarkColor: filterButtonTextColor,
                    showCheckmark: true,
                  ),
                  ..._bodyZoneFilters.map((filter) {
                    return FilterChip(
                      avatar: Icon(filter.icon, color: filterButtonTextColor, size: 18),
                      label: Text(filter.name),
                      selected: _activeBodyZoneFilterName == filter.name,
                      onSelected: (selected) {
                        _applyBodyZoneFilter(filter.name);
                        Navigator.pop(context);
                      },
                      backgroundColor: filterButtonBackground,
                      selectedColor: filterActiveColor,
                      labelStyle: TextStyle(color: filterButtonTextColor, fontWeight: FontWeight.w600),
                      checkmarkColor: filterButtonTextColor,
                      showCheckmark: true,
                    );
                  }).toList(),
                ],
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        );
      },
    );
  }

  void _filterRemedies() {
    // ... remedy filter logic ...
    if (_isLoading || _selectedCategory == null) {
      setState(() {
        _filteredRemedies = [];
      });
      return;
    }
    List<dynamic> results = _allRemedies.where((remedy) {
      bool matchesCategory = remedy['use_category'] == _selectedCategory;
      if (!matchesCategory) return false;
      bool matchesSearch = _searchQuery.isEmpty ||
          (remedy['plant_name']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (remedy['title']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      return matchesSearch;
    }).toList();
    if (mounted) {
      setState(() {
        _filteredRemedies = results;
      });
    }
  }

  void _selectCategory(String category) {
    // ... select category logic ...
    setState(() {
      _selectedCategory = category;
      _currentView = RemediesView.remediesList;
      _searchQuery = '';
      _filterRemedies();
    });
  }

  void _showCategories() {
    // ... show categories logic ...
    setState(() {
      _selectedCategory = null;
      _currentView = RemediesView.categories;
      _searchQuery = '';
      _filteredRemedies = [];
    });
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ImageClassificationWidget(userId: 1)),
        );
        break;
      case 1:
      // Already on remedies page
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FavoritesScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HistoryPage()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen(userId: 1)),
        );
        break;
    }
  }

  Future<void> _toggleRemedyFavorite(String plantName, String remedyTitle) async {
    // ... favorite logic ...
    final remedyIdentifier = _favoritesService.createRemedyIdentifier(plantName, remedyTitle);
    final currentStatus = _remedyFavoriteStatus[remedyIdentifier] ?? false;
    final newStatus = !currentStatus;
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
      setState(() {
        _remedyFavoriteStatus[remedyIdentifier] = currentStatus;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating favorite status'), duration: Duration(seconds: 2)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool _isFilterButtonPressed = false;

    return Scaffold(
      backgroundColor: softBeige,
      appBar: AppBar(
        // --- MODIFIED: Apply main theme color ---
        backgroundColor: deepGreen,
        elevation: 1, // Keep a subtle elevation or set to 0 if preferred
        title: Text(
          _currentView == RemediesView.categories ? 'Remedies' : _selectedCategory ?? 'Remedies',
          // --- MODIFIED: Text color for contrast ---
          style: const TextStyle(color: softBeige, fontWeight: FontWeight.bold),
        ),
        // --- MODIFIED: Icon theme for contrast ---
        iconTheme: const IconThemeData(color: softBeige),
        leading: _currentView == RemediesView.remediesList
            ? IconButton(
          // Icon color is handled by iconTheme
          icon: const Icon(Icons.arrow_back),
          onPressed: _showCategories,
        )
            : null,
        actions: _currentView == RemediesView.categories
            ? [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTapDown: (_) { setState(() { _isFilterButtonPressed = true; }); },
              onTapUp: (_) { setState(() { _isFilterButtonPressed = false; }); _showBodyZoneFilterSheet(); },
              onTapCancel: () { setState(() { _isFilterButtonPressed = false; }); },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  // --- MODIFIED: Filter button background for better contrast with deepGreen AppBar ---
                  color: _activeBodyZoneFilterName != null
                      ? filterActiveColor
                      : (_isFilterButtonPressed
                      ? filterButtonBackground.withOpacity(0.7)
                      : filterButtonBackground), // Using softBeige background
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Filter',
                      style: TextStyle(
                        // --- MODIFIED: Filter button text color ---
                        color: filterButtonTextColor, // Using deepGreen text
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_activeBodyZoneFilterName != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 6.0),
                        // --- MODIFIED: Filter button check icon color ---
                        child: Icon(Icons.check_circle_outline, color: filterButtonTextColor, size: 16),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ]
            : null,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: deepGreen))
          : _buildCurrentView(),
    );
  }

  Widget _buildCurrentView() {
    // ... view switching logic ...
    switch (_currentView) {
      case RemediesView.categories:
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: _buildCategoryView(),
        );
      case RemediesView.remediesList:
        return _buildRemedyListView();
    }
  }

  Widget _buildCategoryView() {
    // ... category grid logic ...
    if (_displayedCategories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            _activeBodyZoneFilterName == null
                ? 'No remedy categories found.'
                : 'No categories found for "$_activeBodyZoneFilterName".\nTry clearing the filter.',
            textAlign: TextAlign.center,
            style: TextStyle(color: earthyBrown.withOpacity(0.8), fontSize: 16),
          ),
        ),
      );
    }
    int crossAxisCount = 3;
    double childAspectRatio = 1;
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: _displayedCategories.length,
      itemBuilder: (context, index) {
        final category = _displayedCategories[index];
        final iconData = _categoryIconMap[category] ?? _defaultCategoryIcon;
        return InkWell(
          onTap: () => _selectCategory(category),
          borderRadius: BorderRadius.circular(15.0),
          child: Card(
            elevation: 0,
            color: categoryCardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Icon(iconData, size: 36.0, color: deepGreen),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    category,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600, color: deepGreen),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRemedyListView() {
    // ... remedy list view logic ...
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: _filteredRemedies.isEmpty
              ? Center(
            child: Text(
              _searchQuery.isEmpty
                  ? 'No remedies found in this category.'
                  : 'No remedies found matching "$_searchQuery".',
              style: TextStyle(color: earthyBrown.withOpacity(0.7), fontSize: 16),
              textAlign: TextAlign.center,
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: _filteredRemedies.length,
            itemBuilder: (context, index) {
              final remedy = _filteredRemedies[index];
              String plantName = remedy['plant_name'] ?? 'Unknown Plant';
              String remedyTitle = remedy['title'] ?? 'Unknown Remedy';
              String remedyIdentifier = _favoritesService.createRemedyIdentifier(plantName, remedyTitle);
              bool isFavorite = _remedyFavoriteStatus[remedyIdentifier] ?? false;
              return _buildRemedyCard(remedy, isFavorite);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    // ... search bar logic ...
    return Container(
      padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 8.0),
      color: softBeige,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search in $_selectedCategory...',
          hintStyle: TextStyle(color: earthyBrown.withOpacity(0.7)),
          prefixIcon: Icon(Icons.search, color: earthyBrown),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: deepGreen, width: 1.5),
          ),
        ),
        onChanged: (value) {
          _searchQuery = value;
          _filterRemedies();
        },
      ),
    );
  }

  Widget _buildRemedyCard(dynamic remedy, bool isFavorite) {
    // ... remedy card logic ...
    String plantName = remedy['plant_name'] ?? 'Unknown Plant';
    String remedyTitle = remedy['title'] ?? 'Unknown Remedy';
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: Colors.white,
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                remedyTitle,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0, color: deepGreen),
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
          style: TextStyle(color: earthyBrown.withOpacity(0.8), fontStyle: FontStyle.italic),
        ),
        leading: CircleAvatar(
          backgroundColor: lightLeaf.withOpacity(0.5),
          child: const Icon(Icons.spa, color: deepGreen),
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
    // ... helper ...
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: earthyBrown)),
    );
  }

  Widget _buildIngredientsList(List<dynamic> ingredients) {
    // ... helper ...
    if (ingredients.isEmpty) return const Text('No ingredients listed.', style: TextStyle(color: earthyBrown));
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
              Expanded(child: Text(ingredient.toString(), style: const TextStyle(color: earthyBrown))),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInstructionsText(String instructions) {
    // ... helper ...
    return Text(
      instructions.isEmpty ? 'No preparation instructions provided.' : instructions,
      style: TextStyle(fontSize: 15.0, color: earthyBrown.withOpacity(0.9)),
    );
  }

  Widget _buildContraindications(dynamic remedy) {
    // ... helper ...
    bool hasToxicParts = remedy['toxic_parts'] != null && remedy['toxic_parts'].isNotEmpty;
    bool hasToxicEffects = remedy['toxic_effects'] != null && (remedy['toxic_effects'] as List).isNotEmpty;
    if (!hasToxicParts && !hasToxicEffects) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Contraindications / Warnings'),
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
              if (hasToxicParts)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.orange.shade900, fontSize: 14.0),
                      children: [
                        const TextSpan(text: 'Toxic parts: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: remedy['toxic_parts']),
                      ],
                    ),
                  ),
                ),
              if (hasToxicEffects)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Possible side effects:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade900)),
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

