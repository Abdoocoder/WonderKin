// Drag & Drop Engine - Core gameplay mechanics
// Single-touch guard, snap-to-target, return animation
import 'dart:math' show cos, sin, pi;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../core/constants/app_constants.dart';
import '../../core/audio/audio_manager.dart';

/// A draggable item that returns to its origin on failed drop
class DraggableItem<T> extends StatefulWidget {
  final T data;
  final Widget child;
  final Offset initialPosition;
  final void Function(T data, Offset position)? onDragStarted;
  final void Function(T data)? onDragEnded;
  final bool enabled;
  
  const DraggableItem({
    super.key,
    required this.data,
    required this.child,
    required this.initialPosition,
    this.onDragStarted,
    this.onDragEnded,
    this.enabled = true,
  });

  @override
  State<DraggableItem<T>> createState() => _DraggableItemState<T>();
}

class _DraggableItemState<T> extends State<DraggableItem<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _returnController;
  late Animation<Offset> _returnAnimation;
  Offset _currentPosition;
  bool _isDragging = false;
  int? _activePointer;
  
  @override
  void initState() {
    super.initState();
    _currentPosition = widget.initialPosition;
    
    _returnController = AnimationController(
      vsync: this,
      duration: AppConstants.returnAnimationDuration,
    );
    
    _returnAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _returnController,
      curve: Curves.elasticOut,
    ));
    
    _returnController.addListener(() {
      if (mounted) {
        setState(() {
          _currentPosition = widget.initialPosition + _returnAnimation.value;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _returnController.dispose();
    super.dispose();
  }
  
  void _handlePanStart(DragStartDetails details) {
    if (!widget.enabled) return;
    
    // Single-touch guard: only accept first pointer
    if (_activePointer != null) return;
    _activePointer = details.pointer;
    
    setState(() {
      _isDragging = true;
    });
    
    widget.onDragStarted?.call(widget.data, widget.initialPosition);
    
    // Haptic + audio feedback
    // HapticFeedback.lightImpact();
    // AudioManager.playPickup(); // Will be called via provider
  }
  
  void _handlePanUpdate(DragUpdateDetails details) {
    // Single-touch guard: ignore other pointers
    if (_activePointer != details.pointer) return;
    if (!widget.enabled) return;
    
    setState(() {
      _currentPosition += details.delta;
    });
  }
  
  void _handlePanEnd(DragEndDetails details) {
    // Single-touch guard
    if (_activePointer != details.pointer) return;
    _activePointer = null;
    
    setState(() {
      _isDragging = false;
    });
    
    widget.onDragEnded?.call(widget.data);
  }
  
  void _handlePanCancel() {
    _activePointer = null;
    setState(() {
      _isDragging = false;
    });
    _animateReturn();
    widget.onDragEnded?.call(widget.data);
  }
  
  /// Call this when drop succeeds (snaps to target)
  void snapToTarget(Offset targetPosition, {VoidCallback? onComplete}) {
    _activePointer = null;
    _isDragging = false;
    
    final controller = AnimationController(
      vsync: this,
      duration: AppConstants.snapAnimationDuration,
    );
    
    final animation = Tween<Offset>(
      begin: _currentPosition - widget.initialPosition,
      end: targetPosition - widget.initialPosition,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutBack,
    ));
    
    controller.addListener(() {
      if (mounted) {
        setState(() {
          _currentPosition = widget.initialPosition + animation.value;
        });
      }
    });
    
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
        onComplete?.call();
      }
    });
    
    controller.forward();
    // AudioManager.playSnap();
  }
  
  /// Call this when drop fails (returns to origin)
  void returnToOrigin({VoidCallback? onComplete}) {
    _animateReturn(onComplete: onComplete);
    // AudioManager.playReturn();
  }
  
  void _animateReturn({VoidCallback? onComplete}) {
    _returnController.reset();
    _returnAnimation = Tween<Offset>(
      begin: _currentPosition - widget.initialPosition,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _returnController,
      curve: Curves.elasticOut,
    ));
    
    _returnController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        onComplete?.call();
      }
    });
    
    _returnController.forward();
  }
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _currentPosition.dx - widget.initialPosition.dx,
      top: _currentPosition.dy - widget.initialPosition.dy,
      child: GestureDetector(
        onPanStart: _handlePanStart,
        onPanUpdate: _handlePanUpdate,
        onPanEnd: _handlePanEnd,
        onPanCancel: _handlePanCancel,
        dragStartBehavior: DragStartBehavior.down,
        child: Transform.scale(
          scale: _isDragging ? 1.1 : 1.0,
          child: Opacity(
            opacity: _isDragging ? 0.9 : 1.0,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// A drop target that validates matches and triggers callbacks
class DropTarget<T> extends StatefulWidget {
  final String targetId;
  final T? expectedData; // The data that matches this target
  final Widget child;
  final void Function(T data)? onAccept;
  final void Function(T data)? onReject;
  final bool enabled;
  final EdgeInsets hitTestPadding;
  
  const DropTarget({
    super.key,
    required this.targetId,
    this.expectedData,
    required this.child,
    this.onAccept,
    this.onReject,
    this.enabled = true,
    this.hitTestPadding = EdgeInsets.zero,
  });

  @override
  State<DropTarget<T>> createState() => _DropTargetState<T>();
}

class _DropTargetState<T> extends State<DropTarget<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isHovered = false;
  bool _justAccepted = false;
  
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return DragTarget<T>(
      onWillAcceptWithDetails: (details) {
        if (!widget.enabled) return false;
        final data = details.data;
        return _isMatch(data);
      },
      onAcceptWithDetails: (details) {
        if (!widget.enabled) return;
        final data = details.data;
        if (_isMatch(data)) {
          _justAccepted = true;
          setState(() => _isHovered = false);
          widget.onAccept?.call(data);
          _animateAccept();
        } else {
          widget.onReject?.call(data);
        }
      },
      onLeave: (data) {
        if (!widget.enabled) return;
        setState(() => _isHovered = false);
      },
      onMove: (details) {
        if (!widget.enabled) return;
        final data = details.data;
        setState(() => _isHovered = _isMatch(data));
      },
      builder: (context, candidateData, rejectedData) {
        final isCandidateMatch = candidateData.any(_isMatch);
        
        return AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: (_isHovered || isCandidateMatch || _justAccepted) 
                  ? _pulseAnimation.value 
                  : 1.0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (_isHovered || isCandidateMatch)
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: (_isHovered || isCandidateMatch || _justAccepted)
                      ? [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary
                                .withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: widget.child,
              ),
            );
          },
        );
      },
    );
  }
  
  bool _isMatch(T? data) {
    if (data == null || widget.expectedData == null) return false;
    return data == widget.expectedData;
  }
  
  void _animateAccept() {
    _justAccepted = true;
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _justAccepted = false);
      }
    });
  }
}

/// Orchestrates multiple draggable items and drop targets
class DragDropArea<T> extends StatefulWidget {
  final List<DraggableItemData<T>> items;
  final List<DropTargetData<T>> targets;
  final Widget Function(BuildContext, List<Widget>, List<Widget>) builder;
  final void Function(T itemData, String targetId)? onMatch;
  final void Function(T itemData)? onMismatch;
  final void Function()? onAllMatched;
  final bool enabled;
  
  const DragDropArea({
    super.key,
    required this.items,
    required this.targets,
    required this.builder,
    this.onMatch,
    this.onMismatch,
    this.onAllMatched,
    this.enabled = true,
  });

  @override
  State<DragDropArea<T>> createState() => _DragDropAreaState<T>();
}

class DraggableItemData<T> {
  final T data;
  final Widget child;
  final Offset position;
  
  const DraggableItemData({
    required this.data,
    required this.child,
    required this.position,
  });
}

class DropTargetData<T> {
  final String id;
  final T? expectedData;
  final Widget child;
  final Offset position;
  
  const DropTargetData({
    required this.id,
    this.expectedData,
    required this.child,
    required this.position,
  });
}

class _DragDropAreaState<T> extends State<DragDropArea<T>> {
  final Map<T, GlobalKey> _itemKeys = {};
  final Map<String, GlobalKey> _targetKeys = {};
  final Set<T> _matchedItems = {};
  final Map<T, Offset> _itemPositions = {};
  
  @override
  void initState() {
    super.initState();
    for (final item in widget.items) {
      _itemKeys[item.data] = GlobalKey();
      _itemPositions[item.data] = item.position;
    }
    for (final target in widget.targets) {
      _targetKeys[target.id] = GlobalKey();
    }
  }
  
  void _handleDragStarted(T data, Offset position) {
    _itemPositions[data] = position;
  }
  
  void _handleDragEnded(T data) {
    // Check if item was matched (handled by DropTarget)
  }
  
  void _handleAccept(T data, String targetId) {
    if (_matchedItems.contains(data)) return;
    
    _matchedItems.add(data);
    widget.onMatch?.call(data, targetId);
    
    // Check if all matched
    if (_matchedItems.length == widget.items.length) {
      widget.onAllMatched?.call();
    }
  }
  
  void _handleReject(T data) {
    widget.onMismatch?.call(data);
    
    // Animate return to origin
    final key = _itemKeys[data];
    if (key.currentContext != null) {
      // The DraggableItem will handle return animation
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.builder(context, [], []);
    }
    
    final itemWidgets = widget.items.map((item) {
      return DraggableItem<T>(
        key: _itemKeys[item.data],
        data: item.data,
        initialPosition: _itemPositions[item.data] ?? item.position,
        enabled: widget.enabled && !_matchedItems.contains(item.data),
        onDragStarted: _handleDragStarted,
        onDragEnded: _handleDragEnded,
        child: item.child,
      );
    }).toList();
    
    final targetWidgets = widget.targets.map((target) {
      return DropTarget<T>(
        key: _targetKeys[target.id],
        targetId: target.id,
        expectedData: target.expectedData,
        enabled: widget.enabled,
        onAccept: (data) => _handleAccept(data, target.id),
        onReject: _handleReject,
        child: target.child,
      );
    }).toList();
    
    return widget.builder(context, itemWidgets, targetWidgets);
  }
}

/// Pre-built drag-drop widgets for common use cases
class DragDropShapeMatch extends StatelessWidget {
  final List<ShapeItem> shapes;
  final void Function()? onComplete;
  final bool enabled;
  
  const DragDropShapeMatch({
    super.key,
    required this.shapes,
    this.onComplete,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final items = shapes.map((s) => DraggableItemData<ShapeItem>(
      data: s,
      position: s.startPosition,
      child: ShapeWidget(shape: s.shape, color: s.color, size: AppConstants.dragItemSize),
    )).toList();
    
    final targets = shapes.map((s) => DropTargetData<ShapeItem>(
      id: s.id,
      expectedData: s,
      position: s.targetPosition,
      child: ShapeOutlineWidget(shape: s.shape, size: AppConstants.dropTargetSize),
    )).toList();
    
    return DragDropArea<ShapeItem>(
      items: items,
      targets: targets,
      enabled: enabled,
      onAllMatched: onComplete,
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

class ShapeItem {
  final String id;
  final ShapeType shape;
  final Color color;
  final Offset startPosition;
  final Offset targetPosition;
  
  const ShapeItem({
    required this.id,
    required this.shape,
    required this.color,
    required this.startPosition,
    required this.targetPosition,
  });
}

enum ShapeType { circle, square, triangle, star, heart, hexagon }

class ShapeWidget extends StatelessWidget {
  final ShapeType shape;
  final Color color;
  final double size;
  
  const ShapeWidget({
    super.key,
    required this.shape,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ShapePainter(shape: shape, color: color),
      ),
    );
  }
}

class ShapeOutlineWidget extends StatelessWidget {
  final ShapeType shape;
  final double size;
  
  const ShapeOutlineWidget({
    super.key,
    required this.shape,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ShapeOutlinePainter(shape: shape),
      ),
    );
  }
}

class _ShapePainter extends CustomPainter {
  final ShapeType shape;
  final Color color;
  
  _ShapePainter({required this.shape, required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    switch (shape) {
      case ShapeType.circle:
        canvas.drawCircle(center, radius, paint);
        break;
      case ShapeType.square:
        canvas.drawRect(rect.deflate(size.width * 0.1), paint);
        break;
      case ShapeType.triangle:
        final path = Path()
          ..moveTo(center.dx, rect.top)
          ..lineTo(rect.right, rect.bottom)
          ..lineTo(rect.left, rect.bottom)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case ShapeType.star:
        canvas.drawPath(_starPath(center, radius), paint);
        break;
      case ShapeType.heart:
        canvas.drawPath(_heartPath(center, radius), paint);
        break;
      case ShapeType.hexagon:
        canvas.drawPath(_hexagonPath(center, radius), paint);
        break;
    }
  }
  
  Path _starPath(Offset center, double radius) {
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
    return path;
  }
  
  Path _heartPath(Offset center, double radius) {
    final path = Path();
    final width = radius * 2;
    final height = radius * 1.8;
    
    path.moveTo(center.dx, center.dy + height * 0.3);
    path.cubicTo(
      center.dx - width * 0.5, center.dy - height * 0.3,
      center.dx - width * 0.5, center.dy - height * 0.8,
      center.dx, center.dy - height * 0.5,
    );
    path.cubicTo(
      center.dx + width * 0.5, center.dy - height * 0.8,
      center.dx + width * 0.5, center.dy - height * 0.3,
      center.dx, center.dy + height * 0.3,
    );
    return path;
  }
  
  Path _hexagonPath(Offset center, double radius) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = i * 2 * pi / 6;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ShapeOutlinePainter extends CustomPainter {
  final ShapeType shape;
  
  _ShapeOutlinePainter({required this.shape});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..isAntiAlias = true;
    
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.9;
    
    switch (shape) {
      case ShapeType.circle:
        canvas.drawCircle(center, radius, paint);
        break;
      case ShapeType.square:
        canvas.drawRect(rect.deflate(size.width * 0.15), paint);
        break;
      case ShapeType.triangle:
        final path = Path()
          ..moveTo(center.dx, rect.top + size.height * 0.1)
          ..lineTo(rect.right - size.width * 0.1, rect.bottom - size.height * 0.1)
          ..lineTo(rect.left + size.width * 0.1, rect.bottom - size.height * 0.1)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case ShapeType.star:
        canvas.drawPath(_starPath(center, radius), paint);
        break;
      case ShapeType.heart:
        canvas.drawPath(_heartPath(center, radius), paint);
        break;
      case ShapeType.hexagon:
        canvas.drawPath(_hexagonPath(center, radius), paint);
        break;
    }
  }
  
  Path _starPath(Offset center, double radius) {
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
    return path;
  }
  
  Path _heartPath(Offset center, double radius) {
    final path = Path();
    final width = radius * 2;
    final height = radius * 1.8;
    
    path.moveTo(center.dx, center.dy + height * 0.3);
    path.cubicTo(
      center.dx - width * 0.5, center.dy - height * 0.3,
      center.dx - width * 0.5, center.dy - height * 0.8,
      center.dx, center.dy - height * 0.5,
    );
    path.cubicTo(
      center.dx + width * 0.5, center.dy - height * 0.8,
      center.dx + width * 0.5, center.dy - height * 0.3,
      center.dx, center.dy + height * 0.3,
    );
    return path;
  }
  
  Path _hexagonPath(Offset center, double radius) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = i * 2 * pi / 6;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
