// lib/services/farmer_request_services.dart
import 'package:dio/dio.dart';
import 'package:grow_right_mobile/config/dio_config.dart';
import 'package:grow_right_mobile/models/farmer_request_payload.dart';
import 'package:grow_right_mobile/models/farmer_request_models.dart';

class FarmerRequestService {
  final Dio _dio = ApiClient().dio;

  Future<String> createFarmerRequest(FarmerRequestPayload payload) async {
    try {
      final res = await _dio.post(
        '/api/farmer-requests',
        data: payload.toJson(),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final msg = (res.data is Map && res.data['message'] is String)
            ? res.data['message'] as String
            : 'success';
        return msg;
      }
      throw Exception('Unexpected status: ${res.statusCode}');
    } on DioException catch (e) {
      final serverMsg = e.response?.data is Map
          ? (e.response!.data['message'] ?? e.message)
          : e.message;
      throw Exception(serverMsg ?? 'Network error');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// GET /api/farmer-requests
  /// Returns all requests for the (server-side) user with latest farmer_response (or null)
  Future<List<FarmerRequestModel>> fetchFarmerRequests() async {
    try {
      final res = await _dio.get('/api/farmer-requests');

      if (res.statusCode == 200) {
        final parsed = FarmerRequestsResponse.fromJson(
          res.data as Map<String, dynamic>,
        );
        return parsed.data;
      }
      throw Exception('Unexpected status: ${res.statusCode}');
    } on DioException catch (e) {
      final serverMsg = e.response?.data is Map
          ? (e.response!.data['message'] ?? e.message)
          : e.message;
      throw Exception(serverMsg ?? 'Network error');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
