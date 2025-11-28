import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user_profile_model.dart';
import '../providers/profile_provider.dart';
import '../widgets/avatar_editable.dart';
import '../widgets/button_primary.dart';

class InformacionPersonalScreen extends ConsumerStatefulWidget {
  const InformacionPersonalScreen({Key? key}) : super(key: key);

  @override
  _InformacionPersonalScreenState createState() =>
      _InformacionPersonalScreenState();
}

class _InformacionPersonalScreenState
    extends ConsumerState<InformacionPersonalScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _shopAddressController;
  late TextEditingController _shopHoursController;
  late TextEditingController _shopDescriptionController;
  late TextEditingController _facebookController;
  late TextEditingController _instagramController;
  late TextEditingController _tiktokController;
  late TextEditingController _whatsappController;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileNotifierProvider).profile;
    _nameController = TextEditingController(text: profile?.name ?? '');
    _emailController = TextEditingController(text: profile?.email ?? '');
    _phoneController = TextEditingController(text: profile?.phone ?? '');
    _shopAddressController =
        TextEditingController(text: profile?.shop_address ?? '');
    _shopHoursController = TextEditingController(text: profile?.shop_hours ?? '');
    _shopDescriptionController =
        TextEditingController(text: profile?.shop_description ?? '');
    _facebookController =
        TextEditingController(text: profile?.social_links?['facebook'] ?? '');
    _instagramController =
        TextEditingController(text: profile?.social_links?['instagram'] ?? '');
    _tiktokController =
        TextEditingController(text: profile?.social_links?['tiktok'] ?? '');
    _whatsappController =
        TextEditingController(text: profile?.social_links?['whatsapp'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _shopAddressController.dispose();
    _shopHoursController.dispose();
    _shopDescriptionController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _tiktokController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final currentProfile = ref.read(profileNotifierProvider).profile;
      if (currentProfile != null) {
        final updatedProfile = currentProfile.copyWith(
          name: _nameController.text,
          phone: _phoneController.text,
          shop_address: _shopAddressController.text,
          shop_hours: _shopHoursController.text,
          shop_description: _shopDescriptionController.text,
          social_links: {
            'facebook': _facebookController.text,
            'instagram': _instagramController.text,
            'tiktok': _tiktokController.text,
            'whatsapp': _whatsappController.text,
          },
        );
        ref
            .read(profileNotifierProvider.notifier)
            .updateUserProfile(updatedProfile);
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileNotifierProvider);
    final profile = profileState.profile;

    return Scaffold(
      appBar: AppBar(
        title: Text('Información Personal', style: GoogleFonts.poppins()),
        backgroundColor: Colors.transparent,
      ),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    AvatarEditable(
                      imageUrl: profile.profilePictureUrl,
                      imagePath: profile.profilePicturePath,
                      radius: 70,
                      onEditPressed: () {
                        ref
                            .read(profileNotifierProvider.notifier)
                            .updateProfilePicture();
                      },
                    ),
                    const SizedBox(height: 40),
                    _buildTextField(
                      controller: _nameController,
                      labelText: 'Nombre Completo',
                      icon: Icons.person_outline,
                      validator: (value) =>
                          value!.isEmpty ? 'El nombre no puede estar vacío' : null,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      icon: Icons.email_outlined,
                      enabled: false, // Email not editable as per description
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _phoneController,
                      labelText: 'Teléfono',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            value.length != 10) {
                          return 'El teléfono debe tener 10 dígitos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _shopAddressController,
                      labelText: 'Dirección de la florería',
                      icon: Icons.store_outlined,
                      validator: (value) => value!.isEmpty
                          ? 'La dirección no puede estar vacía'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _shopHoursController,
                      labelText: 'Horario de atención',
                      icon: Icons.schedule_outlined,
                      validator: (value) => value!.isEmpty
                          ? 'El horario no puede estar vacío'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _shopDescriptionController,
                      labelText: 'Descripción del negocio',
                      icon: Icons.description_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 40),
                    Text('Redes Sociales',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _facebookController,
                      labelText: 'Facebook',
                      icon: Icons.facebook,
                      validator: _validateUrl,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _instagramController,
                      labelText: 'Instagram',
                      icon: Icons.camera_alt_outlined,
                      validator: _validateUrl,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _tiktokController,
                      labelText: 'TikTok',
                      icon: Icons.music_note_outlined,
                      validator: _validateUrl,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _whatsappController,
                      labelText: 'WhatsApp',
                      icon: Icons.wechat_outlined,
                      validator: _validateUrl,
                    ),
                    const SizedBox(height: 40),
                    ButtonPrimary(
                      text: 'Guardar Cambios',
                      onPressed: _saveChanges,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String? _validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final urlPattern = RegExp(
        r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$');
    if (!urlPattern.hasMatch(value)) {
      return 'Por favor ingrese una URL válida';
    }
    return null;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int? maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}

