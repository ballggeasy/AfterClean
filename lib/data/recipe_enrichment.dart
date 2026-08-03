import '../models/recipe.dart';
import '../models/nutrition.dart';
import '../models/ingredient.dart';

/// ข้อมูลเสริมสำหรับสูตร mock — ใส่ metadata ที่ไม่ได้อยู่ใน recipe_data.dart
class RecipeEnrichment {
  static Recipe enrich(Recipe recipe) {
    final meta = _metadata[recipe.id];
    if (meta == null) return recipe;

    return recipe.copyWith(
      prepTimeMinutes: meta['prepTime'] as int? ?? recipe.prepTimeMinutes,
      servings: meta['servings'] as int? ?? recipe.servings,
      tips: meta['tips'] as String?,
      platingTips: meta['plating'] as String?,
      nutrition: meta['nutrition'] as NutritionInfo?,
      dietTags: meta['dietTags'] as List<String>? ?? recipe.dietTags,
      season: meta['season'] as String? ?? recipe.season,
      createdAt: meta['createdAt'] as DateTime? ?? recipe.createdAt,
      viewCount: meta['viewCount'] as int? ?? recipe.viewCount,
      isRecommended: meta['isRecommended'] as bool? ?? recipe.isRecommended,
      ingredientItems: meta['items'] as List<IngredientItem>? ?? recipe.ingredientItems,
      videoUrl: meta['videoUrl'] as String?,
    );
  }

  static final Map<String, Map<String, dynamic>> _metadata = {
    '1': {
      'prepTime': 5,
      'servings': 2,
      'tips': 'ใช้ไฟแรง ผัดให้เร็ว กระเพราจะไม่เลือง',
      'plating': 'ราดบนข้าวสวย วางไข่ดาวด้านบน โรยพริกแห้ง',
      'nutrition': NutritionInfo(calories: 420, protein: 28, fat: 22, carbs: 35, sugar: 2, sodium: 890),
      'dietTags': ['ฮาลาล'],
      'season': 'ตลอดปี',
      'createdAt': DateTime(2025, 7, 20),
      'viewCount': 1250,
      'isRecommended': true,
      'videoUrl': 'placeholder://video/pad-krapao',
      'items': [
        IngredientItem(name: 'หมูสับ', amount: '250', unit: 'กรัม'),
        IngredientItem(name: 'กระเพราใบ', amount: '1', unit: 'กำมือ'),
        IngredientItem(name: 'กระเทียม', amount: '5', unit: 'กลีบ'),
        IngredientItem(name: 'พริกขี้หนู', amount: '5-10', unit: 'เม็ด'),
      ],
    },
    '2': {
      'prepTime': 10,
      'servings': 3,
      'tips': 'อย่าต้มกุ้งนานเกินไป จะเหนียว',
      'plating': 'เสิร์ฟในเข่งหรือหม้อ โรยผักชี',
      'nutrition': NutritionInfo(calories: 180, protein: 22, fat: 4, carbs: 8, sugar: 3, sodium: 1200),
      'dietTags': ['สุขภาพ', 'ลดน้ำหนัก'],
      'season': 'ฤดูฝน',
      'createdAt': DateTime(2025, 7, 15),
      'viewCount': 980,
      'isRecommended': true,
    },
    '3': {
      'prepTime': 15,
      'servings': 2,
      'tips': 'โขลกเบา ๆ อย่าให้มะละกอเละ',
      'nutrition': NutritionInfo(calories: 120, protein: 3, fat: 2, carbs: 18, sugar: 10, sodium: 650),
      'dietTags': ['วีแกน', 'คลีน', 'ลดน้ำหนัก'],
      'season': 'ฤดูร้อน',
      'viewCount': 2100,
      'isRecommended': true,
    },
    '4': {
      'prepTime': 5,
      'servings': 2,
      'tips': 'ปิดไฟก่อนใส่ไข่ ไม่งั้นจะเป็นไข่เจียว',
      'nutrition': NutritionInfo(calories: 550, protein: 22, fat: 28, carbs: 52, sugar: 2, sodium: 780),
      'dietTags': ['มังสวิรัติ'],
      'viewCount': 760,
    },
    '7': {
      'prepTime': 20,
      'servings': 2,
      'tips': 'ต้มน้ำซุปนาน ๆ จะได้รสเข้มข้น',
      'nutrition': NutritionInfo(calories: 480, protein: 25, fat: 15, carbs: 60, sugar: 4, sodium: 1500),
      'viewCount': 890,
      'isRecommended': true,
    },
    '10': {
      'prepTime': 5,
      'servings': 2,
      'nutrition': NutritionInfo(calories: 380, protein: 12, fat: 14, carbs: 48, sugar: 1, sodium: 920),
      'dietTags': ['เด็ก'],
      'viewCount': 540,
    },
    '13': {
      'prepTime': 20,
      'servings': 2,
      'nutrition': NutritionInfo(calories: 520, protein: 30, fat: 18, carbs: 55, sugar: 8, sodium: 1100),
      'dietTags': ['สุขภาพ', 'คลีน'],
      'viewCount': 670,
      'isRecommended': true,
    },
    '14': {
      'prepTime': 5,
      'servings': 2,
      'dietTags': ['เด็ก', 'มังสวิรัติ'],
      'viewCount': 1800,
    },
  };
}
