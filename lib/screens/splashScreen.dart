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

class _SplashScreenState extends State<SplashScreen> 
  with SingleTickerProviderStateMixin{
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    //애니메이션 컨트롤러(2초 동안 실행)
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 2),);
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn,);
    _controller.forward();  //시작할때 자동 실행
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
    await Future.delayed(const Duration(seconds: 2),(){
      Navigator.of(context).pushReplacementNamed('/main');
    });

    //홈으로 이동
    /*Future.delayed(Duration(seconds: 3), (){
      Navigator.pushReplacementNamed(context, '/main');
    });*/
  }

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Image.asset('image/icons/LaunchImage.png', width: 165, height: 165,),
        ),
        
        /*child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('image/icons/LaunchImage.png', width: 150, height: 150,),
            SizedBox(height: 30),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ],  
        ),*/
      ),
    );
  }
}

