import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'api_service.dart';

/// Service for age prediction and visualization
/// Uses Microsoft Face API for age detection
class AgePredictionService {
  final ApiService _apiService;
  
  // Microsoft Face API configuration
  late final String _faceApiBaseUrl;
  late final String _faceApiKey;
  
  /// Singleton instance
  static final AgePredictionService _instance = AgePredictionService._internal();
  factory AgePredictionService() => _instance;
  
  AgePredictionService._internal() : _apiService = ApiService() {
    _faceApiBaseUrl = dotenv.env['MS_FACE_API_URL'] ?? 
        'https://westus.api.cognitive.microsoft.com/face/v1.0';
    _faceApiKey = dotenv.env['MS_FACE_API_KEY'] ?? '';
  }
  
  /// Predict age from a face image
  /// Returns the detected age as an integer
  Future<int> predictAge(File image) async {
    try {
      // Read image bytes
      final bytes = await image.readAsBytes();
      
      // Create Dio instance for Face API
      final dio = Dio(BaseOptions(
        baseUrl: _faceApiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Ocp-Apim-Subscription-Key': _faceApiKey,
          'Content-Type': 'application/octet-stream',
        },
      ));
      
      // Call Face API detect endpoint with age attribute
      final response = await dio.post<List<dynamic>>(
        '/detect',
        data: Stream.fromIterable(bytes.map((e) => [e])),
        queryParameters: {
          'returnFaceAttributes': 'age,gender,smile,facialHair,glasses,emotion',
          'recognitionModel': 'recognition_04',
          'returnRecognitionModel': false,
          'detectionModel': 'detection_03',
        },
        options: Options(
          headers: {
            'Content-Type': 'application/octet-stream',
            'Content-Length': bytes.length,
          },
        ),
      );
      
      if (response.statusCode != 200) {
        throw ApiException(
          message: 'Face API request failed',
          statusCode: response.statusCode,
        );
      }
      
      final faces = response.data;
      
      if (faces == null || faces.isEmpty) {
        throw ApiException(
          message: 'No face detected in the image. Please ensure your face is clearly visible.',
          statusCode: 400,
        );
      }
      
      // Get the first (largest) face detected
      final face = faces.first as Map<String, dynamic>;
      final faceAttributes = face['faceAttributes'] as Map<String, dynamic>?;
      final age = faceAttributes?['age'];
      
      if (age == null) {
        throw ApiException(
          message: 'Could not determine age from face detection.',
          statusCode: 400,
        );
      }
      
      return (age as num).round();
    } on DioException catch (e) {
      // Handle specific Face API errors
      final errorMessage = _parseFaceApiError(e);
      throw ApiException(
        message: errorMessage,
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Unexpected error during age prediction: $e');
    }
  }
  
  /// Calculate exaggerated ages based on skin health score
  /// Returns a map with apparent, worst, and best case ages
  AgeExaggeration calculateExaggeratedAges(int realAge, int skinScore) {
    // Score is 0-100, where 100 is perfect skin
    // The worse the skin, the older you look
    
    // Calculate apparent age based on skin score
    // Lower score = older apparent age
    final scoreFactor = (100 - skinScore) / 100.0;
    
    // Apparent age: How old you currently look based on skin health
    // Range: -5 to +10 years difference from real age
    final apparentAgeDiff = (scoreFactor * 15 - 5).round();
    final apparentAge = (realAge + apparentAgeDiff).clamp(realAge - 5, realAge + 15);
    
    // Worst case: What you'd look like in 10 years without care
    // Based on current skin condition accelerating aging
    final worstCaseDiff = 10 + (scoreFactor * 10).round();
    final worstCaseAge = realAge + worstCaseDiff;
    
    // Best case: What you could look like with optimal care
    // Can look up to 10 years younger with great skin care
    final bestCaseDiff = -5 - ((1 - scoreFactor) * 10).round();
    final bestCaseAge = (realAge + bestCaseDiff).clamp(realAge - 15, realAge);
    
    return AgeExaggeration(
      realAge: realAge,
      apparentAge: apparentAge,
      worstCaseAge: worstCaseAge,
      bestCaseAge: bestCaseAge,
      skinScore: skinScore,
    );
  }
  
  /// Get detailed face analysis including multiple attributes
  Future<FaceAnalysis> analyzeFace(File image) async {
    try {
      final bytes = await image.readAsBytes();
      
      final dio = Dio(BaseOptions(
        baseUrl: _faceApiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ));
      
      final response = await dio.post<List<dynamic>>(
        '/detect',
        data: Stream.fromIterable(bytes.map((e) => [e])),
        queryParameters: {
          'returnFaceAttributes': 'age,gender,smile,facialHair,glasses,emotion,exposure,noise',
          'recognitionModel': 'recognition_04',
          'detectionModel': 'detection_03',
        },
        options: Options(
          headers: {
            'Ocp-Apim-Subscription-Key': _faceApiKey,
            'Content-Type': 'application/octet-stream',
            'Content-Length': bytes.length,
          },
        ),
      );
      
      if (response.statusCode != 200 || response.data == null || response.data!.isEmpty) {
        throw ApiException(
          message: 'Face analysis failed',
          statusCode: response.statusCode,
        );
      }
      
      return FaceAnalysis.fromJson(response.data!.first as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(
        message: _parseFaceApiError(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Face analysis failed: $e');
    }
  }
  
  /// Parse Face API specific error messages
  String _parseFaceApiError(DioException error) {
    final statusCode = error.response?.statusCode;
    final errorData = error.response?.data;
    
    if (errorData != null && errorData is Map) {
      final errorInfo = errorData['error'] as Map?;
      if (errorInfo != null) {
        return errorInfo['message']?.toString() ?? 'Face API error';
      }
    }
    
    switch (statusCode) {
      case 400:
        return 'Invalid image format or no face detected';
      case 401:
        return 'Face API authentication failed';
      case 403:
        return 'Face API access denied';
      case 408:
        return 'Face detection timed out';
      case 429:
        return 'Too many requests. Please try again later.';
      default:
        return error.message ?? 'Face API request failed';
    }
  }
}

/// Age Exaggeration Result Model
class AgeExaggeration {
  final int realAge;
  final int apparentAge;
  final int worstCaseAge;
  final int bestCaseAge;
  final int skinScore;
  
  AgeExaggeration({
    required this.realAge,
    required this.apparentAge,
    required this.worstCaseAge,
    required this.bestCaseAge,
    required this.skinScore,
  });
  
  /// Get the years difference for apparent age
  int get apparentDiff => apparentAge - realAge;
  
  /// Get the years difference for worst case
  int get worstCaseDiff => worstCaseAge - realAge;
  
  /// Get the years difference for best case
  int get bestCaseDiff => bestCaseAge - realAge;
  
  /// Get a description of the skin's impact on appearance
  String get impactDescription {
    if (apparentDiff <= -2) {
      return "Your skin makes you look younger than your age!";
    } else if (apparentDiff <= 2) {
      return "Your skin matches your age well.";
    } else if (apparentDiff <= 5) {
      return "Your skin adds a few years to your appearance.";
    } else {
      return "Your skin significantly affects your apparent age.";
    }
  }
  
  /// Get the potential improvement
  int get potentialImprovement => apparentAge - bestCaseAge;
  
  /// Get the risk without care
  int get riskWithoutCare => worstCaseAge - apparentAge;
  
  Map<String, dynamic> toJson() => {
    'real_age': realAge,
    'apparent_age': apparentAge,
    'worst_case_age': worstCaseAge,
    'best_case_age': bestCaseAge,
    'skin_score': skinScore,
    'apparent_diff': apparentDiff,
    'worst_case_diff': worstCaseDiff,
    'best_case_diff': bestCaseDiff,
  };
}

/// Detailed Face Analysis Model
class FaceAnalysis {
  final String faceId;
  final FaceRectangle faceRectangle;
  final FaceAttributes faceAttributes;
  
  FaceAnalysis({
    required this.faceId,
    required this.faceRectangle,
    required this.faceAttributes,
  });
  
  factory FaceAnalysis.fromJson(Map<String, dynamic> json) {
    return FaceAnalysis(
      faceId: json['faceId'] ?? '',
      faceRectangle: FaceRectangle.fromJson(json['faceRectangle'] ?? {}),
      faceAttributes: FaceAttributes.fromJson(json['faceAttributes'] ?? {}),
    );
  }
}

/// Face Rectangle (bounding box)
class FaceRectangle {
  final int top;
  final int left;
  final int width;
  final int height;
  
  FaceRectangle({
    required this.top,
    required this.left,
    required this.width,
    required this.height,
  });
  
  factory FaceRectangle.fromJson(Map<String, dynamic> json) {
    return FaceRectangle(
      top: json['top'] ?? 0,
      left: json['left'] ?? 0,
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
    );
  }
}

/// Face Attributes from Face API
class FaceAttributes {
  final double age;
  final String gender;
  final double smile;
  final FacialHair? facialHair;
  final String glasses;
  final Emotion? emotion;
  final Exposure? exposure;
  final Noise? noise;
  
  FaceAttributes({
    required this.age,
    required this.gender,
    required this.smile,
    this.facialHair,
    required this.glasses,
    this.emotion,
    this.exposure,
    this.noise,
  });
  
  factory FaceAttributes.fromJson(Map<String, dynamic> json) {
    return FaceAttributes(
      age: (json['age'] ?? 0).toDouble(),
      gender: json['gender'] ?? 'unknown',
      smile: (json['smile'] ?? 0).toDouble(),
      facialHair: json['facialHair'] != null 
          ? FacialHair.fromJson(json['facialHair']) 
          : null,
      glasses: json['glasses'] ?? 'NoGlasses',
      emotion: json['emotion'] != null 
          ? Emotion.fromJson(json['emotion']) 
          : null,
      exposure: json['exposure'] != null 
          ? Exposure.fromJson(json['exposure']) 
          : null,
      noise: json['noise'] != null 
          ? Noise.fromJson(json['noise']) 
          : null,
    );
  }
}

/// Facial Hair Attributes
class FacialHair {
  final double mustache;
  final double beard;
  final double sideburns;
  
  FacialHair({
    required this.mustache,
    required this.beard,
    required this.sideburns,
  });
  
  factory FacialHair.fromJson(Map<String, dynamic> json) {
    return FacialHair(
      mustache: (json['mustache'] ?? 0).toDouble(),
      beard: (json['beard'] ?? 0).toDouble(),
      sideburns: (json['sideburns'] ?? 0).toDouble(),
    );
  }
}

/// Emotion Detection
class Emotion {
  final double anger;
  final double contempt;
  final double disgust;
  final double fear;
  final double happiness;
  final double neutral;
  final double sadness;
  final double surprise;
  
  Emotion({
    required this.anger,
    required this.contempt,
    required this.disgust,
    required this.fear,
    required this.happiness,
    required this.neutral,
    required this.sadness,
    required this.surprise,
  });
  
  factory Emotion.fromJson(Map<String, dynamic> json) {
    return Emotion(
      anger: (json['anger'] ?? 0).toDouble(),
      contempt: (json['contempt'] ?? 0).toDouble(),
      disgust: (json['disgust'] ?? 0).toDouble(),
      fear: (json['fear'] ?? 0).toDouble(),
      happiness: (json['happiness'] ?? 0).toDouble(),
      neutral: (json['neutral'] ?? 0).toDouble(),
      sadness: (json['sadness'] ?? 0).toDouble(),
      surprise: (json['surprise'] ?? 0).toDouble(),
    );
  }
  
  /// Get the dominant emotion
  String get dominant {
    final emotions = {
      'anger': anger,
      'contempt': contempt,
      'disgust': disgust,
      'fear': fear,
      'happiness': happiness,
      'neutral': neutral,
      'sadness': sadness,
      'surprise': surprise,
    };
    
    var maxKey = 'neutral';
    var maxValue = 0.0;
    
    emotions.forEach((key, value) {
      if (value > maxValue) {
        maxValue = value;
        maxKey = key;
      }
    });
    
    return maxKey;
  }
}

/// Image Exposure Quality
class Exposure {
  final double value;
  final String level;
  
  Exposure({
    required this.value,
    required this.level,
  });
  
  factory Exposure.fromJson(Map<String, dynamic> json) {
    return Exposure(
      value: (json['value'] ?? 0).toDouble(),
      level: json['exposureLevel'] ?? 'GoodExposure',
    );
  }
}

/// Image Noise Level
class Noise {
  final double value;
  final String level;
  
  Noise({
    required this.value,
    required this.level,
  });
  
  factory Noise.fromJson(Map<String, dynamic> json) {
    return Noise(
      value: (json['value'] ?? 0).toDouble(),
      level: json['noiseLevel'] ?? 'Low',
    );
  }
}
