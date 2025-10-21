import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/model_boss.dart';
import '../models/model_interval_message.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    init();
  }

  static const String baseUrl = 'http://ec2-3-34-171-56.ap-northeast-2.compute.amazonaws.com:3000/api'; // 실제 API URL로 변경
  late Dio _dio;

  void init() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // 인터셉터 추가
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (kDebugMode) {
            print('API 요청: ${options.method} ${options.path}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('API 응답: ${response.statusCode} ${response.requestOptions.path}');
          }
          handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            print('API 오류: ${error.message}');
          }
          handler.next(error);
        },
      ),
    );
  }

  // 모든 보스 조회
  Future<List<Boss>> getAllBosses({
    int? level,
    String? difficulty,
    String? search,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (level != null) queryParams['level'] = level;
      if (difficulty != null) queryParams['difficulty'] = difficulty;
      if (search != null) queryParams['search'] = search;

      final response = await _dio.get(
        '/boss',
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data;
      return data.map((boss) => Boss.fromJson(boss)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 특정 보스 조회
  Future<Boss> getBossById(String id) async {
    try {
      final response = await _dio.get('/boss/$id');
      return Boss.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 새 보스 생성
  Future<Boss> createBoss(Boss boss) async {
    try {
      final response = await _dio.post(
        '/boss',
        data: boss.toJson(),
      );
      return Boss.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 보스 정보 수정
  Future<Boss> updateBoss(String id, Boss boss) async {
    try {
      final response = await _dio.put(
        '/boss/$id',
        data: boss.toJson(),
      );
      return Boss.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 보스 삭제
  Future<void> deleteBoss(String id) async {
    try {
      await _dio.delete('/boss/$id');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 특정 난이도 정보 조회
  Future<Difficulty> getDifficultyInfo(String bossId, String difficulty) async {
    try {
      final response = await _dio.get('/boss/$bossId/difficulties/$difficulty');
      return Difficulty.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 특정 보스의 특정 난이도 정보 수정
  Future<Boss> updateBossDifficulty(String bossId, String difficulty, Difficulty difficultyData) async {
    try {
      final response = await _dio.put(
        '/boss/$bossId/difficulties/$difficulty',
        data: difficultyData.toJson(),
      );
      return Boss.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ============================================
  // Interval Message API
  // ============================================

  // 모든 정확한 시간 메시지 조회
  Future<List<ExactTimeMessage>> getAllExactTimeMessages() async {
    try {
      final response = await _dio.get('/intervalMessage/exact');
      final data = response.data['data'] as List;
      return data.map((json) => ExactTimeMessage.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 정확한 시간 메시지 생성
  Future<ExactTimeMessage> createExactTimeMessage(ExactTimeMessage message) async {
    try {
      final response = await _dio.post(
        '/intervalMessage/exact',
        data: message.toJson(),
      );
      return ExactTimeMessage.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 정확한 시간 메시지 수정
  Future<ExactTimeMessage> updateExactTimeMessage(String id, ExactTimeMessage message) async {
    try {
      final response = await _dio.put(
        '/intervalMessage/exact/$id',
        data: message.toJson(),
      );
      return ExactTimeMessage.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 정확한 시간 메시지 삭제
  Future<void> deleteExactTimeMessage(String id) async {
    try {
      await _dio.delete('/intervalMessage/exact/$id');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 모든 요일 메시지 조회
  Future<List<WeeklyMessage>> getAllWeeklyMessages() async {
    try {
      final response = await _dio.get('/intervalMessage/weekly');
      final data = response.data['data'] as List;
      return data.map((json) => WeeklyMessage.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 요일 메시지 생성
  Future<WeeklyMessage> createWeeklyMessage(WeeklyMessage message) async {
    try {
      final response = await _dio.post(
        '/intervalMessage/weekly',
        data: message.toJson(),
      );
      return WeeklyMessage.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 요일 메시지 수정
  Future<WeeklyMessage> updateWeeklyMessage(String id, WeeklyMessage message) async {
    try {
      final response = await _dio.put(
        '/intervalMessage/weekly/$id',
        data: message.toJson(),
      );
      return WeeklyMessage.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 요일 메시지 삭제
  Future<void> deleteWeeklyMessage(String id) async {
    try {
      await _dio.delete('/intervalMessage/weekly/$id');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Dio 에러 처리
  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return '연결 시간이 초과되었습니다.';
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 404) {
          return '요청한 데이터를 찾을 수 없습니다.';
        } else if (e.response?.statusCode == 400) {
          final errorData = e.response?.data;
          return errorData is Map && errorData.containsKey('error')
              ? errorData['error']
              : '잘못된 요청입니다.';
        } else if (e.response?.statusCode == 500) {
          return '서버 내부 오류가 발생했습니다.';
        }
        return '서버 오류가 발생했습니다. (${e.response?.statusCode})';
      case DioExceptionType.cancel:
        return '요청이 취소되었습니다.';
      case DioExceptionType.connectionError:
        return '네트워크 연결을 확인해주세요.';
      default:
        return '알 수 없는 오류가 발생했습니다: ${e.message}';
    }
  }

  // API 연결 상태 확인
  Future<bool> checkConnection() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 인증 토큰 설정 (필요한 경우)
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // 인증 토큰 제거
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}