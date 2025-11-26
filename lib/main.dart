import 'package:flutter/material.dart';
import 'car_info_input_page.dart';
import 'mypage.dart';
import 'settings_page.dart';

void main() {
  runApp(const CarPriceApp());
}

class CarPriceApp extends StatefulWidget {
  const CarPriceApp({super.key});

  @override
  State<CarPriceApp> createState() => _CarPriceAppState();
}

class _CarPriceAppState extends State<CarPriceApp> {
  // 테마 모드 상태 관리 (기본값: 라이트 모드)
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '중고차 시세 예측',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      // 라이트 테마 정의
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF0066FF),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        fontFamily: 'Pretendard',
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5F7FA),
          foregroundColor: Colors.black,
        ),
      ),
      // 다크 테마 정의
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF0066FF),
        scaffoldBackgroundColor: const Color(0xFF121212),
        fontFamily: 'Pretendard',
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          foregroundColor: Colors.white,
        ),
      ),
      home: MainScreen(
        isDarkMode: _themeMode == ThemeMode.dark,
        onThemeChanged: _toggleTheme,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const MainScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // 페이지 리스트 초기화 시 콜백 전달
    _pages = [
      const HomePageContent(),
      const CarInfoInputPage(),
      const MyPage(),
      SettingsPage(
        isDarkMode: widget.isDarkMode,
        onThemeChanged: widget.onThemeChanged,
      ),
    ];
  }

  @override
  void didUpdateWidget(MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 테마 변경 시 SettingsPage 업데이트
    if (oldWidget.isDarkMode != widget.isDarkMode) {
      _pages[3] = SettingsPage(
        isDarkMode: widget.isDarkMode,
        onThemeChanged: widget.onThemeChanged,
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final navBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final unselectedItemColor = isDark ? Colors.grey[600] : Colors.grey[400];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: navBgColor,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF0066FF),
          unselectedItemColor: unselectedItemColor,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          onTap: _onItemTapped,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              activeIcon: Icon(Icons.search),
              label: '내 차 찾기',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: '마이페이지',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: '설정',
            ),
          ],
        ),
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // 1. 메인 로그인 카드 영역
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "중고차 시세 예측 AI",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 아이디 입력
                    _buildTextField(hintText: "아이디", isDark: isDark),
                    const SizedBox(height: 12),
                    // 비밀번호 입력
                    _buildTextField(
                        hintText: "비밀번호", obscureText: true, isDark: isDark),
                    const SizedBox(height: 20),

                    // 로그인 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0066FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "로그인",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 소셜 로그인 버튼들
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(
                            "N", const Color(0xFF03C75A), Colors.white),
                        const SizedBox(width: 16),
                        _buildSocialButton("K", const Color(0xFFFEE500),
                            const Color(0xFF3C1E1E)),
                        const SizedBox(width: 16),
                        _buildSocialButton("G", Colors.white, Colors.grey,
                            isBorder: true),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 회원가입 | 아이디 찾기
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTextBtn("회원가입"),
                        Container(
                          height: 12,
                          width: 1,
                          color: Colors.grey[300],
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        _buildTextBtn("아이디찾기"),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 또는 (Divider)
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey[200])),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text("또는",
                              style: TextStyle(
                                  color: Colors.grey[400], fontSize: 12)),
                        ),
                        Expanded(child: Divider(color: Colors.grey[200])),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 로그인 없이 조회 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CarInfoInputPage()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF0066FF)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search,
                                color: Color(0xFF0066FF), size: 20),
                            SizedBox(width: 8),
                            Text(
                              "로그인 없이 시세 조회하기",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0066FF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 2. 최근 조회 차량 섹션
            _buildSectionTitle("최근 조회 차량", textColor),
            const SizedBox(height: 12),
            _buildHorizontalCarList(isReversed: false, isDark: isDark),

            const SizedBox(height: 32),

            // 3. 인기 모델 추천 섹션
            _buildSectionTitle("인기 모델 추천", textColor),
            const SizedBox(height: 12),
            _buildHorizontalCarList(isReversed: true, isDark: isDark),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Helper Widget: 텍스트 필드
  Widget _buildTextField(
      {required String hintText,
      bool obscureText = false,
      required bool isDark}) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
      ),
      child: TextField(
        obscureText: obscureText,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  // Helper Widget: 소셜 로그인 버튼
  Widget _buildSocialButton(String text, Color bgColor, Color textColor,
      {bool isBorder = false}) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
        border: isBorder ? Border.all(color: Colors.grey[300]!) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  // Helper Widget: 텍스트 버튼 (회원가입 등)
  Widget _buildTextBtn(String text) {
    return GestureDetector(
      onTap: () {},
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey[500],
          fontSize: 12,
        ),
      ),
    );
  }

  // Helper Widget: 섹션 타이틀
  Widget _buildSectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const Icon(Icons.arrow_forward, size: 20, color: Colors.grey),
        ],
      ),
    );
  }

  // Helper Widget: 가로 스크롤 차량 리스트
  Widget _buildHorizontalCarList(
      {required bool isReversed, required bool isDark}) {
    // 더미 데이터
    final List<Map<String, dynamic>> cars = [
      {
        "name": "노란색 벤츠",
        "info": "2023년 / 0.8만KM",
        "price": "1억",
        "color": Colors.yellow
      },
      {
        "name": "파란색 차",
        "info": "2024년 / 1만KM",
        "price": "8000만원",
        "color": Colors.blue
      },
      {
        "name": "흰색 SUV",
        "info": "2025년 / 0.9만KM",
        "price": "9000만원",
        "color": Colors.grey[300]
      },
      {
        "name": "검정 세단",
        "info": "2022년 / 3만KM",
        "price": "5500만원",
        "color": Colors.black87
      },
    ];

    final displayList = isReversed ? cars.reversed.toList() : cars;

    return SizedBox(
      height: 190, // 카드 높이 + 그림자 여유분
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: displayList.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final car = displayList[index];
          return CarCard(
            name: car['name'],
            info: car['info'],
            price: car['price'],
            color: car['color'],
            isDark: isDark,
          );
        },
      ),
    );
  }
}

// 분리된 차량 카드 위젯
class CarCard extends StatelessWidget {
  final String name;
  final String info;
  final String price;
  final Color color;
  final bool isDark;

  const CarCard({
    super.key,
    required this.name,
    required this.info,
    required this.price,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[50]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 차량 이미지 영역 (플레이스홀더)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  Icons.directions_car_filled,
                  color: Colors.white.withOpacity(0.5),
                  size: 48,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 차량 정보 텍스트
          Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            info,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            price,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0066FF),
            ),
          ),
        ],
      ),
    );
  }
}
