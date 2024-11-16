import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:intl/intl.dart';

class BookmarkTabScreen extends StatefulWidget {
  const BookmarkTabScreen({super.key});

  @override
  _BookmarkTabScreenState createState() => _BookmarkTabScreenState();
}

class _BookmarkTabScreenState extends State<BookmarkTabScreen> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? _jwtToken;
  List<Map<String, dynamic>> favoriteRooms = [];
  final NumberFormat _numberFormat = NumberFormat('#,###');

  @override
  void initState() {
    super.initState();
    _loadJwtTokenAndData();
  }

  Future<void> _loadJwtTokenAndData() async {
    try {
      _jwtToken = await _secureStorage.read(key: 'jwtToken');
      if (_jwtToken != null) {
        print('JWT 토큰 로드 성공: $_jwtToken');
        await _fetchFavoriteRooms();
      } else {
        print('JWT Token 로드 실패');
      }
    } catch (e) {
      print('에러 발생: $e');
    }
  }

  Future<void> _fetchFavoriteRooms() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://api.dev.borangkkae.com/v1/rooms/favorites',
        options: Options(
          headers: {'Authorization': 'Bearer $_jwtToken'},
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['result']['rows'];
        setState(() {
          favoriteRooms =
              data.map((room) => room as Map<String, dynamic>).toList();
        });
      } else {
        print('서버 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('서버 통신 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "즐겨찾기 원룸 리스트",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (favoriteRooms.isEmpty) {
      return const Center(
        child: Text(
          '즐겨찾기로 등록된 원룸이 없습니다.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    } else {
      return ListView.builder(
        itemCount: favoriteRooms.length,
        itemBuilder: (context, index) {
          return _buildRoomCard(favoriteRooms[index]);
        },
      );
    }
  }

  Widget _buildRoomCard(Map<String, dynamic> room) {
    final int? roomId = room['_id'];
    final String roomUrl = 'https://borangkkae.com/detail/$roomId';
    final String deposit = room['deposit'] != null
        ? _numberFormat.format(room['deposit'])
        : '정보 없음';
    final String cost = room['cost'] != null
        ? _numberFormat.format(room['cost'])
        : '정보 없음';

    return GestureDetector(
      onTap: () {
        if (roomId != null) {
          print('Room ID: $roomId'); // 확인용 로그
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RoomDetailWebView(
                url: roomUrl,
                jwtToken: _jwtToken,
              ),
            ),
          );
        } else {
          print('Room ID가 없습니다.');
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                    image: room['files'] != null && room['files'].isNotEmpty
                        ? DecorationImage(
                      image: NetworkImage(room['files'][0]['url']),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room['name'] ?? '이름 없음',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              room['address'] ?? '주소 없음',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text(
                            '보증금: ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$deposit원',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text(
                            '월세: ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$cost원',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.star, color: Colors.orange),
                  onPressed: () {
                    _removeFavorite(roomId);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _removeFavorite(int? roomId) async {
    if (roomId == null) return;

    try {
      final dio = Dio();
      final response = await dio.delete(
        'https://api.dev.borangkkae.com/v1/rooms/$roomId/favorite',
        options: Options(
          headers: {'Authorization': 'Bearer $_jwtToken'},
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          favoriteRooms.removeWhere((room) => room['_id'] == roomId);
        });
      }
    } catch (e) {
      print('서버 통신 오류 발생: $e');
    }
  }
}

class RoomDetailWebView extends StatefulWidget {
  final String url;
  final String? jwtToken;

  const RoomDetailWebView({super.key, required this.url, this.jwtToken});

  @override
  _RoomDetailWebViewState createState() => _RoomDetailWebViewState();
}

class _RoomDetailWebViewState extends State<RoomDetailWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url), headers: {
        'Authorization': 'Bearer ${widget.jwtToken}',
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Detail'),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
