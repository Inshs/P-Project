import 'package:flutter/material.dart';
import 'result_page.dart';

class CarInfoInputPage extends StatefulWidget {
  const CarInfoInputPage({super.key});

  @override
  State<CarInfoInputPage> createState() => _CarInfoInputPageState();
}

class _CarInfoInputPageState extends State<CarInfoInputPage> {
  // 상태 변수들
  String? _selectedBrand;
  String? _selectedModel;
  String? _selectedYear;
  String? _selectedRegion;
  final TextEditingController _mileageController = TextEditingController();
  String _selectedFuel = '가솔린';
  int _performanceRating = 4;
  bool _isAccidentFree = false;

  // 옵션 상태
  bool _hasSunroof = false;
  bool _hasNavigation = false;
  bool _hasLeatherSeats = false;
  bool _hasSmartKey = false;
  bool _hasRearCamera = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    final borderColor = isDark ? Colors.grey[700]! : Colors.grey[200]!;

    return Scaffold(
      // backgroundColor uses theme default
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "차량 정보 입력",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 1. 기본 정보 카드
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
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
                    // 브랜드 / 모델 선택 (Row)
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            hint: "브랜드 선택",
                            value: _selectedBrand,
                            items: ["현대", "기아", "BMW", "Mercedes"],
                            onChanged: (val) =>
                                setState(() => _selectedBrand = val),
                            isDark: isDark,
                            textColor: textColor,
                            borderColor: borderColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDropdown(
                            hint: "모델 선택",
                            value: _selectedModel,
                            items: ["아반떼", "쏘나타", "그랜저", "X5", "E-Class"],
                            onChanged: (val) =>
                                setState(() => _selectedModel = val),
                            isDark: isDark,
                            textColor: textColor,
                            borderColor: borderColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 연식 선택
                    _buildDropdown(
                      hint: "2024년",
                      value: _selectedYear,
                      items: List.generate(10, (index) => "${2024 - index}년"),
                      onChanged: (val) => setState(() => _selectedYear = val),
                      isDark: isDark,
                      textColor: textColor,
                      borderColor: borderColor,
                    ),
                    const SizedBox(height: 16),

                    // 주행거리 입력
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _mileageController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: textColor),
                              decoration: const InputDecoration(
                                hintText: "35000",
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                          const Text("km",
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 연료 타입
                    const Text("연료",
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChoiceChip("가솔린", isDark),
                        _buildChoiceChip("디젤", isDark),
                        _buildChoiceChip("LPG", isDark),
                        _buildChoiceChip("전기/하이브리드", isDark),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. 상세 옵션 카드
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "상세 옵션 (선택)",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_up, color: Colors.grey[600]),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 성능 점검 (별점)
                    const Text("성능 점검",
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _performanceRating = index + 1),
                          child: Icon(
                            Icons.star_rounded,
                            color: index < _performanceRating
                                ? const Color(0xFFFFC107)
                                : (isDark
                                    ? Colors.grey[700]
                                    : Colors.grey[200]),
                            size: 32,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),

                    // 무사고 여부
                    _buildCheckboxRow("무사고 여부", _isAccidentFree, (val) {
                      setState(() => _isAccidentFree = val ?? false);
                    }, textColor, borderColor),
                    const SizedBox(height: 16),

                    // 옵션 그리드
                    const Text("옵션",
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              _buildCheckboxRow(
                                  "선루프",
                                  _hasSunroof,
                                  (v) => setState(() => _hasSunroof = v!),
                                  textColor,
                                  borderColor),
                              _buildCheckboxRow(
                                  "가죽시트",
                                  _hasLeatherSeats,
                                  (v) => setState(() => _hasLeatherSeats = v!),
                                  textColor,
                                  borderColor),
                              _buildCheckboxRow(
                                  "후방카메라",
                                  _hasRearCamera,
                                  (v) => setState(() => _hasRearCamera = v!),
                                  textColor,
                                  borderColor),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              _buildCheckboxRow(
                                  "내비게이션",
                                  _hasNavigation,
                                  (v) => setState(() => _hasNavigation = v!),
                                  textColor,
                                  borderColor),
                              _buildCheckboxRow(
                                  "스마트키",
                                  _hasSmartKey,
                                  (v) => setState(() => _hasSmartKey = v!),
                                  textColor,
                                  borderColor),
                              const SizedBox(height: 40), // Grid 높이 맞추기용
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 지역 선택
                    const Text("지역",
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      hint: "서울/경기",
                      value: _selectedRegion,
                      items: ["서울/경기", "강원", "충청", "전라", "경상", "제주"],
                      onChanged: (val) => setState(() => _selectedRegion = val),
                      isDark: isDark,
                      textColor: textColor,
                      borderColor: borderColor,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 검색하기 버튼
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ResultPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "검색하기",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 초기화 버튼
              Center(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedBrand = null;
                      _selectedModel = null;
                      _selectedYear = null;
                      _mileageController.clear();
                      _selectedFuel = '가솔린';
                      _performanceRating = 0;
                      _isAccidentFree = false;
                      _hasSunroof = false;
                      _hasNavigation = false;
                      _hasLeatherSeats = false;
                      _hasSmartKey = false;
                      _hasRearCamera = false;
                      _selectedRegion = null;
                    });
                  },
                  child: Text(
                    "초기화",
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required bool isDark,
    required Color textColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint,
              style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
          dropdownColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
          style: TextStyle(color: textColor),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildChoiceChip(String label, bool isDark) {
    bool isSelected = _selectedFuel == label;
    // 다크모드일 때 선택되지 않은 칩의 배경색 조정
    Color unselectedColor =
        isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEAF2FF);

    return GestureDetector(
      onTap: () => setState(() => _selectedFuel = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0066FF) : unselectedColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF0066FF),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxRow(String label, bool value, Function(bool?) onChanged,
      Color textColor, Color borderColor) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            activeColor: const Color(0xFF0066FF),
            side: BorderSide(color: Colors.grey[400]!),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 14, color: textColor)),
      ],
    );
  }
}
