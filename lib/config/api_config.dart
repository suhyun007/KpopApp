import 'package:flutter/foundation.dart';

class ApiConfig {
  // 환경에 따른 API URL 설정
  static String get baseUrl {
    if (kDebugMode) {
      // 로컬 개발 환경
      return 'http://localhost:3000';
    } else {
      // 배포 환경 (Vercel)
      return 'https://kpop-server.vercel.app';
    }
  }
  
  // API 엔드포인트들
  static String get popularArtists => '$baseUrl/api/popular';
  static String get artistDetail => '$baseUrl/api/artists';
  static String get concerts => '$baseUrl/api/concerts';
  
  // 환경 정보 출력 (디버깅용)
  static void printEnvironment() {
    if (kDebugMode) {
      print('🔧 API Config - Environment: ${kDebugMode ? "Development" : "Production"}');
      print('🌐 Base URL: $baseUrl');
    }
  }
}
