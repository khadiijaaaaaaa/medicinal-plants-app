import 'package:flutter/material.dart';

class FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onPressed;
  final double iconSize;

  const FavoriteButton({
    Key? key,
    required this.isFavorite,
    required this.onPressed,
    this.iconSize = 28.0, // Default icon size
  }) : super(key: key);

  // Define colors from the palette
  static const Color deepGreen = Color(0xFF499265);
  static const Color freshLeaf = Color(0xFF87CB7C);
  static const Color sandyBrown = Color(0xFFD9B17D);
  static const Color earthyBrown = Color(0xFFAF8447);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        // Use Fresh Leaf for favorited state, Earthy Brown for non-favorited
        color: isFavorite ? freshLeaf : earthyBrown,
        size: iconSize,
      ),
      tooltip: isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
      onPressed: onPressed,
      // Optional: Add splash/highlight colors for better feedback
      splashColor: freshLeaf.withOpacity(0.2),
      highlightColor: freshLeaf.withOpacity(0.1),
    );
  }
}

