/// คอมเมนต์ใต้สูตรอาหาร (รองรับ reply แบบ nested)
class Comment {
  final String id;
  final String recipeId;
  final String userName;
  final String content;
  final DateTime createdAt;
  final String? imageUrl;
  final List<String> mentions;
  final List<Comment> replies;

  const Comment({
    required this.id,
    required this.recipeId,
    required this.userName,
    required this.content,
    required this.createdAt,
    this.imageUrl,
    this.mentions = const [],
    this.replies = const [],
  });

  Comment copyWith({
    String? content,
    List<Comment>? replies,
  }) {
    return Comment(
      id: id,
      recipeId: recipeId,
      userName: userName,
      content: content ?? this.content,
      createdAt: createdAt,
      imageUrl: imageUrl,
      mentions: mentions,
      replies: replies ?? this.replies,
    );
  }
}
