import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/plant_with_details.dart';
import '../models/plant.dart';
import '../models/toxicity.dart';
import '../models/natural_remedy.dart';

class PlantDetailsScreen extends StatefulWidget {
  final String plantName;

  const PlantDetailsScreen({Key? key, required this.plantName}) : super(key: key);

  @override
  State<PlantDetailsScreen> createState() => _PlantDetailsScreenState();
}

class _PlantDetailsScreenState extends State<PlantDetailsScreen> {
  Map<String, dynamic>? _plantData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlantData();
  }

  Future<void> _loadPlantData() async {
    try {
      // Charger les données du fichier JSON
      final String response = await rootBundle.loadString('assets/plants_data.json');
      final List<dynamic> data = json.decode(response);

      // Rechercher la plante par son nom
      final plantData = data.firstWhere(
            (plant) => plant['name'] == widget.plantName,
        orElse: () => null,
      );

      setState(() {
        _plantData = plantData;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading plant data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2E7D3),
      appBar: AppBar(
        title: Text(
          widget.plantName,
          style: const TextStyle(
            color: Color(0xFFF2E7D3),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF499265),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF499265)))
          : _plantData == null
          ? const Center(
        child: Text(
          'Informations non disponibles',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : _buildPlantDetails(),
    );
  }

  Widget _buildPlantDetails() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec informations générales
          Container(
            color: const Color(0xFF499265),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _plantData!['scientific_name'],
                  style: const TextStyle(
                    color: Color(0xFFF2E7D3),
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildInfoChip(_plantData!['category'] ?? 'Non catégorisé'),
                    const SizedBox(width: 8),
                    _buildInfoChip('Origine: ${_plantData!['origin'] ?? 'Inconnue'}'),
                  ],
                ),
              ],
            ),
          ),

          // Section des usages médicinaux
          _buildSection(
            title: 'Usages médicinaux',
            icon: Icons.healing,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ..._buildListItems(_plantData!['medicinal_uses'] ?? []),
              ],
            ),
          ),

          // Section de l'environnement de croissance
          _buildSection(
            title: 'Environnement de croissance',
            icon: Icons.eco,
            child: Text(
              _plantData!['growth_environment'] ?? 'Information non disponible',
              style: const TextStyle(fontSize: 16),
            ),
          ),

          // Section de toxicité (si applicable)
          if (_plantData!['toxicity']['is_toxic'])
            _buildSection(
              title: 'Toxicité',
              icon: Icons.warning_amber_rounded,
              color: const Color(0xFFFFF3CD),
              borderColor: const Color(0xFFFFB74D),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_plantData!['toxicity']['toxic_parts'] != null && _plantData!['toxicity']['toxic_parts'].isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Parties toxiques: ${_plantData!['toxicity']['toxic_parts']}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  if (_plantData!['toxicity']['effects'] != null && (_plantData!['toxicity']['effects'] as List).isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Effets potentiels:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        ..._buildListItems(_plantData!['toxicity']['effects']),
                      ],
                    ),
                ],
              ),
            ),

          // Section des remèdes naturels
          _buildSection(
            title: 'Remèdes naturels',
            icon: Icons.spa,
            child: Column(
              children: [
                ..._buildRemedies(_plantData!['natural_remedies'] ?? []),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

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
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF499265)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF499265),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          Padding(
            padding: const EdgeInsets.all(12),
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
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }

  List<Widget> _buildListItems(List<dynamic> items) {
    return items.map((item) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              item.toString(),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    )).toList();
  }

  List<Widget> _buildRemedies(List<dynamic> remedies) {
    return remedies.map((remedy) => Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              remedy['title'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF499265),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ingrédients:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            ..._buildListItems(remedy['ingredients']),
            const SizedBox(height: 8),
            const Text(
              'Instructions:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(remedy['instructions']),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                remedy['use_category'],
                style: const TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    )).toList();
  }
}
