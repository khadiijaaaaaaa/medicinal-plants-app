import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/natural_remedy.dart';

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

  @override
  void initState() {
    super.initState();
    _loadRemediesData();
  }

  Future<void> _loadRemediesData() async {
    try {
      // Load JSON file
      final String response = await rootBundle.loadString('assets/plants_data.json');
      final List<dynamic> plants = json.decode(response);

      // Extract all remedies from all plants
      List<dynamic> allRemedies = [];
      Set<String> categories = {'All'};

      for (var plant in plants) {
        if (plant.containsKey('natural_remedies')) {
          List<dynamic> remedies = plant['natural_remedies'];
          for (var remedy in remedies) {
            // Add plant information to each remedy
            remedy['plant_name'] = plant['name'];
            remedy['scientific_name'] = plant['scientific_name'];
            remedy['is_toxic'] = plant['toxicity']['is_toxic'] ?? false;
            remedy['toxic_parts'] = plant['toxicity']['toxic_parts'] ?? '';
            remedy['toxic_effects'] = plant['toxicity']['effects'] ?? [];

            allRemedies.add(remedy);

            // Collect unique categories
            if (remedy.containsKey('use_category') && remedy['use_category'] != null) {
              categories.add(remedy['use_category']);
            }
          }
        }
      }

      setState(() {
        _plants = plants;
        _filteredRemedies = allRemedies;
        _categories = categories.toList()..sort();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterRemedies() {
    if (_plants.isEmpty) return;

    List<dynamic> results = [];

    for (var plant in _plants) {
      if (plant.containsKey('natural_remedies')) {
        List<dynamic> remedies = plant['natural_remedies'];
        for (var remedy in remedies) {
          // Add plant information to each remedy
          remedy['plant_name'] = plant['name'];
          remedy['scientific_name'] = plant['scientific_name'];
          remedy['is_toxic'] = plant['toxicity']['is_toxic'] ?? false;
          remedy['toxic_parts'] = plant['toxicity']['toxic_parts'] ?? '';
          remedy['toxic_effects'] = plant['toxicity']['effects'] ?? [];

          // Filter by search (plant name or remedy title)
          bool matchesSearch = _searchQuery.isEmpty ||
              plant['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
              remedy['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase());

          // Filter by category
          bool matchesCategory = _selectedCategory == 'All' ||
              remedy['use_category'] == _selectedCategory;

          if (matchesSearch && matchesCategory) {
            results.add(remedy);
          }
        }
      }
    }

    setState(() {
      _filteredRemedies = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remedies Guide'),
        backgroundColor: Colors.green.shade700,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _buildSearchAndFilterBar(),
          Expanded(
            child: _filteredRemedies.isEmpty
                ? const Center(child: Text('No remedies found'))
                : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _filteredRemedies.length,
              itemBuilder: (context, index) {
                final remedy = _filteredRemedies[index];
                return _buildRemedyCard(remedy);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.green.shade50,
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by plant name or remedy',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              filled: true,
              fillColor: Colors.white,
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
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                        _filterRemedies();
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: Colors.green.shade200,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemedyCard(dynamic remedy) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ExpansionTile(
        title: Text(
          remedy['title'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
        subtitle: Text(
          'Plant: ${remedy['plant_name']} (${remedy['scientific_name']})',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontStyle: FontStyle.italic,
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Icon(
            Icons.eco,
            color: Colors.green.shade700,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Text(
            remedy['use_category'] ?? 'Uncategorized',
            style: TextStyle(
              color: Colors.green.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Ingredients'),
                _buildIngredientsList(remedy['ingredients']),
                const SizedBox(height: 16.0),

                _buildSectionTitle('Preparation'),
                _buildInstructionsText(remedy['instructions']),
                const SizedBox(height: 16.0),

                if (remedy['is_toxic'])
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
          color: Colors.green.shade800,
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
              const Icon(Icons.fiber_manual_record, size: 12.0, color: Colors.green),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(ingredient),
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
      style: const TextStyle(
        fontSize: 15.0,
      ),
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
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (remedy['toxic_parts'].isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black, fontSize: 14.0),
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
              if (remedy['toxic_effects'].isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Possible side effects:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4.0),
                    ...remedy['toxic_effects'].map<Widget>((effect) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 2.0, bottom: 2.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.warning_amber, size: 16.0, color: Colors.red),
                            const SizedBox(width: 8.0),
                            Expanded(child: Text(effect)),
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

