import 'package:flutter/material.dart';
import '../../models/comment.dart';
import '../../theme/app_theme.dart';

class CommentTile extends StatelessWidget {
  final Comment comment;
  final VoidCallback? onReply;
  final VoidCallback? onDelete;
  final bool isNested;

  const CommentTile({
    super.key,
    required this.comment,
    this.onReply,
    this.onDelete,
    this.isNested = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: isNested ? 24 : 0, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppTheme.primaryLight,
                child: Text(
                  comment.userName[0],
                  style: const TextStyle(fontSize: 12, color: AppTheme.primary),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(comment.createdAt),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _buildContent(),
                    if (comment.imageUrl != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.image, color: AppTheme.primary),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _SmallButton(
                          icon: Icons.reply_outlined,
                          label: 'ตอบกลับ',
                          onTap: onReply,
                        ),
                        if (onDelete != null) ...[
                          const SizedBox(width: 12),
                          _SmallButton(
                            icon: Icons.delete_outline,
                            label: 'ลบ',
                            onTap: onDelete,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (comment.replies.isNotEmpty)
            ...comment.replies.map(
              (r) => CommentTile(
                comment: r,
                isNested: true,
                onReply: onReply,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (comment.mentions.isEmpty) {
      return Text(comment.content, style: const TextStyle(fontSize: 13.5, height: 1.4));
    }
    var text = comment.content;
    final spans = <InlineSpan>[];
    for (final mention in comment.mentions) {
      final tag = '@$mention';
      final idx = text.indexOf(tag);
      if (idx >= 0) {
        if (idx > 0) spans.add(TextSpan(text: text.substring(0, idx)));
        spans.add(TextSpan(
          text: tag,
          style: const TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ));
        text = text.substring(idx + tag.length);
      }
    }
    if (text.isNotEmpty) spans.add(TextSpan(text: text));
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 13.5, color: AppTheme.textPrimary, height: 1.4),
        children: spans,
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

class _SmallButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _SmallButton({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
