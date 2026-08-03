import '../models/review.dart';
import '../models/comment.dart';

/// ข้อมูล mock สำหรับรีวิว
class MockReviews {
  static final List<Review> reviews = [
    Review(
      id: 'r1',
      recipeId: '1',
      userName: 'คุณมิ้นท์',
      rating: 5,
      content: 'อร่อยมาก ทำตามสูตรแล้วได้รสชาติเหมือนร้านเลย!',
      createdAt: DateTime(2025, 7, 10),
      likeCount: 12,
      imageUrls: const [],
      replies: [
        ReviewReply(
          id: 'rr1',
          userName: 'แอดมิน',
          content: 'ขอบคุณที่รีวิวค่ะ 🙏',
          createdAt: DateTime(2025, 7, 11),
        ),
      ],
    ),
    Review(
      id: 'r2',
      recipeId: '1',
      userName: 'เชฟน้อย',
      rating: 4,
      content: 'รสชาติดี แต่แนะนำเพิ่มพริกอีกนิดจะแซ่บกว่านี้',
      createdAt: DateTime(2025, 7, 5),
      likeCount: 5,
    ),
    Review(
      id: 'r3',
      recipeId: '2',
      userName: 'คุณแป้ง',
      rating: 5,
      content: 'ต้มยำกุ้งสูตรนี้เด็ดสุด ๆ กลมกล่อมทุกรส',
      createdAt: DateTime(2025, 6, 20),
      likeCount: 28,
    ),
    Review(
      id: 'r4',
      recipeId: '4',
      userName: 'FoodLover',
      rating: 4.5,
      content: 'คาโบนาร่าเนื้อครีมมม ทำง่ายมาก',
      createdAt: DateTime(2025, 7, 1),
      likeCount: 8,
    ),
  ];
}

/// ข้อมูล mock สำหรับคอมเมนต์
class MockComments {
  static final List<Comment> comments = [
    Comment(
      id: 'c1',
      recipeId: '1',
      userName: 'คุณบี',
      content: 'ใช้กระเพราแดงได้ไหมคะ? 🌿',
      createdAt: DateTime(2025, 7, 8),
      replies: [
        Comment(
          id: 'c1r1',
          recipeId: '1',
          userName: 'แอดมิน',
          content: '@คุณบี ได้เลยค่ะ รสชาติจะต่างกันเล็กน้อย',
          createdAt: DateTime(2025, 7, 8, 14, 30),
          mentions: const ['คุณบี'],
        ),
      ],
    ),
    Comment(
      id: 'c2',
      recipeId: '1',
      userName: 'คุณต้น',
      content: 'อร่อยมากครับ 👍 ทำให้แฟนชอบเลย',
      createdAt: DateTime(2025, 7, 3),
    ),
    Comment(
      id: 'c3',
      recipeId: '2',
      userName: 'คุณหนึ่ง',
      content: 'ถ้าไม่มีกุ้งสด ใช้กุ้งแช่แข็งได้ไหม?',
      createdAt: DateTime(2025, 6, 15),
      replies: [
        Comment(
          id: 'c3r1',
          recipeId: '2',
          userName: 'เชฟโบ',
          content: '@คุณหนึ่ง ได้ครับ แต่ลดเวลาต้มลงนิดหน่อย',
          createdAt: DateTime(2025, 6, 16),
          mentions: const ['คุณหนึ่ง'],
        ),
      ],
    ),
  ];
}
