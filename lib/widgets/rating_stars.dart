import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final Color? color;
  final bool interactive;
  final ValueChanged<int>? onRatingChanged;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 24,
    this.color,
    this.interactive = false,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final starColor = color ?? Colors.amber[700]!;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        return GestureDetector(
          onTap: interactive && onRatingChanged != null
              ? () => onRatingChanged!(starValue)
              : null,
          child: Icon(
            _getStarIcon(starValue, rating),
            size: size,
            color: starColor,
          ),
        );
      }),
    );
  }

  IconData _getStarIcon(int starValue, double rating) {
    if (rating >= starValue) {
      return Icons.star;
    } else if (rating >= starValue - 0.5) {
      return Icons.star_half;
    } else {
      return Icons.star_border;
    }
  }
}