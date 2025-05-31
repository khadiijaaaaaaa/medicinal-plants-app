import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_app/screens/welcome_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
// Assurez-vous que les chemins d'importation correspondent à votre structure de projet
import '../models/user.dart';
import '../repositories/user_repository.dart'; // Adaptez si le chemin est différent
import 'auth/auth_wrapper.dart'; // Add this import

class ProfileScreen extends StatefulWidget {
  final int userId; // ID de l'utilisateur connecté, à passer lors de la navigation

  const ProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserRepository _userRepository = UserRepository();
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  
  User? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;
  File? _selectedImage;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
          _nameController.text = user?.name ?? '';
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

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection de l\'image: ${e.toString()}')),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (_currentUser == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Update user data
      _currentUser!.name = _nameController.text.trim();
      
      // Handle image if selected
      if (_selectedImage != null) {
        // In a real app, you would upload the image to a server
        // and get back a URL. For now, we'll just store the local path
        _currentUser!.profileImagePath = _selectedImage!.path;
      }

      // Save to database
      await _userRepository.updateUser(_currentUser!);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Erreur lors de la mise à jour du profil: ${e.toString()}";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      
      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Déconnexion réussie')),
      );

      // Navigate to auth screen and remove all previous routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la déconnexion: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Utilisateur'),
        actions: [
          if (!_isLoading && _currentUser != null && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile Image
          GestureDetector(
            onTap: _isEditing ? _pickImage : null,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: _getProfileImage(),
                  child: _currentUser?.profileImagePath == null && _selectedImage == null
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Name Field
          if (_isEditing)
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom',
                border: OutlineInputBorder(),
              ),
            )
          else
            Text(
              _currentUser?.name ?? 'Nom non défini',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          const SizedBox(height: 16),

          // Email (read-only)
          ListTile(
            leading: const Icon(Icons.email),
            title: Text(_currentUser!.email),
            subtitle: const Text('Email'),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          if (_isEditing) ...[
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('Enregistrer les modifications'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() {
                _isEditing = false;
                _selectedImage = null;
                _nameController.text = _currentUser?.name ?? '';
              }),
              child: const Text('Annuler'),
            ),
          ],

          if (!_isEditing) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Déconnexion'),
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  ImageProvider? _getProfileImage() {
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    }
    if (_currentUser?.profileImagePath != null) {
      return FileImage(File(_currentUser!.profileImagePath!));
    }
    return null;
  }
}

// Note: Assurez-vous que le champ 'email' existe bien dans votre classe 'User'
// dans 'user.dart'.
// Assurez-vous également que les imports en haut du fichier correspondent
// à l'emplacement réel de vos fichiers 'user.dart' et 'user_repository.dart'.

