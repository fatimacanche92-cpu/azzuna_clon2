import 'package:freezed_annotation/freezed_annotation.dart';
import '../../features/orders/domain/models/order_model.dart'; // Assuming we can reuse the existing OrderModel

part 'seguimiento_inteligente_state.freezed.dart';

// Main state for the view
@freezed
class SeguimientoInteligenteState with _$SeguimientoInteligenteState {
  const factory SeguimientoInteligenteState.loading() = _Loading;
  const factory SeguimientoInteligenteState.data({required CrmData crmData}) =
      _Data;
  const factory SeguimientoInteligenteState.error(String message) = _Error;
}

// A container for all the grouped client data
@freezed
class CrmData with _$CrmData {
  const factory CrmData({
    required List<CrmClient> proximosEventos,
    required List<CrmClient> clientesRecurrentes,
    required List<CrmClient> clientesFrecuentes,
    required List<CrmClient> fechasEspeciales,
    required List<CrmClient> patronesDetectados,
  }) = _CrmData;
}

// Represents a client within the CRM module
@freezed
class CrmClient with _$CrmClient {
  const factory CrmClient({
    required String id,
    required String name,
    String? photoUrl,
    required DateTime lastPurchaseDate,
    required String lastPurchaseSummary,
    DateTime? nextSpecialDate,
    String? nextSpecialDateSummary,
    // Detailed data for the expansion view
    required List<OrderModel> purchaseHistory,
    required List<SpecialDate> specialDates,
    required List<String> favoriteFlowers,
    required List<String> favoriteColors,
    required String purchaseFrequency,
    required String favoriteOccasion,
    required List<String> previousNotes,
    required double averageSpending,
    required AiRecommendation recommendation,
  }) = _CrmClient;
}

// A simple model for special dates
@freezed
class SpecialDate with _$SpecialDate {
  const factory SpecialDate({
    required DateTime date,
    required String occasionName,
  }) = _SpecialDate;
}

// Represents the output from the AI recommender
@freezed
class AiRecommendation with _$AiRecommendation {
  const factory AiRecommendation({
    required String suggestion,
    required String reason,
    @Default(false) bool requiresAction,
  }) = _AiRecommendation;
}
