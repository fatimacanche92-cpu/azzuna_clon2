import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final scheduleController = TextEditingController();

  String? avatarUrl;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        print('User is not logged in.');
        return;
      }

      print('Loading profile for user: ${user.id}');
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data == null) {
        print('No profile found, creating empty one...');
        // Profile doesn't exist, try to create it
        try {
          await Supabase.instance.client.from('profiles').insert({
            'id': user.id,
            'full_name': user.email ?? 'Usuario',
            'email': user.email,
          });
          print('Profile created successfully.');
        } catch (e) {
          print('Error creating profile: $e');
        }
        return;
      }

      if (mounted) {
        setState(() {
          nameController.text = data['full_name'] ?? '';
          phoneController.text = data['phone'] ?? '';
          addressController.text = data['address'] ?? '';
          scheduleController.text = data['schedule'] ?? '';
          avatarUrl = data['avatar_url'];
        });
      }
      print('Profile loaded successfully.');
    } catch (e) {
      print('Error loading profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar el perfil: $e')),
        );
      }
    }
  }

  Future<void> saveProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      print('User is not logged in.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes iniciar sesión para guardar el perfil')),
        );
      }
      return;
    }

    // Show loading indicator
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Guardando perfil...'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    final updates = {
      'full_name': nameController.text.trim(),
      'phone': phoneController.text.trim(),
      'address': addressController.text.trim(),
      'schedule': scheduleController.text.trim(),
      'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    };
    print('Saving profile with data: $updates');

    try {
      await Supabase.instance.client
          .from('profiles')
          .update(updates)
          .eq('id', user.id);
      print('Profile saved successfully.');

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Perfil guardado exitosamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        setState(() => isEditing = false);
      }
    } catch (e, st) {
      print('Error saving profile: $e');
      print('Stacktrace: $st');
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ Error al guardar: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;
    print('Picked image: ${picked.path}');

    final file = File(picked.path);
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes iniciar sesión para subir imagen')),
        );
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Subiendo imagen...'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    final fileName = '${user.id}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

    int attempts = 0;
    const maxAttempts = 3;
    
    while (attempts < maxAttempts) {
      attempts += 1;
      try {
        print('Uploading avatar attempt $attempts for $fileName');
        
        await Supabase.instance.client.storage
            .from('avatars')
            .upload(
              fileName,
              file,
              fileOptions: const FileOptions(upsert: true, cacheControl: '3600'),
            );

        final publicUrl = Supabase.instance.client.storage
            .from('avatars')
            .getPublicUrl(fileName);
        print('Got public URL: $publicUrl');

        // Update profile in DB
        try {
          await Supabase.instance.client
              .from('profiles')
              .update({
                'avatar_url': publicUrl,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', user.id);
          print('Profile avatar_url updated in database.');
        } catch (dbErr) {
          print('Warning: could not update profile avatar_url in DB: $dbErr');
          // Don't fail the upload if DB update fails, the URL is still valid
        }

        if (mounted) {
          setState(() {
            avatarUrl = publicUrl;
          });
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Imagen subida exitosamente'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      } catch (e, st) {
        print('Upload attempt $attempts failed: $e');
        print('Stacktrace: $st');
        
        if (attempts >= maxAttempts) {
          if (mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✗ Error al subir imagen (intento $attempts/$maxAttempts): $e'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
          return;
        } else {
          // Wait before retrying
          print('Retrying in 700ms...');
          await Future.delayed(const Duration(milliseconds: 700));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Perfil"),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (isEditing) {
                saveProfile();
              } else {
                setState(() => isEditing = true);
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // AVATAR
              GestureDetector(
                onTap: isEditing ? pickImage : null,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                  child: avatarUrl == null
                      ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              // CAMPOS
              buildField("Nombre", nameController, isEditing),
              buildField("Teléfono", phoneController, isEditing),
              buildField("Dirección", addressController, isEditing),
              buildField("Horario", scheduleController, isEditing),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildField(String title, TextEditingController controller, bool enabled) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: title.toLowerCase().contains('tel') ? TextInputType.number : TextInputType.text,
          inputFormatters: title.toLowerCase().contains('tel')
              ? <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ]
              : null,
          decoration: const InputDecoration(
            filled: true,
            fillColor: Color(0xFFF2E0D5), // color crema Azzuna
            border: OutlineInputBorder(borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}