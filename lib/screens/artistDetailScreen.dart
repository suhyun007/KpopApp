import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';
import '../config/api_config.dart';

class ArtistDetailScreen extends StatefulWidget {
  final String artistName;
  final int? artistId; // 아티스트 ID 추가

  const ArtistDetailScreen({
    super.key,
    required this.artistName,
    this.artistId, // 선택적 매개변수
  });

  @override
  State<ArtistDetailScreen> createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends State<ArtistDetailScreen> {
  Map<String, dynamic>? artistData;
  List<Map<String, dynamic>> concerts = [];
  bool isLoading = true;
  bool isLoadingConcerts = false;
  String? errorMessage;
  String? concertErrorMessage;
  bool isDescriptionExpanded = false;
  String currentLanguage = 'ko';

  @override
  void initState() {
    super.initState();
    _detectSystemLanguage();
    _fetchArtistDetail();
  }

  void _detectSystemLanguage() {
    final locale = PlatformDispatcher.instance.locale;
    final languageCode = locale.languageCode;
    
    // 지원하는 언어로 매핑 (ko, en, ja, zh, es)
    switch (languageCode) {
      case 'ko':
        currentLanguage = 'ko';
        break;
      case 'ja':
        currentLanguage = 'ja';
        break;
      case 'zh':
        currentLanguage = 'zh';
        break;
      case 'es':
        currentLanguage = 'es';
        break;
      case 'en':
        currentLanguage = 'en';
        break;
      default:
        currentLanguage = 'en'; // 기본값은 영어
        break;
    }
  }

  Future<void> _fetchArtistDetail() async {
    try {
      // artistId가 있으면 ID로 조회, 없으면 이름으로 조회 (fallback)
      String apiUrl;
      if (widget.artistId != null) {
        apiUrl = ApiConfig.getArtistDetailById(widget.artistId!);
        print('🎯 아티스트 상세 조회 (ID): ${widget.artistId}');
      } else {
        apiUrl = ApiConfig.getArtistDetailByName(widget.artistName);
        print('⚠️ 아티스트 상세 조회 (이름 fallback): ${widget.artistName}');
      }
      
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            // API 응답에서 artists 배열의 첫 번째 요소를 가져옴
            final artists = data['artists'] as List<dynamic>?;
            if (artists != null && artists.isNotEmpty) {
              artistData = artists.first as Map<String, dynamic>;
              // 아티스트 정보 로드 후 콘서트 정보 조회
              _fetchConcerts();
            } else {
              artistData = null;
            }
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = data['error'] ?? '아티스트 정보를 불러올 수 없습니다.';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = '서버 오류가 발생했습니다.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = '네트워크 오류가 발생했습니다.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.artistName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _buildBody(),
    );
  }

  Future<void> _fetchConcerts() async {
    setState(() {
      isLoadingConcerts = true;
      concertErrorMessage = null;
    });

    try {
      // artist_id가 있으면 ID로 조회, 없으면 이름으로 조회
      String apiUrl;
      if (artistData != null && artistData!['id'] != null) {
        apiUrl = ApiConfig.getConcertsByArtistId(artistData!['id']);
      } else {
        apiUrl = ApiConfig.getConcertsByArtist(widget.artistName);
      }
      
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            concerts = List<Map<String, dynamic>>.from(data['concerts'] ?? []);
            isLoadingConcerts = false;
            concertErrorMessage = null;
          });
        } else {
          setState(() {
            concerts = [];
            isLoadingConcerts = false;
            concertErrorMessage = data['error'] ?? '콘서트 정보를 불러올 수 없습니다.';
          });
        }
      } else {
        setState(() {
          concerts = [];
          isLoadingConcerts = false;
          concertErrorMessage = '서버 오류가 발생했습니다. (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        concerts = [];
        isLoadingConcerts = false;
        concertErrorMessage = '네트워크 연결을 확인해주세요.';
      });
    }
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFE6C767),
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off,
                color: Colors.red[400],
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                style: TextStyle(
                  color: Colors.red[300],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '네트워크 연결을 확인하고 다시 시도해주세요.',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchArtistDetail,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('다시 시도'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (artistData == null) {
      return const Center(
        child: Text(
          '아티스트 정보를 찾을 수 없습니다.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      );
    }

    return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 아티스트 프로필 섹션
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                  _getColorFromHex(artistData!['color_code'] ?? '#E6C767').withOpacity(0.8),
                  _getColorFromHex(artistData!['color_code'] ?? '#E6C767').withOpacity(0.4),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // 아티스트 프로필 이미지
                  Container(
                  width: 80,
                  height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                      widget.artistName.substring(0, 1),
                        style: const TextStyle(
                          color: Colors.black,
                        fontSize: 40,
                          fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                  // 아티스트 이름
                  Text(
                  widget.artistName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                // 팬 수 (팬덤명 포함)
                  Text(
                  _getFansWithFandom(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                  ),
                ),
                // 소속사
                if (artistData!['agency'] != null && artistData!['agency'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${artistData!['agency']}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 아티스트 소개 섹션
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE6C767), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About artist',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE6C767),
                    ),
                  ),
                  const SizedBox(height: 12),
                _buildDescriptionText(),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 콘서트 정보 섹션
            const Text(
            'COMING SOON',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

          // 실제 콘서트 데이터 표시
          _buildConcertsList(),

            const SizedBox(height: 24),

            // 앨범 정보 섹션
            const Text(
              'LATEST ALBUMS',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // 앨범 카드들
            _buildAlbumCard(
              'Latest Album',
              '2024',
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildAlbumCard(
              'Previous Album',
              '2023',
              Colors.green,
            ),
          ],
        ),
    );
  }

  String _getFansWithFandom() {
    final fandomName = artistData?['fandom_name'];
    final fanCount = artistData?['fan_count'] ?? '0';
    
    if (fandomName != null && fandomName.toString().isNotEmpty) {
      return '$fandomName / $fanCount Fans';
    }
    
    return '$fanCount Fans';
  }

  String _getArtistDescription() {
    if (artistData == null) {
      return '...';
    }

    // artist_translations 테이블에서 현재 언어의 description 찾기
    final translations = artistData!['artist_translations'] as List<dynamic>?;
    if (translations != null && translations.isNotEmpty) {
      // 1. 먼저 현재 언어로 번역 찾기
      for (final translation in translations) {
        if (translation['lang'] == currentLanguage && translation['description'] != null) {
          return translation['description'];
        }
      }
      
      // 2. 현재 언어 번역이 없으면 영어로 fallback
      for (final translation in translations) {
        if (translation['lang'] == 'en' && translation['description'] != null) {
          return translation['description'];
        }
      }
    }

    // 번역이 없으면 기본 설명 반환
    return 'K-POP의 다양한 매력과 색채를 보여주는 아티스트입니다. 음악을 통해 많은 사랑을 받고 있으며, 팬들과 함께 성장해나가고 있습니다.';
  }

  Color _getColorFromHex(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return const Color(0xFFE6C767); // 기본 색상
    }
  }

  Widget _buildConcertsList() {
    if (isLoadingConcerts) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(
            color: Color(0xFFE6C767),
          ),
        ),
      );
    }

    if (concertErrorMessage != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red[900]?.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red[400]!, width: 1),
        ),
        child: Column(
          children: [
            Icon(
              Icons.wifi_off,
              color: Colors.red[400],
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              concertErrorMessage!,
              style: TextStyle(
                color: Colors.red[300],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _fetchConcerts,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('다시 시도'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
      );
    }

    if (concerts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[600]!, width: 1),
        ),
        child: Column(
          children: [
            Text(
              'No upcoming concerts scheduled',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Check back later for updates',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: concerts.map((concert) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildConcertCardFromData(concert),
        );
      }).toList(),
    );
  }

  Widget _buildConcertCardFromData(Map<String, dynamic> concert) {
    final title = concert['description'] ?? 'Concert';
    final startDate = concert['start_date'] ?? '';
    final endDate = concert['end_date'] ?? '';
    final venue = concert['venue_name_en'] ?? concert['venue_name_kr'] ?? '';
    final city = concert['city'] ?? '';
    final country = concert['country'] ?? '';
    final concertType = concert['concert_type'] ?? 'CONCERT';

    // 날짜 포맷팅
    String dateText = startDate;
    if (endDate.isNotEmpty && endDate != startDate) {
      dateText = '$startDate ~ $endDate';
    }

    // 위치 정보
    String location = '';
    if (venue.isNotEmpty) {
      location = venue;
    }
    if (city.isNotEmpty) {
      location += location.isNotEmpty ? ', $city' : city;
    }
    if (country.isNotEmpty) {
      location += location.isNotEmpty ? ', $country' : country;
    }

    return _buildConcertCard(
      title,
      dateText,
      location,
      _getConcertTypeColor(concertType),
    );
  }

  Color _getConcertTypeColor(String type) {
    switch (type) {
      case 'CONCERT':
        return Colors.purple;
      case 'FANMEETING':
        return Colors.pink;
      case 'TOUR':
        return Colors.blue;
      case 'SHOWCASE':
        return Colors.orange;
      case 'SCHEDULE':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildDescriptionText() {
    final description = _getArtistDescription();
    
    // 첫 번째 마침표의 위치 찾기
    final firstDotIndex = description.indexOf('.');
    
    // 마침표가 없거나 첫 번째 문장이 너무 짧으면 더보기 버튼 없이 그대로 표시
    if (firstDotIndex == -1 || firstDotIndex < 20) {
      return Text(
        description,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.white,
          height: 1.4,
        ),
      );
    }

    // 첫 번째 문장 추출 (마침표 포함)
    final firstSentence = description.substring(0, firstDotIndex + 1);

    return isDescriptionExpanded 
      ? RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  height: 1.6,
                ),
              ),
              const TextSpan(text: ' '),
              WidgetSpan(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isDescriptionExpanded = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6C767).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE6C767), width: 1),
                    ),
                    child: const Text(
                      'hide',
                      style: TextStyle(
                        color: Color(0xFFE6C767),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      : RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: firstSentence,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  height: 1.6,
                ),
              ),
              WidgetSpan(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isDescriptionExpanded = true;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6C767).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE6C767), width: 1),
                    ),
                    child: const Text(
                      'more',
                      style: TextStyle(
                        color: Color(0xFFE6C767),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
  }


  Widget _buildConcertCard(String title, String date, String location, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.8),
            color.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            date,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          Text(
            location,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumCard(String title, String year, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                year,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '앨범 정보',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
