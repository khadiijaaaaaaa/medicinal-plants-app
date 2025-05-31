import 'package:flutter/material.dart';
import 'package:flutter_app/screens/welcome_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Assurez-vous que les chemins d'importation correspondent à votre structure de projet
import '../models/user.dart';
import '../repositories/user_repository.dart'; // Adaptez si le chemin est différent

class ProfileScreen extends StatefulWidget {
  final int userId; // ID de l'utilisateur connecté, à passer lors de la navigation

  const ProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserRepository _userRepository = UserRepository();
  User? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Récupérer l'utilisateur par son ID
      final user = await _userRepository.getUserById(widget.userId);
      if (mounted) { // Vérifier si le widgets est toujours monté avant d'appeler setState
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Erreur lors du chargement des données utilisateur: ${e.toString()}";
          _isLoading = false;
        });
      }
    }
  }

  void _editProfile() {
    // Logique pour naviguer vers un écran de modification de profil
    // ou afficher une boîte de dialogue.
    // Pour l'instant, affichons un message.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité de modification à implémenter.')),
    );
    // Exemple de navigation (à adapter) :
    // Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen(user: _currentUser!)));
  }

  void _logout() async {
    // Obtenir l'instance de SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // Supprimer l'ID utilisateur ou tout autre champ de session
    await prefs.remove('userId'); // Change 'userId' si tu utilises une autre clé

    if (!mounted) return; // Vérifie que le widgets est encore monté

    // Affiche un message de confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Déconnexion réussie.')),
    );

    // Redirection vers l'écran de connexion
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const WelcomePage()), // Remplace avec ton écran
          (Route<dynamic> route) => false, // Supprime toutes les routes précédentes
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Utilisateur'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    if (_currentUser == null) {
      return const Center(
        child: Text('Utilisateur non trouvé.'),
      );
    }

    // Affichage des informations utilisateur
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Section Informations Utilisateur
          Text(
            'Informations Personnelles',
            // Correction: Utilisation de titleLarge au lieu de headline6
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16.0),
          // Affichage de l'email uniquement
          ListTile(
            leading: const Icon(Icons.email),
            // Assurez-vous que le modèle User a bien un champ 'email'
            title: Text(_currentUser!.email ?? 'Email non défini'),
          ),

          const Spacer(), // Pousse les boutons vers le bas

          // Section Actions
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Modifier le Profil'),
              onPressed: _currentUser != null ? _editProfile : null, // Désactiver si pas d'utilisateur
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 40)), // Prend toute la largeur
            ),
          ),
          const SizedBox(height: 10.0),
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Déconnexion'),
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Couleur rouge pour la déconnexion
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 40) // Prend toute la largeur
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Note: Assurez-vous que le champ 'email' existe bien dans votre classe 'User'
// dans 'user.dart'.
// Assurez-vous également que les imports en haut du fichier correspondent
// à l'emplacement réel de vos fichiers 'user.dart' et 'user_repository.dart'.

