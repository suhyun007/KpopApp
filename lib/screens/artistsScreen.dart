import '../l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

// 전역 상태 관리 클래스
class ArtistsData {
  static final ArtistsData _instance = ArtistsData._internal();
  factory ArtistsData() => _instance;
  ArtistsData._internal();

  List<Map<String, dynamic>> artists = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  String? errorMessage;
  int currentPage = 1;
  int limit = 10;
  bool hasMoreData = true;

  Future<void> fetchArtists({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage = 1;
      artists = [];
      hasMoreData = true;
    }

    if (isLoading || !hasMoreData) return;

    isLoading = true;
    errorMessage = null;

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.artistDetail}?search=true&page=$currentPage&limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final newArtists = List<Map<String, dynamic>>.from(data['artists'] ?? []);
          
          if (isRefresh) {
            artists = newArtists;
            currentPage = 2; // 다음 페이지는 2
          } else {
            artists.addAll(newArtists);
            currentPage++;
          }
          
          hasMoreData = newArtists.length == limit;
          isLoading = false;
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

  Future<void> loadMoreArtists() async {
    if (isLoadingMore || !hasMoreData) return;

    isLoadingMore = true;

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.artistDetail}?search=true&page=$currentPage&limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final newArtists = List<Map<String, dynamic>>.from(data['artists'] ?? []);
          
          artists.addAll(newArtists);
          currentPage++;
          hasMoreData = newArtists.length == limit;
          isLoadingMore = false;
        } else {
          isLoadingMore = false;
        }
      } else {
        isLoadingMore = false;
      }
    } catch (e) {
      isLoadingMore = false;
    }
  }

  void reset() {
    artists = [];
    isLoading = false;
    isLoadingMore = false;
    errorMessage = null;
    currentPage = 1;
    hasMoreData = true;
  }

}

class ArtistsScreen extends StatefulWidget {
  const ArtistsScreen({super.key});

  @override
  State<ArtistsScreen> createState() => _ArtistsScreenState();
}

class _ArtistsScreenState extends State<ArtistsScreen> {
  final ArtistsData _data = ArtistsData();

  @override
  void initState() {
    super.initState();
    _data.fetchArtists().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: RefreshIndicator(
        onRefresh: () async {
          await _data.fetchArtists(isRefresh: true);
          if (mounted) setState(() {});
        },
        color: const Color(0xFFE6C767),
        child: _data.isLoading && _data.artists.isEmpty
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFE6C767),
                ),
              )
            : _data.errorMessage != null && _data.artists.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _data.errorMessage!,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: () async {
                            await _data.fetchArtists(isRefresh: true);
                            if (mounted) setState(() {});
                          },
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  )
                : Stack(
                    children: [
                      // 메인 GridView
                      GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _data.artists.length,
                        itemBuilder: (context, index) {
                          // 스크롤이 끝에 가까우면 더 많은 데이터 로드
                          if (index == _data.artists.length - 1 && _data.hasMoreData && !_data.isLoadingMore) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _data.loadMoreArtists().then((_) {
                                if (mounted) setState(() {});
                              });
                              // isLoadingMore = true 설정 직후 setState 호출
                              if (mounted) setState(() {});
                            });
                          }
                          
                          return _buildArtistCard(_data.artists[index]);
                        },
                      ),
                      // 로딩 오버레이 - 맨 마지막에 배치하여 모든 위젯 위에 표시
                      if (_data.isLoadingMore)
                        Container(
                          color: Colors.black.withOpacity(0.3), // 반투명 배경
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFE6C767),
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildArtistCard(Map<String, dynamic> artist) {
    final artistName = artist['artist_name_en'] as String? ?? '';
    final fanCount = artist['fan_count'] as String? ?? '0';
    // 무조건 골드 색상 사용
    final color = const Color(0xFFE6C767);
    
    return GestureDetector(
      onTap: () {
        // 아티스트 상세 페이지로 이동 (ID와 이름 모두 전달)
        Navigator.pushNamed(
          context,
          '/artist-detail',
          arguments: {
            'artistName': artistName,
            'artistId': artist['id'],
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 아티스트 프로필 이미지
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  artistName.isNotEmpty ? artistName.substring(0, 1) : '?',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // 아티스트 이름
            Text(
              artistName,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Raleway',
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 4),
            
            // 팬 수
            Text(
              '$fanCount Fans',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontFamily: 'Raleway',
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}
