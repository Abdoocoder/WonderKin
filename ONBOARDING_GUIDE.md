# Onboarding Guide: Kids Adventure App

## Overview
An interactive educational app for children ages 4-7 that combines illustrated stories with drag-and-drop puzzles to develop language, logic, and fine motor skills. Built with Flutter for iOS and Android, fully offline with no ads, no in-app purchases, and no data collection.

## Tech Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| Language | Dart | 3.3+ |
| Framework | Flutter | 3.19+ |
| State Management | Provider | 6.1+ |
| Database | Drift (SQLite) | 2.35+ |
| Localization | easy_localization | 3.0+ |
| Audio | just_audio + audio_session | 0.9+ / 0.1+ |
| Animations | flutter_animate | 4.5+ |
| Confetti Effects | confetti | 0.8+ |
| Secure Storage | flutter_secure_storage | 11.2+ |
| Linting | flutter_lints | 6.0+ |

## Architecture

**Pattern**: Feature-first layered architecture with offline-first data flow

```
lib/
├── main.dart                    # App entry point, DI setup
├── core/                        # Shared infrastructure
│   ├── constants/               # App-wide constants
│   ├── theme/                   # Material 3 theming (light/dark)
│   ├── audio/                   # AudioManager (3 players: SFX, music, voice)
│   ├── storage/                 # Drift database + DAOs
│   └── utils/                   # Helper utilities
├── features/                    # Feature modules (self-contained)
│   ├── home/                    # Main hub: levels + sticker book
│   ├── story_mode/              # Interactive stories with narration
│   ├── puzzle_mode/             # Drag-drop puzzles (4 types)
│   ├── sticker_book/            # Collection viewer
│   ├── parental_gate/           # Math challenge + settings
│   └── settings/                # User preferences
├── shared/                      # Cross-feature components
│   ├── models/                  # Content models (Level, Story, Puzzle, Sticker)
│   └── widgets/                 # Reusable UI components
│       ├── drag_drop/           # Custom drag-drop engine
│       └── common/              # Stars, buttons, animated widgets
└── l10n/                        # Localization delegates
```

## Key Entry Points

| Purpose | Location |
|---------|----------|
| App bootstrap & DI | `lib/main.dart` |
| Database schema & DAOs | `lib/core/storage/database.dart` |
| Theme system | `lib/core/theme/app_theme.dart` |
| Audio management | `lib/core/audio/audio_manager.dart` |
| Content definitions | `lib/shared/models/content_models.dart` |
| Home screen (hub) | `lib/features/home/screens/home_screen.dart` |
| Story gameplay | `lib/features/story_mode/screens/story_screen.dart` |
| Puzzle gameplay | `lib/features/puzzle_mode/screens/puzzle_screen.dart` |
| Drag-drop engine | `lib/shared/widgets/drag_drop/drag_drop_engine.dart` |
| Build commands | `Makefile` |

## Request Lifecycle

**Story Mode Flow:**
1. User taps level card → `HomeScreen._navigateToLevel()`
2. `StoryScreen` loads `StoryContent` from `ContentLoader`
3. `PageView` renders pages with `_StoryPageView`
4. Each page: narration audio → interactive elements → drag-drop area
5. Drag-drop handled by `DragDropArea<DraggableItemData>` (engine)
6. On match: `onItemMatched` → `_onItemMatched()` → check page complete
7. Page complete → auto-advance or level complete
8. Level complete → `LevelProgressDao.completeLevel()` → stars + sticker unlock

**Puzzle Mode Flow:**
1. Similar entry via `HomeScreen._navigateToLevel()`
2. `PuzzleScreen` loads `PuzzleContent` 
3. `DragDropArea<PuzzleItem>` manages items/targets
4. Timer runs if `timeLimitSeconds > 0`
5. Complete → stars calculated (completion + no mistakes + speed) → saved

## Data Flow (Database)

```
User Action
    │
    ▼
Provider.of<AppDatabase>() / Provider.of<AudioManager>()
    │
    ├──▶ AudioManager.playSfx()/playMusic()/playVoice()  ──▶ just_audio players
    │
    └──▶ DAO methods (ProfileDao, SettingsDao, LevelProgressDao, StickerCollectionDao)
              │
              ▼
         Drift Database (SQLite)
              │
              ├──▶ profiles: childName, totalStars
              ├──▶ settings: dailyLimit, volumes, parentalGate, lastResetDate
              ├──▶ level_progress: levelId, starsEarned, isCompleted, attempts, bestTimeMs
              └──▶ sticker_collection: stickerId, unlockedAt
```

## Conventions

**Naming:**
- Files: `snake_case.dart` (e.g., `story_screen.dart`, `drag_drop_engine.dart`)
- Classes: `PascalCase` (e.g., `StoryScreen`, `AudioManager`)
- Private classes: `_PascalCase` (e.g., `_StoryScreenState`, `_DraggableItemState`)
- Constants: `lowerCamelCase` with descriptive prefixes (e.g., `sfxPickup`, `musicBackground`)

**State Management:**
- `Provider` for DI (database, audio manager)
- `ChangeNotifierProvider` for `ParentalGateProvider`
- `Consumer` + `StreamBuilder` for reactive DB queries
- Local `StatefulWidget` state for UI animations/controllers

**Drag-Drop Engine Patterns:**
- `DraggableItem<T>` with single-touch guard (`_activePointer`)
- `DropTarget<T>` with `DragTarget` + visual feedback (pulse, border glow)
- `DragDropArea<T>` orchestrates items/targets, handles match/mismatch callbacks
- Snap animation: `Curves.easeOutBack` (300ms)
- Return animation: `Curves.elasticOut` (400ms)

**Audio:**
- Three separate `AudioPlayer` instances (SFX, music, voice)
- SFX: prevents overlap (stops current before new)
- Music: loops, handles audio focus/ducking
- Voice: sequential, stops previous on new

**Localization:**
- Arabic (RTL, default) + English
- JSON files in `assets/i18n/{ar,en}.json`
- `getLocalizedTitle()` / `getLocalizedText()` pattern on models
- `easy_localization` with `context.locale`

**Testing:**
- `flutter_test` framework
- Test file: `test/widget_test.dart`
- Run: `make test` or `flutter test`
- Coverage: `flutter test --coverage`

## Common Tasks

| Task | Command |
|------|---------|
| Install deps | `make get-deps` |
| Generate icons | `make icons` |
| Run dev | `make run` |
| Run on device | `make run-device DEVICE=<id>` |
| Analyze code | `make analyze` |
| Run tests | `make test` |
| Test with coverage | `flutter test --coverage` |
| Format code | `make format` |
| Generate code (Drift) | `make generate` |
| Watch codegen | `make watch` |
| Build APK | `make build-apk` |
| Build IPA (macOS) | `make build-ipa` |
| Full health check | `make doctor` |
| Check outdated | `make outdated` |
| Upgrade packages | `make upgrade` |
| Clean build | `make clean` |

## Where to Look

| I want to... | Look at... |
|--------------|-----------|
| Add a new story level | `lib/shared/models/content_models.dart` → `ContentLoader._createDefaultContent()` |
| Add a new puzzle type | `lib/core/constants/app_constants.dart` (PuzzleType enum) + `lib/features/puzzle_mode/screens/puzzle_screen.dart` |
| Modify drag-drop behavior | `lib/shared/widgets/drag_drop/drag_drop_engine.dart` |
| Change theme/colors | `lib/core/theme/colors.dart` + `lib/core/theme/app_theme.dart` |
| Add audio assets | `lib/core/audio/audio_manager.dart` (AudioConstants) + add `.ogg` files to `assets/audio/` |
| Adjust screen time limits | `lib/core/constants/app_constants.dart` (screenTimeOptions) |
| Modify parental gate | `lib/features/parental_gate/parental_gate.dart` |
| Add translation keys | `assets/i18n/ar.json` + `assets/i18n/en.json` |
| Change star thresholds | `lib/core/constants/app_constants.dart` (starsForCompletion, etc.) |
| Add sticker | `lib/shared/models/content_models.dart` (Sticker model + ContentLoader) |
| Modify level unlock logic | `lib/shared/models/content_models.dart` (ContentLoader.getUnlockedLevels) |

## Key Design Decisions

1. **Offline-first**: All content embedded, Drift/SQLite for progress — no network required
2. **Single-touch drag**: Prevents multi-finger confusion for young children (`_activePointer` guard)
3. **Three audio players**: Isolated SFX/music/voice with overlap prevention per type
4. **Material 3 + custom kid theme**: Rounded corners (16-24dp), large touch targets (48dp min), warm colors
5. **RTL-first**: Arabic default, full RTL support in layouts and text
6. **Level progression**: Sequential unlock via `unlockLevelId` in rewards
7. **Star system**: 3 stars max (completion + no mistakes + speed bonus)
8. **Parental gate**: Dynamic math challenge (a+b, a,b∈[1,9]), 3 attempts, 30s lockout

## Git Conventions

- Branch naming: `feature/<desc>`, `fix/<desc>`, `chore/<desc>`
- Commits: Conventional commits style (feat:, fix:, chore:, docs:)
- PR workflow: Squash and merge (default from GitHub settings)