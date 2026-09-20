// Sticker Book Screen - Collection of unlocked stickers
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/audio/audio_manager.dart';
import '../../../core/storage/database.dart';
import '../../../core/theme/text_styles.dart';
import '../../../shared/models/content_models.dart';

class StickerBookScreen extends StatefulWidget {
  const StickerBookScreen({super.key});

  @override
  State<StickerBookScreen> createState() => _StickerBookScreenState();
}

class _StickerBookScreenState extends State<StickerBookScreen> with TickerProviderStateMixin {
  String _selectedCategory = 'all';
  late AnimationController _pageController;
  
  @override
  void initState() {
    super.initState();
    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
                  theme.colorScheme.tertiaryContainer.withOpacity(0.3),
                  theme.colorScheme.surface,
                  theme.colorScheme.primaryContainer.withOpacity(0.2),
                ],
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(theme),
                
                // Category Tabs
                _buildCategoryTabs(theme),
                
                // Sticker Grid
                Expanded(
                  child: _buildStickerGrid(theme),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Back Button
          _StickerBookButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.pop(context),
          ),
          
          const Spacer(),
          
          // Title
          Text(
            'ألبوم الملصقات',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          
          const Spacer(),
          
          // Stats
          Consumer<AppDatabase>(
            builder: (context, db, _) {
              return StreamBuilder<List<StickerCollectionData>>(
                stream: db.stickerCollectionDao.watchAllStickers(),
                builder: (context, snapshot) {
                  final unlocked = snapshot.data?.length ?? 0;
                  final total = ContentLoader.getAllStickers().length;
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.collections_rounded,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$unlocked / $total',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryTabs(ThemeData theme) {
    final categories = ['all', 'stars', 'numbers', 'shapes', 'animals'];
    final categoryLabels = {
      'all': 'الكل',
      'stars': 'نجوم',
      'numbers': 'أرقام',
      'shapes': 'أشكال',
      'animals': 'حيوانات',
    };
    final categoryIcons = {
      'all': Icons.apps_rounded,
      'stars': Icons.star_rounded,
      'numbers': Icons.numbers_rounded,
      'shapes': Icons.shape_line_rounded,
      'animals': Icons.pets_rounded,
    };
    
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final selected = _selectedCategory == category;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _CategoryTab(
              label: categoryLabels[category]!,
              icon: categoryIcons[category]!,
              selected: selected,
              onTap: () {
                setState(() => _selectedCategory = category);
                context.read<AudioManager>().playTap();
              },
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildStickerGrid(ThemeData theme) {
    return Consumer<AppDatabase>(
      builder: (context, db, _) {
        return StreamBuilder<List<StickerCollectionData>>(
          stream: db.stickerCollectionDao.watchAllStickers(),
          builder: (context, snapshot) {
            final unlockedStickers = snapshot.data
                ?.map((s) => s.stickerId)
                .toSet() ?? {};
            
            var allStickers = ContentLoader.getAllStickers();
            
            // Filter by category
            if (_selectedCategory != 'all') {
              allStickers = allStickers
                  .where((s) => s.category == _selectedCategory)
                  .toList();
            }
            
            if (allStickers.isEmpty) {
              return _EmptyState(
                icon: Icons.sentiment_dissatisfied_rounded,
                title: 'لا توجد ملصقات في هذا القسم',
                subtitle: 'استكشف أقساماً أخرى أو أكمل مغامرات جديدة',
              );
            }
            
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: allStickers.length,
              itemBuilder: (context, index) {
                final sticker = allStickers[index];
                final isUnlocked = unlockedStickers.contains(sticker.id);
                
                return _StickerBookCard(
                  sticker: sticker,
                  isUnlocked: isUnlocked,
                  onTap: () => _showStickerDetail(context, sticker, isUnlocked),
                ).animate()
                  .fadeIn(delay: (50 * index).ms, duration: 300.ms)
                  .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
              },
            );
          },
        );
      },
    );
  }
  
  void _showStickerDetail(BuildContext context, Sticker sticker, bool unlocked) {
    context.read<AudioManager>().playTap();
    
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StickerDetailSheet(sticker: sticker, unlocked: unlocked),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  
  const _CategoryTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: selected ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: selected 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StickerBookCard extends StatelessWidget {
  final Sticker sticker;
  final bool isUnlocked;
  final VoidCallback onTap;
  
  const _StickerBookCard({
    required this.sticker,
    required this.isUnlocked,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: isUnlocked 
                ? theme.colorScheme.surface 
                : theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUnlocked 
                  ? theme.colorScheme.primary.withOpacity(0.3) 
                  : theme.colorScheme.outlineVariant,
              width: 1,
            ),
            boxShadow: isUnlocked ? [
              BoxShadow(
                color: theme.colorScheme.shadow,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Column(
            children: [
              // Sticker Image
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: isUnlocked 
                        ? DecorationImage(
                            image: AssetImage(sticker.assetPath),
                            fit: BoxFit.contain,
                          )
                        : null,
                    color: isUnlocked 
                        ? theme.colorScheme.primaryContainer.withOpacity(0.2) 
                        : theme.colorScheme.surfaceContainer,
                  ),
                  child: !isUnlocked
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.lock_rounded,
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 32,
                            ),
                            Positioned(
                              bottom: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'مقفلة',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
              
              // Sticker Name
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Text(
                  sticker.getLocalizedName(context),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isUnlocked 
                        ? theme.colorScheme.onSurface 
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StickerDetailSheet extends StatefulWidget {
  final Sticker sticker;
  final bool unlocked;
  
  const _StickerDetailSheet({
    required this.sticker,
    required this.unlocked,
  });
  
  @override
  State<_StickerDetailSheet> createState() => _StickerDetailSheetState();
}

class _StickerDetailSheetState extends State<_StickerDetailSheet>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
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
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Sticker Image with Animation
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _controller.value.clamp(0.5, 1.0),
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(24),
                    image: widget.unlocked
                        ? DecorationImage(
                            image: AssetImage(widget.sticker.assetPath),
                            fit: BoxFit.contain,
                          )
                        : null,
                    border: Border.all(
                      color: widget.unlocked 
                          ? theme.colorScheme.primary.withOpacity(0.3) 
                          : theme.colorScheme.outlineVariant,
                      width: 2,
                    ),
                  ),
                  child: !widget.unlocked
                      ? Icon(
                          Icons.lock_rounded,
                          size: 70,
                          color: theme.colorScheme.onSurfaceVariant,
                        )
                      : null,
                ),
              );
            },
          ),
          
          const SizedBox(height: 20),
          
          // Name
          Text(
            widget.sticker.getLocalizedName(context),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // Category Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getCategoryIcon(widget.sticker.category),
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  _getCategoryLabel(widget.sticker.category),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Status
          if (!widget.unlocked) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: theme.colorScheme.tertiary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'أكمل المغامرات لفتح هذه الملصقة الرائعة!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'تهانينا! هذه الملصقة في مجموعتك للأبد',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Close Button
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'إغلاق',
                style: AppTextStyles.kidButton,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'stars': return Icons.star_rounded;
      case 'numbers': return Icons.numbers_rounded;
      case 'shapes': return Icons.shape_line_rounded;
      case 'animals': return Icons.pets_rounded;
      default: return Icons.category_rounded;
    }
  }
  
  String _getCategoryLabel(String category) {
    switch (category) {
      case 'stars': return 'نجوم';
      case 'numbers': return 'أرقام';
      case 'shapes': return 'أشكال';
      case 'animals': return 'حيوانات';
      default: return 'أخرى';
    }
  }
}

class _StickerBookButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  
  const _StickerBookButton({required this.icon, required this.onTap});
  
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

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}