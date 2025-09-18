import 'package:flutter/material.dart';

class PopularList extends StatelessWidget {
  const PopularList({super.key});

  // K-pop 가수 TOP 10 리스트
  final List<Map<String, dynamic>> kpopArtists = const [
    {'rank': 1, 'name': 'BTS', 'group': '방탄소년단', 'color': Color(0xFF6B46C1)},
    {'rank': 2, 'name': 'BLACKPINK', 'group': '블랙핑크', 'color': Color(0xFF000000)},
    {'rank': 3, 'name': 'Stray Kids', 'group': '스트레이 키즈', 'color': Color(0xFF1E40AF)},
    {'rank': 4, 'name': 'NewJeans', 'group': '뉴진스', 'color': Color(0xFF059669)},
    {'rank': 5, 'name': 'SEVENTEEN', 'group': '세븐틴', 'color': Color(0xFFDC2626)},
    {'rank': 6, 'name': '아이브', 'group': 'IVE', 'color': Color(0xFF7C3AED)},
    {'rank': 7, 'name': 'TWICE', 'group': '트와이스', 'color': Color(0xFFEC4899)},
    {'rank': 8, 'name': '에스파', 'group': 'aespa', 'color': Color(0xFF06B6D4)},
    {'rank': 9, 'name': '르세라핌', 'group': 'LE SSERAFIM', 'color': Color(0xFFF59E0B)},
    {'rank': 10, 'name': '베이몬스터', 'group': 'BAEMON', 'color': Color(0xFF8B5CF6)},
  ];

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
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: kpopArtists.length,
              itemBuilder: (context, index) {
                final artist = kpopArtists[index];
                return Top10ArtistItem(
                  rank: artist['rank'] as int,
                  name: artist['name'] as String,
                  group: artist['group'] as String,
                  color: artist['color'] as Color,
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
    return Container(
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
    );
  }
}
