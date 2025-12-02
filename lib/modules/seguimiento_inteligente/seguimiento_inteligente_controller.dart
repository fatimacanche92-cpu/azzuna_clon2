import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/modules/seguimiento_inteligente/seguimiento_inteligente_state.dart';
import 'package:flutter_app/features/orders/domain/models/order_model.dart';
import 'ia/recomendador_ia.dart';

// Provider for the controller
final seguimientoControllerProvider =
    StateNotifierProvider<SeguimientoController, SeguimientoInteligenteState>((
      ref,
    ) {
      // In a real app, you would pass the Supabase client or a repository here
      return SeguimientoController(ref);
    });

class SeguimientoController extends StateNotifier<SeguimientoInteligenteState> {
  final Ref _ref;
  final AIRecommender _aiRecommender = AIRecommender();

  SeguimientoController(this._ref)
    : super(const SeguimientoInteligenteState.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      // 1. Fetch data (using dummy data for now)
      final clients = await _fetchDummyData();

      // 2. Process and group data
      final crmData = await _groupClients(clients);

      // 3. Update state
      state = SeguimientoInteligenteState.data(crmData: crmData);
    } catch (e) {
      state = SeguimientoInteligenteState.error(e.toString());
    }
  }

  Future<CrmData> _groupClients(List<CrmClient> clients) async {
    // This is where you'd implement the business logic for grouping
    final now = DateTime.now();

    // Example grouping logic
    final proximosEventos = clients
        .where(
          (c) =>
              c.nextSpecialDate != null &&
              c.nextSpecialDate!.isAfter(now) &&
              c.nextSpecialDate!.difference(now).inDays <= 30,
        )
        .toList();

    final clientesRecurrentes = clients
        .where((c) => c.purchaseHistory.length > 3)
        .toList();

    // In a real app, you would have more sophisticated logic here
    final clientesFrecuentes = clients
        .where((c) => c.purchaseFrequency.contains('Mensual'))
        .toList();

    final patronesDetectados = clients
        .where((c) => c.recommendation.requiresAction)
        .toList();

    return CrmData(
      proximosEventos: proximosEventos,
      clientesRecurrentes: clientesRecurrentes,
      clientesFrecuentes: clientesFrecuentes,
      fechasEspeciales: proximosEventos, // Reusing for this example
      patronesDetectados: patronesDetectados,
    );
  }

  // --- Data Fetching ---
  // This section would contain the real Supabase queries.
  // For now, it returns rich dummy data.
  Future<List<CrmClient>> _fetchDummyData() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final dummyOrdersClient1 = [
      OrderModel(
        id: '101',
        clientName: 'Ana López',
        arrangementType: 'Ramo de Rosas Rojas',
        scheduledDate: DateTime.now().subtract(const Duration(days: 30)),
        deliveryType: OrderDeliveryType.envio,
        paymentStatus: OrderPaymentStatus.pagado,
        price: 750,
        arrangementColor: 'Rojo',
        arrangementFlowerType: 'Rosas',
      ),
      OrderModel(
        id: '102',
        clientName: 'Ana López',
        arrangementType: 'Arreglo de Girasoles',
        scheduledDate: DateTime.now().subtract(const Duration(days: 120)),
        deliveryType: OrderDeliveryType.envio,
        paymentStatus: OrderPaymentStatus.pagado,
        price: 600,
        arrangementColor: 'Amarillo',
        arrangementFlowerType: 'Girasoles',
      ),
      OrderModel(
        id: '103',
        clientName: 'Ana López',
        arrangementType: 'Ramo de Tulipanes',
        scheduledDate: DateTime.now().subtract(const Duration(days: 370)),
        deliveryType: OrderDeliveryType.envio,
        paymentStatus: OrderPaymentStatus.pagado,
        price: 800,
        arrangementColor: 'Rosa',
        arrangementFlowerType: 'Tulipanes',
      ),
    ];

    final dummyOrdersClient2 = [
      OrderModel(
        id: '201',
        clientName: 'Carlos Pérez',
        arrangementType: 'Caja de Chocolates y Flores',
        scheduledDate: DateTime.now().subtract(const Duration(days: 7)),
        deliveryType: OrderDeliveryType.recoger,
        paymentStatus: OrderPaymentStatus.pagado,
        price: 950,
        arrangementColor: 'Variado',
        arrangementFlowerType: 'Rosas y Lirios',
      ),
    ];

    final client1 = CrmClient(
      id: 'cli_001',
      name: 'Ana López',
      photoUrl: 'https://i.pravatar.cc/150?u=ana',
      lastPurchaseDate: dummyOrdersClient1.first.scheduledDate,
      lastPurchaseSummary: dummyOrdersClient1.first.arrangementType,
      nextSpecialDate: DateTime.now().add(const Duration(days: 15)),
      nextSpecialDateSummary: 'Aniversario en 15 días',
      purchaseHistory: dummyOrdersClient1,
      specialDates: [
        SpecialDate(
          date: DateTime.now().add(const Duration(days: 15)),
          occasionName: 'Aniversario',
        ),
        SpecialDate(
          date: DateTime(DateTime.now().year, 8, 20),
          occasionName: 'Cumpleaños',
        ),
      ],
      favoriteFlowers: ['Rosas', 'Girasoles'],
      favoriteColors: ['Rojo', 'Amarillo'],
      purchaseFrequency: 'Trimestral',
      favoriteOccasion: 'Aniversario',
      previousNotes: [
        'Le gustan las tarjetas con mensaje corto.',
        'Prefiere entregas por la mañana.',
      ],
      averageSpending: 750.0,
      recommendation: await _aiRecommender.analizarCliente(dummyOrdersClient1, {
        'name': 'Ana López',
        'special_dates': [DateTime.now().add(const Duration(days: 15))],
      }),
    );

    final client2 = CrmClient(
      id: 'cli_002',
      name: 'Carlos Pérez',
      photoUrl: 'https://i.pravatar.cc/150?u=carlos',
      lastPurchaseDate: dummyOrdersClient2.first.scheduledDate,
      lastPurchaseSummary: dummyOrdersClient2.first.arrangementType,
      nextSpecialDate: DateTime.now().add(const Duration(days: 1)),
      nextSpecialDateSummary: 'Cumpleaños de su esposa mañana',
      purchaseHistory: dummyOrdersClient2,
      specialDates: [
        SpecialDate(
          date: DateTime.now().add(const Duration(days: 1)),
          occasionName: 'Cumpleaños de Esposa',
        ),
      ],
      favoriteFlowers: ['Rosas', 'Lirios'],
      favoriteColors: ['Blanco', 'Rojo'],
      purchaseFrequency: 'Esporádica',
      favoriteOccasion: 'Cumpleaños',
      previousNotes: ['Siempre pide envoltura de regalo premium.'],
      averageSpending: 950.0,
      recommendation: await _aiRecommender.analizarCliente(dummyOrdersClient2, {
        'name': 'Carlos Pérez',
        'special_dates': [DateTime.now().add(const Duration(days: 1))],
      }),
    );

    return [client1, client2];
  }

  // --- SUPABASE PLACEHOLDER ---
  // In a real implementation, you would use this method.
  Future<void> _fetchFromSupabase() async {
    // final supabase = _ref.read(supabaseProvider); // Assuming you have a Supabase provider
    // final response = await supabase.from('clientes').select('''
    //   *,
    //   pedidos(*),
    //   fechas_especiales(*)
    // ''');
    //
    // if (response.error != null) {
    //   throw Exception('Failed to fetch clients: ${response.error!.message}');
    // }
    //
    // final List<dynamic> data = response.data;
    // final clients = data.map((clientData) => CrmClient.fromJson(clientData)).toList();
    // state = SeguimientoInteligenteState.data(crmData: _groupClients(clients));
  }
}
