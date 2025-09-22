import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../include/popularList.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _preloadData();
  }

  Future<void> _preloadData() async {
    try {
      // TOP 10 아티스트 데이터 미리 로드
      final response = await http.get(
        Uri.parse(ApiConfig.popularArtists),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // 데이터 로드 성공 시 PopularListData에 저장
          PopularListData().artists = List<Map<String, dynamic>>.from(data['artists']);
          PopularListData().hasLoaded = true;
          PopularListData().isLoading = false;
        }
      }
    } catch (e) {
      // 에러가 발생해도 메인 화면으로 이동
      print('Splash preload error: $e');
    }

    // 최소 2초는 스플래시 화면 유지
    await Future.delayed(const Duration(seconds: 2));

    // 메인 화면으로 이동
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: const Center(
          child: Image(
            image: AssetImage('image/icons/LaunchImage.png'),
            width: 150,
            height: 150,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

