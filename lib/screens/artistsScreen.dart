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
          } else {
            artists.addAll(newArtists);
          }
          
          currentPage++;
          hasMoreData = newArtists.length == limit;
          isLoading = false;
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
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async {
                            await _data.fetchArtists(isRefresh: true);
                            if (mounted) setState(() {});
                          },
                          child: const Text('다시 시도'),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _data.artists.length + (_data.hasMoreData ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _data.artists.length) {
                        // 로딩 인디케이터
                        return _data.isLoadingMore
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFFE6C767),
                                ),
                              )
                            : const SizedBox.shrink();
                      }
                      
                      // 스크롤이 끝에 가까우면 더 많은 데이터 로드
                      if (index == _data.artists.length - 1 && _data.hasMoreData && !_data.isLoadingMore) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _data.loadMoreArtists().then((_) {
                            if (mounted) setState(() {});
                          });
                        });
                      }
                      
                      return _buildArtistCard(_data.artists[index]);
                    },
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
