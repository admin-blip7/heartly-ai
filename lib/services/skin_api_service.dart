import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'api_service.dart';

/// Service for skin analysis API operations
/// Integrates with AILabTools for analysis and Replicate for image generation
class SkinApiService {
  final ApiService _apiService;
  
  // API endpoints (configured via environment)
  late final String _ailabBaseUrl;
  late final String _replicateBaseUrl;
  late final String _ailabApiKey;
  late final String _replicateApiKey;
  
  /// Singleton instance
  static final SkinApiService _instance = SkinApiService._internal();
  factory SkinApiService() => _instance;
  
  SkinApiService._internal() : _apiService = ApiService() {
    _ailabBaseUrl = dotenv.env['AILAB_BASE_URL'] ?? 'https://api.ailabtools.com/v1';
    _replicateBaseUrl = dotenv.env['REPLICATE_BASE_URL'] ?? 'https://api.replicate.com/v1';
    _ailabApiKey = dotenv.env['AILAB_API_KEY'] ?? '';
    _replicateApiKey = dotenv.env['REPLICATE_API_KEY'] ?? '';
  }
  
  /// Analyze skin from an image
  /// Returns a SkinAnalysis object with detected defects and scores
  Future<SkinAnalysis> analyzeSkin(File image) async {
    try {
      // Prepare multipart form data
      final fileName = image.path.split('/').last;
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          image.path,
          filename: fileName,
        ),
        'analysis_type': 'comprehensive',
      });
      
      // Create options with AILabTools auth
      final options = Options(
        headers: {
          'Authorization': 'Bearer $_ailabApiKey',
          'X-API-Key': _ailabApiKey,
        },
      );
      
      // Create a separate Dio instance for AILabTools
      final dio = Dio(BaseOptions(
        baseUrl: _ailabBaseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 120),
      ));
      
      final response = await dio.post(
        '/skin/analyze',
        data: formData,
        options: options,
      );
      
      if (response.statusCode == 200 && response.data != null) {
        return SkinAnalysis.fromJson(response.data);
      } else {
        throw ApiException(
          message: 'Failed to analyze skin',
          statusCode: response.statusCode,
          data: response.data,
        );
      }
    } on DioException catch (e) {
      throw ApiException(
        message: e.response?.data?['message'] ?? 'Skin analysis failed',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    } catch (e) {
      throw ApiException(message: 'Unexpected error during skin analysis: $e');
    }
  }
  
  /// Generate worst-case visualization image
  /// Uses AI to show what skin could look like if conditions worsen
  Future<String> generateWorstCaseImage(File image, Map<String, dynamic> defects) async {
    try {
      // Prepare the request for image generation
      final fileName = image.path.split('/').last;
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          image.path,
          filename: fileName,
        ),
        'defects': defects,
        'enhancement_level': 'severe',
        'preserve_features': true,
      });
      
      // Use Replicate API for image generation
      final dio = Dio(BaseOptions(
        baseUrl: _replicateBaseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 180),
      ));
      
      final options = Options(
        headers: {
          'Authorization': 'Token $_replicateApiKey',
          'Content-Type': 'multipart/form-data',
        },
      );
      
      // Start prediction
      final predictionResponse = await dio.post(
        '/predictions',
        data: formData,
        options: options,
      );
      
      if (predictionResponse.statusCode != 201) {
        throw ApiException(
          message: 'Failed to start worst-case image generation',
          statusCode: predictionResponse.statusCode,
        );
      }
      
      final predictionId = predictionResponse.data['id'];
      
      // Poll for result
      return await _pollForResult(dio, predictionId, options);
    } on DioException catch (e) {
      throw ApiException(
        message: e.response?.data?['message'] ?? 'Failed to generate worst-case image',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Unexpected error: $e');
    }
  }
  
  /// Generate best-case visualization image
  /// Uses AI to show what skin could look like with optimal care
  Future<String> generateBestCaseImage(File image) async {
    try {
      final fileName = image.path.split('/').last;
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          image.path,
          filename: fileName,
        ),
        'enhancement_type': 'skin_improvement',
        'enhancement_level': 'optimal',
        'preserve_features': true,
      });
      
      // Use Replicate API for image generation
      final dio = Dio(BaseOptions(
        baseUrl: _replicateBaseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 180),
      ));
      
      final options = Options(
        headers: {
          'Authorization': 'Token $_replicateApiKey',
          'Content-Type': 'multipart/form-data',
        },
      );
      
      // Start prediction
      final predictionResponse = await dio.post(
        '/predictions',
        data: formData,
        options: options,
      );
      
      if (predictionResponse.statusCode != 201) {
        throw ApiException(
          message: 'Failed to start best-case image generation',
          statusCode: predictionResponse.statusCode,
        );
      }
      
      final predictionId = predictionResponse.data['id'];
      
      // Poll for result
      return await _pollForResult(dio, predictionId, options);
    } on DioException catch (e) {
      throw ApiException(
        message: e.response?.data?['message'] ?? 'Failed to generate best-case image',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Unexpected error: $e');
    }
  }
  
  /// Poll Replicate API for prediction result
  Future<String> _pollForResult(Dio dio, String predictionId, Options options) async {
    const maxAttempts = 60; // 5 minutes max (5 seconds each)
    var attempts = 0;
    
    while (attempts < maxAttempts) {
      await Future.delayed(const Duration(seconds: 5));
      attempts++;
      
      try {
        final statusResponse = await dio.get(
          '/predictions/$predictionId',
          options: options,
        );
        
        final status = statusResponse.data['status'];
        
        if (status == 'succeeded') {
          final output = statusResponse.data['output'];
          if (output is String) {
            return output;
          } else if (output is List && output.isNotEmpty) {
            return output.first;
          }
          throw ApiException(message: 'Invalid output format from image generation');
        } else if (status == 'failed') {
          throw ApiException(
            message: statusResponse.data['error'] ?? 'Image generation failed',
          );
        }
        // Continue polling if status is 'starting' or 'processing'
      } on DioException catch (e) {
        if (e.response?.statusCode != null && e.response!.statusCode! >= 500) {
          // Retry on server errors
          continue;
        }
        throw ApiException(
          message: 'Failed to check generation status',
          statusCode: e.response?.statusCode,
        );
      }
    }
    
    throw ApiException(message: 'Image generation timed out');
  }
  
  /// Get skin analysis by ID (for retrieving past analyses)
  Future<SkinAnalysis> getAnalysisById(String analysisId) async {
    try {
      final response = await _apiService.get('/skin/analysis/$analysisId');
      return SkinAnalysis.fromJson(response.data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to get analysis: $e');
    }
  }
  
  /// Get analysis history for current user
  Future<List<SkinAnalysis>> getAnalysisHistory({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _apiService.get(
        '/skin/analysis/history',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );
      
      final List<dynamic> data = response.data['analyses'] ?? response.data;
      return data.map((json) => SkinAnalysis.fromJson(json)).toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to get analysis history: $e');
    }
  }
}

/// Skin Analysis Model
class SkinAnalysis {
  final String id;
  final DateTime createdAt;
  final String imageUrl;
  final int overallScore;
  final Map<String, SkinDefect> defects;
  final List<String> recommendations;
  final String? worstCaseImageUrl;
  final String? bestCaseImageUrl;
  
  SkinAnalysis({
    required this.id,
    required this.createdAt,
    required this.imageUrl,
    required this.overallScore,
    required this.defects,
    required this.recommendations,
    this.worstCaseImageUrl,
    this.bestCaseImageUrl,
  });
  
  factory SkinAnalysis.fromJson(Map<String, dynamic> json) {
    final defectsMap = <String, SkinDefect>{};
    if (json['defects'] != null && json['defects'] is Map) {
      (json['defects'] as Map).forEach((key, value) {
        defectsMap[key.toString()] = SkinDefect.fromJson(value);
      });
    }
    
    return SkinAnalysis(
      id: json['id'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      imageUrl: json['image_url'] ?? '',
      overallScore: json['overall_score'] ?? 0,
      defects: defectsMap,
      recommendations: List<String>.from(json['recommendations'] ?? []),
      worstCaseImageUrl: json['worst_case_image_url'],
      bestCaseImageUrl: json['best_case_image_url'],
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'created_at': createdAt.toIso8601String(),
    'image_url': imageUrl,
    'overall_score': overallScore,
    'defects': defects.map((key, value) => MapEntry(key, value.toJson())),
    'recommendations': recommendations,
    'worst_case_image_url': worstCaseImageUrl,
    'best_case_image_url': bestCaseImageUrl,
  };
}

/// Skin Defect Model
class SkinDefect {
  final String name;
  final double severity;
  final double confidence;
  final String? description;
  final String? location;
  
  SkinDefect({
    required this.name,
    required this.severity,
    required this.confidence,
    this.description,
    this.location,
  });
  
  factory SkinDefect.fromJson(Map<String, dynamic> json) {
    return SkinDefect(
      name: json['name'] ?? '',
      severity: (json['severity'] ?? 0).toDouble(),
      confidence: (json['confidence'] ?? 0).toDouble(),
      description: json['description'],
      location: json['location'],
    );
  }
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'severity': severity,
    'confidence': confidence,
    'description': description,
    'location': location,
  };
}
