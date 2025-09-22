import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

// 전역 상태 관리 클래스
class PopularListData {
  static final PopularListData _instance = PopularListData._internal();
  factory PopularListData() => _instance;
  PopularListData._internal();

  List<Map<String, dynamic>> artists = [];
  bool isLoading = true;
  String? errorMessage;
  bool hasLoaded = false; // 이미 로드되었는지 확인

  Future<void> fetchPopularArtists() async {
    if (hasLoaded && artists.isNotEmpty) {
      isLoading = false;
      return; // 이미 로드된 데이터가 있으면 API 호출하지 않음
    }

    try {
      // 환경 정보 출력 (디버깅용)
      ApiConfig.printEnvironment();
      
      // Next.js 서버의 API 엔드포인트 호출
      final response = await http.get(
        Uri.parse(ApiConfig.popularArtists),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          artists = List<Map<String, dynamic>>.from(data['artists']);
          isLoading = false;
          hasLoaded = true; // 로드 완료 표시
        } else {
          errorMessage = data['error'] ?? '데이터를 가져오는데 실패했습니다.';
          isLoading = false;
        }
      } else {
        errorMessage = '서버 오류: ${response.statusCode}';
        isLoading = false;
      }
    } catch (e) {
      errorMessage = '네트워크 오류: $e';
      isLoading = false;
    }
  }

  void reset() {
    artists = [];
    isLoading = true;
    errorMessage = null;
    hasLoaded = false;
  }
}

class PopularList extends StatefulWidget {
  const PopularList({super.key});

  @override
  State<PopularList> createState() => _PopularListState();
}

class _PopularListState extends State<PopularList> {
  final PopularListData _data = PopularListData();

  @override
  void initState() {
    super.initState();
    _data.fetchPopularArtists().then((_) {
      if (mounted) setState(() {});
    });
  }

  Color _getColorFromHex(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF6B46C1); // 기본 색상
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TOP 10',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 7),
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
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () async {
                                await _data.fetchPopularArtists();
                                if (mounted) setState(() {});
                              },
                              child: const Text('다시 시도'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _data.artists.length,
                        itemBuilder: (context, index) {
                          final artist = _data.artists[index];
                          return Top10ArtistItem(
                            rank: artist['rank'] as int,
                            name: artist['artist_name_en'] as String,
                            group: artist['artist_name_kr'] as String? ?? '',
                            color: _getColorFromHex(artist['color_code'] as String? ?? '#6B46C1'),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// TOP 10 가수 아이템 위젯
class Top10ArtistItem extends StatelessWidget {
  final int rank;
  final String name;
  final String group;
  final Color color;

  const Top10ArtistItem({
    super.key,
    required this.rank,
    required this.name,
    required this.group,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/artist-detail',
          arguments: name,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            // 순위 번호
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 가수 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    group,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
