// Star Rating Widget
import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final int stars;
  final int maxStars;
  final double size;
  final Color filledColor;
  final Color emptyColor;
  final double spacing;

  const StarRating({
    super.key,
    required this.stars,
    this.maxStars = 3,
    this.size = 24,
    required this.filledColor,
    required this.emptyColor,
    this.spacing = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (index) {
        final filled = index < stars;
        return Padding(
          padding: EdgeInsets.only(right: index < maxStars - 1 ? spacing : 0),
          child: Icon(
            filled ? Icons.star_rounded : Icons.star_border_rounded,
            size: size,
            color: filled ? filledColor : emptyColor,
          ),
        );
      }),
    );
  }
}