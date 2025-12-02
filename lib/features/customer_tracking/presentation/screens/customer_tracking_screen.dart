import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/features/customer_tracking/domain/customer_event.dart';
import 'package:flutter_app/features/customer_tracking/presentation/providers/customer_tracking_providers.dart';
import 'package:flutter_app/features/customer_tracking/presentation/widgets/customer_event_card.dart';

class CustomerTrackingScreen extends ConsumerWidget {
  const CustomerTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerTrackingNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguimiento de Clientes'),
        backgroundColor: theme.primaryColor,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(customerTrackingNotifierProvider.notifier).loadEvents(),
        child: _buildBody(context, state),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/customer-tracking/add-event');
        },
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody(BuildContext context, CustomerTrackingState state) {
    if (state.isLoading && state.events.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return Center(child: Text(state.errorMessage!));
    }

    if (state.events.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No hay eventos de clientes registrados.\nToca el botón "+" para añadir uno nuevo.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    // Separate events into sections
    final now = DateTime.now();
    final upcomingEvents = state.events
        .where(
          (e) =>
              e.eventDate.isAfter(now) &&
              e.eventDate.difference(now).inDays <= 30,
        )
        .toList();

    final otherEvents = state.events
        .where((e) => !upcomingEvents.contains(e))
        .toList();

    return ListView(
      children: [
        if (upcomingEvents.isNotEmpty)
          _buildSectionHeader('Próximos eventos', context),
        ...upcomingEvents.map((event) => CustomerEventCard(event: event)),

        if (otherEvents.isNotEmpty)
          _buildSectionHeader('Todos los eventos', context),
        ...otherEvents.map((event) => CustomerEventCard(event: event)),

        const SizedBox(height: 80), // Space for FAB
      ],
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
