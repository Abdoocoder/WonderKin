// Core Constants
class AppConstants {
  static const String appName = 'عالم المغامرات الذكي';
  static const String appVersion = '1.0.0';
  
  // Screen time limits (minutes)
  static const List<int> screenTimeOptions = [15, 30, 45];
  static const int defaultScreenTime = 30;
  
  // Star thresholds
  static const int maxStarsPerLevel = 3;
  static const int starsForCompletion = 1;
  static const int starsForNoMistakes = 1;
  static const int starsForSpeed = 1;
  
  // Animation durations
  static const Duration snapAnimationDuration = Duration(milliseconds: 300);
  static const Duration returnAnimationDuration = Duration(milliseconds: 400);
  static const Duration celebrationDuration = Duration(milliseconds: 1500);
  
  // Touch target sizes
  static const double minTouchTarget = 48.0;
  static const double dragItemSize = 80.0;
  static const double dropTargetSize = 100.0;
  
  // Parental gate
  static const int maxGateAttempts = 3;
  static const Duration gateLockoutDuration = Duration(seconds: 30);
  
  // Audio
  static const double defaultSfxVolume = 1.0;
  static const double defaultMusicVolume = 0.7;
}

class AudioConstants {
  // SFX
  static const String sfxPickup = 'pickup';
  static const String sfxSnap = 'snap';
  static const String sfxReturn = 'return';
  static const String sfxTap = 'tap';
  static const String sfxStar = 'star';
  static const String sfxSticker = 'sticker';
  static const String sfxLevelComplete = 'level_complete';
  static const String sfxError = 'error';
  static const String sfxButton = 'button';
  static const String sfxCelebration = 'celebration';
  
  // Music
  static const String musicBackground = 'background_music';
  static const String musicStory = 'story_music';
  static const String musicPuzzle = 'puzzle_music';
  
  // Voice (narration)
  static const String voicePrefix = 'voice_';
}

class GameConstants {
  // Level types
  static const String typeStory = 'story';
  static const String typePuzzle = 'puzzle';
  
  // Puzzle types
  static const String puzzleShapeMatch = 'shape_match';
  static const String puzzleLetterMatch = 'letter_match';
  static const String puzzleNumberSequence = 'number_sequence';
  static const String puzzleCategorySort = 'category_sort';
  
  // Skill tags for reporting
  static const List<String> skillTags = [
    'letters',      // الحروف
    'numbers',      // الأرقام
    'shapes',       // الأشكال
    'colors',       // الألوان
    'animals',      // الحيوانات
    'fruits',       // الفواكه
    'vehicles',     // المركبات
    'logic',        // المنطق
    'memory',       // الذاكرة
    'fine_motor',   // المهارات الحركية الدقيقة
  ];
}