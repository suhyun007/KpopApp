import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

// 전역 상태 관리 클래스
class ComingSoonData {
  static final ComingSoonData _instance = ComingSoonData._internal();
  factory ComingSoonData() => _instance;
  ComingSoonData._internal();

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
          errorMessage = data['error'] ?? '데이터를 불러올 수 없습니다.';
          isLoading = false;
        }
      } else {
        errorMessage = '서버 오류가 발생했습니다.';
        isLoading = false;
      }
    } catch (e) {
      errorMessage = '네트워크 오류가 발생했습니다.';
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

class ComingSoon extends StatefulWidget {
  const ComingSoon({super.key});

  @override
  State<ComingSoon> createState() => _ComingSoonState();
}

class _ComingSoonState extends State<ComingSoon> {
  final ComingSoonData _data = ComingSoonData();

  @override
  void initState() {
    super.initState();
    _data.fetchConcerts().then((_) {
      if (mounted) setState(() {});
    });
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 고정 제목
          const Text(
            'COMING SOON',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 7),
          // 스크롤 가능한 카드들
          Expanded(
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
                              child: const Text('다시 시도'),
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
                        : SingleChildScrollView(
                            child: Column(
                              children: _data.concerts.map((concert) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: SizedBox(
                                    height: 72,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/concert-detail',
                                          arguments: {
                                            'concert': concert,
                                          },
                                        );
                                      },
                                      child: ComingSoonCard(
                                        artist: concert['artist_name_en'] ?? '',
                                        venue: concert['venue_name_en'] ?? '',
                                        city: concert['city'] ?? '',
                                        date: concert['start_date'] ?? '',
                                        color: _getArtistColor(concert['artist_name_en'] ?? ''),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Color _getArtistColor(String artist) {
    switch (artist.toLowerCase()) {
      case 'bts':
        return Colors.purple;
      case 'blackpink':
        return Colors.pink;
      case 'twice':
        return Colors.blue;
      case 'stray kids':
        return Colors.orange;
      case 'newjeans':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

// COMING SOON 카드 위젯
class ComingSoonCard extends StatelessWidget {
  final String artist;
  final String venue;
  final String city;
  final String date;
  final Color color;

  const ComingSoonCard({
    super.key,
    required this.artist,
    required this.venue,
    required this.city,
    required this.date,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color.withOpacity(0.4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            artist,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${_formatDate(date)}, $city',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return '';
    
    try {
      final date = DateTime.parse(dateString);
      final months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 
                     'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
      return '${months[date.month - 1]} ${date.day}';
    } catch (e) {
      return dateString;
    }
  }
}
