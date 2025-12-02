import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/theme.dart';
import 'package:flutter_app/features/settings/data/profile_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/avatar_editable.dart';
import '../widgets/card_list_item.dart';

class PerfilGeneralScreen extends ConsumerWidget {
  const PerfilGeneralScreen({Key? key}) : super(key: key);

 @override
Widget build(BuildContext context, WidgetRef ref) {
  final profileAsync = ref.watch(profileFutureProvider);

  return Scaffold(
    appBar: AppBar(
      title: const Text("Mi Perfil"),
    ),

    body: profileAsync.when(
      data: (profile) {
        if (profile == null) {
          return const Center(child: Text("Perfil no encontrado."));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text("Nombre: ${profile['full_name'] ?? '---'}"),
            Text("Correo: ${profile['email'] ?? '---'}"),
            Text("Teléfono: ${profile['phone'] ?? '---'}"),
            Text("Dirección: ${profile['address'] ?? '---'}"),
            Text("Horario: ${profile['schedule'] ?? '---'}"),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("Error cargando perfil: $e")),
    ),
  );
}

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(value, style: GoogleFonts.poppins(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinks(Map<String, dynamic> links) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (links['facebook'] != null && links['facebook'].isNotEmpty)
            _buildSocialIcon(Icons.facebook, links['facebook']),
          if (links['instagram'] != null && links['instagram'].isNotEmpty)
            _buildSocialIcon(Icons.camera_alt_outlined, links['instagram']),
          if (links['tiktok'] != null && links['tiktok'].isNotEmpty)
            _buildSocialIcon(Icons.music_note_outlined, links['tiktok']),
          if (links['whatsapp'] != null && links['whatsapp'].isNotEmpty)
            _buildSocialIcon(Icons.wechat_outlined, links['whatsapp']),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, String url) {
    return IconButton(
      icon: Icon(icon, color: AppColors.redWine, size: 30),
      onPressed: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required List<Widget> items,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[500],
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...items,
          ],
        ),
      ),
    );
  }
}
