import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/profile_model.dart';
import '../../services/profile_service.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _profileService = ProfileService();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _floreriaController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _locationController = TextEditingController();
  final _businessHoursController = TextEditingController();
  final _businessDescriptionController = TextEditingController();
  final List<TextEditingController> _socialMediaControllers = [];

  late Future<Profile> _profileFuture;
  Profile? _profile;
  String? _avatarUrl;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _floreriaController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _locationController.dispose();
    _businessHoursController.dispose();
    _businessDescriptionController.dispose();
    for (var controller in _socialMediaControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<Profile> _loadProfile() async {
    try {
      final profile = await _profileService.getProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          _avatarUrl = profile.avatarUrl;
          _updateControllers(profile);
        });
      }
      return profile;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar el perfil: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      rethrow;
    }
  }

  void _updateControllers(Profile profile) {
    _nameController.text = profile.name ?? '';
    _floreriaController.text = profile.floristeria ?? '';
    _emailController.text = profile.email ?? '';
    _telefonoController.text = profile.telefono ?? '';
    _locationController.text = profile.location ?? '';
    _businessHoursController.text = profile.businessHours ?? '';
    _businessDescriptionController.text = profile.businessDescription ?? '';

    _socialMediaControllers.clear();
    _socialMediaControllers.addAll(
      (profile.socialMediaLinks).map(
        (link) => TextEditingController(text: link),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() => _isSaving = true);

    try {
      final updatedProfile = _profile!.copyWith(
        name: _nameController.text,
        floristeria: _floreriaController.text,
        telefono: _telefonoController.text,
        location: _locationController.text,
        businessHours: _businessHoursController.text,
        businessDescription: _businessDescriptionController.text,
        socialMediaLinks: _socialMediaControllers.map((e) => e.text).toList(),
        avatarUrl: _avatarUrl,
      );

      await _profileService.updateProfile(updatedProfile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado con éxito.'),
            backgroundColor: Colors.green,
          ),
        );
      }
      setState(() {
        _profile = updatedProfile;
        _isEditing = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar el perfil: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final imageFile = File(pickedFile.path);

    try {
      final newAvatarUrl = await _profileService.uploadAvatar(imageFile);
      setState(() {
        _avatarUrl = newAvatarUrl;
        _profile = _profile?.copyWith(avatarUrl: newAvatarUrl);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Imagen de perfil actualizada.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir la imagen: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _changePassword() async {
    try {
      await _profileService.resetPassword(_emailController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Se ha enviado un correo para restablecer la contraseña.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al solicitar cambio de contraseña: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    try {
      await _profileService.signOut();
      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Perfil'),
        actions: [
          TextButton(
            onPressed: _isSaving
                ? null
                : () {
                    if (_isEditing) {
                      _saveChanges();
                    } else {
                      setState(() => _isEditing = true);
                    }
                  },
            child: _isSaving
                ? const CircularProgressIndicator()
                : Text(_isEditing ? 'Guardar' : 'Editar'),
          ),
        ],
      ),
      body: FutureBuilder<Profile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No se pudo cargar el perfil.'),
                  TextButton(
                    onPressed: () => setState(() {
                      _profileFuture = _loadProfile();
                    }),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          return _buildProfileForm(context);
        },
      ),
    );
  }

  Widget _buildProfileForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: 32),
            _buildTextField(context, _nameController, 'Nombre', Icons.person),
            const SizedBox(height: 16),
            _buildTextField(
              context,
              _floreriaController,
              'Florería',
              Icons.store,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              context,
              _telefonoController,
              'Teléfono',
              Icons.phone,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              context,
              _locationController,
              'Ubicación',
              Icons.location_on,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              context,
              _businessHoursController,
              'Horario de Atención',
              Icons.access_time,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              context,
              _businessDescriptionController,
              'Descripción del Negocio',
              Icons.description,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              context,
              _emailController,
              'Correo',
              Icons.email,
              isEditable: false,
            ),
            const SizedBox(height: 16),
            _buildSocialMediaLinksSection(context),
            const SizedBox(height: 32),
            _buildPasswordSection(context),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _isEditing ? _pickAndUploadAvatar : null,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: theme.colorScheme.primary,
                  backgroundImage: _avatarUrl != null
                      ? NetworkImage(_avatarUrl!)
                      : null,
                  child: _avatarUrl == null
                      ? Icon(
                          Icons.person,
                          size: 60,
                          color: theme.colorScheme.onPrimary,
                        )
                      : null,
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(_nameController.text, style: theme.textTheme.headlineSmall),
        ],
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isEditable = true,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      readOnly: !_isEditing || !isEditable,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: theme.colorScheme.primary),
        filled: true,
        fillColor: theme.colorScheme.surface.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      validator: (value) {
        if (label == 'Nombre' && (value == null || value.isEmpty)) {
          return 'El nombre no puede estar vacío';
        }
        return null;
      },
    );
  }

  Widget _buildSocialMediaLinksSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Redes Sociales', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ..._socialMediaControllers.asMap().entries.map((entry) {
          int index = entry.key;
          TextEditingController controller = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    context,
                    controller,
                    'Enlace de Red Social',
                    Icons.link,
                    isEditable: _isEditing,
                  ),
                ),
                if (_isEditing)
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: () {
                      setState(() {
                        controller.dispose();
                        _socialMediaControllers.removeAt(index);
                      });
                    },
                  ),
              ],
            ),
          );
        }).toList(),
        if (_isEditing)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _socialMediaControllers.add(TextEditingController());
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Añadir Enlace'),
            ),
          ),
      ],
    );
  }

  Widget _buildPasswordSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Contraseña', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _buildTextField(
          context,
          TextEditingController(text: '********'),
          'Contraseña',
          Icons.lock,
          isEditable: false,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _changePassword,
            child: const Text('Cambiar Contraseña'),
          ),
        ),
      ],
    );
  }
}
