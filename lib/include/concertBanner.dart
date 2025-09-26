import '../l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

// 전역 상태 관리 클래스
class ConcertBannerData {
  static final ConcertBannerData _instance = ConcertBannerData._internal();
  factory ConcertBannerData() => _instance;
  ConcertBannerData._internal();

  List<Map<String, dynamic>> concerts = [];
  bool isLoading = true;
  String? errorMessage;
  bool hasLoaded = false; // 이미 로드되었는지 확인

  Future<void> fetchConcerts() async {
    if (hasLoaded && concerts.isNotEmpty) {
      isLoading = false;
      return; // 이미 로드된 데이터가 있으면 API 호출하지 않음
    }

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.concerts),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          concerts = List<Map<String, dynamic>>.from(data['concerts'] ?? []);
          isLoading = false;
          hasLoaded = true; // 로드 완료 표시
        } else {
          errorMessage = 'AppLocalizations.of(context)?.serverError ?? "일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요."';
          isLoading = false;
        }
      } else {
        errorMessage = 'AppLocalizations.of(context)?.serverError ?? "일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요."';
        isLoading = false;
      }
    } catch (e) {
      errorMessage = 'AppLocalizations.of(context)?.networkError ?? "네트워크 상태를 확인해주세요."';
      isLoading = false;
    }
  }

  void reset() {
    concerts = [];
    isLoading = true;
    errorMessage = null;
    hasLoaded = false;
  }
}

class ConcertBanner extends StatefulWidget {
  const ConcertBanner({super.key});

  @override
  State<ConcertBanner> createState() => _ConcertBannerState();
}

class _ConcertBannerState extends State<ConcertBanner> {
  final ConcertBannerData _data = ConcertBannerData();
  int currentIndex = 0;
  PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
    _data.fetchConcerts().then((_) {
      if (mounted) {
        setState(() {});
        if (_data.concerts.isNotEmpty) {
          _startAutoScroll();
        }
      }
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }


  void _startAutoScroll() {
    if (_data.concerts.length <= 1) return; // 콘서트가 1개 이하면 자동 스크롤 불필요
    
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _data.concerts.isNotEmpty && _data.concerts.length > 1) {
        setState(() {
          currentIndex = (currentIndex + 1) % _data.concerts.length;
        });
        pageController.animateToPage(
          currentIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startAutoScroll();
      }
    });
  }

  int _calculateDaysUntil(String dateString) {
    try {
      final targetDate = DateTime.parse(dateString);
      final today = DateTime.now();
      final difference = targetDate.difference(today).inDays;
      return difference;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 420,
      height: 150,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage('image/bg/main.png'),
          fit: BoxFit.cover,
          opacity: 0.5,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.3),
              Colors.black.withOpacity(0.1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _data.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : _data.errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _data.errorMessage!,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async {
                            await _data.fetchConcerts();
                            if (mounted) setState(() {});
                          },
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  )
                : _data.concerts.isEmpty
                    ? const Center(
                        child: Text(
                          '등록된 콘서트가 없습니다.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : PageView.builder(
                        controller: pageController,
                        onPageChanged: (index) {
                          setState(() {
                            currentIndex = index;
                          });
                        },
                        itemCount: _data.concerts.length,
                        itemBuilder: (context, index) {
                          final concert = _data.concerts[index];
                          final daysUntil = _calculateDaysUntil(concert['start_date'] ?? '');
                          
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/artist-detail',
                                arguments: concert['artist_name_en'] ?? '',
                              );
                            },
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    concert['artist_name_en'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(3, 3),
                                          blurRadius: 6,
                                          color: Colors.black,
                                        ),
                                        Shadow(
                                          offset: Offset(2, 2),
                                          blurRadius: 4,
                                          color: Colors.black,
                                        ),
                                        Shadow(
                                          offset: Offset(1, 1),
                                          blurRadius: 2,
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    daysUntil >= 0 ? 'D-$daysUntil' : 'D+${-daysUntil}',
                                    style: const TextStyle(
                                      fontSize: 38,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(3, 3),
                                          blurRadius: 6,
                                          color: Colors.black,
                                        ),
                                        Shadow(
                                          offset: Offset(2, 2),
                                          blurRadius: 4,
                                          color: Colors.black,
                                        ),
                                        Shadow(
                                          offset: Offset(1, 1),
                                          blurRadius: 2,
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
