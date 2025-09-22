import 'package:flutter/material.dart';
import 'include/topMenu.dart';
import 'include/popularList.dart';
import 'include/comingSoon.dart';
import 'include/concertBanner.dart';
import 'screens/artistsScreen.dart';
import 'screens/mapScreen.dart';
import 'screens/myScreen.dart';
import 'screens/artistDetailScreen.dart';
import 'screens/concertDetailScreen.dart';
import 'screens/splashScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kpop Call',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/main': (context) => const MainScreen(),
        '/artist-detail': (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          if (args is Map<String, dynamic>) {
            // ID와 이름이 모두 있는 경우
            return ArtistDetailScreen(
              artistName: args['artistName'] as String,
              artistId: args['artistId'] as int?,
            );
          } else {
            // 이름만 있는 경우 (하위 호환성)
            return ArtistDetailScreen(artistName: args as String);
          }
        },
        '/concert-detail': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return ConcertDetailScreen(concert: args['concert']);
        },
      },
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
            // 동적 콘서트 배너
            const ConcertBanner(),
        
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

