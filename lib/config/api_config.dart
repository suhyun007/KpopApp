import 'package:flutter/foundation.dart';
import 'dart:io';

class ApiConfig {
  // 환경에 따른 API URL 설정
  static String get baseUrl {
    if (kDebugMode) {
       // 로컬 개발 환경 - 플랫폼별로 다른 URL 사용
       if (Platform.isAndroid) {
         // 안드로이드 에뮬레이터에서는 10.0.2.2 사용
         return 'http://10.0.2.2:3000/';
       } else if (Platform.isIOS) {
         // iOS 시뮬레이터에서는 localhost 사용
         // iOS 실제 디바이스에서는 맥북의 IP 주소 사용 (예: 192.168.1.100)
         return 'http://localhost:3000/';
       } else {
         // 기타 플랫폼 (웹, 데스크톱 등)
         return 'http://localhost:3000/';
       }
     } else {
       // 배포 환경 (Vercel)
       return 'https://kpop-server-lilac.vercel.app';
     }
  }
  
  // 핸드폰에서 맥북 서버 접근용 IP 주소
  static String get mobileBaseUrl {
    // 맥북의 실제 IP 주소 (ifconfig 명령어로 확인한 주소)
    return 'http://172.30.82.154:3000';
  }
  
  // iOS 시뮬레이터와 실제 디바이스 구분
  static bool get isIOSSimulator {
    if (!Platform.isIOS) return false;
    // iOS 시뮬레이터에서는 localhost가 작동함
    // 실제 디바이스에서는 localhost가 작동하지 않음
    return true; // 일단 시뮬레이터로 가정
  }
  
  // 핸드폰 테스트용 URL (실제 디바이스에서 테스트할 때 사용)
  static String get baseUrlForMobile {
    if (kDebugMode) {
      if (Platform.isIOS) {
        // iOS에서는 localhost 사용 (시뮬레이터용)
        return 'http://localhost:3000';
        //return 'https://kpop-server-lilac.vercel.app';
      } else if (Platform.isAndroid) {
        // 안드로이드 에뮬레이터에서는 10.0.2.2 사용
        return 'http://10.0.2.2:3000';
      }
      return mobileBaseUrl;
    } else {
      return 'https://kpop-server-lilac.vercel.app';
    }
  }
  
  // API 엔드포인트들 (핸드폰 테스트용)
  static String get popularArtists => '$baseUrlForMobile/api/popular';
  static String get artistDetail => '$baseUrlForMobile/api/artists';
  static String get concerts => '$baseUrlForMobile/api/concerts';
  
  // 아티스트 상세 정보 조회 (이름으로)
  static String getArtistDetailByName(String artistName) => '$baseUrlForMobile/api/artists?name=$artistName';
  
  // 아티스트별 콘서트 정보 조회
  static String getConcertsByArtist(String artistName) => '$baseUrlForMobile/api/concerts?artist=$artistName';
  
  // 환경 정보 출력 (디버깅용)
  static void printEnvironment() {
    if (kDebugMode) {
      print('🔧 API Config - Environment: ${kDebugMode ? "Development" : "Production"}');
      print('🌐 Base URL: $baseUrl');
      print('📱 Mobile Base URL: $baseUrlForMobile');
      print('🍎 Platform: ${Platform.isIOS ? "iOS" : Platform.isAndroid ? "Android" : "Other"}');
      print('🎯 Popular Artists URL: $popularArtists');
      print('🎯 Artist Detail URL: $artistDetail');
      print('🎯 Concerts URL: $concerts');
    }
  }
}
