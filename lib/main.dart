import 'package:flutter/material.dart';
import 'include/topMenu.dart';
import 'include/popularList.dart';
import 'include/comingSoon.dart';
import 'screens/artistsScreen.dart';
import 'screens/mapScreen.dart';
import 'screens/myScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'K-Pop Call',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    const ArtistsScreen(),
    const MapScreen(),
    const MyScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const TopMenu(),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[400],
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'Artists',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'My',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
            // 포스터 배너
            Container(
              //width: double.infinity,
              width: 420,
              height: 200,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: AssetImage('image/bg/main.png'),
                  fit: BoxFit.cover, // 이미지가 컨테이너를 꽉 채움
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.3), // 어두운 오버레이
                      Colors.black.withOpacity(0.1),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'BTS CONCERT\nD-5',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 3,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        
        // 좌우 분할 레이아웃
         Expanded(
           child: Row(
             crossAxisAlignment: CrossAxisAlignment.start, // 상단 정렬
             children: [
               // 왼쪽: TOP 10 섹션
               Expanded(
                 flex: 1,
                 child: const PopularList(),
               ),
               
               // 오른쪽: COMING SOON 섹션
               Expanded(
                 flex: 1,
                 child: const ComingSoon(),
               ),
             ],
           ),
         ),
      ],
    );
  }
}

