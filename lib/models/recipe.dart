class Recipe {
  final String id;
  final String name;
  final String emoji; // ใช้เป็น fallback ถ้าโหลดรูปจริงไม่ได้
  final String imageUrl; // URL รูปภาพจริงของเมนู
  final String category;
  final int cookTimeMinutes;
  final String difficulty; // ง่าย / ปานกลาง / ยาก
  final List<String> ingredients;
  final List<String> steps;

  /// ประเทศ/ชาติของอาหาร เช่น ไทย, อิตาลี, ญี่ปุ่น
  final String country;

  /// true = สูตรทางการจากทีม, false = ผู้ใช้อัปโหลดเอง
  final bool isOfficial;

  /// ชื่อผู้อัปโหลด (ใช้แสดงเมื่อ isOfficial เป็น false)
  final String? uploaderName;

  /// คะแนนเฉลี่ย 1.0 - 5.0
  final double rating;

  /// จำนวนรีวิวทั้งหมด
  final int reviewCount;

  const Recipe({
    required this.id,
    required this.name,
    required this.emoji,
    required this.imageUrl,
    required this.category,
    required this.cookTimeMinutes,
    required this.difficulty,
    required this.ingredients,
    required this.steps,
    required this.country,
    this.isOfficial = true,
    this.uploaderName,
    this.rating = 0.0,
    this.reviewCount = 0,
  });

  /// ข้อความแสดงเครดิตแหล่งที่มา เช่น "ทางการ" หรือ "โดย คุณส้ม"
  String get sourceLabel => isOfficial ? 'สูตรทางการ' : 'โดย ${uploaderName ?? 'ผู้ใช้'}';

  /// ใช้ตรวจสอบว่าสูตรนี้มีวัตถุดิบที่ตรงกับคำค้นหาหรือไม่
  bool matchesIngredientQuery(String query) {
    if (query.trim().isEmpty) return true;
    final lowerQuery = query.toLowerCase().trim();
    return ingredients.any(
      (ingredient) => ingredient.toLowerCase().contains(lowerQuery),
    );
  }

  /// ใช้ตรวจสอบว่าชื่อสูตรตรงกับคำค้นหาหรือไม่ (ใช้ร่วมกับค้นหาวัตถุดิบ)
  bool matchesNameQuery(String query) {
    if (query.trim().isEmpty) return true;
    return name.toLowerCase().contains(query.toLowerCase().trim());
  }

  bool matchesQuery(String query) {
    if (query.trim().isEmpty) return true;
    return matchesNameQuery(query) || matchesIngredientQuery(query);
  }
}
