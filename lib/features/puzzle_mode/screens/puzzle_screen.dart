// Puzzle Screen - Interactive puzzles with drag-drop
import 'dart:async' show Timer;
import 'dart:math' show cos, sin, pi;
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/audio/audio_manager.dart';
import '../../../core/storage/database.dart';
import '../../../shared/models/content_models.dart';
import '../../../shared/widgets/drag_drop/drag_drop_engine.dart';
import '../../../shared/widgets/common/star_rating.dart';
import '../../../shared/widgets/common/animated_button.dart';

class PuzzleScreen extends StatefulWidget {
  final Level level;
  
  const PuzzleScreen({super.key, required this.level});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> with TickerProviderStateMixin {
  bool _levelCompleted = false;
  int _mistakes = 0;
  int _startTime = 0;
  int _matchedCount = 0;
  late Timer? _timer;
  int _remainingSeconds = 0;
  
  // Drag-drop state
  final Map<String, Offset> _itemPositions = {};
  final Set<String> _matchedItems = {};
  
  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now().millisecondsSinceEpoch;
    
    // Initialize item positions
    final puzzle = widget.level.puzzle;
    if (puzzle != null) {
      for (final item in puzzle.items) {
        _itemPositions[item.id] = item.startPosition;
      }
      
      // Start timer if applicable
      if (puzzle.timeLimitSeconds > 0) {
        _remainingSeconds = puzzle.timeLimitSeconds;
        _startTimer();
      }
    }
    
    // Play puzzle music
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AudioManager>().playPuzzleMusic();
    });
  }
  
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _remainingSeconds--;
          if (_remainingSeconds <= 0) {
            _timer?.cancel();
            _handleTimeUp();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }
  
  void _handleTimeUp() {
    if (_levelCompleted) return;
    _completeLevel(ranOutOfTime: true);
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    context.read<AudioManager>().stopMusic();
    super.dispose();
  }
  
  void _onItemMatched(String itemId, String targetId) {
    setState(() {
      _matchedItems.add(itemId);
      _matchedCount++;
    });
    
    context.read<AudioManager>().playSnap();
    
    // Check if all matched
    final puzzle = widget.level.puzzle;
    if (puzzle != null && _matchedCount >= puzzle.items.length) {
      _completeLevel();
    }
  }
  
  void _onItemMismatched(String itemId) {
    setState(() {
      _mistakes++;
    });
    context.read<AudioManager>().playReturn();
  }
  
  void _completeLevel({bool ranOutOfTime = false}) async {
    if (_levelCompleted) return;
    _levelCompleted = true;
    _timer?.cancel();
    
    final timeMs = DateTime.now().millisecondsSinceEpoch - _startTime;
    final hadMistakes = _mistakes > 0 || ranOutOfTime;
    
    // Calculate stars
    int stars = 1; // completion
    if (!hadMistakes) stars++;
    if (timeMs < 60000 && !ranOutOfTime) stars++; // under 1 minute
    stars = stars.clamp(1, 3);
    
    if (ranOutOfTime) {
      context.read<AudioManager>().playError();
    } else {
      context.read<AudioManager>().playLevelComplete();
    }
    
    // Save progress
    await context.read<AppDatabase>().levelProgressDao.completeLevel(
      levelId: widget.level.id,
      starsEarned: stars,
      timeMs: timeMs,
      hadMistakes: hadMistakes,
    );
    
    // Unlock sticker if any
    if (widget.level.rewards.stickerId != null) {
      await context.read<AppDatabase>().stickerCollectionDao.unlockSticker(
        widget.level.rewards.stickerId!,
      );
    }
    
    // Show celebration
    if (mounted) {
      _showCelebration(stars, ranOutOfTime);
    }
  }
  
  void _showCelebration(int stars, bool ranOutOfTime) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _PuzzleCelebrationDialog(
        stars: stars,
        stickerId: widget.level.rewards.stickerId,
        ranOutOfTime: ranOutOfTime,
        onContinue: () {
          Navigator.pop(context); // Close dialog
          Navigator.pop(context); // Return to home
        },
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final puzzle = widget.level.puzzle;
    
    if (puzzle == null) {
      return Scaffold(
        body: Center(child: Text('Puzzle not found')),
      );
    }
    
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.secondaryContainer.withOpacity(0.2),
                  theme.colorScheme.surface,
                  theme.colorScheme.primaryContainer.withOpacity(0.1),
                ],
              ),
            ),
          ),
          
          // Puzzle Content
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                _buildTopBar(theme, puzzle),
                
                // Puzzle Area
                Expanded(
                  child: _buildPuzzleArea(theme, puzzle),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTopBar(ThemeData theme, PuzzleContent puzzle) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Back Button
          _PuzzleTopButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.pop(context),
          ),
          
          const Spacer(),
          
          // Timer
          if (puzzle.timeLimitSeconds > 0)
            _TimerDisplay(
              remainingSeconds: _remainingSeconds,
              totalSeconds: puzzle.timeLimitSeconds,
            ),
          
          const Spacer(),
          
          // Level Title
          Text(
            widget.level.getLocalizedTitle(context),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const Spacer(),
          
          // Progress (matched / total)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '$_matchedCount / ${puzzle.items.length}',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPuzzleArea(ThemeData theme, PuzzleContent puzzle) {
    // Build items
    final items = puzzle.items.map((item) {
      final isMatched = _matchedItems.contains(item.id);
      return DraggableItemData<PuzzleItem>(
        data: item,
        position: _itemPositions[item.id] ?? item.startPosition,
        child: _DraggablePuzzleItem(
          item: item,
          isMatched: isMatched,
        ),
      );
    }).toList();
    
    // Build targets
    final targets = puzzle.targets.map((target) {
      return DropTargetData<PuzzleItem>(
        id: target.id,
        expectedData: puzzle.items.firstWhere(
          (item) => puzzle.matching[item.id] == target.id,
          orElse: () => throw Exception('No matching item for target ${target.id}'),
        ),
        position: target.position,
        child: _PuzzleDropTarget(
          target: target,
          puzzleType: puzzle.type,
        ),
      );
    }).toList();
    
    return DragDropArea<PuzzleItem>(
      items: items,
      targets: targets,
      onMatch: _onItemMatched,
      onMismatch: _onItemMismatched,
      builder: (context, itemWidgets, targetWidgets) {
        return Stack(
          children: [
            // Background grid/pattern
            _PuzzleBackground(puzzleType: puzzle.type),
            
            // Targets first (behind items)
            ...targetWidgets,
            
            // Items on top
            ...itemWidgets,
          ],
        );
      },
    );
  }
}

class _PuzzleBackground extends StatelessWidget {
  final PuzzleType puzzleType;
  
  const _PuzzleBackground({required this.puzzleType});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return CustomPaint(
      size: Size.infinite,
      painter: _PuzzleBackgroundPainter(puzzleType: puzzleType),
    );
  }
}

class _PuzzleBackgroundPainter extends CustomPainter {
  final PuzzleType puzzleType;
  
  _PuzzleBackgroundPainter({required this.puzzleType});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..isAntiAlias = true;
    
    switch (puzzleType) {
      case PuzzleType.shapeMatch:
        paint.color = Colors.blue.withOpacity(0.1);
        _drawGrid(canvas, size, paint, 80);
        break;
      case PuzzleType.letterMatch:
        paint.color = Colors.purple.withOpacity(0.1);
        _drawGrid(canvas, size, paint, 100);
        break;
      case PuzzleType.numberSequence:
        paint.color = Colors.green.withOpacity(0.1);
        _drawGrid(canvas, size, paint, 120);
        break;
      case PuzzleType.categorySort:
        paint.color = Colors.orange.withOpacity(0.1);
        _drawCategoryZones(canvas, size, paint);
        break;
    }
  }
  
  void _drawGrid(Canvas canvas, Size size, Paint paint, double spacing) {
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  
  void _drawCategoryZones(Canvas canvas, Size size, Paint paint) {
    // Draw three horizontal zones
    final zoneHeight = size.height / 3;
    paint.color = Colors.brown.withOpacity(0.1);
    paint.style = PaintingStyle.fill;
    
    // Land zone (top)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, zoneHeight),
      paint,
    );
    
    // Water zone (middle)
    paint.color = Colors.blue.withOpacity(0.1);
    canvas.drawRect(
      Rect.fromLTWH(0, zoneHeight, size.width, zoneHeight),
      paint,
    );
    
    // Sky zone (bottom)
    paint.color = Colors.lightBlue.withOpacity(0.1);
    canvas.drawRect(
      Rect.fromLTWH(0, zoneHeight * 2, size.width, zoneHeight),
      paint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DraggablePuzzleItem extends StatelessWidget {
  final PuzzleItem item;
  final bool isMatched;
  
  const _DraggablePuzzleItem({
    required this.item,
    required this.isMatched,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (isMatched) {
      return const SizedBox.shrink();
    }
    
    return Container(
      width: AppConstants.dragItemSize,
      height: AppConstants.dragItemSize,
      decoration: BoxDecoration(
        color: item.color?.withOpacity(0.2) ?? theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.color ?? theme.colorScheme.primary,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: _buildItemContent(item, theme),
      ),
    );
  }
  
  Widget _buildItemContent(PuzzleItem item, ThemeData theme) {
    switch (item.type) {
      case 'number':
      case 'letter':
        return Text(
          item.content,
          style: theme.textTheme.displayMedium?.copyWith(
            color: item.color ?? theme.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        );
      case 'shape':
        return _buildShape(item.content, item.color ?? theme.colorScheme.primary);
      case 'image':
        return Image.asset(
          item.content,
          width: AppConstants.dragItemSize * 0.7,
          height: AppConstants.dragItemSize * 0.7,
          errorBuilder: (_, __, ___) => Icon(
            Icons.image_not_supported,
            size: 40,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        );
      default:
        return Text(
          item.content,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        );
    }
  }
  
  Widget _buildShape(String shape, Color color) {
    return CustomPaint(
      size: Size(AppConstants.dragItemSize * 0.6, AppConstants.dragItemSize * 0.6),
      painter: _ShapePainter(shape: shape, color: color),
    );
  }
}

class _PuzzleDropTarget extends StatelessWidget {
  final PuzzleTarget target;
  final PuzzleType puzzleType;
  
  const _PuzzleDropTarget({
    required this.target,
    required this.puzzleType,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: target.size.width,
      height: target.size.height,
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline,
          width: 3,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surfaceContainer.withOpacity(0.3),
      ),
      child: Center(
        child: _buildTargetContent(target, theme),
      ),
    );
  }
  
  Widget _buildTargetContent(PuzzleTarget target, ThemeData theme) {
    if (target.type == 'outline' || target.type == 'slot') {
      return Icon(
        Icons.add_rounded,
        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
        size: 32,
      );
    } else if (target.type == 'category') {
      // Category icon
      IconData icon;
      Color color;
      switch (target.expectedContent) {
        case 'land':
          icon = Icons.park_rounded;
          color = Colors.brown;
          break;
        case 'water':
          icon = Icons.water_drop_rounded;
          color = Colors.blue;
          break;
        case 'sky':
          icon = Icons.cloud_rounded;
          color = Colors.lightBlue;
          break;
        default:
          icon = Icons.category_rounded;
          color = theme.colorScheme.onSurfaceVariant;
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(height: 4),
          Text(
            target.expectedContent ?? '',
            style: theme.textTheme.labelMedium?.copyWith(color: color),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}

class _PuzzleTopButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  
  const _PuzzleTopButton({required this.icon, required this.onTap});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: theme.colorScheme.surface.withOpacity(0.9),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(icon, color: theme.colorScheme.onSurface, size: 22),
        ),
      ),
    );
  }
}

class _TimerDisplay extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;
  
  const _TimerDisplay({
    required this.remainingSeconds,
    required this.totalSeconds,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = remainingSeconds / totalSeconds;
    final isLow = progress < 0.3;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isLow ? theme.colorScheme.errorContainer : theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_rounded,
            size: 18,
            color: isLow ? theme.colorScheme.error : theme.colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            _formatTime(remainingSeconds),
            style: theme.textTheme.labelLarge?.copyWith(
              color: isLow ? theme.colorScheme.error : theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

class _PuzzleCelebrationDialog extends StatefulWidget {
  final int stars;
  final String? stickerId;
  final bool ranOutOfTime;
  final VoidCallback onContinue;
  
  const _PuzzleCelebrationDialog({
    required this.stars,
    this.stickerId,
    required this.ranOutOfTime,
    required this.onContinue,
  });
  
  @override
  State<_PuzzleCelebrationDialog> createState() => _PuzzleCelebrationDialogState();
}

class _PuzzleCelebrationDialogState extends State<_PuzzleCelebrationDialog>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!widget.ranOutOfTime)
              ConfettiWidget(
                controller: _controller,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                  theme.colorScheme.tertiary,
                ],
              ),
            
            // Stars or Time Up
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                if (widget.ranOutOfTime) {
                  return Column(
                    children: [
                      Icon(
                        Icons.timer_off_rounded,
                        size: 80,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'انتهى الوقت!',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                }
                
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final delay = index * 200;
                    final animValue = (_controller.value * 1500 - delay).clamp(0, 500) / 500;
                    
                    return Transform.scale(
                      scale: animValue.clamp(0, 1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          index < widget.stars 
                              ? Icons.star_rounded 
                              : Icons.star_border_rounded,
                          size: 48,
                          color: index < widget.stars
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant,
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            if (!widget.ranOutOfTime) ...[
              Text(
                'أحسنت! 🎉',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'لقد حللت اللغز بنجاح!',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ] else ...[
              Text(
                'لا تقلق، حاول مرة أخرى!',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            
            // Sticker unlock
            if (widget.stickerId != null && !widget.ranOutOfTime) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.card_giftcard_rounded,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'ملصقة جديدة!',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 32),
            
            AnimatedButton(
              onPressed: widget.onContinue,
              child: Text(
                widget.ranOutOfTime ? 'إعادة المحاولة' : 'متابعة',
                style: theme.textTheme.kidButton,
              ),
            ),
          ],
        ),
      ),
    );
  }
}