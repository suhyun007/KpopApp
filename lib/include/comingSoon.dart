import 'package:flutter/material.dart';

class ComingSoon extends StatelessWidget {
  const ComingSoon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      //height: 280, // 고정 높이 (제목 + 3개 카드 + 간격)
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          const Text(
            'COMING SOON',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              SizedBox(
                height:72,
                child: ComingSoonCard(
                  artist: 'BTS',
                  date: 'APR 18, SEOUL',
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 72,
                child: ComingSoonCard(
                  artist: 'BLACKPINK',
                  date: 'MAY 5, TOKYO',
                  color: Colors.pink,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 72,
                child: ComingSoonCard(
                  artist: 'TWICE',
                  date: 'JUL 10, LOS ANGELES',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 72,
                child: ComingSoonCard(
                  artist: 'Stray Kids',
                  date: 'AUG 15, SEOUL',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 72,
                child: ComingSoonCard(
                  artist: 'NewJeans',
                  date: 'SEP 20, TOKYO',
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }
}

// COMING SOON 카드 위젯
class ComingSoonCard extends StatelessWidget {
  final String artist;
  final String date;
  final Color color;

  const ComingSoonCard({
    super.key,
    required this.artist,
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
          const SizedBox(height: 4),
          Text(
            date,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
