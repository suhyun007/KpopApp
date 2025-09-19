import 'package:flutter/foundation.dart';

class ApiConfig {
  // 환경에 따른 API URL 설정
  static String get baseUrl {
    // 테스트를 위해 강제로 로컬 서버 사용 (포트 3002)
    //return 'https://kpop-server-lilac.vercel.app/';
     if (kDebugMode) {
       // 로컬 개발 환경
       return 'http://localhost:3000/';  // 포트 3002로 변경
     } else {
       // 배포 환경 (Vercel)
       return 'https://kpop-server-lilac.vercel.app/';
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
