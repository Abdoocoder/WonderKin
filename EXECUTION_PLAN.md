# Execution Plan: عالم المغامرات الذكي (Interactive Story & Puzzle Kids App)

**Project Type:** New Flutter Application (Offline-First, Ages 4-7)
**Target Platforms:** iOS / Android (phones & tablets)
**Language:** Arabic-first, RTL support
**Architecture:** Feature-based, Provider + Local Storage (Drift/SQLite)

---

## Phase 0: Project Setup & Foundation (Week 1)

### 0.1 Initialize Flutter Project
- [ ] `flutter create kids_adventure_app --org com.kidsadventure --project-name kids_adventure_app`
- [ ] Configure `pubspec.yaml` with dependencies
- [ ] Set up `analysis_options.yaml` (strict linting)
- [ ] Configure `easy_localization` for AR/EN (Arabic default)
- [ ] Add Cairo font (already in Fajrak assets) + child-friendly font option
- [ ] Set up RTL support via `easy_localization`

### 0.2 Core Dependencies (pubspec.yaml)
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  # Local DB (Offline-first)
  drift: ^2.18.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.1.5
  path: ^1.9.0
  # State Management
  provider: ^6.1.1
  # Audio
  just_audio: ^0.9.36
  audio_session: ^0.1.18
  # Assets & Animations
  flare_flutter: ^3.0.0  # or rive for interactive animations
  confetti: ^0.8.0  # celebrations
  # Utils
  uuid: ^4.5.3
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^11.0.0  # parental gate settings
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  drift_dev: ^2.18.0
  build_runner: ^2.4.0
  flutter_launcher_icons: ^0.14.4
```

### 0.3 Project Structure
```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   ├── audio_constants.dart
│   │   └── game_constants.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── colors.dart
│   │   └── text_styles.dart
│   ├── audio/
│   │   ├── audio_manager.dart
│   │   └── sound_effects.dart
│   ├── storage/
│   │   ├── database.dart
│   │   ├── tables/
│   │   │   ├── profile_table.dart
│   │   │   ├── level_progress_table.dart
│   │   │   ├── settings_table.dart
│   │   │   └── sticker_collection_table.dart
│   │   └── dao/
│   │       ├── profile_dao.dart
│   │       ├── progress_dao.dart
│   │       └── settings_dao.dart
│   └── utils/
│       ├── drag_drop_utils.dart
│       ├── math_utils.dart
│       └── parental_gate.dart
├── features/
│   ├── onboarding/
│   ├── home/
│   ├── story_mode/
│   │   ├── widgets/
│   │   ├── screens/
│   │   ├── models/
│   │   └── providers/
│   ├── puzzle_mode/
│   │   ├── widgets/
│   │   ├── screens/
│   │   ├── models/
│   │   └── providers/
│   ├── sticker_book/
│   ├── parental_gate/
│   └── settings/
├── shared/
│   ├── widgets/
│   │   ├── drag_drop/
│   │   │   ├── draggable_item.dart
│   │   │   ├── drop_target.dart
│   │   │   └── drag_drop_area.dart
│   │   ├── common/
│   │   │   ├── animated_button.dart
│   │   │   ├── star_rating.dart
│   │   │   └── progress_indicator.dart
│   │   └── audio/
│   │       ├── audio_button.dart
│   │       └── speaking_text.dart
│   └── models/
│       ├── level.dart
│       ├── story.dart
│       ├── puzzle.dart
│       └── sticker.dart
└── l10n/
    ├── ar.json
    └── en.json
```

---

## Phase 1: Core Infrastructure (Week 1-2)

### 1.1 Local Database (Drift) - **Critical Path**
**Files:** `lib/core/storage/database.dart`, tables, DAOs

**Schema Implementation:**
```sql
-- Profile Table
CREATE TABLE profile (
  id TEXT PRIMARY KEY,
  child_name TEXT NOT NULL,
  total_stars INTEGER DEFAULT 0,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- Settings Table
CREATE TABLE settings (
  id INTEGER PRIMARY KEY CHECK (id = 1),  -- singleton
  daily_limit_minutes INTEGER DEFAULT 30,
  sound_volume REAL DEFAULT 1.0,
  music_volume REAL DEFAULT 0.7,
  parental_gate_enabled INTEGER DEFAULT 1,
  last_reset_date INTEGER
);

-- Level Progress Table
CREATE TABLE level_progress (
  id TEXT PRIMARY KEY,  -- levelId
  level_id TEXT NOT NULL,
  stars_earned INTEGER DEFAULT 0,
  is_completed INTEGER DEFAULT 0,
  completed_at INTEGER,
  attempts INTEGER DEFAULT 0,
  best_time_ms INTEGER,
  UNIQUE(level_id)
);

-- Sticker Collection Table
CREATE TABLE sticker_collection (
  id TEXT PRIMARY KEY,  -- stickerId
  sticker_id TEXT NOT NULL,
  unlocked_at INTEGER NOT NULL,
  UNIQUE(sticker_id)
);
```

**DAOs with reactive streams:**
- `ProfileDao.watchProfile()` → Stream<Profile>
- `ProgressDao.watchLevelProgress(levelId)` → Stream<LevelProgress>
- `SettingsDao.watchSettings()` → Stream<Settings>

### 1.2 Audio Manager - **Critical Path**
**File:** `lib/core/audio/audio_manager.dart`

**Requirements:**
- Single audio instance (prevent overlap per PRD §5)
- Preload all SFX at startup
- Background music loop with volume control
- Instant playback (<100ms response)
- Methods: `playSfx(String id)`, `playMusic(String id)`, `stopAll()`, `setSfxVolume(double)`, `setMusicVolume(double)`

### 1.3 Drag & Drop Engine - **Critical Path**
**Files:** `lib/shared/widgets/drag_drop/`

**Core Components:**
1. `DraggableItem` - wraps child, handles drag start/end, returns to origin on failed drop
2. `DropTarget` - defines target area, validates match, triggers snap animation
3. `DragDropArea` - orchestrates multiple items/targets, handles single-touch guard

**Key Behaviors (PRD §4.1, §5):**
- Snap-to-target with spring animation (~300ms)
- Return-to-origin with elastic animation (~400ms) on wrong drop
- **Single-touch guard**: Ignore secondary pointers during drag
- Haptic feedback on snap/return
- Audio cues: "pop" on pick, "click" on snap, "bounce" on return

### 1.4 Parental Gate
**File:** `lib/core/utils/parental_gate.dart`, `lib/features/parental_gate/`

**Implementation:**
- Dynamic math question: `a + b = ?` where a,b ∈ [1,9], changes each attempt
- 3 attempts before lockout (30s cooldown)
- Stored in `flutter_secure_storage` (not SharedPreferences)
- Gate screen: Large numbers, voice reads question, numpad input

---

## Phase 2: Content Models & Data (Week 2)

### 2.1 Content Definitions (JSON Assets)
**Files:** `assets/content/`

```json
// levels.json
{
  "levels": [
    {
      "id": "level_1",
      "title": "الحروف الأولى",
      "type": "story",
      "order": 1,
      "story": {
        "pages": [
          {"text": "أهلاً بك في عالم الحروف!", "audio": "intro.mp3", "interactiveElements": ["balloon", "star"]},
          {"text": "هذا حرف الألف", "audio": "alif.mp3", "draggableItems": ["alif"], "targets": ["alif_slot"]}
        ]
      },
      "puzzle": null,
      "rewards": {"stars": 3, "sticker": "star_sticker_1"}
    },
    {
      "id": "level_2",
      "title": "الأرقام المرحة",
      "type": "puzzle",
      "order": 2,
      "puzzle": {
        "items": ["1", "2", "3"],
        "targets": ["slot_1", "slot_2", "slot_3"],
        "matching": {"1": "slot_1", "2": "slot_2", "3": "slot_3"}
      },
      "rewards": {"stars": 2, "sticker": "number_sticker_1"}
    }
  ]
}
```

### 2.2 Content Loader Service
**File:** `lib/core/services/content_loader.dart`
- Loads JSON at startup, caches in memory
- Provides `getLevel(id)`, `getNextLevel(currentId)`, `getUnlockedLevels(profile)`

---

## Phase 3: Story Mode (Week 3-4)

### 3.1 Story Screen & Page View
**Files:** `lib/features/story_mode/screens/story_screen.dart`, `story_page.dart`

**Features:**
- PageView with swipe navigation (disabled for kids - use arrows)
- Auto-advance after narration completes (optional)
- Tap-to-animate elements on each page
- Word highlighting during narration (sync with audio timestamps)

### 3.2 Interactive Story Elements
- `TapToAnimate` widget: plays sound + animation on tap
- `SpeakingText` widget: highlights words as audio plays
- `StoryNarrator`: manages audio queue, auto-advance logic

### 3.3 Drag & Drop in Stories
- Embedded `DragDropArea` within story pages
- Completion triggers star animation + level unlock

---

## Phase 4: Puzzle Mode (Week 4-5)

### 4.1 Puzzle Screen
**Files:** `lib/features/puzzle_mode/screens/puzzle_screen.dart`

**Features:**
- Grid of draggable items + target slots
- Multiple puzzle types: match shape, match letter, match number, sequence
- Progressive difficulty within level
- Instant feedback (visual + audio)

### 4.2 Puzzle Types
1. **Shape Matching** - Drag shapes to outlines
2. **Letter Matching** - Drag letters to same letter slots
3. **Number Sequencing** - Drag numbers in order
4. **Category Sorting** - Drag items to category bins (animals, fruits, etc.)

---

## Phase 5: Gamification & Progression (Week 5-6)

### 5.1 Star System
- 3 stars per level based on: completion (1), no mistakes (1), speed (1)
- Persisted in `level_progress` table
- Visual: `StarRating` widget with animated fill

### 5.2 Level Unlocking
- Sequential unlock: complete level N → unlock N+1
- Replay unlocked levels anytime
- "Next Level" button appears after completion

### 5.3 Sticker Book
**Files:** `lib/features/sticker_book/`
- Grid of sticker slots (locked/unlocked)
- Tap unlocked sticker → full screen view with celebration animation
- Confetti on new unlock
- Persisted in `sticker_collection` table

---

## Phase 6: Parental Dashboard (Week 6)

### 6.1 Parental Gate Screen
- Math challenge entry
- Settings access after success

### 6.2 Settings Screen
- Screen time limit: 15/30/45 min picker
- Volume sliders (SFX, Music)
- Language toggle (AR/EN)
- Reset progress (with confirmation)
- View reports

### 6.3 Progress Report
- Total stars earned
- Levels completed / total
- Skills acquired (derived from level tags)
- Daily/weekly play time (from timestamps)

### 6.4 Screen Time Enforcement
- Background timer (survives app background)
- "Rest Time" overlay when limit reached
- Auto-pause game, show friendly message
- Resume next day or after parent extends

---

## Phase 7: Polish & Edge Cases (Week 7)

### 7.1 Edge Case Handling (PRD §5)
- [ ] Multi-touch guard (implemented in DragDropArea)
- [ ] Audio overlap prevention (AudioManager single-instance)
- [ ] Instant progress save (DAOs write on every star/sticker/level)
- [ ] Offline-first verified (no network calls in core loop)

### 7.2 Performance
- [ ] Preload all assets at splash
- [ ] Image compression (WebP, appropriate sizes)
- [ ] Audio format: OGG for Android, M4A for iOS
- [ ] Target <100ms touch response
- [ ] App size <100MB initial download

### 7.3 Accessibility & UX
- [ ] Large touch targets (min 48dp)
- [ ] High contrast mode support
- [ ] VoiceOver/TalkBack labels
- [ ] No text-only instructions (visual + audio)
- [ ] RTL layout verified

### 7.4 Polish
- [ ] Splash screen with app logo
- [ ] Level transition animations
- [ ] Celebration sequences (stars, confetti, sound)
- [ ] Error states (friendly, non-text)
- [ ] App icon & store assets

---

## Phase 8: Testing & Release (Week 8)

### 8.1 Testing
- [ ] Unit tests: DAOs, AudioManager, ParentalGate, ContentLoader
- [ ] Widget tests: DragDropArea, StoryPage, PuzzleScreen
- [ ] Integration tests: Full level flow, parental gate, screen time
- [ ] Manual testing: Multiple devices (phone/tablet), orientations

### 8.2 Build & Release
- [ ] `flutter build apk --release` / `flutter build ipa --release`
- [ ] App Store Connect / Play Console setup
- [ ] Privacy policy (no data collection, offline-first)
- [ ] Age rating: 4+ / Everyone

---

## Dependency Graph & Critical Path

```
Phase 0 (Setup)
    ↓
Phase 1.1 (Database) ←──┐
Phase 1.2 (Audio)  ←───┤  Can parallelize
Phase 1.3 (DragDrop) ←─┤
Phase 1.4 (Gate)   ←───┘
    ↓
Phase 2 (Content Models) ←── Depends on DB
    ↓
Phase 3 (Story Mode) ←────── Depends on DragDrop, Audio, Content
Phase 4 (Puzzle Mode) ←───── Depends on DragDrop, Audio, Content
    ↓
Phase 5 (Gamification) ←──── Depends on DB, Story, Puzzle
    ↓
Phase 6 (Parental) ←──────── Depends on Gate, DB
    ↓
Phase 7 (Polish) ←────────── All features
    ↓
Phase 8 (Release)
```

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Drag & drop performance on low-end devices | Test on Android Go devices; simplify animations if needed |
| Audio latency | Preload all sounds; use `just_audio` with `AudioSession` |
| App size | Compress assets; use deferred components for later levels |
| Parental gate bypass | Secure storage + server-time check (if online) |
| Data loss | Drift transactions + immediate writes on progress |

---

## Success Metrics (Post-Launch)

- **Retention**: Day 1 > 40%, Day 7 > 20%
- **Session length**: Avg 15-20 min (matches screen time limits)
- **Completion rate**: >60% of started levels finished
- **Parental gate effectiveness**: <1% unauthorized access
- **Crash-free sessions**: >99.5%

---

## Notes for Implementation

1. **Arabic-first**: All UI text in `ar.json` first, `en.json` as translation
2. **No external dependencies** in core gameplay loop (offline-first)
3. **Single-touch** is non-negotiable for drag-drop (kids use palms)
4. **Audio is core UX** - invest in quality SFX/music
5. **Sticker book** is the long-term retention hook - make it delightful
6. **Screen time** must be tamper-proof (persist end-time, not just duration)