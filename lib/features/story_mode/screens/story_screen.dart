// Story Screen - Interactive story with narration and drag-drop
import 'dart:math' show cos, sin, pi;
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/audio/audio_manager.dart';
import '../../core/storage/database.dart';
import '../../shared/models/content_models.dart';
import '../../shared/widgets/drag_drop/drag_drop_engine.dart';
import '../../shared/widgets/common/star_rating.dart';
import '../../shared/widgets/common/animated_button.dart';

class StoryScreen extends StatefulWidget {
  final Level level;
  
  const StoryScreen({super.key, required this.level});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  bool _isNarrating = false;
  bool _pageCompleted = false;
  bool _levelCompleted = false;
  int _mistakes = 0;
  int _startTime = 0;
  
  // Drag-drop state
  final Map<String, Offset> _itemPositions = {};
  final Set<String> _matchedItems = {};
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startTime = DateTime.now().millisecondsSinceEpoch;
    
    // Initialize item positions
    final page = widget.level.story?.pages[_currentPage];
    if (page?.draggableItems != null) {
      for (final item in page!.draggableItems!) {
        _itemPositions[item.id] = item.position;
      }
    }
    
    // Start narration
    _playNarration();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    context.read<AudioManager>().stopVoice();
    super.dispose();
  }
  
  void _playNarration() {
    final page = widget.level.story?.pages[_currentPage];
    if (page != null) {
      setState(() => _isNarrating = true);
      context.read<AudioManager>().playVoiceLine(page.audioId).then((_) {
        if (mounted) {
          setState(() => _isNarrating = false);
        }
      });
    }
  }
  
  void _onItemMatched(String itemId, String targetId) {
    setState(() {
      _matchedItems.add(itemId);
      _pageCompleted = _checkPageComplete();
    });
    
    context.read<AudioManager>().playSnap();
    
    if (_pageCompleted) {
      _handlePageComplete();
    }
  }
  
  void _onItemMismatched(String itemId) {
    setState(() {
      _mistakes++;
    });
    context.read<AudioManager>().playReturn();
  }
  
  bool _checkPageComplete() {
    final page = widget.level.story?.pages[_currentPage];
    if (page?.draggableItems == null) return true;
    
    return page!.draggableItems!.every((item) => _matchedItems.contains(item.id));
  }
  
  void _handlePageComplete() {
    context.read<AudioManager>().playStar();
    
    // Check if this is the last page
    final isLastPage = _currentPage == (widget.level.story?.pages.length ?? 1) - 1;
    
    if (isLastPage) {
      _completeLevel();
    } else {
      // Auto-advance after celebration
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          _nextPage();
        }
      });
    }
  }
  
  void _nextPage() {
    if (_currentPage < (widget.level.story?.pages.length ?? 1) - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }
  
  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }
  
  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
      _pageCompleted = false;
      _matchedItems.clear();
      
      // Reset item positions for new page
      _itemPositions.clear();
      final pageData = widget.level.story?.pages[page];
      if (pageData?.draggableItems != null) {
        for (final item in pageData!.draggableItems!) {
          _itemPositions[item.id] = item.position;
        }
      }
    });
    
    _playNarration();
  }
  
  void _completeLevel() async {
    if (_levelCompleted) return;
    _levelCompleted = true;
    
    final timeMs = DateTime.now().millisecondsSinceEpoch - _startTime;
    final hadMistakes = _mistakes > 0;
    
    // Calculate stars (1 for completion, 1 for no mistakes, 1 for speed)
    int stars = 1; // completion
    if (!hadMistakes) stars++;
    if (timeMs < 60000) stars++; // under 1 minute
    stars = stars.clamp(1, 3);
    
    context.read<AudioManager>().playLevelComplete();
    
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
      _showCelebration(stars);
    }
  }
  
  void _showCelebration(int stars) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _CelebrationDialog(
        stars: stars,
        stickerId: widget.level.rewards.stickerId,
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
    final story = widget.level.story;
    final page = story?.pages[_currentPage];
    
    if (story == null || page == null) {
      return Scaffold(
        body: Center(child: Text('Story not found')),
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
                  theme.colorScheme.primaryContainer.withOpacity(0.2),
                  theme.colorScheme.surface,
                ],
              ),
            ),
          ),
          
          // Story Content
          PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(), // Disable swipe for kids
            onPageChanged: _onPageChanged,
            itemCount: story.pages.length,
            itemBuilder: (context, index) {
              final p = story.pages[index];
              return _StoryPageView(
                page: p,
                pageIndex: index,
                totalPages: story.pages.length,
                itemPositions: _itemPositions,
                matchedItems: _matchedItems,
                isCurrentPage: index == _currentPage,
                onItemMatched: _onItemMatched,
                onItemMismatched: _onItemMismatched,
              );
            },
          ),
          
          // Navigation Arrows
          if (!_isNarrating && !_levelCompleted) ...[
            // Previous
            if (_currentPage > 0)
              Positioned(
                left: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _NavArrow(
                    icon: Icons.chevron_left_rounded,
                    onTap: _previousPage,
                    enabled: !_pageCompleted,
                  ),
                ),
              ),
            
            // Next
            if (_currentPage < story.pages.length - 1)
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _NavArrow(
                    icon: Icons.chevron_right_rounded,
                    onTap: _pageCompleted ? _nextPage : null,
                    enabled: _pageCompleted,
                  ),
                ),
              ),
          ],
          
          // Top Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Back Button
                  _StoryTopButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  
                  const Spacer(),
                  
                  // Level Title
                  Text(
                    widget.level.getLocalizedTitle(context),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Progress Indicator
                  _StoryProgressIndicator(
                    current: _currentPage + 1,
                    total: story.pages.length,
                  ),
                  
                  const Spacer(),
                  
                  // Speaker Button (Replay narration)
                  _StoryTopButton(
                    icon: _isNarrating 
                        ? Icons.stop_rounded 
                        : Icons.volume_up_rounded,
                    onTap: _isNarrating 
                        ? () => context.read<AudioManager>().stopVoice()
                        : _playNarration,
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Indicator (Page dots)
          SafeArea(
            bottom: true,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(story.pages.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == _currentPage ? 24 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: index == _currentPage
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryPageView extends StatelessWidget {
  final StoryPage page;
  final int pageIndex;
  final int totalPages;
  final Map<String, Offset> itemPositions;
  final Set<String> matchedItems;
  final bool isCurrentPage;
  final void Function(String itemId, String targetId) onItemMatched;
  final void Function(String itemId) onItemMismatched;
  
  const _StoryPageView({
    required this.page,
    required this.pageIndex,
    required this.totalPages,
    required this.itemPositions,
    required this.matchedItems,
    required this.isCurrentPage,
    required this.onItemMatched,
    required this.onItemMismatched,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Stack(
      children: [
        // Background Illustration
        Positioned.fill(
          child: _PageBackground(pageIndex: pageIndex),
        ),
        
        // Text Narration (with word highlighting)
        if (page.textAr.isNotEmpty)
          Positioned(
            bottom: 180,
            left: 24,
            right: 24,
            child: _NarrationText(
              text: page.getLocalizedText(context),
              audioId: page.audioId,
            ),
          ),
        
        // Interactive Elements (Tap to animate)
        ...page.interactiveElements.map((element) {
          return Positioned(
            left: element.position.dx,
            top: element.position.dy,
            child: _InteractiveElementWidget(element: element),
          );
        }),
        
        // Drag & Drop Area
        if (page.draggableItems != null && page.dropTargets != null)
          Positioned.fill(
            child: _StoryDragDropArea(
              page: page,
              itemPositions: itemPositions,
              matchedItems: matchedItems,
              isCurrentPage: isCurrentPage,
              onItemMatched: onItemMatched,
              onItemMismatched: onItemMismatched,
            ),
          ),
      ],
    );
  }
}

class _PageBackground extends StatelessWidget {
  final int pageIndex;
  
  const _PageBackground({required this.pageIndex});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // In production, load actual background images
    // For now, use decorative gradients
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer.withOpacity(0.1),
            theme.colorScheme.secondaryContainer.withOpacity(0.1),
            theme.colorScheme.tertiaryContainer.withOpacity(0.1),
          ],
        ),
      ),
      child: CustomPaint(
        painter: _BackgroundPainter(pageIndex: pageIndex),
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final int pageIndex;
  
  _BackgroundPainter({required this.pageIndex});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    
    // Draw decorative shapes based on page
    switch (pageIndex % 4) {
      case 0: // Clouds
        _drawClouds(canvas, size, paint);
        break;
      case 1: // Stars
        _drawStars(canvas, size, paint);
        break;
      case 2: // Bubbles
        _drawBubbles(canvas, size, paint);
        break;
      case 3: // Leaves
        _drawLeaves(canvas, size, paint);
        break;
    }
  }
  
  void _drawClouds(Canvas canvas, Size size, Paint paint) {
    paint.color = Colors.white.withOpacity(0.3);
    for (int i = 0; i < 5; i++) {
      final x = (size.width * (i * 0.2 + 0.1)) % size.width;
      final y = size.height * 0.15 + (i * 30.0) % 100;
      _drawCloud(canvas, Offset(x, y), 60 + (i * 10), paint);
    }
  }
  
  void _drawCloud(Canvas canvas, Offset center, double width, Paint paint) {
    final path = Path();
    final radius = width / 2;
    path.addOval(Rect.fromCircle(center: center, radius: radius * 0.6));
    path.addOval(Rect.fromCircle(center: center + Offset(-radius * 0.4, 0), radius: radius * 0.5));
    path.addOval(Rect.fromCircle(center: center + Offset(radius * 0.4, 0), radius: radius * 0.5));
    path.addOval(Rect.fromCircle(center: center + Offset(0, -radius * 0.3), radius: radius * 0.4));
    canvas.drawPath(path, paint);
  }
  
  void _drawStars(Canvas canvas, Size size, Paint paint) {
    paint.color = Colors.amber.withOpacity(0.4);
    for (int i = 0; i < 8; i++) {
      final x = (size.width * (i * 0.125 + 0.05)) % size.width;
      final y = size.height * 0.1 + (i * 50.0) % (size.height * 0.4);
      _drawStar(canvas, Offset(x, y), 8 + (i % 3) * 4, paint);
    }
  }
  
  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = -pi / 2 + i * 2 * pi / 5;
      final outerX = center.dx + radius * cos(angle);
      final outerY = center.dy + radius * sin(angle);
      final innerAngle = angle + pi / 5;
      final innerX = center.dx + radius * 0.4 * cos(innerAngle);
      final innerY = center.dy + radius * 0.4 * sin(innerAngle);
      
      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      path.lineTo(innerX, innerY);
    }
    path.close();
    canvas.drawPath(path, paint);
  }
  
  void _drawBubbles(Canvas canvas, Size size, Paint paint) {
    paint.color = Colors.cyan.withOpacity(0.2);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    for (int i = 0; i < 10; i++) {
      final x = (size.width * (i * 0.1 + 0.05)) % size.width;
      final y = size.height * 0.3 + (i * 40.0) % (size.height * 0.5);
      final radius = 15 + (i % 5) * 10;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }
  
  void _drawLeaves(Canvas canvas, Size size, Paint paint) {
    paint.color = Colors.green.withOpacity(0.2);
    for (int i = 0; i < 6; i++) {
      final x = (size.width * (i * 0.16 + 0.08)) % size.width;
      final y = size.height * 0.2 + (i * 60.0) % (size.height * 0.5);
      _drawLeaf(canvas, Offset(x, y), 20 + (i % 3) * 10, paint);
    }
  }
  
  void _drawLeaf(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy - size);
    path.quadraticBezierTo(
      center.dx + size, center.dy - size / 2,
      center.dx, center.dy,
    );
    path.quadraticBezierTo(
      center.dx - size, center.dy - size / 2,
      center.dx, center.dy - size,
    );
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NarrationText extends StatefulWidget {
  final String text;
  final String audioId;
  
  const _NarrationText({required this.text, required this.audioId});
  
  @override
  State<_NarrationText> createState() => _NarrationTextState();
}

class _NarrationTextState extends State<_NarrationText>
    with SingleTickerProviderStateMixin {
  late AnimationController _highlightController;
  late Animation<int> _wordIndexAnimation;
  List<String> _words = [];
  
  @override
  void initState() {
    super.initState();
    _words = widget.text.split(' ');
    
    _highlightController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Approximate
    );
    
    _wordIndexAnimation = IntTween(
      begin: 0,
      end: _words.length - 1,
    ).animate(CurvedAnimation(
      parent: _highlightController,
      curve: Curves.linear,
    ));
    
    _highlightController.forward();
  }
  
  @override
  void dispose() {
    _highlightController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _wordIndexAnimation,
        builder: (context, child) {
          return Text.rich(
            TextSpan(
              children: _words.asMap().entries.map((entry) {
                final index = entry.key;
                final word = entry.value;
                final isHighlighted = index <= _wordIndexAnimation.value;
                
                return TextSpan(
                  text: '$word ',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 20,
                    height: 1.6,
                    color: isHighlighted 
                        ? theme.colorScheme.primary 
                        : theme.colorScheme.onSurface,
                    fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
                  ),
                );
              }).toList(),
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          );
        },
      ),
    );
  }
}

class _InteractiveElementWidget extends StatelessWidget {
  final InteractiveElement element;
  
  const _InteractiveElementWidget({required this.element});
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Play sound and animation
        context.read<AudioManager>().playSfx(element.soundId);
        // TODO: Play Rive/Flare animation
      },
      child: Container(
        width: element.size.width,
        height: element.size.height,
        child: CustomPaint(
          painter: _InteractiveElementPainter(element: element),
        ),
      ),
    );
  }
}

class _InteractiveElementPainter extends CustomPainter {
  final InteractiveElement element;
  
  _InteractiveElementPainter({required this.element});
  
  @override
  void paint(Canvas canvas, Size size) {
    // Placeholder - in production, render Rive/Flare animation
    final paint = Paint()
      ..color = Colors.amber.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StoryDragDropArea extends StatelessWidget {
  final StoryPage page;
  final Map<String, Offset> itemPositions;
  final Set<String> matchedItems;
  final bool isCurrentPage;
  final void Function(String itemId, String targetId) onItemMatched;
  final void Function(String itemId) onItemMismatched;
  
  const _StoryDragDropArea({
    required this.page,
    required this.itemPositions,
    required this.matchedItems,
    required this.isCurrentPage,
    required this.onItemMatched,
    required this.onItemMismatched,
  });
  
  @override
  Widget build(BuildContext context) {
    if (page.draggableItems == null || page.dropTargets == null) {
      return const SizedBox.shrink();
    }
    
    final items = page.draggableItems!.map((item) {
      final isMatched = matchedItems.contains(item.id);
      return DraggableItemData<DraggableItemData>(
        data: item,
        position: itemPositions[item.id] ?? item.position,
        child: _DraggableStoryItem(
          item: item,
          isMatched: isMatched,
        ),
      );
    }).toList();
    
    final targets = page.dropTargets!.map((target) {
      return DropTargetData<DraggableItemData>(
        id: target.id,
        expectedData: page.draggableItems!.firstWhere(
          (item) => item.id == target.expectedItemId,
          orElse: () => throw Exception('Item not found'),
        ),
        position: target.position,
        child: _DropTargetOutline(target: target),
      );
    }).toList();
    
    return DragDropArea<DraggableItemData>(
      items: items,
      targets: targets,
      enabled: isCurrentPage,
      onMatch: onItemMatched,
      onMismatch: onItemMismatched,
      builder: (context, itemWidgets, targetWidgets) {
        return Stack(
          children: [
            ...targetWidgets,
            ...itemWidgets,
          ],
        );
      },
    );
  }
}

class _DraggableStoryItem extends StatelessWidget {
  final DraggableItemData item;
  final bool isMatched;
  
  const _DraggableStoryItem({
    required this.item,
    required this.isMatched,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (isMatched) {
      return const SizedBox.shrink(); // Hidden when matched
    }
    
    return Container(
      width: AppConstants.dragItemSize,
      height: AppConstants.dragItemSize,
      decoration: BoxDecoration(
        color: item.color ?? theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: item.type == 'letter' || item.type == 'number'
            ? Text(
                item.content,
                style: theme.textTheme.displayMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              )
            : _buildShapeIcon(item.content, theme),
      ),
    );
  }
  
  Widget _buildShapeIcon(String shape, ThemeData theme) {
    switch (shape) {
      case 'circle':
        return Icon(Icons.circle_rounded, size: 40, color: theme.colorScheme.onPrimaryContainer);
      case 'square':
        return Icon(Icons.crop_square_rounded, size: 40, color: theme.colorScheme.onPrimaryContainer);
      case 'triangle':
        return Icon(Icons.change_history_rounded, size: 40, color: theme.colorScheme.onPrimaryContainer);
      default:
        return Icon(Icons.help_outline, size: 40, color: theme.colorScheme.onPrimaryContainer);
    }
  }
}

class _DropTargetOutline extends StatelessWidget {
  final DropTargetData target;
  
  const _DropTargetOutline({required this.target});
  
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
        color: theme.colorScheme.surfaceContainer.withOpacity(0.5),
      ),
      child: Center(
        child: Icon(
          Icons.add_rounded,
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          size: 32,
        ),
      ),
    );
  }
}

class _NavArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;
  
  const _NavArrow({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: enabled ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 28,
            color: enabled 
                ? theme.colorScheme.primary 
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _StoryTopButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  
  const _StoryTopButton({
    required this.icon,
    required this.onTap,
  });
  
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
          child: Icon(
            icon,
            color: theme.colorScheme.onSurface,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _StoryProgressIndicator extends StatelessWidget {
  final int current;
  final int total;
  
  const _StoryProgressIndicator({
    required this.current,
    required this.total,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$current / $total',
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _CelebrationDialog extends StatefulWidget {
  final int stars;
  final String? stickerId;
  final VoidCallback onContinue;
  
  const _CelebrationDialog({
    required this.stars,
    this.stickerId,
    required this.onContinue,
  });
  
  @override
  State<_CelebrationDialog> createState() => _CelebrationDialogState();
}

class _CelebrationDialogState extends State<_CelebrationDialog>
    with TickerProviderStateMixin {
  late AnimationController _starController;
  late AnimationController _confettiController;
  
  @override
  void initState() {
    super.initState();
    
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    _starController.forward();
    _confettiController.forward();
  }
  
  @override
  void dispose() {
    _starController.dispose();
    _confettiController.dispose();
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
            // Confetti
            AnimatedBuilder(
              animation: _confettiController,
              builder: (context, child) {
                return ConfettiWidget(
                  controller: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                    theme.colorScheme.tertiary,
                    theme.colorScheme.error,
                  ],
                );
              },
            ),
            
            // Stars
            AnimatedBuilder(
              animation: _starController,
              builder: (context, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final delay = index * 200;
                    final animValue = (_starController.value * 1500 - delay).clamp(0, 500) / 500;
                    
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
            
            // Title
            Text(
              'أحسنت! 🎉',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'لقد أكملت المغامرة بنجاح!',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            
            // Sticker unlock
            if (widget.stickerId != null) ...[
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
            
            // Continue Button
            AnimatedButton(
              onPressed: widget.onContinue,
              child: Text(
                'متابعة',
                style: theme.textTheme.kidButton,
              ),
            ),
          ],
        ),
      ),
    );
  }
}