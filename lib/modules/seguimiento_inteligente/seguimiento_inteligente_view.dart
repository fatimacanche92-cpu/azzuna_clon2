import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_app/modules/seguimiento_inteligente/seguimiento_inteligente_state.dart';
import 'package:flutter_app/modules/seguimiento_inteligente/seguimiento_inteligente_controller.dart';
import 'widgets/cliente_card.dart';

class SeguimientoInteligenteView extends ConsumerWidget {
  const SeguimientoInteligenteView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(seguimientoControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Seguimiento Inteligente',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        data: (crmData) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSection(
                context,
                'Próximos eventos',
                crmData.proximosEventos,
              ),
              _buildSection(
                context,
                'Clientes recurrentes',
                crmData.clientesRecurrentes,
              ),
              _buildSection(
                context,
                'Clientes frecuentes',
                crmData.clientesFrecuentes,
              ),
              _buildSection(
                context,
                'Fechas especiales cercanas',
                crmData.fechasEspeciales,
              ),
              _buildSection(
                context,
                'Patrones detectados por IA',
                crmData.patronesDetectados,
              ),
            ],
          );
        },
        error: (message) => Center(
          child: Text(
            'Error: $message',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<CrmClient> clients,
  ) {
    if (clients.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: clients.length,
          itemBuilder: (context, index) {
            final client = clients[index];
            return ClienteCard(client: client);
          },
        ),
      ],
    );
  }
}
