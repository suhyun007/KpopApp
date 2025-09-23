import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class ConcertDetailScreen extends StatefulWidget {
  final Map<String, dynamic> concert;

  const ConcertDetailScreen({
    super.key,
    required this.concert,
  });

  @override
  State<ConcertDetailScreen> createState() => _ConcertDetailScreenState();
}

class _ConcertDetailScreenState extends State<ConcertDetailScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _concertData;
  List<Map<String, dynamic>> _artistConcerts = [];
  bool _isLoadingConcerts = true;

  @override
  void initState() {
    super.initState();
    _fetchConcertDetail();
  }

  Future<void> _fetchConcertDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final concertId = widget.concert['id'];
      final response = await http.get(
        Uri.parse(ApiConfig.getConcertDetailById(concertId)),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _concertData = data['concert'];
            _isLoading = false;
          });
          // 콘서트 데이터 로드 후 해당 아티스트의 모든 콘서트 조회
          _fetchArtistConcerts();
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

  Future<void> _fetchArtistConcerts() async {
    if (_concertData == null || _concertData!['artist_id'] == null) return;

    setState(() {
      _isLoadingConcerts = true;
    });

    try {
      final artistId = _concertData!['artist_id'];
      final response = await http.get(
        Uri.parse(ApiConfig.getConcertsByArtistId(artistId)),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _artistConcerts = List<Map<String, dynamic>>.from(data['concerts'] ?? []);
            _isLoadingConcerts = false;
          });
        } else {
          setState(() {
            _isLoadingConcerts = false;
          });
        }
      } else {
        setState(() {
          _isLoadingConcerts = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingConcerts = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Concert Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE6C767),
              ),
            )
          : _errorMessage != null
              ? _buildErrorState()
              : _buildConcertDetail(),
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
            onPressed: _fetchConcertDetail,
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

  Widget _buildConcertDetail() {
    if (_concertData == null) return const SizedBox.shrink();

    final concert = _concertData!;
    final artist = concert['artists'] ?? {};
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 아티스트 정보 카드
          _buildArtistCard(artist),
          const SizedBox(height: 12),
          
          // 콘서트 기본 정보
          // 통합된 콘서트 상세 정보
          _buildUnifiedConcertDetailsCard(concert),
          
          // 해당 아티스트의 모든 콘서트 일정
          const SizedBox(height: 12),
          _buildArtistConcertsSection(),
        ],
      ),
    );
  }

  Widget _buildArtistCard(Map<String, dynamic> artist) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE6C767), Color(0xFFD4B85A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            artist['artist_name_en'] ?? '',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (artist['artist_name_kr'] != null && artist['artist_name_kr'].toString().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              artist['artist_name_kr'],
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (artist['fandom_name'] != null && artist['fandom_name'].toString().isNotEmpty) ...[
            const SizedBox(height: 0),
            Text(
              '${artist['fandom_name']}',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnifiedConcertDetailsCard(Map<String, dynamic> concert) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE6C767),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 콘서트 정보 섹션
          _buildSectionHeader(Icons.event, 'Concert Information'),
          const SizedBox(height: 8),
          _buildInfoRow('Type', concert['concert_type'] ?? 'N/A'),
          _buildInfoRow('Status', concert['is_active'] == true ? 'Active' : 'Inactive'),
          if (concert['memo'] != null && concert['memo'].toString().isNotEmpty)
            _buildInfoRow('Memo', concert['memo']),
          
          const SizedBox(height: 12),
          
          // 장소 정보 섹션
          _buildSectionHeader(Icons.place, 'Venue Information'),
          const SizedBox(height: 8),
          _buildInfoRow('Venue', concert['venue_name_en'] ?? 'N/A'),
          if (concert['venue_name_kr'] != null && concert['venue_name_kr'].toString().isNotEmpty)
            _buildInfoRow('장소', concert['venue_name_kr']),
          _buildInfoRow('City', concert['city'] ?? 'N/A'),
          _buildInfoRow('Country', concert['country'] ?? 'N/A'),
          
          const SizedBox(height: 12),
          
          // 날짜 및 시간 섹션
          _buildSectionHeader(Icons.calendar_today, 'Date & Time'),
          const SizedBox(height: 8),
          _buildInfoRow('Start Date', concert['start_date'] ?? 'N/A'),
          _buildInfoRow('End Date', concert['end_date'] ?? 'N/A'),
          
          // 티켓 정보 (있는 경우만)
          if (concert['ticket_price'] != null && concert['ticket_price'].toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildSectionHeader(Icons.confirmation_number, 'Ticket Information'),
            const SizedBox(height: 8),
            _buildInfoRow('Price', concert['ticket_price']),
          ],
          
          // 설명 (있는 경우만)
          if (concert['description'] != null && concert['description'].toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildSectionHeader(Icons.description, 'Description'),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                concert['description'],
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFB8860B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildArtistConcertsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE6C767),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event_note,
                color: const Color(0xFFE6C767),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'All Concerts',
                style: TextStyle(
                  color: Color(0xFFE6C767),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _isLoadingConcerts
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFE6C767),
                  ),
                )
              : _artistConcerts.isEmpty
                  ? const Center(
                      child: Text(
                        'No other concerts scheduled',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : Column(
                      children: _artistConcerts.map((concert) => _buildConcertListItem(concert)).toList(),
                    ),
        ],
      ),
    );
  }

  Widget _buildConcertListItem(Map<String, dynamic> concert) {
    final venueName = concert['venue_name_en'] as String? ?? '';
    final startDate = concert['start_date'] as String? ?? '';
    final endDate = concert['end_date'] as String? ?? '';
    final city = concert['city'] as String? ?? '';
    final country = concert['country'] as String? ?? '';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey[600]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  style: const TextStyle(
                    color: Color(0xFFE6C767),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
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
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          
          // 위치
          if (city.isNotEmpty || country.isNotEmpty)
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.grey[400],
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  [city, country].where((e) => e.isNotEmpty).join(', '),
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _formatDateRange(String startDate, String endDate) {
    if (startDate.isEmpty) return 'Date TBD';
    
    try {
      final start = DateTime.parse(startDate);
      if (endDate.isEmpty || startDate == endDate) {
        return '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
      }
      
      final end = DateTime.parse(endDate);
      return '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')} ~ ${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return startDate;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'TBD';
    
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}
