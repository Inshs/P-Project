import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/car.dart'; // RecommendedCar 타입 참조용

// 모델 클래스 re-export (하위 호환성 유지)
// 이제 모델들은 lib/models/ 디렉토리에서 관리됩니다.
export '../models/prediction.dart';
export '../models/car.dart';
export '../models/deal.dart';
export '../models/user.dart';
export '../models/ai.dart';

/// Car-Sentix API Service
/// ML 서비스와 통신하는 클라이언트
///
/// 고도화 버전 v2.1
/// - 에뮬레이터 자동 감지 (Android: 10.0.2.2)
/// - 타임아웃 설정 (15초)
/// - 에러 핸들링 강화
/// - JWT 인증 헤더 지원
class ApiService {
  // 서버 포트
  static const int _port = 8001;

  // 타임아웃 설정
  static const Duration _timeout = Duration(seconds: 15);

  // AuthService 참조
  final AuthService _authService = AuthService();

  // Mock 모드 설정
  static const bool _useMock = true;

  // 베이스 URL (플랫폼에 따라 자동 설정)
  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:$_port/api';
    }
    // Android 에뮬레이터에서는 10.0.2.2가 호스트 머신의 localhost
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:$_port/api';
    }
    // iOS 시뮬레이터, Windows, macOS 등
    return 'http://localhost:$_port/api';
  }

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// 현재 사용 중인 URL 확인 (디버깅용)
  String get currentBaseUrl => _baseUrl;

  /// 인증 헤더 생성
  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_authService.token != null) {
      headers['Authorization'] = 'Bearer ${_authService.token}';
    }
    return headers;
  }

  /// 사용자 ID (로그인 시) 또는 guest
  String get _userId => _authService.userId ?? 'guest';

  /// 가격 예측
  Future<PredictionResult> predict({
    required String brand,
    required String model,
    required int year,
    required int mileage,
    required String fuel,
    bool hasSunroof = false,
    bool hasNavigation = false,
    bool hasLeatherSeat = false,
    bool hasSmartKey = false,
    bool hasRearCamera = false,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 2));
      return PredictionResult(
        predictedPrice: 3500,
        priceRange: [3200, 3800],
        confidence: 0.85,
      );
    }

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/predict'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'brand': brand,
              'model': model,
              'year': year,
              'mileage': mileage,
              'fuel': fuel,
              'has_sunroof': hasSunroof,
              'has_navigation': hasNavigation,
              'has_leather_seat': hasLeatherSeat,
              'has_smart_key': hasSmartKey,
              'has_rear_camera': hasRearCamera,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return PredictionResult.fromJson(jsonDecode(response.body));
      } else {
        final error = _parseError(response);
        throw ApiException('가격 예측 실패: $error');
      }
    } on http.ClientException catch (e) {
      throw ApiException('서버 연결 실패: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('네트워크 오류: $e');
    }
  }

  /// 타이밍 분석
  Future<TimingResult> analyzeTiming(String model) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return TimingResult(
        timingScore: 85.0,
        decision: '구매 적기',
        color: 'green',
        breakdown: {'seasonal': 10.0, 'market': 5.0, 'model_cycle': 5.0},
        reasons: ['계절적 비수기로 가격 하락세', '신형 모델 출시 임박으로 구형 감가 예상'],
      );
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/timing'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'model': model}),
    );

    if (response.statusCode == 200) {
      return TimingResult.fromJson(jsonDecode(response.body));
    } else {
      throw ApiException('타이밍 분석 실패');
    }
  }

  /// 통합 스마트 분석 (가격 + 타이밍 + AI)
  Future<SmartAnalysisResult> smartAnalysis({
    required String brand,
    required String model,
    required int year,
    required int mileage,
    required String fuel,
    // 옵션
    bool hasSunroof = false,
    bool hasNavigation = false,
    bool hasLeatherSeat = false,
    bool hasSmartKey = false,
    bool hasRearCamera = false,
    bool hasHeatedSeat = false,
    bool hasVentilatedSeat = false,
    bool hasLedLamp = false,
    bool isAccidentFree = true,
    // 성능점검 등급 (1-5 별표 → normal/good/excellent)
    String inspectionGrade = 'normal',
    // AI 분석용
    int? salePrice,
    String? dealerDescription,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 3));
      return SmartAnalysisResult(
        prediction: PredictionResult(
          predictedPrice: 3500,
          priceRange: [3300, 3700],
          confidence: 0.92,
        ),
        timing: TimingResult(
          timingScore: 78.0,
          decision: '구매 적기',
          color: 'green',
          breakdown: {'market': 8.0},
          reasons: ['시장 공급 과잉으로 인한 가격 하락'],
        ),
        groqAnalysis: {
          'signal': {'signal': '매수 추천', 'emoji': '🟢'},
          'fraud_check': {'fraud_score': 10},
          'negotiation': {
            'message_script': '안녕하세요, 차량 보고 연락드립니다. 쿨거래 시 네고 가능할까요?',
            'phone_script': '전화로 문의하실 때는 차량 상태를 먼저 물어보세요.'
          }
        },
      );
    }

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/smart-analysis'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'brand': brand,
              'model': model,
              'year': year,
              'mileage': mileage,
              'fuel': fuel,
              // 옵션
              'has_sunroof': hasSunroof,
              'has_navigation': hasNavigation,
              'has_leather_seat': hasLeatherSeat,
              'has_smart_key': hasSmartKey,
              'has_rear_camera': hasRearCamera,
              'has_heated_seat': hasHeatedSeat,
              'has_ventilated_seat': hasVentilatedSeat,
              'has_led_lamp': hasLedLamp,
              'is_accident_free': isAccidentFree,
              'inspection_grade': inspectionGrade,
              if (salePrice != null) 'sale_price': salePrice,
              if (dealerDescription != null)
                'dealer_description': dealerDescription,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return SmartAnalysisResult.fromJson(jsonDecode(response.body));
      } else {
        final error = _parseError(response);
        throw ApiException('통합 분석 실패: $error');
      }
    } on http.ClientException catch (e) {
      throw ApiException('서버 연결 실패: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('네트워크 오류: $e');
    }
  }

  /// 비슷한 차량 분포
  Future<SimilarResult> getSimilar({
    required String brand,
    required String model,
    required int year,
    required int mileage,
    required double predictedPrice,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return SimilarResult(
        similarCount: 15,
        histogram: [
          {'range_min': 3000, 'range_max': 3200, 'count': 2},
          {'range_min': 3200, 'range_max': 3400, 'count': 5},
          {'range_min': 3400, 'range_max': 3600, 'count': 8},
          {'range_min': 3600, 'range_max': 3800, 'count': 3},
        ],
        yourPosition: '평균',
        positionColor: 'blue',
      );
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/similar'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'brand': brand,
        'model': model,
        'year': year,
        'mileage': mileage,
        'predicted_price': predictedPrice,
      }),
    );

    if (response.statusCode == 200) {
      return SimilarResult.fromJson(jsonDecode(response.body));
    } else {
      throw ApiException('비슷한 차량 조회 실패');
    }
  }

  /// 인기 차량
  Future<List<PopularCar>> getPopular({
    String category = 'all',
    int limit = 5,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      return [
        PopularCar(
            brand: 'Hyundai',
            model: 'Grandeur',
            listings: 1200,
            avgPrice: 3500,
            medianPrice: 3400),
        PopularCar(
            brand: 'Kia',
            model: 'Sorento',
            listings: 980,
            avgPrice: 3200,
            medianPrice: 3100),
        PopularCar(
            brand: 'Genesis',
            model: 'G80',
            listings: 850,
            avgPrice: 5500,
            medianPrice: 5400),
        PopularCar(
            brand: 'BMW',
            model: '5 Series',
            listings: 700,
            avgPrice: 6000,
            medianPrice: 5900),
        PopularCar(
            brand: 'Mercedes-Benz',
            model: 'E-Class',
            listings: 650,
            avgPrice: 6500,
            medianPrice: 6400),
      ];
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/popular?category=$category&limit=$limit'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['models'] as List)
          .map((e) => PopularCar.fromJson(e))
          .toList();
    } else {
      throw ApiException('인기 차량 조회 실패');
    }
  }

  /// 브랜드 목록
  Future<List<String>> getBrands() async {
    if (_useMock) {
      return [
        'Hyundai',
        'Kia',
        'Genesis',
        'BMW',
        'Mercedes-Benz',
        'Audi',
        'Chevrolet',
        'Renault Korea'
      ];
    }

    final response = await http.get(Uri.parse('$_baseUrl/brands'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data['brands']);
    } else {
      throw ApiException('브랜드 목록 조회 실패');
    }
  }

  /// 모델 목록
  Future<List<String>> getModels(String brand) async {
    if (_useMock) {
      if (brand == 'Hyundai') {
        return ['Avante', 'Sonata', 'Grandeur', 'Tucson', 'Santa Fe'];
      }
      if (brand == 'Kia') {
        return ['K3', 'K5', 'K8', 'Sportage', 'Sorento'];
      }
      if (brand == 'Genesis') {
        return ['G70', 'G80', 'G90', 'GV70', 'GV80'];
      }
      return ['Model A', 'Model B', 'Model C'];
    }

    final response = await http.get(Uri.parse('$_baseUrl/models/$brand'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data['models']);
    } else {
      throw ApiException('모델 목록 조회 실패');
    }
  }

  /// 검색 이력
  Future<List<SearchHistory>> getHistory({int limit = 10}) async {
    if (_useMock) {
      return [
        SearchHistory(
            brand: 'Hyundai',
            model: 'Grandeur',
            year: 2021,
            mileage: 30000,
            predictedPrice: 3500,
            timestamp: '2024-01-15T10:00:00'),
        SearchHistory(
            brand: 'Kia',
            model: 'Sorento',
            year: 2020,
            mileage: 45000,
            predictedPrice: 2800,
            timestamp: '2024-01-14T15:30:00'),
      ];
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/history?user_id=$_userId&limit=$limit'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['history'] as List)
          .map((e) => SearchHistory.fromJson(e))
          .toList();
    } else {
      throw ApiException('검색 이력 조회 실패');
    }
  }

  /// 검색 이력 추가
  Future<void> addHistory({
    required String brand,
    required String model,
    required int year,
    required int mileage,
    double? predictedPrice,
  }) async {
    if (_useMock) return;

    final response = await http
        .post(
          Uri.parse('$_baseUrl/history?user_id=$_userId'),
          headers: _headers,
          body: jsonEncode({
            'brand': brand,
            'model': model,
            'year': year,
            'mileage': mileage,
            'predicted_price': predictedPrice,
          }),
        )
        .timeout(_timeout);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ApiException('검색 이력 저장 실패');
    }
  }

  /// 검색 이력 삭제
  Future<bool> removeHistory(int historyId) async {
    if (_useMock) return true;

    final response = await http
        .delete(
          Uri.parse('$_baseUrl/history/$historyId?user_id=$_userId'),
          headers: _headers,
        )
        .timeout(_timeout);

    return response.statusCode == 200;
  }

  /// 검색 이력 전체 삭제
  Future<int> clearHistory() async {
    if (_useMock) return 2;

    final response = await http
        .delete(
          Uri.parse('$_baseUrl/history?user_id=$_userId'),
          headers: _headers,
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['deleted_count'] ?? 0;
    }
    return 0;
  }

  /// 추천 차량 목록
  Future<List<RecommendedCar>> getRecommendations({
    String category = 'all',
    int? budgetMin,
    int? budgetMax,
    int limit = 10,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return List.generate(
          5,
          (index) => RecommendedCar(
                brand: 'Hyundai',
                model: 'Grandeur IG',
                year: 2019 + index,
                mileage: 30000 + (index * 5000),
                actualPrice: 2500 + (index * 200),
                predictedPrice: 2600 + (index * 200),
                priceDiff: -100,
                isGoodDeal: true,
                score: 90.0,
                type: 'domestic',
                fuel: '가솔린',
                imageUrl: 'https://via.placeholder.com/300x200?text=Car+$index',
                detailUrl: 'https://example.com',
                options: CarOptions(isAccidentFree: true, hasSunroof: true),
              ));
    }

    var url = '$_baseUrl/recommendations?category=$category&limit=$limit';
    if (budgetMin != null) url += '&budget_min=$budgetMin';
    if (budgetMax != null) url += '&budget_max=$budgetMax';

    final response = await http.get(Uri.parse(url)).timeout(_timeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['recommendations'] as List)
          .map((e) => RecommendedCar.fromJson(e))
          .toList();
    } else {
      throw ApiException('추천 차량 조회 실패');
    }
  }

  /// 가성비 좋은 차량
  Future<List<RecommendedCar>> getGoodDeals({
    String category = 'all',
    int limit = 10,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return List.generate(
          5,
          (index) => RecommendedCar(
                brand: 'Kia',
                model: 'K5 DL3',
                year: 2020 + index,
                mileage: 20000 + (index * 5000),
                actualPrice: 2200 + (index * 150),
                predictedPrice: 2300 + (index * 150),
                priceDiff: -100,
                isGoodDeal: true,
                score: 92.0,
                type: 'domestic',
                fuel: '가솔린',
                imageUrl:
                    'https://via.placeholder.com/300x200?text=Deal+$index',
                detailUrl: 'https://example.com',
                options: CarOptions(isAccidentFree: true, hasNavigation: true),
              ));
    }

    final response = await http
        .get(
          Uri.parse('$_baseUrl/good-deals?category=$category&limit=$limit'),
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['deals'] as List)
          .map((e) => RecommendedCar.fromJson(e))
          .toList();
    } else {
      throw ApiException('가성비 차량 조회 실패');
    }
  }

  /// 특정 모델의 가성비 좋은 매물
  Future<List<RecommendedCar>> getModelDeals({
    required String brand,
    required String model,
    int limit = 10,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return List.generate(
          3,
          (index) => RecommendedCar(
                brand: brand,
                model: model,
                year: 2021,
                mileage: 15000 * (index + 1),
                actualPrice: 3000 - (index * 100),
                predictedPrice: 3100 - (index * 100),
                priceDiff: -100,
                isGoodDeal: true,
                score: 88.0,
                type: 'domestic',
                fuel: '가솔린',
                imageUrl:
                    'https://via.placeholder.com/300x200?text=$model+$index',
                detailUrl: 'https://example.com',
                options: CarOptions(isAccidentFree: true, hasSmartKey: true),
              ));
    }

    final response = await http
        .get(
          Uri.parse(
              '$_baseUrl/model-deals?brand=${Uri.encodeComponent(brand)}&model=${Uri.encodeComponent(model)}&limit=$limit'),
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['deals'] as List)
          .map((e) => RecommendedCar.fromJson(e))
          .toList();
    } else {
      throw ApiException('모델별 추천 차량 조회 실패');
    }
  }

  /// 개별 매물 상세 분석
  Future<DealAnalysis> analyzeDeal({
    required String brand,
    required String model,
    required int year,
    required int mileage,
    required int actualPrice,
    int? predictedPrice,
    String fuel = '가솔린',
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 2));
      return DealAnalysis(
        brand: brand,
        model: model,
        year: year,
        mileage: mileage,
        fuel: fuel,
        priceFairness: PriceFairness(
          score: 80,
          label: '적정',
          percentile: 45,
          description: '시세 대비 적정한 가격입니다.',
        ),
        fraudRisk: FraudRisk(
          score: 10,
          level: 'low',
          factors: [
            FraudFactor(check: '소유자 변경', status: 'pass', msg: '변경 이력 양호'),
            FraudFactor(check: '사고 이력', status: 'info', msg: '보험 이력 확인 필요'),
          ],
        ),
        negoPoints: ['타이어 마모 상태 확인 필요', '엔진 오일 교체 주기 확인'],
        summary: DealSummary(
          actualPrice: actualPrice,
          predictedPrice: predictedPrice ?? actualPrice + 100,
          priceDiff: -100,
          priceDiffPct: -3.5,
          isGoodDeal: true,
          verdict: '구매 추천',
        ),
      );
    }

    final response = await http
        .post(
          Uri.parse('$_baseUrl/analyze-deal'),
          headers: _headers,
          body: jsonEncode({
            'brand': brand,
            'model': model,
            'year': year,
            'mileage': mileage,
            'actual_price': actualPrice,
            'predicted_price': predictedPrice ?? 0,
            'fuel': fuel,
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      return DealAnalysis.fromJson(jsonDecode(response.body));
    } else {
      throw ApiException('매물 분석 실패');
    }
  }

  /// 트렌딩 모델
  Future<List<Map<String, dynamic>>> getTrending(
      {int days = 7, int limit = 10}) async {
    if (_useMock) {
      return [
        {'rank': 1, 'brand': 'Hyundai', 'model': 'Grandeur', 'change': 5},
        {'rank': 2, 'brand': 'Kia', 'model': 'Sorento', 'change': 3},
        {'rank': 3, 'brand': 'Genesis', 'model': 'G80', 'change': -1},
      ];
    }

    final response = await http
        .get(
          Uri.parse('$_baseUrl/trending?days=$days&limit=$limit'),
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['trending'] ?? []);
    } else {
      throw ApiException('트렌딩 조회 실패');
    }
  }

  // ========== 즐겨찾기 API ==========

  /// 즐겨찾기 목록 조회
  Future<List<Favorite>> getFavorites() async {
    if (_useMock) {
      return [
        Favorite(
          id: 1,
          brand: 'Hyundai',
          model: 'Grandeur',
          year: 2020,
          mileage: 40000,
          predictedPrice: 3200,
          actualPrice: 3150,
          createdAt: '2024-01-20',
        ),
      ];
    }

    final response = await http
        .get(
          Uri.parse('$_baseUrl/favorites?user_id=$_userId'),
          headers: _headers,
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['favorites'] as List)
          .map((e) => Favorite.fromJson(e))
          .toList();
    } else {
      throw ApiException('즐겨찾기 조회 실패');
    }
  }

  /// 즐겨찾기 추가
  Future<Map<String, dynamic>> addFavorite({
    required String brand,
    required String model,
    required int year,
    required int mileage,
    double? predictedPrice,
    int? actualPrice,
    String? detailUrl,
    String? carId, // 엔카 차량 고유 ID (핵심 식별자)
  }) async {
    if (_useMock) {
      return {'success': true, 'id': 123};
    }

    final response = await http
        .post(
          Uri.parse('$_baseUrl/favorites?user_id=$_userId'),
          headers: _headers,
          body: jsonEncode({
            'brand': brand,
            'model': model,
            'year': year,
            'mileage': mileage,
            'predicted_price': predictedPrice,
            'actual_price': actualPrice,
            'detail_url': detailUrl,
            'car_id': carId,
          }),
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw ApiException('즐겨찾기 추가 실패');
    }
  }

  /// 즐겨찾기 삭제
  Future<bool> removeFavorite(int favoriteId) async {
    if (_useMock) return true;

    final response = await http
        .delete(
          Uri.parse('$_baseUrl/favorites/$favoriteId?user_id=$_userId'),
          headers: _headers,
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] ?? false;
    } else {
      throw ApiException('즐겨찾기 삭제 실패');
    }
  }

  // ========== 가격 알림 API ==========

  /// 알림 목록 조회
  Future<List<PriceAlert>> getAlerts() async {
    if (_useMock) {
      return [
        PriceAlert(
          id: 1,
          brand: 'Kia',
          model: 'K5',
          year: 2021,
          targetPrice: 2000,
          isActive: true,
          createdAt: '2024-01-10',
        ),
      ];
    }

    final response = await http
        .get(
          Uri.parse('$_baseUrl/alerts?user_id=$_userId'),
          headers: _headers,
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['alerts'] as List)
          .map((e) => PriceAlert.fromJson(e))
          .toList();
    } else {
      throw ApiException('알림 조회 실패');
    }
  }

  /// 알림 추가
  Future<Map<String, dynamic>> addAlert({
    required String brand,
    required String model,
    required int year,
    required double targetPrice,
  }) async {
    if (_useMock) {
      return {'success': true, 'id': 456};
    }

    final response = await http
        .post(
          Uri.parse('$_baseUrl/alerts?user_id=$_userId'),
          headers: _headers,
          body: jsonEncode({
            'brand': brand,
            'model': model,
            'year': year,
            'target_price': targetPrice,
          }),
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw ApiException('알림 추가 실패');
    }
  }

  /// 알림 토글
  Future<Map<String, dynamic>> toggleAlert(int alertId) async {
    if (_useMock) {
      return {'success': true, 'is_active': false};
    }

    final response = await http
        .put(
          Uri.parse('$_baseUrl/alerts/$alertId/toggle?user_id=$_userId'),
          headers: _headers,
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw ApiException('알림 토글 실패');
    }
  }

  /// 알림 삭제
  Future<bool> removeAlert(int alertId) async {
    if (_useMock) return true;

    final response = await http
        .delete(
          Uri.parse('$_baseUrl/alerts/$alertId?user_id=$_userId'),
          headers: _headers,
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] ?? false;
    } else {
      throw ApiException('알림 삭제 실패');
    }
  }

  /// 검색 이력 저장
  Future<void> saveSearchHistory({
    required String brand,
    required String model,
    required int year,
    required int mileage,
    double? predictedPrice,
  }) async {
    if (_useMock) return;

    try {
      await http
          .post(
            Uri.parse('$_baseUrl/history?user_id=$_userId'),
            headers: _headers,
            body: jsonEncode({
              'brand': brand,
              'model': model,
              'year': year,
              'mileage': mileage,
              'predicted_price': predictedPrice,
            }),
          )
          .timeout(_timeout);
    } catch (e) {
      // 이력 저장 실패해도 무시 (크리티컬하지 않음)
    }
  }

  /// 헬스체크 (연결 상태 확인)
  Future<bool> healthCheck() async {
    if (_useMock) return true;

    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/health'),
          )
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// 연결 상태 상세 정보
  Future<Map<String, dynamic>> getConnectionStatus() async {
    if (_useMock) {
      return {
        'connected': true,
        'baseUrl': 'Mock Mode',
        'data': {'status': 'ok', 'mock': true},
      };
    }

    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/health'),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return {
          'connected': true,
          'baseUrl': _baseUrl,
          'data': jsonDecode(response.body),
        };
      }
      return {
        'connected': false,
        'baseUrl': _baseUrl,
        'error': 'Status: ${response.statusCode}',
      };
    } catch (e) {
      return {
        'connected': false,
        'baseUrl': _baseUrl,
        'error': e.toString(),
      };
    }
  }

  /// 에러 메시지 파싱
  String _parseError(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      return data['detail'] ?? data['message'] ?? 'Unknown error';
    } catch (_) {
      return 'Status ${response.statusCode}';
    }
  }

  // ========== Groq AI API (네고 대본 생성) ==========

  /// Groq AI로 네고 대본 생성 (고도화)
  Future<NegotiationScript> generateNegotiationScript({
    required String carName,
    required String price,
    required String info,
    List<String> checkpoints = const [],
    // 고도화: 정확한 가격 정보 (선택적)
    int? actualPrice,
    int? predictedPrice,
    int? year,
    int? mileage,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 2));
      return NegotiationScript(
        messageScript: '안녕하세요, $carName 차량 보고 연락드립니다. 상태가 좋아 보이는데 네고 가능할까요?',
        phoneScript: [
          '1. 인사 및 차량 확인: 안녕하세요, 엔카 보고 연락드렸습니다. $carName 아직 있나요?',
          '2. 상태 문의: 사고 이력이나 특이사항은 없나요?',
          '3. 가격 제안: 쿨거래 시 조금 깎아주실 수 있나요?',
        ],
        tip: '매너 있게 접근하면 성공 확률이 높습니다.',
        checkpoints: ['엔진 소리 확인', '타이어 마모도 확인'],
      );
    }

    try {
      final body = {
        'car_name': carName,
        'price': price,
        'info': info,
        'checkpoints': checkpoints,
      };

      // 정확한 가격 정보가 있으면 추가
      if (actualPrice != null) body['actual_price'] = actualPrice;
      if (predictedPrice != null) body['predicted_price'] = predictedPrice;
      if (year != null) body['year'] = year;
      if (mileage != null) body['mileage'] = mileage;

      final response = await http
          .post(
            Uri.parse('$_baseUrl/negotiation/generate'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30)); // AI 응답은 시간이 걸릴 수 있음

      if (response.statusCode == 200) {
        return NegotiationScript.fromJson(jsonDecode(response.body));
      } else {
        throw ApiException('네고 대본 생성 실패: ${_parseError(response)}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('네고 대본 생성 오류: $e');
    }
  }

  /// AI 상태 확인 (Groq API 연결 여부)
  Future<AiStatus> getAiStatus() async {
    if (_useMock) {
      return AiStatus(
          isConnected: true, model: 'llama3-70b-8192', status: 'connected');
    }

    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/ai/status'), // _baseUrl에 이미 /api 포함
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return AiStatus.fromJson(jsonDecode(response.body));
      } else {
        return AiStatus(isConnected: false, model: null, status: 'error');
      }
    } catch (e) {
      return AiStatus(isConnected: false, model: null, status: 'disconnected');
    }
  }
}

// ========== Data Models ==========

class PredictionResult {
  final double predictedPrice;
  final List<double> priceRange;
  final double confidence;

  PredictionResult({
    required this.predictedPrice,
    required this.priceRange,
    required this.confidence,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      predictedPrice: (json['predicted_price'] as num).toDouble(),
      priceRange: (json['price_range'] as List)
          .map((e) => (e as num).toDouble())
          .toList(),
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  String get formattedPrice => '${predictedPrice.toStringAsFixed(0)}만원';
  String get formattedRange =>
      '${priceRange[0].toStringAsFixed(0)} ~ ${priceRange[1].toStringAsFixed(0)}만원';
}

class TimingResult {
  final double timingScore;
  final String decision;
  final String color;
  final Map<String, double> breakdown;
  final List<String> reasons;

  TimingResult({
    required this.timingScore,
    required this.decision,
    required this.color,
    required this.breakdown,
    required this.reasons,
  });

  factory TimingResult.fromJson(Map<String, dynamic> json) {
    return TimingResult(
      timingScore: (json['timing_score'] as num).toDouble(),
      decision: json['decision'] as String,
      color: json['color'] as String,
      breakdown: Map<String, double>.from(
        (json['breakdown'] as Map)
            .map((k, v) => MapEntry(k, (v as num).toDouble())),
      ),
      reasons: List<String>.from(json['reasons']),
    );
  }

  bool get isGoodTime => timingScore >= 70;
}

class SmartAnalysisResult {
  final PredictionResult prediction;
  final TimingResult timing;
  final Map<String, dynamic>? groqAnalysis;

  SmartAnalysisResult({
    required this.prediction,
    required this.timing,
    this.groqAnalysis,
  });

  factory SmartAnalysisResult.fromJson(Map<String, dynamic> json) {
    return SmartAnalysisResult(
      prediction: PredictionResult.fromJson(json['prediction']),
      timing: TimingResult.fromJson(json['timing']),
      groqAnalysis: json['groq_analysis'] as Map<String, dynamic>?,
    );
  }

  // AI 신호 (매수/관망/회피)
  String? get signal => groqAnalysis?['signal']?['signal'];
  String? get signalEmoji => groqAnalysis?['signal']?['emoji'];

  // 허위매물 의심도
  int? get fraudScore => groqAnalysis?['fraud_check']?['fraud_score'];

  // 네고 대본
  String? get messageScript => groqAnalysis?['negotiation']?['message_script'];
  String? get phoneScript => groqAnalysis?['negotiation']?['phone_script'];
}

class SimilarResult {
  final int similarCount;
  final Map<String, dynamic>? priceDistribution;
  final List<Map<String, dynamic>> histogram;
  final String yourPosition;
  final String positionColor;

  SimilarResult({
    required this.similarCount,
    this.priceDistribution,
    required this.histogram,
    required this.yourPosition,
    required this.positionColor,
  });

  factory SimilarResult.fromJson(Map<String, dynamic> json) {
    return SimilarResult(
      similarCount: json['similar_count'] as int,
      priceDistribution: json['price_distribution'] as Map<String, dynamic>?,
      histogram: List<Map<String, dynamic>>.from(json['histogram'] ?? []),
      yourPosition: json['your_position'] as String,
      positionColor: json['position_color'] as String,
    );
  }
}

class PopularCar {
  final String brand;
  final String model;
  final int listings; // 엔카 등록 대수
  final int avgPrice;
  final int medianPrice;
  final String? type; // domestic/imported

  PopularCar({
    required this.brand,
    required this.model,
    required this.listings,
    required this.avgPrice,
    required this.medianPrice,
    this.type,
  });

  factory PopularCar.fromJson(Map<String, dynamic> json) {
    return PopularCar(
      brand: json['brand'] as String,
      model: json['model'] as String,
      listings: json['listings'] ?? json['searches'] ?? 0,
      avgPrice: json['avg_price'] ?? 0,
      medianPrice: json['median_price'] ?? json['avg_price'] ?? 0,
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand': brand,
      'model': model,
      'listings': listings,
      'avg_price': avgPrice,
      'median_price': medianPrice,
      'type': type,
    };
  }
}

// CarOptions, RecommendedCar는 models/car.dart에서 정의됨

class SearchHistory {
  final int? id;
  final String? timestamp;
  final String brand;
  final String model;
  final int year;
  final int mileage;
  final String? fuel;
  final double? predictedPrice;
  final String? lastSearched;

  SearchHistory({
    this.id,
    this.timestamp,
    required this.brand,
    required this.model,
    required this.year,
    required this.mileage,
    this.fuel,
    this.predictedPrice,
    this.lastSearched,
  });

  factory SearchHistory.fromJson(Map<String, dynamic> json) {
    return SearchHistory(
      id: json['id'],
      timestamp: json['timestamp'] ?? json['searched_at'],
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? 0,
      mileage: json['mileage'] ?? 0,
      fuel: json['fuel'],
      predictedPrice: json['predicted_price']?.toDouble(),
      lastSearched: json['last_searched'],
    );
  }
}

/// 즐겨찾기 모델
class Favorite {
  final int id;
  final String? carId; // 엔카 차량 고유 ID (핵심 식별자)
  final String brand;
  final String model;
  final int year;
  final int mileage;
  final String? fuel;
  final double? predictedPrice;
  final int? actualPrice;
  final String? detailUrl;
  final String? memo;
  final String? createdAt;

  Favorite({
    required this.id,
    this.carId,
    required this.brand,
    required this.model,
    required this.year,
    required this.mileage,
    this.fuel,
    this.predictedPrice,
    this.actualPrice,
    this.detailUrl,
    this.memo,
    this.createdAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'] ?? 0,
      carId: json['car_id']?.toString(),
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? 0,
      mileage: json['mileage'] ?? 0,
      fuel: json['fuel'],
      predictedPrice: json['predicted_price']?.toDouble(),
      actualPrice: json['actual_price'],
      detailUrl: json['detail_url'],
      memo: json['memo'],
      createdAt: json['created_at'],
    );
  }

  /// 같은 매물인지 확인 (OR 조건 - 어떤 것이든 일치하면 true)
  bool isSameDeal(RecommendedCar car) {
    // URL에서 carId 추출하는 헬퍼 함수
    String? extractCarIdFromUrl(String? url) {
      if (url == null) return null;
      final match = RegExp(r'carid=(\d+)').firstMatch(url);
      return match?.group(1);
    }

    final urlCarId = extractCarIdFromUrl(detailUrl);
    final carUrlCarId = extractCarIdFromUrl(car.detailUrl);

    // 조건 1: carId 직접 비교 (가장 정확)
    if (carId != null &&
        carId!.isNotEmpty &&
        car.carId != null &&
        car.carId!.isNotEmpty &&
        carId == car.carId) {
      return true;
    }

    // 조건 2: detailUrl 직접 비교
    if (detailUrl != null &&
        detailUrl!.isNotEmpty &&
        car.detailUrl != null &&
        car.detailUrl!.isNotEmpty &&
        detailUrl == car.detailUrl) {
      return true;
    }

    // 조건 3: URL에서 추출한 carId 비교
    if (urlCarId != null && carUrlCarId != null && urlCarId == carUrlCarId) {
      return true;
    }

    // 조건 4: carId ↔ URL의 carId 크로스 비교
    if (carId != null &&
        carId!.isNotEmpty &&
        carUrlCarId != null &&
        carId == carUrlCarId) {
      return true;
    }
    if (urlCarId != null &&
        car.carId != null &&
        car.carId!.isNotEmpty &&
        urlCarId == car.carId) {
      return true;
    }

    // 조건 5: brand + model + year + actualPrice (가격으로 구별)
    if (brand == car.brand &&
        model == car.model &&
        year == car.year &&
        actualPrice != null &&
        actualPrice! > 0 &&
        car.actualPrice > 0 &&
        actualPrice == car.actualPrice) {
      return true;
    }

    return false;
  }
}

/// 개별 매물 분석 결과
class DealAnalysis {
  final String brand;
  final String model;
  final int year;
  final int mileage;
  final String fuel;
  final PriceFairness priceFairness;
  final FraudRisk fraudRisk;
  final List<String> negoPoints;
  final DealSummary summary;

  DealAnalysis({
    required this.brand,
    required this.model,
    required this.year,
    required this.mileage,
    required this.fuel,
    required this.priceFairness,
    required this.fraudRisk,
    required this.negoPoints,
    required this.summary,
  });

  factory DealAnalysis.fromJson(Map<String, dynamic> json) {
    return DealAnalysis(
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? 0,
      mileage: json['mileage'] ?? 0,
      fuel: json['fuel'] ?? '가솔린',
      priceFairness: PriceFairness.fromJson(json['price_fairness'] ?? {}),
      fraudRisk: FraudRisk.fromJson(json['fraud_risk'] ?? {}),
      negoPoints: List<String>.from(json['nego_points'] ?? []),
      summary: DealSummary.fromJson(json['summary'] ?? {}),
    );
  }
}

/// 가격 적정성
class PriceFairness {
  final int score;
  final String label;
  final int percentile;
  final String description;

  PriceFairness({
    required this.score,
    required this.label,
    required this.percentile,
    required this.description,
  });

  factory PriceFairness.fromJson(Map<String, dynamic> json) {
    return PriceFairness(
      score: json['score'] ?? 50,
      label: json['label'] ?? '판단불가',
      percentile: json['percentile'] ?? 50,
      description: json['description'] ?? '',
    );
  }
}

/// 허위매물 위험도
class FraudRisk {
  final int score;
  final String level; // low, medium, high
  final List<FraudFactor> factors;

  FraudRisk({
    required this.score,
    required this.level,
    required this.factors,
  });

  factory FraudRisk.fromJson(Map<String, dynamic> json) {
    return FraudRisk(
      score: json['score'] ?? 0,
      level: json['level'] ?? 'low',
      factors: (json['factors'] as List? ?? [])
          .map((e) => FraudFactor.fromJson(e))
          .toList(),
    );
  }

  Color get levelColor {
    switch (level) {
      case 'high':
        return const Color(0xFFE53935);
      case 'medium':
        return const Color(0xFFFFA726);
      default:
        return const Color(0xFF66BB6A);
    }
  }

  String get levelText {
    switch (level) {
      case 'high':
        return '높음';
      case 'medium':
        return '보통';
      default:
        return '낮음';
    }
  }
}

/// 허위매물 체크 요소
class FraudFactor {
  final String check;
  final String status; // pass, warn, fail, info
  final String msg;

  FraudFactor({
    required this.check,
    required this.status,
    required this.msg,
  });

  factory FraudFactor.fromJson(Map<String, dynamic> json) {
    return FraudFactor(
      check: json['check'] ?? '',
      status: json['status'] ?? 'info',
      msg: json['msg'] ?? '',
    );
  }

  Color get statusColor {
    switch (status) {
      case 'pass':
        return const Color(0xFF66BB6A);
      case 'warn':
        return const Color(0xFFFFA726);
      case 'fail':
        return const Color(0xFFE53935);
      default:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case 'pass':
        return Icons.check_circle;
      case 'warn':
        return Icons.warning;
      case 'fail':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }
}

/// 분석 요약
class DealSummary {
  final int actualPrice;
  final int predictedPrice;
  final int priceDiff;
  final double priceDiffPct;
  final bool isGoodDeal;
  final String verdict;

  DealSummary({
    required this.actualPrice,
    required this.predictedPrice,
    required this.priceDiff,
    required this.priceDiffPct,
    required this.isGoodDeal,
    required this.verdict,
  });

  factory DealSummary.fromJson(Map<String, dynamic> json) {
    return DealSummary(
      actualPrice: json['actual_price'] ?? 0,
      predictedPrice: json['predicted_price'] ?? 0,
      priceDiff: json['price_diff'] ?? 0,
      priceDiffPct: (json['price_diff_pct'] ?? 0).toDouble(),
      isGoodDeal: json['is_good_deal'] ?? false,
      verdict: json['verdict'] ?? '',
    );
  }
}

/// 가격 알림 모델
class PriceAlert {
  final int id;
  final String brand;
  final String model;
  final int year;
  final double targetPrice;
  final bool isActive;
  final String? createdAt;

  PriceAlert({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.targetPrice,
    required this.isActive,
    this.createdAt,
  });

  factory PriceAlert.fromJson(Map<String, dynamic> json) {
    return PriceAlert(
      id: json['id'] ?? 0,
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? 0,
      targetPrice: (json['target_price'] ?? 0).toDouble(),
      isActive: json['is_active'] ?? false,
      createdAt: json['created_at'],
    );
  }
}

/// AI 생성 네고 대본 모델
class NegotiationScript {
  final String messageScript; // 문자용 대본
  final List<String> phoneScript; // 전화용 단계별 대본
  final String tip; // 협상 팁
  final List<String> checkpoints; // 체크포인트

  NegotiationScript({
    required this.messageScript,
    required this.phoneScript,
    required this.tip,
    required this.checkpoints,
  });

  factory NegotiationScript.fromJson(Map<String, dynamic> json) {
    return NegotiationScript(
      messageScript: json['message_script'] ?? '',
      phoneScript: List<String>.from(json['phone_script'] ?? []),
      tip: json['tip'] ?? '',
      checkpoints: List<String>.from(json['checkpoints'] ?? []),
    );
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

/// AI 상태 모델
class AiStatus {
  final bool isConnected;
  final String? model;
  final String status;

  AiStatus({
    required this.isConnected,
    this.model,
    required this.status,
  });

  factory AiStatus.fromJson(Map<String, dynamic> json) {
    return AiStatus(
      isConnected: json['groq_available'] ?? false,
      model: json['model'],
      status: json['status'] ?? 'unknown',
    );
  }
}
