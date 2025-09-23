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
            _errorMessage = '문제가 발생했습니다. 앱을 다시 실행해주세요.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = '일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '네트워크 상태를 확인해주세요.';
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
          title: Row(
            children: [
              const Text(
                'Concert Map',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _fetchAllConcerts,
                padding: EdgeInsets.only(top:2),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          centerTitle: false,
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
          const SizedBox(height: 15),
          ElevatedButton.icon(
            onPressed: _fetchAllConcerts,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Try Again'),
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
      padding: const EdgeInsets.only(top: 0, left: 15, right: 15, bottom: 15),
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
      margin: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 지역 헤더 - 골드 색상
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE6C767),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                /*Icon(
                  Icons.location_on,
                  color: Colors.grey[800],
                  size: 20,
                ),*/
                const SizedBox(width: 5),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city.isNotEmpty ? city : country,
                        style: TextStyle(
                          color: Colors.grey[900],
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (city.isNotEmpty)
                        Text(
                          country,
                          style: TextStyle(
                            color: Colors.grey[900],
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${concerts.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 콘서트 목록
          ...concerts.asMap().entries.map((entry) {
            final index = entry.key;
            final concert = entry.value;
            return _buildConcertItem(concert, isFirst: index == 0);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildConcertItem(Map<String, dynamic> concert, {bool isFirst = false}) {
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
        margin: const EdgeInsets.only(left: 0, right: 0, bottom: 0),
        padding: const EdgeInsets.only(top: 15, left: 20, right: 15, bottom: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: isFirst 
            ? const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
              )
            : null,
          border: const Border(
            bottom: BorderSide(
              color: Color(0xFFC3C3C3),
              width: 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 아티스트명
            Text(
              artistName,
              style: const TextStyle(
                color: Colors.black,
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
                  color: Colors.grey[600],
                  size: 17,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    venueName,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            
            // 날짜와 화살표
            Row(
              children: [
                const SizedBox(width: 2),
                Icon(
                  Icons.calendar_today,
                  color: Colors.grey[800],
                  size: 14,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    _formatDateRange(startDate, endDate),
                    style: const TextStyle(
                      color: Color(0xFFB8860B),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[600],
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
