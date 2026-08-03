import 'package:flutter/foundation.dart';

import '../models/comment.dart';
import '../data/mock_social_data.dart';

/// จัดการคอมเมนต์: แสดง, ตอบกลับ, mention, emoji, ลบ
class CommentProvider extends ChangeNotifier {
  final List<Comment> _comments = [...MockComments.comments];

  List<Comment> getTopLevelComments(String recipeId) {
    return _comments
        .where((c) => c.recipeId == recipeId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void addComment({
    required String recipeId,
    required String userName,
    required String content,
    String? parentId,
    List<String> mentions = const [],
    String? imageUrl,
  }) {
    final comment = Comment(
      id: 'c${_comments.length + 1}',
      recipeId: recipeId,
      userName: userName,
      content: content,
      createdAt: DateTime.now(),
      mentions: mentions,
      imageUrl: imageUrl,
    );

    if (parentId != null) {
      _addReply(parentId, comment);
    } else {
      _comments.insert(0, comment);
    }
    notifyListeners();
  }

  void _addReply(String parentId, Comment reply) {
    for (var i = 0; i < _comments.length; i++) {
      if (_comments[i].id == parentId) {
        _comments[i] = _comments[i].copyWith(
          replies: [..._comments[i].replies, reply],
        );
        return;
      }
      final updated = _addReplyNested(_comments[i], parentId, reply);
      if (updated != null) {
        _comments[i] = updated;
        return;
      }
    }
  }

  Comment? _addReplyNested(Comment parent, String parentId, Comment reply) {
    for (var i = 0; i < parent.replies.length; i++) {
      if (parent.replies[i].id == parentId) {
        final newReplies = [...parent.replies];
        newReplies[i] = newReplies[i].copyWith(
          replies: [...newReplies[i].replies, reply],
        );
        return parent.copyWith(replies: newReplies);
      }
    }
    return null;
  }

  void deleteComment(String commentId) {
    _comments.removeWhere((c) => c.id == commentId);
    for (var i = 0; i < _comments.length; i++) {
      _comments[i] = _removeReplyRecursive(_comments[i], commentId);
    }
    notifyListeners();
  }

  Comment _removeReplyRecursive(Comment comment, String commentId) {
    return comment.copyWith(
      replies: comment.replies
          .where((r) => r.id != commentId)
          .map((r) => _removeReplyRecursive(r, commentId))
          .toList(),
    );
  }
}
