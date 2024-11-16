import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'find.dart';
import 'bookmark.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sundeokbang/screen/usersettings/user_setting_page.dart';
import 'package:sundeokbang/screen/home/tip.dart'; // Import TipPage
import 'management.dart';
import 'package:sundeokbang/screen/home/customer_service.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // 현재 선택된 탭의 인덱스
  String schoolName = '학교 이름 없음'; // 초기값 설정
  String? jwtToken; // JWT 토큰 저장 변수
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage(); // Secure storage
  List<Map<String, String>> roomTips = []; // roomTips 리스트 추가

  @override
  void initState() {
    super.initState();
    _loadJwtToken(); // JWT 토큰 로드 및 학교 이름 설정
  }

  Future<void> _loadJwtToken() async {
    jwtToken = await secureStorage.read(key: 'jwtToken');

    if (jwtToken != null) {
      // JWT 토큰에서 학교 이름 추출
      Map<String, dynamic> decodedToken = JwtDecoder.decode(jwtToken!);
      setState(() {
        schoolName = decodedToken['university'] ?? '학교 정보 없음'; // 토큰 내에 학교 정보가 없을 경우 기본값 설정
        roomTips = decodedToken['roomTips'] != null
            ? List<Map<String, String>>.from(decodedToken['roomTips'])
            : []; // roomTips 정보가 있으면 추출, 없으면 빈 리스트
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0 // 홈 탭에서만 앱바가 보이도록 설정
          ? PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: AppBar(
          backgroundColor: Colors.white, // 앱바 배경색 흰색으로 설정
          flexibleSpace: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 83,
                        height: 28,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        schoolName, // JWT에서 추출한 학교 이름 표시
                        style: const TextStyle(
                          color: Colors.deepOrange,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          height: 1.19,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      // user_setting_page.dart로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UserSettingPage()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[200],
                        backgroundImage:
                        const AssetImage('assets/images/account_image.png'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      )
          : null,
      body: HomeTab(
        jwtToken: jwtToken,
        roomTips: roomTips, // roomTips 전달
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '원룸 찾기',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: '즐겨찾기',
          ),
        ],
        currentIndex: _selectedIndex, // 현재 선택된 탭의 인덱스
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 1) {
            // 원룸 찾기 탭으로 이동
            if (jwtToken != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FindTabScreen(token: jwtToken!)),
              );
            }
          } else if (index == 2) {
            // 즐겨찾기 탭으로 이동
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BookmarkTabScreen()),
            );
          } else {
            setState(() {
              _selectedIndex = index; // 홈탭 선택
            });
          }
        },
      ),
    );
  }
}

// 홈탭 화면 구성 (기존의 홈 화면 구성 요소)
class HomeTab extends StatelessWidget {
  final String? jwtToken;
  final List<Map<String, String>> roomTips; // roomTips 매개변수 추가

  const HomeTab({super.key, this.jwtToken, required this.roomTips});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildImageButton(
                  context,
                  'assets/images/room_search.png',
                  '원룸 찾기',
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FindTabScreen(token: '')), // 임시 토큰
                    );
                  },
                ),
                _buildImageButton(
                  context,
                  'assets/images/bookmark.png',
                  '즐겨찾기',
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const BookmarkTabScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildAdBanner(),
          const SizedBox(height: 20),
          _buildRoomTips(context), // roomTips를 사용하는 위젯
          const SizedBox(height: 20),
          _buildShortcut(context: context, jwtToken: jwtToken),
        ],
      ),
    );
  }

  Widget _buildRoomTips(BuildContext context) {
    final tips = [
      {
        'image': 'assets/images/tip1.png',
        'title': '원룸 종류와 장단점, 자취생들을 위한 꿀팁!',
        'url': 'https://post.naver.com/viewer/postView.nhn?volumeNo=31577966&memberNo=41665055&vType=VERTICAL'
      },
      {
        'image': 'assets/images/tip2.PNG',
        'title': '원룸구하기 꿀팁 7가지',
        'url': 'https://blog.naver.com/eidnr148/223605863493'
      },
      {
        'image': 'assets/images/tip3.PNG',
        'title': '원룸꿀팁 알아봐요',
        'url': 'https://blog.naver.com/cleanworlds/223562761392'
      }
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '원룸 꿀팁',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TipPage(),
                    ),
                  );
                },
                child: const Text(
                  '더보기 >',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: tips.map((tip) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TipWebView(
                          url: tip['url']!,
                          title: tip['title']!,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 150,
                    margin: const EdgeInsets.only(right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            tip['image']!,
                            width: 150,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          // 제목 영역의 높이를 고정
                          height: 40,
                          child: Text(
                            tip['title']!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageButton(BuildContext context, String imagePath, String label,
      VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAdBanner() {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF091D3A), // 배경 색상 #091D3A
      ),
      child: Center(
        child: Text(
          'CODE 0.1',
          style: const TextStyle(
            color: Color(0xFF00C2FF), // 텍스트 색상 #00C2FF
            fontSize: 50,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildShortcut({required BuildContext context, String? jwtToken}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          const Padding(
            padding: EdgeInsets.only(left: 15),
            child: Text(
              '바로가기',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          _buildCustomTile(
            context,
            '고객센터',
            onTap: () {
              // 고객센터 클릭 시 CustomerServicePage로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CustomerServicePage(),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          _buildCustomTile(
            context,
            '사장님 바로가기',
            onTap: () {
              // 사장님 바로가기 클릭 시 ManagementPage로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManagementPage(token: ''),
                ),
              );
            },
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }


  Widget _buildCustomTile(BuildContext context, String title,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 11.0),
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
