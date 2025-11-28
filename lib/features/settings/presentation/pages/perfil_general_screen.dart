import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/theme.dart';
import '../providers/profile_provider.dart';
import '../widgets/avatar_editable.dart';
import '../widgets/card_list_item.dart';

class PerfilGeneralScreen extends ConsumerWidget {
  const PerfilGeneralScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileNotifierProvider);
    final profile = profileState.profile;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: Text('Mi Perfil', style: GoogleFonts.poppins()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: profileState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : profile == null
              ? const Center(child: Text('No se pudo cargar el perfil.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      AvatarEditable(
                        imageUrl: profile.profilePictureUrl,
                        onEditPressed: () {
                          context.go('/profile/informacion-personal');
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        profile.name,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.email,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () {
                          context.go('/profile/informacion-personal');
                        },
                        child: const Text('Editar Perfil'),
                      ),
                      const SizedBox(height: 32),
                      _buildSectionCard(
                        context,
                        title: 'Florería',
                        items: [
                          if (profile.shop_address != null &&
                              profile.shop_address!.isNotEmpty)
                            _buildInfoItem(Icons.store_outlined,
                                'Dirección', profile.shop_address!),
                          if (profile.shop_hours != null &&
                              profile.shop_hours!.isNotEmpty)
                            _buildInfoItem(Icons.schedule_outlined,
                                'Horario', profile.shop_hours!),
                          if (profile.shop_description != null &&
                              profile.shop_description!.isNotEmpty)
                            _buildInfoItem(
                                Icons.description_outlined,
                                'Descripción',
                                profile.shop_description!),
                          if (profile.social_links != null)
                            _buildSocialLinks(profile.social_links!),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSectionCard(
                        context,
                        title: 'Mi Cuenta',
                        items: [
                          CardListItem(
                            title: 'Direcciones Guardadas',
                            icon: Icons.location_on_outlined,
                            onTap: () {
                              context.go('/profile/direcciones-guardadas');
                            },
                          ),
                          CardListItem(
                            title: 'Historial de Pedidos',
                            icon: Icons.history_outlined,
                            onTap: () {
                              context.go('/orders');
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSectionCard(
                        context,
                        title: 'Preferencias y Ajustes',
                        items: [
                          CardListItem(
                            title: 'Notificaciones',
                            icon: Icons.notifications_none_outlined,
                            trailing: Switch(
                              value: profile.notificationsEnabled,
                              onChanged: (value) {
                                ref
                                    .read(profileNotifierProvider.notifier)
                                    .toggleNotifications(value);
                              },
                              activeColor: AppColors.redWine,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSectionCard(
                        context,
                        title: 'Ayuda y enlaces',
                        items: [
                          CardListItem(
                            title: 'Ayuda y Soporte',
                            icon: Icons.help_outline,
                            onTap: () {},
                          ),
                          CardListItem(
                            title: 'Términos y Condiciones',
                            icon: Icons.description_outlined,
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      TextButton.icon(
                        icon: const Icon(Icons.logout, color: AppColors.redWine),
                        label: Text(
                          'Cerrar sesión',
                          style: GoogleFonts.poppins(
                              color: AppColors.redWine,
                              fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          // ignore: avoid_print
                          print('Logout requested');
                        },
                      ),
                    ],
                  ),
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
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
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

  Widget _buildSectionCard(BuildContext context,
      {required String title, required List<Widget> items}) {
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
