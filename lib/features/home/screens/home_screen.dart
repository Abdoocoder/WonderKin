// Home Screen - Main entry point for kids
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'dart:math' show sin;
import '../../../core/audio/audio_manager.dart';
import '../../../core/storage/database.dart';
import '../../../shared/models/content_models.dart';
import '../../story_mode/screens/story_screen.dart';
import '../../puzzle_mode/screens/puzzle_screen.dart';
import '../../sticker_book/screens/sticker_book_screen.dart';
import '../../parental_gate/parental_gate.dart';
import '../../../shared/widgets/common/animated_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  int _selectedTab = 0;
  
  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    
    // Start background music
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AudioManager>().playBackgroundMusic();
    });
  }
  
  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final audioManager = context.watch<AudioManager>();
    
    return Scaffold(
      body: Stack(
        children: [
          // Background
          _buildBackground(theme),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(theme, audioManager),
                
                // Tab Bar
                _buildTabBar(theme),
                
                // Content
                Expanded(
                  child: IndexedStack(
                    index: _selectedTab,
                    children: [
                      _buildLevelsTab(theme),
                      _buildStickerBookTab(theme),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBackground(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primaryContainer.withOpacity(0.3),
            theme.colorScheme.surface,
            theme.colorScheme.secondaryContainer.withOpacity(0.2),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Decorative floating elements
          Positioned(
            top: 50,
            right: 20,
            child: _FloatingDecoration(
              animation: _floatAnimation,
              child: Icon(
                Icons.star_rounded,
                size: 40,
                color: theme.colorScheme.primary.withOpacity(0.3),
              ),
            ),
          ),
          Positioned(
            top: 150,
            left: 10,
            child: _FloatingDecoration(
              animation: _floatAnimation,
              child: Icon(
                Icons.favorite_rounded,
                size: 30,
                color: theme.colorScheme.tertiary.withOpacity(0.3),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: 10,
            child: _FloatingDecoration(
              animation: _floatAnimation,
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 35,
                color: theme.colorScheme.secondary.withOpacity(0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeader(ThemeData theme, AudioManager audioManager) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // App Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'عالم المغامرات',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'الذكي',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          
          // Star Counter
          Consumer<AppDatabase>(
            builder: (context, db, _) {
              return StreamBuilder(
                stream: db.profileDao.watchProfile(),
                builder: (context, snapshot) {
                  final stars = snapshot.data?.totalStars ?? 0;
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
                          Icons.star_rounded,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          stars.toString(),
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          
          const SizedBox(width: 12),
          
          // Settings Button (Parental Gate)
          _HeaderIconButton(
            icon: Icons.settings_rounded,
            onTap: () => _showParentalGate(context),
            tooltip: 'إعدادات الأهل',
          ),
          
          const SizedBox(width: 8),
          
          // Sound Toggle
          _HeaderIconButton(
            icon: audioManager.sfxVolume > 0 
                ? Icons.volume_up_rounded 
                : Icons.volume_off_rounded,
            onTap: () {
              audioManager.setSfxVolume(audioManager.sfxVolume > 0 ? 0 : 1);
              audioManager.setMusicVolume(audioManager.musicVolume > 0 ? 0 : 0.7);
            },
            tooltip: 'الصوت',
          ),
        ],
      ),
    );
  }
  
  Widget _buildTabBar(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _TabButton(
            index: 0,
            selected: _selectedTab == 0,
            icon: Icons.menu_book_rounded,
            label: 'المغامرات',
            onTap: () => setState(() => _selectedTab = 0),
          ),
          _TabButton(
            index: 1,
            selected: _selectedTab == 1,
            icon: Icons.collections_rounded,
            label: 'ملصقاتي',
            onTap: () => setState(() => _selectedTab = 1),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLevelsTab(ThemeData theme) {
    return Consumer<AppDatabase>(
      builder: (context, db, _) {
        return StreamBuilder<List<LevelProgressData>>(
          stream: db.levelProgressDao.watchAllProgress(),
          builder: (context, progressSnapshot) {
            final completedLevels = progressSnapshot.data
                ?.where((p) => p.isCompleted)
                .map((p) => p.levelId)
                .toSet() ?? {};
            
            final unlockedLevels = ContentLoader.getUnlockedLevels(completedLevels);
            
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: unlockedLevels.length,
              itemBuilder: (context, index) {
                final level = unlockedLevels[index];
                final LevelProgressData? progress = progressSnapshot.data
                    ?.firstWhere((p) => p.levelId == level.id);
                
                return _LevelCard(
                  level: level,
                  starsEarned: progress?.starsEarned ?? 0,
                  isCompleted: progress?.isCompleted ?? false,
                  onTap: () => _navigateToLevel(context, level),
                ).animate()
                  .fadeIn(delay: (100 * index).ms, duration: 400.ms)
                  .slideY(begin: 0.2, end: 0);
              },
            );
          },
        );
      },
    );
  }
  
  Widget _buildStickerBookTab(ThemeData theme) {
    return Consumer<AppDatabase>(
      builder: (context, db, _) {
        return StreamBuilder<List<StickerCollectionData>>(
          stream: db.stickerCollectionDao.watchAllStickers(),
          builder: (context, snapshot) {
            final unlockedStickers = snapshot.data
                ?.map((s) => s.stickerId)
                .toSet() ?? {};
            
            final allStickers = ContentLoader.getAllStickers();
            
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
                
                return _StickerCard(
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
  
  void _navigateToLevel(BuildContext context, Level level) {
    context.read<AudioManager>().playTap();
    
    if (level.type == LevelType.story) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StoryScreen(level: level),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PuzzleScreen(level: level),
        ),
      );
    }
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
  
  void _showParentalGate(BuildContext context) {
    context.read<AudioManager>().playButton();
    
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ParentalGateBottomSheet(),
    );
  }
}

class _FloatingDecoration extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  
  const _FloatingDecoration({required this.animation, required this.child});
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, animation.value),
          child: this.child,
        );
      },
      child: child,
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Tooltip(
      message: tooltip,
      child: Material(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final int index;
  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  
  const _TabButton({
    required this.index,
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Expanded(
      child: Material(
        color: selected ? theme.colorScheme.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: selected 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
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
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final Level level;
  final int starsEarned;
  final bool isCompleted;
  final VoidCallback onTap;
  
  const _LevelCard({
    required this.level,
    required this.starsEarned,
    required this.isCompleted,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnlocked = isCompleted || level.isUnlockedByDefault;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isUnlocked ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isCompleted 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.outlineVariant,
              width: isCompleted ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Level Icon
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: isCompleted 
                      ? theme.colorScheme.primaryContainer 
                      : theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  level.type == LevelType.story 
                      ? Icons.menu_book_rounded 
                      : Icons.extension_rounded,
                  size: 32,
                  color: isCompleted 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Level Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level.getLocalizedTitle(context),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isUnlocked 
                            ? theme.colorScheme.onSurface 
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: level.skills.map((skill) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            skill.arabicName,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              
              // Stars
              StarRating(
                stars: starsEarned,
                maxStars: 3,
                size: 24,
                filledColor: theme.colorScheme.primary,
                emptyColor: theme.colorScheme.outlineVariant,
              ),
              
              const SizedBox(width: 8),
              
              // Lock/Arrow
              if (!isUnlocked)
                Icon(
                  Icons.lock_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 24,
                )
              else
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StickerCard extends StatelessWidget {
  final Sticker sticker;
  final bool isUnlocked;
  final VoidCallback onTap;
  
  const _StickerCard({
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
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Sticker Image/Placeholder
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUnlocked 
                        ? theme.colorScheme.primaryContainer.withOpacity(0.3) 
                        : theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                    image: isUnlocked 
                        ? DecorationImage(
                            image: AssetImage(sticker.assetPath),
                            fit: BoxFit.contain,
                          )
                        : null,
                  ),
                  child: !isUnlocked
                      ? Icon(
                          Icons.lock_rounded,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 32,
                        )
                      : null,
                ),
              ),
              
              // Sticker Name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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

class _StickerDetailSheet extends StatelessWidget {
  final Sticker sticker;
  final bool unlocked;
  
  const _StickerDetailSheet({
    required this.sticker,
    required this.unlocked,
  });
  
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
          
          // Sticker Image
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              image: unlocked
                  ? DecorationImage(
                      image: AssetImage(sticker.assetPath),
                      fit: BoxFit.contain,
                    )
                  : null,
            ),
            child: !unlocked
                ? Icon(
                    Icons.lock_rounded,
                    size: 60,
                    color: theme.colorScheme.onSurfaceVariant,
                  )
                : null,
          ),
          
          const SizedBox(height: 16),
          
          // Name
          Text(
            sticker.getLocalizedName(context),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // Category
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              sticker.category,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Status
          if (!unlocked)
            Text(
              'أكمل المغامرات لفتح هذه الملصقة!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            )
          else
            Text(
              'تهانينا! هذه الملصقة في مجموعتك',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class ParentalGateBottomSheet extends StatelessWidget {
  const ParentalGateBottomSheet({super.key});
  
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Title
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'إعدادات الأهل',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              // Parental Gate
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ParentalGateScreen(
                    onSuccess: () => Navigator.pop(context),
                    onCancel: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}