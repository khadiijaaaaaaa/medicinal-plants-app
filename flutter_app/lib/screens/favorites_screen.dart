import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/screens/profile_screen.dart';
import 'package:flutter_app/screens/remedies_page.dart';
import '../services/local_favorites_service.dart'; // Import the local service
import '../widgets/bottom_nav_bar.dart';
import 'history_page.dart';
import 'image_classification_widget.dart';
import 'plant_details_screen.dart'; // Import detail screen for navigation

// Helper class to hold favorite item details for display
class FavoriteDisplayItem {
  final String identifier; // plantName or plantName::remedyTitle
  final String type; // 'plant' or 'remedy'
  final String displayName;
  final String? plantName; // Only for remedies, to find plant context
  final String? remedyTitle; // Only for remedies

  FavoriteDisplayItem({
    required this.identifier,
    required this.type,
    required this.displayName,
    this.plantName,
    this.remedyTitle,
  });
}

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final LocalFavoritesService _favoritesService = LocalFavoritesService();
  List<FavoriteDisplayItem> _favoriteItems = [];
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _allPlantData; // To look up details

  int _currentIndex = 2; // Favorites is at index 2

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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RemediesPage()),
        );
        break;
      case 2:
      // Already on favorites page
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


  // Define colors from the palette
  static const Color deepGreen = Color(0xFF499265);
  static const Color freshLeaf = Color(0xFF87CB7C);
  static const Color lightLeaf = Color(0xFFBCE7B4);
  static const Color softBeige = Color(0xFFF2E7D3);
  static const Color sandyBrown = Color(0xFFD9B17D);
  static const Color earthyBrown = Color(0xFFAF8447);

  @override
  void initState() {
    super.initState();
    _loadAllDataAndFavorites();
  }

  Future<void> _loadAllDataAndFavorites() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // 1. Load all plant data from JSON (needed for display details)
      // In a real app, consider a more efficient data loading/caching strategy
      final String response = await rootBundle.loadString('assets/plants_data.json');
      final List<dynamic> jsonData = json.decode(response);
      // Create a map for easy lookup by plant name
      _allPlantData = { for (var plant in jsonData) plant['name'] : plant };

      // 2. Load favorite identifiers from local storage
      final plantFavNames = await _favoritesService.getPlantFavorites();
      final remedyFavIdentifiers = await _favoritesService.getRemedyFavorites();

      // 3. Create display items
      final List<FavoriteDisplayItem> displayItems = [];

      // Process plant favorites
      for (String plantName in plantFavNames) {
        // Optional: Check if plant still exists in our loaded data
        if (_allPlantData!.containsKey(plantName)) {
           displayItems.add(FavoriteDisplayItem(
            identifier: plantName,
            type: 'plant',
            displayName: plantName,
          ));
        } else {
          // Handle case where favorited plant name is no longer in JSON
          print('Warning: Favorited plant "$plantName" not found in current data.');
          // Optionally remove it from favorites here
          // await _favoritesService.removePlantFavorite(plantName);
        }
      }

      // Process remedy favorites
      for (String identifier in remedyFavIdentifiers) {
        final parsed = _favoritesService.parseRemedyIdentifier(identifier);
        if (parsed != null) {
          String plantName = parsed['plantName']!;
          String remedyTitle = parsed['remedyTitle']!;
          // Optional: Check if plant and remedy still exist
          if (_allPlantData!.containsKey(plantName) &&
              _allPlantData![plantName]['natural_remedies']?.any((r) => r['title'] == remedyTitle) == true) {
             displayItems.add(FavoriteDisplayItem(
              identifier: identifier,
              type: 'remedy',
              displayName: remedyTitle,
              plantName: plantName, // Store associated plant name
              remedyTitle: remedyTitle,
            ));
          } else {
             print('Warning: Favorited remedy "$identifier" not found in current data.');
             // Optionally remove it
             // await _favoritesService.removeRemedyFavorite(identifier);
          }
        }
      }

      // Optional: Sort the list (e.g., by type then name)
      displayItems.sort((a, b) {
        int typeCompare = a.type.compareTo(b.type);
        if (typeCompare != 0) return typeCompare;
        return a.displayName.compareTo(b.displayName);
      });

      if (mounted) {
        setState(() {
          _favoriteItems = displayItems;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading favorites screen data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to load favorites: ${e.toString()}";
        });
      }
    }
  }

  Future<void> _removeFavorite(FavoriteDisplayItem item) async {
    try {
      if (item.type == 'plant') {
        await _favoritesService.removePlantFavorite(item.identifier);
      } else if (item.type == 'remedy') {
        await _favoritesService.removeRemedyFavorite(item.identifier);
      }

      // Refresh the list from scratch
      await _loadAllDataAndFavorites();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.type == 'plant' ? 'Plant' : 'Remedy'} removed from favorites.'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error removing favorite: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not remove favorite.')),
      );
    }
  }

  void _navigateToPlantDetails(String plantName) {
    // Check if plant data exists before navigating
    if (_allPlantData != null && _allPlantData!.containsKey(plantName)) {
       Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlantDetailsScreen(plantName: plantName),
        ),
      ).then((_) => _loadAllDataAndFavorites()); // Refresh list when returning
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plant details not found.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBeige,
      appBar: AppBar(
        title: const Text(
          'My Favorites',
          style: TextStyle(color: softBeige, fontWeight: FontWeight.bold),
        ),
        backgroundColor: deepGreen,
        iconTheme: const IconThemeData(color: softBeige),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: deepGreen))
          : _errorMessage != null
              ? Center(child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 16), textAlign: TextAlign.center,)
                ))
              : _favoriteItems.isEmpty
                  ? Center(
                      child: Text(
                        'You haven\'t added any favorites yet.',
                        style: TextStyle(fontSize: 18, color: earthyBrown.withOpacity(0.7)),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadAllDataAndFavorites, // Allow pull-to-refresh
                      color: deepGreen,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: _favoriteItems.length,
                        itemBuilder: (context, index) {
                          final item = _favoriteItems[index];
                          return _buildFavoriteItem(item);
                        },
                      ),
                    ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _buildFavoriteItem(FavoriteDisplayItem item) {
    IconData leadingIcon = item.type == 'plant' ? Icons.grass : Icons.spa;
    String subtitle = item.type == 'plant' ? 'Type: Plant' : 'Remedy from: ${item.plantName}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: lightLeaf.withOpacity(0.5),
          child: Icon(leadingIcon, color: deepGreen),
        ),
        title: Text(
          item.displayName, // Plant name or Remedy title
          style: const TextStyle(fontWeight: FontWeight.w500, color: earthyBrown),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: earthyBrown.withOpacity(0.7)),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: sandyBrown),
          tooltip: 'Remove Favorite',
          onPressed: () => _removeFavorite(item),
        ),
        onTap: () {
          // Always navigate to the plant details screen
          // If it's a remedy, the user can find it within the plant's details
          String plantNameToNavigate = item.type == 'plant' ? item.identifier : item.plantName!;
          _navigateToPlantDetails(plantNameToNavigate);
        },
      ),
    );
  }
}

