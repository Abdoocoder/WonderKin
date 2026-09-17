// Common Shared Widgets
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../../../../core/theme/app_theme.dart';

// Star Rating Widget
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

// Animated Button Widget
class AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double? elevation;

  const AnimatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
    this.elevation,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Material(
            color: widget.backgroundColor ?? theme.colorScheme.primary,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
            elevation: widget.elevation ?? 2,
            shadowColor: theme.colorScheme.shadow,
            child: InkWell(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
              child: Container(
                padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: DefaultTextStyle(
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: widget.foregroundColor ?? theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ) ?? const TextStyle(),
                  child: widget.child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Progress Indicator Widget
class KidProgressIndicator extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double height;
  final Color? progressColor;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final Widget? label;

  const KidProgressIndicator({
    super.key,
    required this.progress,
    this.height = 8,
    this.progressColor,
    this.backgroundColor,
    this.borderRadius,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          label!,
          const SizedBox(height: 8),
        ],
        ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
          child: Container(
            height: height,
            width: double.infinity,
            color: backgroundColor ?? theme.colorScheme.surfaceContainer,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: progressColor ?? theme.colorScheme.primary,
                  borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Speaking Text Widget - Highlights words as audio plays
class SpeakingText extends StatefulWidget {
  final String text;
  final String textAr;
  final Duration? estimatedDuration;
  final TextStyle? style;
  final TextStyle? highlightedStyle;
  final TextAlign textAlign;

  const SpeakingText({
    super.key,
    required this.text,
    required this.textAr,
    this.estimatedDuration,
    this.style,
    this.highlightedStyle,
    this.textAlign = TextAlign.center,
  });

  @override
  State<SpeakingText> createState() => _SpeakingTextState();
}

class _SpeakingTextState extends State<SpeakingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _wordIndexAnimation;
  List<String> _words = [];

  @override
  void initState() {
    super.initState();
    final Locale locale = Localizations.localeOf(context);
    _words = (locale.languageCode == 'ar' ? widget.textAr : widget.text).split(' ');

    _controller = AnimationController(
      vsync: this,
      duration: widget.estimatedDuration ?? Duration(milliseconds: _words.length * 300),
    );

    _wordIndexAnimation = IntTween(
      begin: -1,
      end: _words.length - 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void start() => _controller.forward(from: 0);
  void stop() => _controller.stop();
  void reset() => _controller.reset();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle defaultStyle = widget.style ?? theme.textTheme.bodyLarge?.copyWith(fontSize: 20, height: 1.6) ?? const TextStyle();
    final TextStyle defaultHighlightedStyle = widget.highlightedStyle ?? defaultStyle.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.w600,
    );

    return AnimatedBuilder(
      animation: _wordIndexAnimation,
      builder: (context, child) {
        return Text.rich(
          TextSpan(
            children: _words.asMap().entries.map((entry) {
              final int index = entry.key;
              final String word = entry.value;
              final bool isHighlighted = index <= _wordIndexAnimation.value;

              return TextSpan(
                text: '$word ',
                style: isHighlighted ? defaultHighlightedStyle : defaultStyle,
              );
            }).toList(),
          ),
          textAlign: widget.textAlign,
          textDirection: TextDirection.rtl,
        );
      },
    );
  }
}

// Confetti Celebration Widget
class CelebrationOverlay extends StatefulWidget {
  final bool show;
  final VoidCallback? onComplete;
  final List<Color> colors;

  const CelebrationOverlay({
    super.key,
    required this.show,
    this.onComplete,
    this.colors = const [
      Colors.pink,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ],
  });

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    if (widget.show) {
      _controller.forward().then((_) {
        widget.onComplete?.call();
      });
    }
  }

  @override
  void didUpdateWidget(CelebrationOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show && !oldWidget.show) {
      _controller.forward(from: 0).then((_) {
        widget.onComplete?.call();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.show) return const SizedBox.shrink();

    return IgnorePointer(
      child: ConfettiWidget(
        controller: _controller,
        blastDirectionality: BlastDirectionality.explosive,
        shouldLoop: false,
        colors: widget.colors,
        numberOfParticles: 50,
        maxBlastForce: 30,
        minBlastForce: 10,
        emissionFrequency: 0.05,
        gravity: 0.3,
      ),
    );
  }
}