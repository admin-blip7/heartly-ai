import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Base API service with Dio client setup, error handling, and common HTTP methods
class ApiService {
  late final Dio _dio;
  
  /// Singleton instance
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  
  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: dotenv.env['API_BASE_URL'] ?? 'https://api.heartly.ai/v1',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    // Add interceptors for logging and error handling
    _dio.interceptors.add(_AuthInterceptor());
    _dio.interceptors.add(_ErrorInterceptor());
  }
  
  /// Get the underlying Dio client for advanced usage
  Dio get dio => _dio;
  
  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  /// Upload multipart form data (for images)
  Future<Response> uploadMultipart(
    String path, {
    required FormData formData,
    ProgressCallback? onSendProgress,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  /// Handle Dio errors and convert to custom exceptions
  ApiException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Connection timeout. Please check your internet connection.',
          statusCode: error.response?.statusCode,
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 
                        error.response?.statusMessage ?? 
                        'Unknown error occurred';
        return ApiException(
          message: message,
          statusCode: statusCode,
          data: error.response?.data,
        );
      case DioExceptionType.cancel:
        return ApiException(
          message: 'Request was cancelled',
          statusCode: null,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'No internet connection. Please check your network.',
          statusCode: null,
        );
      case DioExceptionType.badCertificate:
        return ApiException(
          message: 'SSL certificate error. Please contact support.',
          statusCode: null,
        );
      case DioExceptionType.unknown:
      default:
        return ApiException(
          message: error.message ?? 'An unexpected error occurred',
          statusCode: null,
        );
    }
  }
  
  /// Update base URL (useful for environment switching)
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }
  
  /// Set authorization header
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }
  
  /// Clear authorization header
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}

/// Custom API Exception class
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;
  
  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });
  
  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
  
  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode != null && statusCode! >= 500;
  bool get isClientError => statusCode != null && statusCode! >= 400 && statusCode! < 500;
}

/// Auth interceptor for adding tokens to requests
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add any auth logic here if needed
    // The token is already set via setAuthToken method
    super.onRequest(options, handler);
  }
}

/// Error interceptor for logging and error handling
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Log error for debugging (in production, send to crash reporting)
    print('API Error: ${err.type} - ${err.message}');
    
    // Continue with error handling
    super.onError(err, handler);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Log successful responses in debug mode
    print('API Response: ${response.statusCode} - ${response.requestOptions.path}');
    super.onResponse(response, handler);
  }
}
