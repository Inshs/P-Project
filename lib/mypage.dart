import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/car_data.dart';
import 'car_detail_page.dart';
import 'comparison_page.dart';
import 'providers/comparison_provider.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 더미 데이터 상태 관리
  final List<CarData> _allCars = [
    CarData(
      id: '1',
      name: "그랜저 3.3 GDI",
      price: "3,200만원",
      info: "32,000km · 2022년",
      date: "11.25 조회",
      color: Colors.grey[300]!,
      isLiked: true, // 이미 찜한 상태 예시
    ),
    CarData(
      id: '2',
      name: "제네시스 G80 2.5T",
      price: "4,500만원",
      info: "18,500km · 2023년",
      date: "11.23 조회",
      color: Colors.black87,
      isLiked: true,
    ),
    CarData(
      id: '3',
      name: "K5 2.0 터보",
      price: "2,800만원",
      info: "45,200km · 2021년",
      date: "11.20 조회",
      color: Colors.grey[400]!,
      isLiked: true,
    ),
    CarData(
      id: '4',
      name: "쏘나타",
      price: "2,500만원",
      info: "50,000km · 2020년",
      date: "11.18 조회",
      color: Colors.blue[100]!,
      isLiked: false,
    ),
    CarData(
      id: '5',
      name: "아반떼",
      price: "1,800만원",
      info: "15,000km · 2023년",
      date: "11.15 조회",
      color: Colors.green[100]!,
      isLiked: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleLike(CarData car) {
    setState(() {
      car.isLiked = !car.isLiked;
    });

    // 찜 해제 시 스낵바 표시 (옵션)
    if (!car.isLiked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("'${car.name}' 찜 목록에서 삭제되었습니다."),
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("'${car.name}' 찜 목록에 추가되었습니다."),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _toggleNotification(CarData car) {
    setState(() {
      car.isNotificationOn = !car.isNotificationOn;
    });

    String msg = car.isNotificationOn
        ? "'${car.name}' 목표 가격 알림이 설정되었습니다."
        : "'${car.name}' 알림이 해제되었습니다.";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      // backgroundColor uses theme default
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () {
            // 메인 탭 구조상 뒤로가기 동작 정의 필요 시 구현
          },
        ),
        title: Text(
          "마이 페이지",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF0066FF),
            unselectedLabelColor: Colors.grey[400],
            indicatorColor: const Color(0xFF0066FF),
            indicatorWeight: 3,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: const [
              Tab(text: "찜한 차량"),
              Tab(text: "최근 분석"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLikedCarsTab(isDark, cardColor, textColor),
                _buildRecentAnalysisTab(isDark, cardColor, textColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 1. 찜한 차량 탭 (isLiked == true 인 항목만 표시)
  Widget _buildLikedCarsTab(bool isDark, Color cardColor, Color textColor) {
    final likedCars = _allCars.where((car) => car.isLiked).toList();

    if (likedCars.isEmpty) {
      return const Center(
        child: Text("찜한 차량이 없습니다.", style: TextStyle(color: Colors.grey)),
      );
    }

    return Column(
      children: [
        // 상단 액션 버튼 영역 (비교하기)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  final provider = context.read<ComparisonProvider>();
                  // 이미 비교함에 차량이 있으면 바로 이동
                  if (provider.comparingCars.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ComparisonPage(),
                      ),
                    );
                  } else {
                    // 없으면 찜한 차량 중 상위 2개 추가 후 이동
                    if (likedCars.length >= 2) {
                      provider.clear();
                      provider.addCar(likedCars[0]);
                      provider.addCar(likedCars[1]);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ComparisonPage(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("비교할 차량이 2대 이상 필요합니다.")),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.compare_arrows, size: 18),
                label: const Text("비교하기"),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF0066FF),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: likedCars.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildCarCard(
                  likedCars[index], isDark, cardColor, textColor,
                  isLikedTab: true);
            },
          ),
        ),
      ],
    );
  }

  // 2. 최근 분석 탭 (모든 항목 표시)
  Widget _buildRecentAnalysisTab(
      bool isDark, Color cardColor, Color textColor) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _allCars.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildAnalysisCard(
            _allCars[index], isDark, cardColor, textColor);
      },
    );
  }

  // 찜한 차량 카드 위젯
  Widget _buildCarCard(
      CarData car, bool isDark, Color cardColor, Color textColor,
      {bool isLikedTab = false}) {
    final borderColor = isDark ? Colors.grey[800]! : Colors.grey[100]!;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CarDetailPage(car: car),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 차량 이미지 Placeholder
            Container(
              width: 100,
              height: 80,
              decoration: BoxDecoration(
                color: car.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.directions_car,
                  color: Colors.white, size: 40),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car.name,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: textColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    car.price,
                    style: const TextStyle(
                      color: Color(0xFF0066FF),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    car.info,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                // 알림 버튼
                GestureDetector(
                  onTap: () => _toggleNotification(car),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: car.isNotificationOn
                          ? (isDark
                              ? const Color(0xFF3E2723)
                              : const Color(0xFFFFF8E1))
                          : (isDark ? Colors.grey[800] : Colors.grey[100]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      car.isNotificationOn
                          ? Icons.notifications_active
                          : Icons.notifications_none,
                      color: car.isNotificationOn
                          ? const Color(0xFFFFAB00)
                          : Colors.grey[400],
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // 좋아요 버튼
                GestureDetector(
                  onTap: () => _toggleLike(car),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: car.isLiked
                          ? (isDark
                              ? const Color(0xFF3E2020)
                              : const Color(0xFFFFEBEE))
                          : (isDark ? Colors.grey[800] : Colors.grey[100]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      car.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: car.isLiked
                          ? const Color(0xFFFF5252)
                          : Colors.grey[400],
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 최근 분석 카드 위젯
  Widget _buildAnalysisCard(
      CarData car, bool isDark, Color cardColor, Color textColor) {
    final borderColor = isDark ? Colors.grey[800]! : Colors.grey[100]!;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CarDetailPage(car: car),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 차량 이미지 Placeholder
            Container(
              width: 80,
              height: 60,
              decoration: BoxDecoration(
                color: car.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.directions_car,
                  color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car.name,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: textColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "예상가 ${car.price}",
                    style: const TextStyle(
                      color: Color(0xFF0066FF),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    car.date,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                // 알림 버튼
                IconButton(
                  onPressed: () => _toggleNotification(car),
                  icon: Icon(
                    car.isNotificationOn
                        ? Icons.notifications_active
                        : Icons.notifications_none,
                    color: car.isNotificationOn
                        ? const Color(0xFFFFAB00)
                        : Colors.grey[400],
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(height: 12),
                // 좋아요 버튼
                IconButton(
                  onPressed: () => _toggleLike(car),
                  icon: Icon(
                    car.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: car.isLiked
                        ? const Color(0xFFFF5252)
                        : Colors.grey[400],
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
