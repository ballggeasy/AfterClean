/// รีวิวสูตรอาหาร
class Review {
  final String id;
  final String recipeId;
  final String userName;
  final double rating;
  final String content;
  final DateTime createdAt;
  final List<String> imageUrls;
  final int likeCount;
  final bool isLiked;
  final List<ReviewReply> replies;
  final bool isReported;

  const Review({
    required this.id,
    required this.recipeId,
    required this.userName,
    required this.rating,
    required this.content,
    required this.createdAt,
    this.imageUrls = const [],
    this.likeCount = 0,
    this.isLiked = false,
    this.replies = const [],
    this.isReported = false,
  });

  Review copyWith({
    double? rating,
    String? content,
    List<String>? imageUrls,
    int? likeCount,
    bool? isLiked,
    List<ReviewReply>? replies,
    bool? isReported,
  }) {
    return Review(
      id: id,
      recipeId: recipeId,
      userName: userName,
      rating: rating ?? this.rating,
      content: content ?? this.content,
      createdAt: createdAt,
      imageUrls: imageUrls ?? this.imageUrls,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      replies: replies ?? this.replies,
      isReported: isReported ?? this.isReported,
    );
  }
}

class ReviewReply {
  final String id;
  final String userName;
  final String content;
  final DateTime createdAt;

  const ReviewReply({
    required this.id,
    required this.userName,
    required this.content,
    required this.createdAt,
  });
}
