import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _searchResults = [];

  // 검색할 데이터 (임시)
  final List<Map<String, dynamic>> _allData = [
    {'name': 'BTS', 'type': 'artist', 'fans': '1.2M'},
    {'name': 'BLACKPINK', 'type': 'artist', 'fans': '980K'},
    {'name': 'Stray Kids', 'type': 'artist', 'fans': '850K'},
    {'name': 'NewJeans', 'type': 'artist', 'fans': '720K'},
    {'name': 'SEVENTEEN', 'type': 'artist', 'fans': '680K'},
    {'name': '아이브', 'type': 'artist', 'fans': '650K'},
    {'name': 'TWICE', 'type': 'artist', 'fans': '620K'},
    {'name': '에스파', 'type': 'artist', 'fans': '580K'},
    {'name': '르세라핌', 'type': 'artist', 'fans': '550K'},
    {'name': '베이몬스터', 'type': 'artist', 'fans': '520K'},
    {'name': 'BTS WORLD TOUR', 'type': 'concert', 'date': '2024-03-15'},
    {'name': 'BLACKPINK CONCERT', 'type': 'concert', 'date': '2024-04-20'},
    {'name': 'Stray Kids SHOW', 'type': 'concert', 'date': '2024-05-10'},
  ];

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = _allData
            .where((item) => item['name'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: '아티스트, 콘서트 검색...',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
          ),
          onChanged: _performSearch,
          autofocus: true,
        ),
        actions: [
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.white),
              onPressed: () {
                _searchController.clear();
                _performSearch('');
              },
            ),
        ],
      ),
      body: _searchQuery.isEmpty
          ? _buildEmptyState()
          : _searchResults.isEmpty
              ? _buildNoResults()
              : _buildSearchResults(),
    );
  }

  Widget _buildEmptyState() {
    return Stack(
      children: [
        Positioned(
          top: 250,
          left: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.search,
                color: Colors.grey,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                '아티스트 또는 콘서트를 검색해주세요.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoResults() {
    return Stack(
      children: [
        Positioned(
          top: 250,
          left: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.search_off,
                color: Colors.grey,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                '"$_searchQuery"에 대한 검색 결과가 없습니다',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        return _buildSearchResultItem(item);
      },
    );
  }

  Widget _buildSearchResultItem(Map<String, dynamic> item) {
    final isArtist = item['type'] == 'artist';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isArtist ? const Color(0xFFE6C767) : const Color(0xFFD4AF37),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 아이콘
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isArtist ? const Color(0xFFE6C767) : const Color(0xFFD4AF37),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isArtist ? Icons.music_note : Icons.event,
              color: Colors.black,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: TextStyle(
                    color: isArtist ? const Color(0xFFE6C767) : const Color(0xFFD4AF37),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Raleway',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isArtist ? '${item['fans']} 팬' : '${item['date']}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontFamily: 'Raleway',
                  ),
                ),
              ],
            ),
          ),
          // 화살표
          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey,
            size: 16,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
