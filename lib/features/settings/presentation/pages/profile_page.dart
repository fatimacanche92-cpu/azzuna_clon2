import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

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
    final user = Supabase.instance.client.auth.currentUser;

    final data = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', user!.id)
        .single();

    setState(() {
      nameController.text = data['full_name'] ?? '';
      phoneController.text = data['phone'] ?? '';
      addressController.text = data['address'] ?? '';
      scheduleController.text = data['schedule'] ?? '';
      avatarUrl = data['avatar_url'];
    });
  }

  Future<void> saveProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      print('User is not logged in.');
      return;
    }

    final updates = {
      'full_name': nameController.text,
      'phone': phoneController.text,
      'address': addressController.text,
      'schedule': scheduleController.text,
      'avatar_url': avatarUrl,
    };
    print('Saving profile with data: $updates');

    try {
      await Supabase.instance.client.from('profiles').update(updates).eq('id', user.id);
      print('Profile saved successfully.');

      setState(() => isEditing = false);
    } catch (e) {
      print('Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar el perfil: $e')),
        );
      }
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;
    print('Picked image: ${picked.path}');

    final bytes = await picked.readAsBytes();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    print('Uploading with filename: $fileName');

    try {
      await Supabase.instance.client.storage
          .from('avatars')
          .uploadBinary(fileName, bytes, fileOptions: const FileOptions(upsert: true));

      final publicUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(fileName);
      print('Got public URL: $publicUrl');

      setState(() {
        avatarUrl = publicUrl;
      });
    } catch (e) {
      print('Error uploading image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir la imagen: $e')),
        );
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