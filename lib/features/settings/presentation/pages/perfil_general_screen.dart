import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
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
                      // User Info
                      AvatarEditable(
                        imageUrl: profile.profilePictureUrl,
                        imagePath: profile.profilePicturePath,
                        onEditPressed: () {
                          ref.read(profileNotifierProvider.notifier).updateProfilePicture();
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

                      // Sections
                      _buildSectionCard(
                        context,
                        title: 'Mi Cuenta',
                        items: [
                          CardListItem(
                            title: 'Información Personal',
                            icon: Icons.person_outline,
                            onTap: () {
                              context.go('/profile/informacion-personal');
                            },
                          ),
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
                                ref.read(profileNotifierProvider.notifier).toggleNotifications(value);
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

                      // Logout Button
                      TextButton.icon(
                        icon: const Icon(Icons.logout, color: AppColors.redWine),
                        label: Text(
                          'Cerrar sesión',
                          style: GoogleFonts.poppins(color: AppColors.redWine, fontWeight: FontWeight.bold),
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
