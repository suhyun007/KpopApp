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
  bool isLoading = true;
  String? errorMessage;
  bool hasLoaded = false; // 이미 로드되었는지 확인

  Future<void> fetchArtists() async {
    if (hasLoaded && artists.isNotEmpty) {
      isLoading = false;
      return; // 이미 로드된 데이터가 있으면 API 호출하지 않음
    }

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.artistDetail),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          artists = List<Map<String, dynamic>>.from(data['artists'] ?? []);
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
    artists = [];
    isLoading = true;
    errorMessage = null;
    hasLoaded = false;
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


  Color _getColorFromHex(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return const Color(0xFFE6C767); // 기본 색상
    }
  }

  String _getArtistShortDescription(String artistName) {
    switch (artistName.toUpperCase()) {
      case 'BTS':
        return '한국을 대표하는 글로벌 보이그룹. 희망과 도전의 메시지를 전달하며 시대적 아이콘으로 자리잡았습니다.';
      case 'STRAY KIDS':
        return '강렬한 사운드와 자작곡 중심의 음악으로 주목받는 8인조 보이그룹. 차세대 K-POP을 대표하는 글로벌 아티스트입니다.';
      case 'NEWJEANS':
        return '신선한 음악과 자연스러운 콘셉트로 주목받는 5인조 걸그룹. K-POP의 새로운 흐름을 만들어가는 그룹입니다.';
      case 'SEVENTEEN':
        return '자체 프로듀싱 아이돌로 알려진 13명의 멤버로 구성된 보이그룹. 퍼포먼스, 보컬, 힙합 팀으로 나뉘어 다양한 매력을 보여줍니다.';
      case 'IVE':
        return '고급스럽고 세련된 콘셉트로 주목받는 6인조 걸그룹. 글로벌 음악 시장에서 두각을 드러내는 차세대 대표 그룹입니다.';
      case 'AESPA':
        return '현실과 가상 세계를 연결하는 독창적인 콘셉트로 주목받는 4인조 걸그룹. 혁신적인 아이디어로 글로벌 팬덤을 확장해가는 그룹입니다.';
      case 'TWICE':
        return '밝고 긍정적인 에너지로 사랑받는 대표 걸그룹. 활발한 해외 활동을 통해 글로벌 팬덤을 구축해왔습니다.';
      case 'LE SSERAFIM':
        return '자신감 넘치는 태도와 강렬한 메시지로 주목받는 5인조 걸그룹. 두려움 없는 매력으로 K-POP을 이끌어가는 팀입니다.';
      case 'BABYMONSTER':
        return '강력한 보컬과 랩 실력을 겸비한 7인조 걸그룹. 차세대 글로벌 걸그룹으로 주목받고 있습니다.';
      case 'NCT 127':
        return '실험적인 음악과 독창적인 퍼포먼스로 주목받는 9인조 보이그룹. 혁신적인 K-POP의 가능성을 보여주고 있습니다.';
      case 'ITZY':
        return '당당하고 자유로운 매력으로 사랑받는 5인조 걸그룹. 차세대 걸그룹으로 글로벌 시장에서 존재감을 키워가고 있습니다.';
      case 'ENHYPEN':
        return '몰입도 높은 세계관과 스토리텔링으로 팬들을 사로잡는 7인조 그룹. 새로운 세대의 K-POP 대표 그룹입니다.';
      case 'EXO':
        return '강렬한 퍼포먼스와 탄탄한 보컬 실력으로 인정받는 9인조 보이그룹. K-POP의 한 시대를 대표한 그룹입니다.';
      case 'RED VELVET':
        return '다채로운 콘셉트와 넓은 음악 스펙트럼을 보여주는 5인조 걸그룹. K-POP만의 다양성을 잘 보여주는 그룹입니다.';
      case 'TXT':
        return '청춘의 성장과 감정을 진솔하게 담아내는 5인조 보이그룹. 차세대 K-POP을 이끄는 대표적인 청춘 아이콘입니다.';
      case '(G)I-DLE':
        return '자작곡과 창의적인 콘셉트로 주목받는 5인조 걸그룹. K-POP 안에서 독보적인 위치를 차지하고 있습니다.';
      case 'SHINEE':
        return '실험적인 음악과 세련된 퍼포먼스로 오랜 시간 사랑받는 5인조 그룹. 자신들만의 음악 세계를 구축한 롱런 아티스트입니다.';
      default:
        return 'K-POP의 다양한 매력과 색깔을 보여주는 아티스트입니다.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 로딩 상태
            if (_data.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(50),
                  child: CircularProgressIndicator(
                    color: Color(0xFFE6C767),
                  ),
                ),
              )
            // 에러 상태
            else if (_data.errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(50),
                  child: Column(
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
                          await _data.fetchArtists();
                          if (mounted) setState(() {});
                        },
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
              )
            // 아티스트 그리드
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _data.artists.length,
                itemBuilder: (context, index) {
                  return _buildArtistCard(_data.artists[index]);
                },
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
        // 아티스트 상세 페이지로 이동
        Navigator.pushNamed(
          context,
          '/artist-detail',
          arguments: artistName,
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
              '$fanCount 팬',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontFamily: 'Raleway',
              ),
            ),
            
            const SizedBox(height: 8),
            
            // 아티스트 소개 (간단 버전)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                _getArtistShortDescription(artistName),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontFamily: 'Raleway',
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
