import 'package:flutter/material.dart';

class AudioWaveform extends StatelessWidget {
  final List<double> heights;
  final Color activeColor;
  final Color inactiveColor;
  final int activeIndex;
  final double barWidth;
  final double spacing;

  const AudioWaveform({
    super.key,
    this.heights = const [
      12, 24, 16, 32, 20, 28, 14, 36, 24, 18, 30, 22, 16, 28, 14, 8, 12, 6, 10
    ],
    this.activeColor = const Color(0xFFD98E32),
    this.inactiveColor = const Color(0xFFE2E8F0),
    this.activeIndex = 12,
    this.barWidth = 3.5,
    this.spacing = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(heights.length, (index) {
        final isActive = index <= activeIndex;
        return Container(
          margin: EdgeInsets.only(right: spacing),
          width: barWidth,
          height: heights[index],
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
