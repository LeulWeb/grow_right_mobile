// lib/models/farmer_request_models.dart
import 'dart:convert';

class FarmerRequestsResponse {
  final List<FarmerRequestModel> data;

  FarmerRequestsResponse({required this.data});

  factory FarmerRequestsResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List? ?? [])
        .map((e) => FarmerRequestModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return FarmerRequestsResponse(data: list);
  }

  static FarmerRequestsResponse fromRaw(String raw) =>
      FarmerRequestsResponse.fromJson(json.decode(raw));
}

class FarmerRequestModel {
  final int id;
  final int userId;
  final int soilId;
  final int seasonId;
  final String? soilImage;
  final String? accuracy;
  final bool hasIrrigation;
  final String goals;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double? lat; // may arrive as String -> parsed
  final double? lng; // may arrive as String -> parsed
  final String address;
  final FarmerResponseModel? farmerResponse;

  FarmerRequestModel({
    required this.id,
    required this.userId,
    required this.soilId,
    required this.seasonId,
    required this.soilImage,
    required this.accuracy,
    required this.hasIrrigation,
    required this.goals,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.lat,
    required this.lng,
    required this.address,
    required this.farmerResponse,
  });

  factory FarmerRequestModel.fromJson(Map<String, dynamic> json) {
    return FarmerRequestModel(
      id: _asInt(json['id']),
      userId: _asInt(json['user_id']),
      soilId: _asInt(json['soil_id']),
      seasonId: _asInt(json['season_id']),
      soilImage: json['soil_image'] as String?,
      accuracy: json['accuracy'] as String?,
      hasIrrigation:
          (json['has_irrigation'] == true) ||
          (json['has_irrigation'] == 1) ||
          (json['has_irrigation'] == '1'),
      goals: json['goals']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdAt: _asDate(json['created_at']),
      updatedAt: _asDate(json['updated_at']),
      lat: _asDouble(json['lat']),
      lng: _asDouble(json['lng']),
      address: json['address']?.toString() ?? '',
      farmerResponse: json['farmer_response'] == null
          ? null
          : FarmerResponseModel.fromJson(
              json['farmer_response'] as Map<String, dynamic>,
            ),
    );
  }
}

class FarmerResponseModel {
  final int id;
  final int farmerRequestId;
  final List<RecommendationItem> recommendations; // flexible list
  final String? reasoning;
  final String? plantingWindows;

  /// "l" | "m" | "h" (low/medium/high); keep string for flexibility
  final String? marketDemand;
  final dynamic aiRaw; // might be null or JSON
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FarmerResponseModel({
    required this.id,
    required this.farmerRequestId,
    required this.recommendations,
    required this.reasoning,
    required this.plantingWindows,
    required this.marketDemand,
    required this.aiRaw,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FarmerResponseModel.fromJson(Map<String, dynamic> json) {
    final recList = (json['recommendations'] as List? ?? [])
        .map((e) => RecommendationItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return FarmerResponseModel(
      id: _asInt(json['id']),
      farmerRequestId: _asInt(json['farmer_request_id']),
      recommendations: recList,
      reasoning: json['reasoning'] as String?,
      plantingWindows: json['planting_windows'] as String?,
      marketDemand: json['market_demand']?.toString(),
      aiRaw: json['ai_raw'],
      createdAt: _asDate(json['created_at']),
      updatedAt: _asDate(json['updated_at']),
    );
  }
}

class RecommendationItem {
  final String value;

  RecommendationItem({required this.value});

  factory RecommendationItem.fromJson(Map<String, dynamic> json) {
    // In case backend sends just string in the future, handle both
    if (json.containsKey('value')) {
      return RecommendationItem(value: json['value']?.toString() ?? '');
    }
    return RecommendationItem(value: json.values.first?.toString() ?? '');
  }
}

/// ---- helpers ----
int _asInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

double? _asDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

DateTime? _asDate(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString());
}
