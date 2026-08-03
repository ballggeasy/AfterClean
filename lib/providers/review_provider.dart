import 'package:flutter/foundation.dart';

import '../models/review.dart';
import '../data/mock_social_data.dart';

/// จัดการรีวิว: ให้คะแนน, รีวิว, ถูกใจ, รายงาน, ตอบกลับ
class ReviewProvider extends ChangeNotifier {
  final List<Review> _reviews = [...MockReviews.reviews];

  List<Review> getReviewsForRecipe(String recipeId) =>
      _reviews.where((r) => r.recipeId == recipeId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  double getAverageRating(String recipeId) {
    final list = getReviewsForRecipe(recipeId);
    if (list.isEmpty) return 0;
    return list.map((r) => r.rating).reduce((a, b) => a + b) / list.length;
  }

  void addReview({
    required String recipeId,
    required String userName,
    required double rating,
    required String content,
    List<String> imageUrls = const [],
  }) {
    _reviews.insert(
      0,
      Review(
        id: 'r${_reviews.length + 1}',
        recipeId: recipeId,
        userName: userName,
        rating: rating,
        content: content,
        createdAt: DateTime.now(),
        imageUrls: imageUrls,
      ),
    );
    notifyListeners();
  }

  void toggleLike(String reviewId) {
    final index = _reviews.indexWhere((r) => r.id == reviewId);
    if (index == -1) return;
    final review = _reviews[index];
    _reviews[index] = review.copyWith(
      isLiked: !review.isLiked,
      likeCount: review.isLiked ? review.likeCount - 1 : review.likeCount + 1,
    );
    notifyListeners();
  }

  void reportReview(String reviewId) {
    final index = _reviews.indexWhere((r) => r.id == reviewId);
    if (index == -1) return;
    _reviews[index] = _reviews[index].copyWith(isReported: true);
    notifyListeners();
  }

  void addReply(String reviewId, String userName, String content) {
    final index = _reviews.indexWhere((r) => r.id == reviewId);
    if (index == -1) return;
    final review = _reviews[index];
    _reviews[index] = review.copyWith(
      replies: [
        ...review.replies,
        ReviewReply(
          id: 'rr${review.replies.length + 1}',
          userName: userName,
          content: content,
          createdAt: DateTime.now(),
        ),
      ],
    );
    notifyListeners();
  }
}
