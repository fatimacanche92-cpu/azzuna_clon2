import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue, // Customize color
            ),
            child: Text(
              'Azzuna',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Perfil'),
            onTap: () {
              context.pop(); // Close the drawer
              context.push('/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.book_outlined),
            title: const Text('Catálogo'),
            onTap: () {
              context.pop();
              context.push('/catalogs');
            },
          ),
          ListTile(
            leading: const Icon(Icons.drafts_outlined),
            title: const Text('Borradores'),
            onTap: () {
              context.pop();
              context.push('/drafts');
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment_outlined),
            title: const Text('Encargos'),
            onTap: () {
              context.pop();
              context.push('/encargo');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Ajustes'),
            onTap: () {
              // TODO: Create and navigate to settings page
              context.pop();
            },
          ),
        ],
      ),
    );
  }
}
