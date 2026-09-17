// Audio Manager - Single instance, prevents overlap, instant playback
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

class AudioManager {
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _voicePlayer = AudioPlayer();

  bool _initialized = false;
  double _sfxVolume = AppConstants.defaultSfxVolume;
  double _musicVolume = AppConstants.defaultMusicVolume;

  // Preloaded asset paths
  final Map<String, String> _sfxAssets = <String, String>{};
  final Map<String, String> _musicAssets = <String, String>{};
  final Map<String, String> _voiceAssets = <String, String>{};

  // Track currently playing SFX to prevent overlap
  String? _currentSfxId;

  AudioManager();

  Future<void> initialize() async {
    if (_initialized) return;

    // Configure audio session for game-like behavior
    final AudioSession session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.ambient,
      avAudioSessionCategoryOptions: <AVAudioSessionCategoryOptions>[
        AVAudioSessionCategoryOptions.mixWithOthers,
        AVAudioSessionCategoryOptions.allowBluetooth,
      ],
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
    ));

    // Set up players
    await _sfxPlayer.setVolume(_sfxVolume);
    await _musicPlayer.setVolume(_musicVolume);
    await _musicPlayer.setLoopMode(LoopMode.all);
    await _voicePlayer.setVolume(1.0); // Voice always at full volume

    // Handle audio focus
    _setupAudioFocus(session);

    _initialized = true;
    debugPrint('AudioManager initialized');
  }

  void _setupAudioFocus(AudioSession session) {
    session.becomingNoisyEventStream.listen((_) {
      pauseMusic();
      pauseVoice();
    });

    session.interruptionEventStream.listen((AudioInterruptionEvent event) {
      if (event.begin) {
        if (event.type == AudioInterruptionType.ducked) {
          unawaited(_musicPlayer.setVolume(_musicVolume * 0.2));
        } else {
          unawaited(pauseMusic());
          unawaited(pauseVoice());
        }
      } else {
        unawaited(_musicPlayer.setVolume(_musicVolume));
      }
    });
  }

  // SFX - Instant playback, prevents overlap
  Future<void> playSfx(String id) async {
    if (!_initialized) await initialize();

    // Stop current SFX if different (prevents overlap per PRD §5)
    if (_currentSfxId != null && _currentSfxId != id) {
      await _sfxPlayer.stop();
    }

    _currentSfxId = id;

    try {
      final String assetPath = _getSfxAssetPath(id);
      await _sfxPlayer.setAsset(assetPath);
      await _sfxPlayer.play();
    } catch (e) {
      debugPrint('Error playing SFX $id: $e');
    }
  }

  Future<void> stopSfx() async {
    await _sfxPlayer.stop();
    _currentSfxId = null;
  }

  // Music - Background loop
  Future<void> playMusic(String id) async {
    if (!_initialized) await initialize();

    try {
      final String assetPath = _getMusicAssetPath(id);
      await _musicPlayer.setAsset(assetPath);
      await _musicPlayer.play();
    } catch (e) {
      debugPrint('Error playing music $id: $e');
    }
  }

  Future<void> pauseMusic() async {
    await _musicPlayer.pause();
  }

  Future<void> resumeMusic() async {
    if (_musicPlayer.playing) return;
    await _musicPlayer.play();
  }

  Future<void> stopMusic() async {
    await _musicPlayer.stop();
  }

  // Voice/Narration - Sequential, no overlap with itself
  Future<void> playVoice(String id) async {
    if (!_initialized) await initialize();

    // Stop any current voice
    await _voicePlayer.stop();

    try {
      final String assetPath = _getVoiceAssetPath(id);
      await _voicePlayer.setAsset(assetPath);
      await _voicePlayer.play();
    } catch (e) {
      debugPrint('Error playing voice $id: $e');
    }
  }

  Future<void> pauseVoice() async {
    await _voicePlayer.pause();
  }

  Future<void> stopVoice() async {
    await _voicePlayer.stop();
  }

  Future<void> stopAll() async {
    await Future.wait([
      _sfxPlayer.stop(),
      _musicPlayer.stop(),
      _voicePlayer.stop(),
    ]);
    _currentSfxId = null;
  }

  // Volume Controls
  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
    _sfxPlayer.setVolume(_sfxVolume);
  }

  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
    _musicPlayer.setVolume(_musicVolume);
  }

  double get sfxVolume => _sfxVolume;
  double get musicVolume => _musicVolume;

  // Asset Path Resolution
  String _getSfxAssetPath(String id) {
    return _sfxAssets[id] ?? 'assets/audio/sfx/$id.ogg';
  }

  String _getMusicAssetPath(String id) {
    return _musicAssets[id] ?? 'assets/audio/music/$id.ogg';
  }

  String _getVoiceAssetPath(String id) {
    return _voiceAssets[id] ?? 'assets/audio/voice/$id.ogg';
  }

  // Preload assets for instant playback
  Future<void> preloadSfx(List<String> ids) async {
    for (final String id in ids) {
      try {
        await _sfxPlayer.setAsset(_getSfxAssetPath(id));
        await _sfxPlayer.load();
      } catch (e) {
        debugPrint('Failed to preload SFX $id: $e');
      }
    }
  }

  Future<void> preloadMusic(List<String> ids) async {
    for (final String id in ids) {
      try {
        await _musicPlayer.setAsset(_getMusicAssetPath(id));
        await _musicPlayer.load();
      } catch (e) {
        debugPrint('Failed to preload music $id: $e');
      }
    }
  }

  // Stream getters for UI reactivity
  Stream<PlayerState> get sfxStateStream => _sfxPlayer.playerStateStream;
  Stream<PlayerState> get musicStateStream => _musicPlayer.playerStateStream;
  Stream<PlayerState> get voiceStateStream => _voicePlayer.playerStateStream;

  bool get isMusicPlaying => _musicPlayer.playing;
  bool get isVoicePlaying => _voicePlayer.playing;

  // Cleanup
  Future<void> dispose() async {
    await Future.wait([
      _sfxPlayer.dispose(),
      _musicPlayer.dispose(),
      _voicePlayer.dispose(),
    ]);
    _initialized = false;
  }
}

// Convenience extension for common game sounds
extension GameAudio on AudioManager {
  // Drag & Drop sounds
  Future<void> playPickup() => playSfx(AudioConstants.sfxPickup);
  Future<void> playSnap() => playSfx(AudioConstants.sfxSnap);
  Future<void> playReturn() => playSfx(AudioConstants.sfxReturn);

  // UI sounds
  Future<void> playTap() => playSfx(AudioConstants.sfxTap);
  Future<void> playButton() => playSfx(AudioConstants.sfxButton);
  Future<void> playError() => playSfx(AudioConstants.sfxError);

  // Reward sounds
  Future<void> playStar() => playSfx(AudioConstants.sfxStar);
  Future<void> playSticker() => playSfx(AudioConstants.sfxSticker);
  Future<void> playLevelComplete() => playSfx(AudioConstants.sfxLevelComplete);
  Future<void> playCelebration() => playSfx(AudioConstants.sfxCelebration);

  // Music
  Future<void> playBackgroundMusic() => playMusic(AudioConstants.musicBackground);
  Future<void> playStoryMusic() => playMusic(AudioConstants.musicStory);
  Future<void> playPuzzleMusic() => playMusic(AudioConstants.musicPuzzle);

  // Voice
  Future<void> playVoiceLine(String lineId) => playVoice('${AudioConstants.voicePrefix}$lineId');
}