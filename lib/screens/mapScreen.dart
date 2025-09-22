import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Map<String, dynamic>> _allConcerts = [];
  Map<String, List<Map<String, dynamic>>> _groupedConcerts = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAllConcerts();
  }

  Future<void> _fetchAllConcerts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.concerts),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _allConcerts = List<Map<String, dynamic>>.from(data['concerts'] ?? []);
            _groupConcertsByLocation();
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = data['error'] ?? '콘서트 정보를 불러올 수 없습니다.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = '서버 오류가 발생했습니다.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '네트워크 오류가 발생했습니다.';
        _isLoading = false;
      });
    }
  }

  void _groupConcertsByLocation() {
    _groupedConcerts.clear();
    
    for (final concert in _allConcerts) {
      final country = concert['country'] as String? ?? 'Unknown';
      final city = concert['city'] as String? ?? 'Unknown';
      final locationKey = '$country, $city';
      
      if (!_groupedConcerts.containsKey(locationKey)) {
        _groupedConcerts[locationKey] = [];
      }
      _groupedConcerts[locationKey]!.add(concert);
    }
    
    // 각 지역별로 날짜순 정렬
    _groupedConcerts.forEach((key, concerts) {
      concerts.sort((a, b) {
        final dateA = a['start_date'] as String? ?? '';
        final dateB = b['start_date'] as String? ?? '';
        return dateA.compareTo(dateB);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Concert Map',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchAllConcerts,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE6C767),
              ),
            )
          : _errorMessage != null
              ? _buildErrorState()
              : _buildConcertMap(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[400],
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: TextStyle(
              color: Colors.red[300],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _fetchAllConcerts,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('다시 시도'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConcertMap() {
    if (_groupedConcerts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              color: Colors.grey,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'No concerts scheduled',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: _groupedConcerts.length,
      itemBuilder: (context, index) {
        final locationKey = _groupedConcerts.keys.elementAt(index);
        final concerts = _groupedConcerts[locationKey]!;
        
        return _buildLocationGroup(locationKey, concerts);
      },
    );
  }

  Widget _buildLocationGroup(String locationKey, List<Map<String, dynamic>> concerts) {
    final parts = locationKey.split(', ');
    final country = parts[0];
    final city = parts.length > 1 ? parts[1] : '';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFE6C767),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 지역 헤더
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: const Color(0xFFE6C767).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: const Color(0xFFE6C767),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city.isNotEmpty ? city : country,
                        style: const TextStyle(
                          color: Color(0xFFE6C767),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (city.isNotEmpty)
                        Text(
                          country,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6C767),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${concerts.length}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 콘서트 목록
          ...concerts.map((concert) => _buildConcertItem(concert)).toList(),
        ],
      ),
    );
  }

  Widget _buildConcertItem(Map<String, dynamic> concert) {
    // artists 객체가 중첩되어 있을 수 있으므로 안전하게 처리
    String artistName = '';
    if (concert['artists'] != null && concert['artists'] is Map) {
      artistName = (concert['artists'] as Map<String, dynamic>)['artist_name_en'] as String? ?? '';
    } else {
      artistName = concert['artist_name_en'] as String? ?? '';
    }
    
    final venueName = concert['venue_name_en'] as String? ?? '';
    final startDate = concert['start_date'] as String? ?? '';
    final endDate = concert['end_date'] as String? ?? '';
    
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/concert-detail',
          arguments: {
            'concert': concert,
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[600]!,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 아티스트명
            Text(
              artistName,
              style: const TextStyle(
                color: Color(0xFFE6C767),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // 장소명
            Row(
              children: [
                Icon(
                  Icons.place,
                  color: Colors.grey[400],
                  size: 16,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    venueName,
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            
            // 날짜
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Colors.grey[400],
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDateRange(startDate, endDate),
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            
            // 클릭 힌트
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[500],
                  size: 12,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateRange(String startDate, String endDate) {
    if (startDate.isEmpty) return 'Date TBD';
    
    final start = DateTime.tryParse(startDate);
    if (start == null) return startDate;
    
    if (endDate.isEmpty || startDate == endDate) {
      return '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
    }
    
    final end = DateTime.tryParse(endDate);
    if (end == null) return startDate;
    
    return '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')} ~ ${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';
  }
}
