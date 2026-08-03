import 'package:flutter/material.dart';
import '../../models/review.dart';
import '../../theme/app_theme.dart';
import '../rating_display.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  final VoidCallback? onLike;
  final VoidCallback? onReport;
  final VoidCallback? onReply;

  const ReviewCard({
    super.key,
    required this.review,
    this.onLike,
    this.onReport,
    this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primaryLight,
                child: Text(
                  review.userName[0],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                      ),
                    ),
                    RatingDisplay(
                      rating: review.rating,
                      reviewCount: 0,
                      fontSize: 11,
                      starSize: 12,
                      showCount: false,
                    ),
                  ],
                ),
              ),
              Text(
                _formatDate(review.createdAt),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(review.content, style: const TextStyle(fontSize: 14, height: 1.4)),
          if (review.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.image_outlined, color: AppTheme.primary),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              _ActionButton(
                icon: review.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                label: '${review.likeCount}',
                onTap: onLike,
                active: review.isLiked,
              ),
              const SizedBox(width: 16),
              _ActionButton(
                icon: Icons.reply_outlined,
                label: 'ตอบกลับ',
                onTap: onReply,
              ),
              const Spacer(),
              _ActionButton(
                icon: Icons.flag_outlined,
                label: review.isReported ? 'รายงานแล้ว' : 'รายงาน',
                onTap: review.isReported ? null : onReport,
              ),
            ],
          ),
          if (review.replies.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...review.replies.map(
              (r) => Padding(
                padding: const EdgeInsets.only(left: 20, top: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.subdirectory_arrow_right, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textPrimary,
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(
                              text: '${r.userName}: ',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            TextSpan(text: r.content),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day}/${d.month}/${d.year}';
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool active;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: active ? AppTheme.primary : AppTheme.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: active ? AppTheme.primary : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
