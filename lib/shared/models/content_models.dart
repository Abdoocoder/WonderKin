// Content Models - Levels, Stories, Puzzles, Stickers
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

// Level Types
enum LevelType { story, puzzle }

// Puzzle Types
enum PuzzleType { shapeMatch, letterMatch, numberSequence, categorySort }

// Skill Tags
enum SkillTag {
  letters('letters', 'الحروف'),
  numbers('numbers', 'الأرقام'),
  shapes('shapes', 'الأشكال'),
  colors('colors', 'الألوان'),
  animals('animals', 'الحيوانات'),
  fruits('fruits', 'الفواكه'),
  vehicles('vehicles', 'المركبات'),
  logic('logic', 'المنطق'),
  memory('memory', 'الذاكرة'),
  fineMotor('fine_motor', 'المهارات الحركية');

  const SkillTag(this.id, this.arabicName);
  final String id;
  final String arabicName;
}

// Level Model
class Level {
  final String id;
  final String title;
  final String titleAr;
  final LevelType type;
  final int order;
  final List<SkillTag> skills;
  final StoryContent? story;
  final PuzzleContent? puzzle;
  final LevelRewards rewards;
  final bool isUnlockedByDefault;
  
  const Level({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.type,
    required this.order,
    required this.skills,
    this.story,
    this.puzzle,
    required this.rewards,
    this.isUnlockedByDefault = false,
  });
  
  String getLocalizedTitle(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return locale == 'ar' ? titleAr : title;
  }
  
  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'] as String,
      title: json['title'] as String,
      titleAr: json['titleAr'] as String,
      type: LevelType.values.byName(json['type'] as String),
      order: json['order'] as int,
      skills: (json['skills'] as List).map((s) => 
        SkillTag.values.byName(s as String)).toList(),
      story: json['story'] != null ? StoryContent.fromJson(json['story']) : null,
      puzzle: json['puzzle'] != null ? PuzzleContent.fromJson(json['puzzle']) : null,
      rewards: LevelRewards.fromJson(json['rewards']),
      isUnlockedByDefault: json['isUnlockedByDefault'] as bool? ?? false,
    );
  }
}

// Story Content
class StoryContent {
  final List<StoryPage> pages;
  
  const StoryContent({required this.pages});
  
  factory StoryContent.fromJson(Map<String, dynamic> json) {
    return StoryContent(
      pages: (json['pages'] as List)
          .map((p) => StoryPage.fromJson(p))
          .toList(),
    );
  }
}

class StoryPage {
  final String text;
  final String textAr;
  final String audioId;
  final List<InteractiveElement> interactiveElements;
  final List<DraggableItemData>? draggableItems;
  final List<DropTargetData>? dropTargets;
  
  const StoryPage({
    required this.text,
    required this.textAr,
    required this.audioId,
    this.interactiveElements = const [],
    this.draggableItems,
    this.dropTargets,
  });
  
  String getLocalizedText(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return locale == 'ar' ? textAr : text;
  }
  
  factory StoryPage.fromJson(Map<String, dynamic> json) {
    return StoryPage(
      text: json['text'] as String,
      textAr: json['textAr'] as String,
      audioId: json['audio'] as String,
      interactiveElements: (json['interactiveElements'] as List?)
          ?.map((e) => InteractiveElement.fromJson(e))
          .toList() ?? [],
      draggableItems: (json['draggableItems'] as List?)
          ?.map((e) => DraggableItemData.fromJson(e))
          .toList(),
      dropTargets: (json['dropTargets'] as List?)
          ?.map((e) => DropTargetData.fromJson(e))
          .toList(),
    );
  }
}

class InteractiveElement {
  final String id;
  final String type; // 'animation', 'sound', 'both'
  final String animationAsset;
  final String soundId;
  final Offset position;
  final Size size;
  
  const InteractiveElement({
    required this.id,
    required this.type,
    required this.animationAsset,
    required this.soundId,
    required this.position,
    required this.size,
  });
  
  factory InteractiveElement.fromJson(Map<String, dynamic> json) {
    return InteractiveElement(
      id: json['id'] as String,
      type: json['type'] as String,
      animationAsset: json['animationAsset'] as String,
      soundId: json['soundId'] as String,
      position: Offset(
        (json['position']['x'] as num).toDouble(),
        (json['position']['y'] as num).toDouble(),
      ),
      size: Size(
        (json['size']['width'] as num).toDouble(),
        (json['size']['height'] as num).toDouble(),
      ),
    );
  }
}

// Puzzle Content
class PuzzleContent {
  final PuzzleType type;
  final List<PuzzleItem> items;
  final List<PuzzleTarget> targets;
  final Map<String, String> matching; // itemId -> targetId
  final int timeLimitSeconds; // 0 = no limit
  
  const PuzzleContent({
    required this.type,
    required this.items,
    required this.targets,
    required this.matching,
    this.timeLimitSeconds = 0,
  });
  
  factory PuzzleContent.fromJson(Map<String, dynamic> json) {
    return PuzzleContent(
      type: PuzzleType.values.byName(json['type'] as String),
      items: (json['items'] as List)
          .map((i) => PuzzleItem.fromJson(i))
          .toList(),
      targets: (json['targets'] as List)
          .map((t) => PuzzleTarget.fromJson(t))
          .toList(),
      matching: Map<String, String>.from(json['matching'] as Map),
      timeLimitSeconds: json['timeLimitSeconds'] as int? ?? 0,
    );
  }
}

class PuzzleItem {
  final String id;
  final String type; // 'image', 'text', 'shape', 'number', 'letter'
  final String content; // asset path, text, or shape type
  final Color? color;
  final Offset startPosition;
  
  const PuzzleItem({
    required this.id,
    required this.type,
    required this.content,
    this.color,
    required this.startPosition,
  });
  
  factory PuzzleItem.fromJson(Map<String, dynamic> json) {
    return PuzzleItem(
      id: json['id'] as String,
      type: json['type'] as String,
      content: json['content'] as String,
      color: json['color'] != null 
          ? Color(int.parse(json['color'] as String, radix: 16))
          : null,
      startPosition: Offset(
        (json['startPosition']['x'] as num).toDouble(),
        (json['startPosition']['y'] as num).toDouble(),
      ),
    );
  }
}

class PuzzleTarget {
  final String id;
  final String type; // 'outline', 'slot', 'category'
  final String? expectedContent; // for validation
  final Offset position;
  final Size size;
  
  const PuzzleTarget({
    required this.id,
    required this.type,
    this.expectedContent,
    required this.position,
    required this.size,
  });
  
  factory PuzzleTarget.fromJson(Map<String, dynamic> json) {
    return PuzzleTarget(
      id: json['id'] as String,
      type: json['type'] as String,
      expectedContent: json['expectedContent'] as String?,
      position: Offset(
        (json['position']['x'] as num).toDouble(),
        (json['position']['y'] as num).toDouble(),
      ),
      size: Size(
        (json['size']['width'] as num).toDouble(),
        (json['size']['height'] as num).toDouble(),
      ),
    );
  }
}

// Draggable/Droppable Data for Stories
class DraggableItemData {
  final String id;
  final String type;
  final String content;
  final Color? color;
  final Offset position;
  
  const DraggableItemData({
    required this.id,
    required this.type,
    required this.content,
    this.color,
    required this.position,
  });
  
  factory DraggableItemData.fromJson(Map<String, dynamic> json) {
    return DraggableItemData(
      id: json['id'] as String,
      type: json['type'] as String,
      content: json['content'] as String,
      color: json['color'] != null 
          ? Color(int.parse(json['color'] as String, radix: 16))
          : null,
      position: Offset(
        (json['position']['x'] as num).toDouble(),
        (json['position']['y'] as num).toDouble(),
      ),
    );
  }
}

class DropTargetData {
  final String id;
  final String expectedItemId;
  final Offset position;
  final Size size;
  
  const DropTargetData({
    required this.id,
    required this.expectedItemId,
    required this.position,
    required this.size,
  });
  
  factory DropTargetData.fromJson(Map<String, dynamic> json) {
    return DropTargetData(
      id: json['id'] as String,
      expectedItemId: json['expectedItemId'] as String,
      position: Offset(
        (json['position']['x'] as num).toDouble(),
        (json['position']['y'] as num).toDouble(),
      ),
      size: Size(
        (json['size']['width'] as num).toDouble(),
        (json['size']['height'] as num).toDouble(),
      ),
    );
  }
}

// Rewards
class LevelRewards {
  final int stars;
  final String? stickerId;
  final String? unlockLevelId;
  
  const LevelRewards({
    required this.stars,
    this.stickerId,
    this.unlockLevelId,
  });
  
  factory LevelRewards.fromJson(Map<String, dynamic> json) {
    return LevelRewards(
      stars: json['stars'] as int,
      stickerId: json['sticker'] as String?,
      unlockLevelId: json['unlockLevel'] as String?,
    );
  }
}

// Sticker Model
class Sticker {
  final String id;
  final String name;
  final String nameAr;
  final String assetPath;
  final String category;
  final int unlockOrder;
  
  const Sticker({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.assetPath,
    required this.category,
    required this.unlockOrder,
  });
  
  String getLocalizedName(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return locale == 'ar' ? nameAr : name;
  }
  
  factory Sticker.fromJson(Map<String, dynamic> json) {
    return Sticker(
      id: json['id'] as String,
      name: json['name'] as String,
      nameAr: json['nameAr'] as String,
      assetPath: json['assetPath'] as String,
      category: json['category'] as String,
      unlockOrder: json['unlockOrder'] as int,
    );
  }
}

// Content Loader Service
class ContentLoader {
  static final Map<String, Level> _levels = {};
  static final Map<String, Sticker> _stickers = {};
  static bool _loaded = false;
  
  static Future<void> load() async {
    if (_loaded) return;
    
    // In production, load from assets/content/levels.json and stickers.json
    // For now, create default content
    _createDefaultContent();
    _loaded = true;
  }
  
  static void _createDefaultContent() {
    // Level 1: Story - Letters Introduction
    _levels['level_1'] = Level(
      id: 'level_1',
      title: 'First Letters',
      titleAr: 'الحروف الأولى',
      type: LevelType.story,
      order: 1,
      skills: [SkillTag.letters, SkillTag.fineMotor],
      isUnlockedByDefault: true,
      story: StoryContent(pages: [
        StoryPage(
          text: 'Welcome to the World of Letters!',
          textAr: 'أهلاً بك في عالم الحروف!',
          audioId: 'story_1_intro',
          interactiveElements: [
            InteractiveElement(
              id: 'balloon',
              type: 'both',
              animationAsset: 'assets/animations/balloon.flr',
              soundId: 'pop',
              position: const Offset(100, 200),
              size: const Size(80, 100),
            ),
          ],
        ),
        StoryPage(
          text: 'This is the letter Alif',
          textAr: 'هذا حرف الألف',
          audioId: 'story_1_alif',
          draggableItems: [
            DraggableItemData(
              id: 'alif_drag',
              type: 'letter',
              content: 'أ',
              position: const Offset(100, 400),
            ),
          ],
          dropTargets: [
            DropTargetData(
              id: 'alif_slot',
              expectedItemId: 'alif_drag',
              position: const Offset(300, 400),
              size: const Size(100, 100),
            ),
          ],
        ),
      ]),
      puzzle: null,
      rewards: const LevelRewards(stars: 3, stickerId: 'star_1', unlockLevelId: 'level_2'),
    );
    
    // Level 2: Puzzle - Number Matching
    _levels['level_2'] = Level(
      id: 'level_2',
      title: 'Fun Numbers',
      titleAr: 'الأرقام المرحة',
      type: LevelType.puzzle,
      order: 2,
      skills: [SkillTag.numbers, SkillTag.logic],
      story: null,
      puzzle: PuzzleContent(
        type: PuzzleType.numberSequence,
        items: [
          PuzzleItem(
            id: 'num_1',
            type: 'number',
            content: '1',
            color: Colors.red,
            startPosition: const Offset(50, 300),
          ),
          PuzzleItem(
            id: 'num_2',
            type: 'number',
            content: '2',
            color: Colors.blue,
            startPosition: const Offset(50, 420),
          ),
          PuzzleItem(
            id: 'num_3',
            type: 'number',
            content: '3',
            color: Colors.green,
            startPosition: const Offset(50, 540),
          ),
        ],
        targets: [
          PuzzleTarget(
            id: 'slot_1',
            type: 'slot',
            expectedContent: '1',
            position: const Offset(300, 200),
            size: const Size(100, 100),
          ),
          PuzzleTarget(
            id: 'slot_2',
            type: 'slot',
            expectedContent: '2',
            position: const Offset(300, 350),
            size: const Size(100, 100),
          ),
          PuzzleTarget(
            id: 'slot_3',
            type: 'slot',
            expectedContent: '3',
            position: const Offset(300, 500),
            size: const Size(100, 100),
          ),
        ],
        matching: {'num_1': 'slot_1', 'num_2': 'slot_2', 'num_3': 'slot_3'},
      ),
      rewards: const LevelRewards(stars: 2, stickerId: 'number_1', unlockLevelId: 'level_3'),
    );
    
    // Level 3: Story - Shapes
    _levels['level_3'] = Level(
      id: 'level_3',
      title: 'Shape Friends',
      titleAr: 'أصدقاء الأشكال',
      type: LevelType.story,
      order: 3,
      skills: [SkillTag.shapes, SkillTag.colors],
      story: StoryContent(pages: [
        StoryPage(
          text: 'Meet the shape friends!',
          textAr: 'تعرف على أصدقاء الأشكال!',
          audioId: 'story_3_intro',
          interactiveElements: [],
        ),
        StoryPage(
          text: 'Circle, Square, and Triangle want to play',
          textAr: 'الدائرة والمربع والمثلث يريدون اللعب',
          audioId: 'story_3_shapes',
          draggableItems: [
            DraggableItemData(
              id: 'circle',
              type: 'shape',
              content: 'circle',
              color: Colors.red,
              position: const Offset(80, 350),
            ),
            DraggableItemData(
              id: 'square',
              type: 'shape',
              content: 'square',
              color: Colors.blue,
              position: const Offset(200, 350),
            ),
            DraggableItemData(
              id: 'triangle',
              type: 'shape',
              content: 'triangle',
              color: Colors.yellow,
              position: const Offset(320, 350),
            ),
          ],
          dropTargets: [
            DropTargetData(
              id: 'circle_slot',
              expectedItemId: 'circle',
              position: const Offset(80, 500),
              size: const Size(100, 100),
            ),
            DropTargetData(
              id: 'square_slot',
              expectedItemId: 'square',
              position: const Offset(200, 500),
              size: const Size(100, 100),
            ),
            DropTargetData(
              id: 'triangle_slot',
              expectedItemId: 'triangle',
              position: const Offset(320, 500),
              size: const Size(100, 100),
            ),
          ],
        ),
      ]),
      puzzle: null,
      rewards: const LevelRewards(stars: 3, stickerId: 'shape_1', unlockLevelId: 'level_4'),
    );
    
    // Level 4: Puzzle - Animal Categories
    _levels['level_4'] = Level(
      id: 'level_4',
      title: 'Animal Homes',
      titleAr: 'بيوت الحيوانات',
      type: LevelType.puzzle,
      order: 4,
      skills: [SkillTag.animals, SkillTag.logic],
      story: null,
      puzzle: PuzzleContent(
        type: PuzzleType.categorySort,
        items: [
          PuzzleItem(
            id: 'lion',
            type: 'image',
            content: 'assets/images/stickers/lion.png',
            startPosition: const Offset(50, 200),
          ),
          PuzzleItem(
            id: 'elephant',
            type: 'image',
            content: 'assets/images/stickers/elephant.png',
            startPosition: const Offset(50, 320),
          ),
          PuzzleItem(
            id: 'fish',
            type: 'image',
            content: 'assets/images/stickers/fish.png',
            startPosition: const Offset(50, 440),
          ),
          PuzzleItem(
            id: 'bird',
            type: 'image',
            content: 'assets/images/stickers/bird.png',
            startPosition: const Offset(50, 560),
          ),
        ],
        targets: [
          PuzzleTarget(
            id: 'land',
            type: 'category',
            expectedContent: 'land',
            position: const Offset(300, 200),
            size: const Size(150, 150),
          ),
          PuzzleTarget(
            id: 'water',
            type: 'category',
            expectedContent: 'water',
            position: const Offset(300, 400),
            size: const Size(150, 150),
          ),
          PuzzleTarget(
            id: 'sky',
            type: 'category',
            expectedContent: 'sky',
            position: const Offset(300, 600),
            size: const Size(150, 150),
          ),
        ],
        matching: {
          'lion': 'land',
          'elephant': 'land',
          'fish': 'water',
          'bird': 'sky',
        },
      ),
      rewards: const LevelRewards(stars: 3, stickerId: 'animal_1', unlockLevelId: 'level_5'),
    );
    
    // Stickers
    _stickers['star_1'] = const Sticker(
      id: 'star_1',
      name: 'Golden Star',
      nameAr: 'نجمة ذهبية',
      assetPath: 'assets/images/stickers/star_gold.png',
      category: 'stars',
      unlockOrder: 1,
    );
    
    _stickers['number_1'] = const Sticker(
      id: 'number_1',
      name: 'Number Friends',
      nameAr: 'أصدقاء الأرقام',
      assetPath: 'assets/images/stickers/numbers.png',
      category: 'numbers',
      unlockOrder: 2,
    );
    
    _stickers['shape_1'] = const Sticker(
      id: 'shape_1',
      name: 'Shape Collector',
      nameAr: 'جامع الأشكال',
      assetPath: 'assets/images/stickers/shapes.png',
      category: 'shapes',
      unlockOrder: 3,
    );
    
    _stickers['animal_1'] = const Sticker(
      id: 'animal_1',
      name: 'Animal Lover',
      nameAr: 'محبة الحيوانات',
      assetPath: 'assets/images/stickers/animals.png',
      category: 'animals',
      unlockOrder: 4,
    );
  }
  
  static Level? getLevel(String id) => _levels[id];
  static List<Level> getAllLevels() => _levels.values.toList()..sort((a, b) => a.order.compareTo(b.order));
  static List<Level> getUnlockedLevels(Set<String> unlockedIds) {
    return _levels.values.where((l) => 
      l.isUnlockedByDefault || unlockedIds.contains(l.id)).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }
  static Level? getNextLevel(String currentId) {
    final levels = getAllLevels();
    final index = levels.indexWhere((l) => l.id == currentId);
    if (index >= 0 && index < levels.length - 1) {
      return levels[index + 1];
    }
    return null;
  }
  
  static Sticker? getSticker(String id) => _stickers[id];
  static List<Sticker> getAllStickers() => _stickers.values.toList()..sort((a, b) => a.unlockOrder.compareTo(b.unlockOrder));
}