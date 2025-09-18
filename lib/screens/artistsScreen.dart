import 'package:flutter/material.dart';

class ArtistsScreen extends StatelessWidget {
  const ArtistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // 아티스트 그리드
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 10,
              itemBuilder: (context, index) {
                return _buildArtistCard(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArtistCard(int index) {
    final artists = [
      {'name': 'BTS', 'fans': '1.2M', 'color': Color(0xFFE6C767)},
      {'name': 'BLACKPINK', 'fans': '980K', 'color': Color(0xFFD4AF37)},
      {'name': 'Stray Kids', 'fans': '850K', 'color': Color(0xFFE6C767)},
      {'name': 'NewJeans', 'fans': '720K', 'color': Color(0xFFD4AF37)},
      {'name': 'SEVENTEEN', 'fans': '680K', 'color': Color(0xFFE6C767)},
      {'name': '아이브', 'fans': '650K', 'color': Color(0xFFD4AF37)},
      {'name': 'TWICE', 'fans': '620K', 'color': Color(0xFFE6C767)},
      {'name': '에스파', 'fans': '580K', 'color': Color(0xFFD4AF37)},
      {'name': '르세라핌', 'fans': '550K', 'color': Color(0xFFE6C767)},
      {'name': '베이몬스터', 'fans': '520K', 'color': Color(0xFFD4AF37)},
    ];

    final artist = artists[index];
    
    return GestureDetector(
      onTap: () {
        // 아티스트 상세 페이지로 이동
        print('${artist['name']} 선택됨');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: artist['color'] as Color,
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
                color: artist['color'] as Color,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  artist['name'].toString().substring(0, 1),
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
              artist['name'].toString(),
              style: TextStyle(
                color: artist['color'] as Color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Raleway',
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 4),
            
            // 팬 수
            Text(
              '${artist['fans']} 팬',
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
