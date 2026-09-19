# Project Instructions

## Tech Stack
- **Language**: Dart 3.3+
- **Framework**: Flutter 3.19+
- **State Management**: Provider 6.1+
- **Database**: Drift 2.35+ (SQLite, offline-first)
- **Localization**: easy_localization 3.0+ (AR/EN, RTL support)
- **Audio**: just_audio 0.9+ + audio_session 0.1+ (3 players: SFX, music, voice)
- **Animations**: flutter_animate 4.5+, confetti 0.8+
- **Secure Storage**: flutter_secure_storage 11.2+

## Code Style
- **File naming**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Private classes**: `_PascalCase`
- **Constants**: `lowerCamelCase` with descriptive prefixes (`sfxPickup`, `musicBackground`)
- **Line length**: 100 chars (formatter), 80 chars (linter warning)
- **Trailing commas**: Required (linter: `require_trailing_commas`)
- **Imports**: Relative for internal, package: for external
- **Null safety**: Strict (no `dynamic`, prefer explicit types)
- **Drift**: Generated code in `.g.dart` files (excluded from analysis)

## Testing
- **Run tests**: `make test` or `flutter test`
- **Test pattern**: `test/widget_test.dart` (mirrors `lib/` structure)
- **Coverage**: `flutter test --coverage`
- **Framework**: flutter_test
- **Naming**: `*_test.dart`

## Build & Run
- **Dev server**: `make run`
- **Build APK**: `make build-apk`
- **Build IPA** (macOS): `make build-ipa`
- **Lint**: `make analyze` (flutter analyze)
- **Format**: `make format` (dart format --line-length 100)
- **Codegen**: `make generate` (build_runner for Drift)
- **Watch**: `make watch` (continuous codegen)
- **Full check**: `make doctor` (analyze + test)

## Project Structure
```
lib/
├── main.dart                    # App entry, DI setup (Database, AudioManager, ParentalGateProvider)
├── core/                        # Shared infrastructure
│   ├── constants/               # AppConstants, AudioConstants, GameConstants
│   ├── theme/                   # AppTheme (Material 3, light/dark), colors, text_styles
│   ├── audio/                   # AudioManager (3 players, focus handling, preloading)
│   ├── storage/                 # AppDatabase (Drift), DAOs (Profile, Settings, LevelProgress, Sticker)
│   └── utils/
├── features/                    # Feature modules (self-contained)
│   ├── home/                    # HomeScreen: level list + sticker book tabs
│   ├── story_mode/              # StoryScreen: PageView + narration + drag-drop
│   ├── puzzle_mode/             # PuzzleScreen: timer + drag-drop (4 puzzle types)
│   ├── sticker_book/            # Collection viewer
│   ├── parental_gate/           # Math challenge, settings access
│   └── settings/                # User preferences
├── shared/                      # Cross-feature
│   ├── models/                  # Level, Story, Puzzle, Sticker, ContentLoader
│   └── widgets/
│       ├── drag_drop/           # DragDropEngine (DraggableItem, DropTarget, DragDropArea)
│       └── common/              # StarRating, AnimatedButton, AnimatedWidgets
└── l10n/                        # Localization delegates
```

## Conventions

### State Management
- **DI**: `Provider<AppDatabase>`, `Provider<AudioManager>` in `main.dart`
- **Reactive DB**: `Consumer<AppDatabase>` + `StreamBuilder` with DAO `.watch*()` streams
- **Local UI state**: `StatefulWidget` with `TickerProviderStateMixin` for animations
- **Parental gate**: `ChangeNotifierProvider<ParentalGateProvider>`

### Drag-Drop Engine (`lib/shared/widgets/drag_drop/drag_drop_engine.dart`)
- **Single-touch guard**: `_activePointer` prevents multi-finger drag
- **DraggableItem<T>**: Handles pan, snap (`easeOutBack` 300ms), return (`elasticOut` 400ms)
- **DropTarget<T>**: `DragTarget` with pulse animation + border glow on hover/match
- **DragDropArea<T>**: Orchestrates items/targets, callbacks `onMatch`/`onMismatch`/`onAllMatched`

### Audio (`lib/core/audio/audio_manager.dart`)
- **3 players**: `_sfxPlayer`, `_musicPlayer`, `_voicePlayer`
- **SFX**: Stops current before new (prevents overlap)
- **Music**: Loops, handles audio focus/ducking via `audio_session`
- **Voice**: Sequential, stops previous on new
- **Volume**: Separate SFX/music controls (0.0-1.0), voice always 1.0
- **Preload**: `preloadSfx()` / `preloadMusic()` for instant playback

### Localization
- **Files**: `assets/i18n/ar.json`, `assets/i18n/en.json`
- **Default**: Arabic (RTL), fallback to Arabic
- **Model helpers**: `getLocalizedTitle(context)`, `getLocalizedText(context)`
- **Context**: `context.locale`, `context.supportedLocales`

### Database (`lib/core/storage/database.dart`)
- **Tables**: `Profiles`, `Settings`, `LevelProgress`, `StickerCollection`
- **DAOs**: ProfileDao, SettingsDao, LevelProgressDao, StickerCollectionDao
- **Pattern**: Reactive streams (`watch*()`) + one-shot (`get*()`)
- **Schema version**: 1 (migration strategy in place)

### Theme (`lib/core/theme/app_theme.dart`)
- **Material 3**: Full `ColorScheme` for light/dark
- **Kid-friendly**: Rounded corners (16-24dp), min touch target 48dp
- **Fonts**: Cairo (UI), Amiri (Arabic content)
- **Component themes**: Buttons, cards, dialogs, nav bar, inputs, chips, etc.

### Content Models (`lib/shared/models/content_models.dart`)
- **Level**: id, title/titleAr, type (story/puzzle), order, skills[], story?, puzzle?, rewards, isUnlockedByDefault
- **StoryContent**: pages[] (StoryPage: text/textAr, audioId, interactiveElements[], draggableItems?, dropTargets?)
- **PuzzleContent**: type, items[], targets[], matching{}, timeLimitSeconds
- **ContentLoader**: In-memory registry with default levels + stickers (replace with JSON loading in prod)

## Git Workflow
- **Branches**: `feature/<desc>`, `fix/<desc>`, `chore/<desc>`
- **Commits**: Conventional (feat:, fix:, chore:, docs:)
- **PR**: Squash and merge
- **Version**: Update `pubspec.yaml` (`version: X.Y.Z+N`) + `CHANGELOG.md`

## Key Files to Know
| Purpose | File |
|---------|------|
| App bootstrap | `lib/main.dart` |
| Database schema | `lib/core/storage/database.dart` |
| Theme system | `lib/core/theme/app_theme.dart` |
| Audio manager | `lib/core/audio/audio_manager.dart` |
| Constants | `lib/core/constants/app_constants.dart` |
| Content models | `lib/shared/models/content_models.dart` |
| Drag-drop engine | `lib/shared/widgets/drag_drop/drag_drop_engine.dart` |
| Home screen | `lib/features/home/screens/home_screen.dart` |
| Story gameplay | `lib/features/story_mode/screens/story_screen.dart` |
| Puzzle gameplay | `lib/features/puzzle_mode/screens/puzzle_screen.dart` |
| Build commands | `Makefile` |