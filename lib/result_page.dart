import 'package:flutter/material.dart';
import 'negotiation_page.dart';
// import 'package:fl_chart/fl_chart.dart'; // Removed due to build issues

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    final borderColor = isDark ? Colors.grey[800]! : Colors.grey[100]!;

    return Scaffold(
      // backgroundColor uses theme default
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "중고차 시세 예측 결과",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. 상단 고정 영역 (예상 시세)
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "예상 시세",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "3,200만원",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0066FF),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Divider(color: borderColor),
                      const SizedBox(height: 16),
                      const Text(
                        "합리적 범위",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "2,880 ~ 3,520만원",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. 탭 바
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF0066FF),
              unselectedLabelColor: Colors.grey[400],
              indicatorColor: const Color(0xFF0066FF),
              indicatorWeight: 3,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              tabs: const [
                Tab(text: "가격 분석"),
                Tab(text: "구매 타이밍"),
                Tab(text: "AI 조언"),
              ],
            ),
          ),

          // 3. 탭 뷰
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPriceAnalysisTab(isDark, cardColor, textColor),
                _buildBuyingTimingTab(isDark, cardColor, textColor),
                _buildAIAdviceTab(isDark, cardColor, textColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tab 1: 가격 분석
  Widget _buildPriceAnalysisTab(bool isDark, Color cardColor, Color textColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 신뢰도 카드
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text("신뢰도", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),
                SizedBox(
                  height: 150,
                  width: 150,
                  child: Stack(
                    children: [
                      // Placeholder for PieChart
                      CircularProgressIndicator(
                        value: 0.87,
                        strokeWidth: 15,
                        backgroundColor:
                            isDark ? Colors.grey[800] : Colors.grey[200],
                        color: const Color(0xFF0066FF),
                      ),
                      const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "87%",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0066FF),
                              ),
                            ),
                            Text(
                              "높은 신뢰도",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 비슷한 차량 가격 분포
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "비슷한 차량 가격 분포",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor),
                ),
                const Text(
                  "최근 3개월 거래 데이터 기준",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 200,
                  child: Center(
                    child: Text(
                      "가격 분포 그래프 (준비중)",
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tab 2: 구매 타이밍
  Widget _buildBuyingTimingTab(bool isDark, Color cardColor, Color textColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 구매 적기 카드
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00C853),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00C853).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child:
                      const Icon(Icons.circle, color: Colors.white, size: 24),
                ),
                const SizedBox(height: 20),
                const Text(
                  "지금이 구매 적기!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00C853),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "구매하기 좋은 타이밍입니다",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 타이밍 지표
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "타이밍 지표",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCircularIndicator(
                        78, "거시경제", const Color(0xFF00C853), isDark, textColor),
                    _buildCircularIndicator(
                        73, "트렌드", const Color(0xFFFFAB00), isDark, textColor),
                    _buildCircularIndicator(76, "신차 일정",
                        const Color(0xFF00C853), isDark, textColor),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 상세 분석
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "상세 분석",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor),
                ),
                const SizedBox(height: 16),
                _buildCheckItem("저금리 시기로 구매 부담 감소", textColor),
                _buildCheckItem("검색량 안정세 유지", textColor),
                _buildCheckItem("신차 출시 예정 없음", textColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularIndicator(
      int score, String label, Color color, bool isDark, Color textColor) {
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            children: [
              // Placeholder for PieChart
              CircularProgressIndicator(
                value: score / 100,
                strokeWidth: 8,
                backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
                color: color,
              ),
              Center(
                child: Text(
                  score.toString(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
        const Text("/ 100", style: TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }

  Widget _buildCheckItem(String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.check, color: Color(0xFF00C853), size: 20),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: 14, color: textColor)),
        ],
      ),
    );
  }

  // Tab 3: AI 조언
  Widget _buildAIAdviceTab(bool isDark, Color cardColor, Color textColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // AI 조언 카드
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0066FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.smart_toy,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "AI 조언",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: textColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "이 차량은 시세 대비 적정합니다. 현재 시장에서 동일한 연식과 주행거리를 가진 차량들과 비교했을 때 합리적인 가격대를 형성하고 있습니다.\n\n다만, 구매 전 반드시 차량 상태를 직접 확인하고, 정비 이력과 사고 이력을 꼼꼼히 확인하시기 바랍니다.",
                        style: TextStyle(
                            color: textColor, height: 1.5, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 허위매물 위험도
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "허위매물 위험도",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00C853),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          "낮음",
                          style: TextStyle(
                            color: Color(0xFF00C853),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: 0.35,
                    backgroundColor:
                        isDark ? Colors.grey[800] : Colors.grey[100],
                    color: const Color(0xFF00C853),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("위험도 점수",
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text("35 / 100",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  "가격, 사진, 상세 정보가 일치하며 신뢰할 수 있는 매물입니다. 판매자와 직접 통화하여 추가 확인을 권장합니다.",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 버튼들
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const NegotiationPage(initialTabIndex: 0),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text("문자 복사"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const NegotiationPage(initialTabIndex: 1),
                      ),
                    );
                  },
                  icon: const Icon(Icons.phone, size: 18),
                  label: const Text("전화 대본 보기"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0066FF),
                    side: const BorderSide(color: Color(0xFF0066FF)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 구매 전 확인사항
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF3E2723) : const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: isDark
                      ? const Color(0xFF4E342E)
                      : const Color(0xFFFFECB3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: Color(0xFFFFAB00), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "구매 전 확인사항",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: textColor),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildWarningItem("실물 차량 상태 점검", textColor),
                _buildWarningItem("사고 이력 및 정비 기록 확인", textColor),
                _buildWarningItem("판매자 신원 및 소유권 확인", textColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningItem(String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 28),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Color(0xFFFFAB00),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: 13, color: textColor)),
        ],
      ),
    );
  }
}
