import 'package:dio/dio.dart';
import '../models/api_response.dart';

class ApiService {
  final Dio _dio = Dio();
  static const String _baseUrl = 'https://bd.maido.io/api.json';

  ApiService() {
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  Future<ApiResponse> fetchArchive() async {
    try {
      final response = await _dio.get(_baseUrl);

      if (response.statusCode == 200) {
        return ApiResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to load archive: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load archive: $e');
    }
  }
}
