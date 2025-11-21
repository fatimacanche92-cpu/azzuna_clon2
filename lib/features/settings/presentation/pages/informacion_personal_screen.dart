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

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileNotifierProvider).profile;
    _nameController = TextEditingController(text: profile?.name ?? '');
    _emailController = TextEditingController(text: profile?.email ?? '');
    _phoneController = TextEditingController(text: profile?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final currentProfile = ref.read(profileNotifierProvider).profile;
      if (currentProfile != null) {
        final updatedProfile = currentProfile.copyWith(
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
        );
        ref.read(profileNotifierProvider.notifier).updateUserProfile(updatedProfile);
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
                        ref.read(profileNotifierProvider.notifier).updateProfilePicture();
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
                        if (value != null && value.isNotEmpty && value.length != 10) {
                          return 'El teléfono debe tener 10 dígitos';
                        }
                        return null;
                      },
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
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
