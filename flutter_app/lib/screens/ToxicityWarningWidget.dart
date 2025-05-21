import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

class ToxicityWarningWidget extends StatelessWidget {
  final bool isToxic;
  final String? toxicParts;
  final List<String> effects;

  const ToxicityWarningWidget({
    Key? key,
    required this.isToxic,
    this.toxicParts,
    required this.effects,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isToxic) return const SizedBox.shrink(); // Ne rien afficher si non toxique

    return Card(
      elevation: 4,
      color: const Color(0xFFFFF3CD), // Couleur d'avertissement jaune pâle
      margin: const EdgeInsets.only(top: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFFFB74D), width: 1), // Bordure orange
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF9800), size: 24),
                const SizedBox(width: 8),
                const Text(
                  'ATTENTION : Plante toxique',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFFE65100),
                  ),
                ),
              ],
            ),
            if (toxicParts != null && toxicParts!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Parties toxiques : $toxicParts',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF424242),
                ),
              ),
            ],
            if (effects.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Effets potentiels :',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF424242),
                ),
              ),
              const SizedBox(height: 4),
              ...effects.map((effect) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: Color(0xFF424242))),
                    Expanded(
                      child: Text(
                        effect,
                        style: const TextStyle(color: Color(0xFF424242)),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
}
