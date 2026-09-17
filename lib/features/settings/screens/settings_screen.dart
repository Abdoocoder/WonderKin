// Settings Screen - Parental settings after gate
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/audio/audio_manager.dart';
import '../../core/storage/database.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/common/animated_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late int _selectedScreenTime;
  late double _sfxVolume;
  late double _musicVolume;
  late bool _parentalGateEnabled;
  String _selectedLanguage = 'ar';
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final db = context.read<AppDatabase>();
    final settings = await db.settingsDao.getSettings();
    
    setState(() {
      _selectedScreenTime = settings.dailyLimitMinutes;
      _sfxVolume = settings.soundVolume;
      _musicVolume = settings.musicVolume;
      _parentalGateEnabled = settings.parentalGateEnabled;
    });
    
    final locale = context.locale;
    _selectedLanguage = locale.languageCode;
  }
  
  Future<void> _saveSettings() async {
    final db = context.read<AppDatabase>();
    final audioManager = context.read<AudioManager>();
    
    await db.settingsDao.updateSettings(
      dailyLimitMinutes: _selectedScreenTime,
      soundVolume: _sfxVolume,
      musicVolume: _musicVolume,
      parentalGateEnabled: _parentalGateEnabled,
    );
    
    audioManager.setSfxVolume(_sfxVolume);
    audioManager.setMusicVolume(_musicVolume);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('settings_saved'.tr()),
          backgroundColor: Theme.of(context).colorScheme.success,
        ),
      );
    }
  }
  
  Future<void> _resetProgress() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('reset_progress_title'.tr()),
        content: Text('reset_progress_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('common_no'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text('common_yes'.tr()),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final db = context.read<AppDatabase>();
      
      // Delete all progress data
      await db.delete(db.levelProgress).go();
      await db.delete(db.stickerCollection).go();
      await db.update(db.profiles).write(ProfilesCompanion(
        totalStars: const Value(0),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ));
      
      // Reset screen time
      await db.settingsDao.updateSettings(lastResetDate: DateTime.now().millisecondsSinceEpoch);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('reset_progress_done'.tr()),
            backgroundColor: Theme.of(context).colorScheme.success,
          ),
        );
        Navigator.pop(context); // Return to home
      }
    }
  }
  
  void _changeLanguage(String languageCode) async {
    setState(() => _selectedLanguage = languageCode);
    await context.setLocale(Locale(languageCode));
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('settings_title'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Screen Time Section
          _buildSectionHeader('settings_screen_time'.tr(), Icons.schedule_rounded),
          const SizedBox(height: 12),
          _buildScreenTimeSelector(theme),
          
          const SizedBox(height: 24),
          
          // Audio Section
          _buildSectionHeader('settings_audio'.tr(), Icons.volume_up_rounded),
          const SizedBox(height: 12),
          _buildVolumeSlider(
            'settings_sound_volume'.tr(),
            _sfxVolume,
            (value) => setState(() => _sfxVolume = value),
            Icons.graphic_eq_rounded,
          ),
          const SizedBox(height: 12),
          _buildVolumeSlider(
            'settings_music_volume'.tr(),
            _musicVolume,
            (value) => setState(() => _musicVolume = value),
            Icons.music_note_rounded,
          ),
          
          const SizedBox(height: 24),
          
          // Language Section
          _buildSectionHeader('settings_language'.tr(), Icons.language_rounded),
          const SizedBox(height: 12),
          _buildLanguageSelector(theme),
          
          const SizedBox(height: 24),
          
          // Parental Gate Section
          _buildSectionHeader('settings_parental_gate'.tr(), Icons.security_rounded),
          const SizedBox(height: 12),
          _buildParentalGateToggle(theme),
          
          const SizedBox(height: 24),
          
          // Danger Zone
          _buildSectionHeader('settings_danger_zone'.tr(), Icons.warning_amber_rounded),
          const SizedBox(height: 12),
          _buildDangerZone(theme),
          
          const SizedBox(height: 24),
          
          // Save Button
          AnimatedButton(
            onPressed: _saveSettings,
            child: Text('common_save'.tr()),
          ).animate().fadeIn().slideY(begin: 0.2),
          
          const SizedBox(height: 16),
          
          // App Info
          _buildAppInfo(theme),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title, IconData icon) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
  
  Widget _buildScreenTimeSelector(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'settings_screen_time_desc'.tr(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: AppConstants.screenTimeOptions.map((minutes) {
              final selected = _selectedScreenTime == minutes;
              return ChoiceChip(
                label: Text(
                  minutes == 15 ? 'screen_time_15'.tr() :
                  minutes == 30 ? 'screen_time_30'.tr() : 'screen_time_45'.tr(),
                ),
                selected: selected,
                onSelected: (_) {
                  setState(() => _selectedScreenTime = minutes);
                  context.read<AudioManager>().playTap();
                },
                selectedColor: theme.colorScheme.primaryContainer,
                labelStyle: TextStyle(
                  color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: selected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildVolumeSlider(String label, double value, ValueChanged<double> onChanged, IconData icon) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Slider(
                  value: value,
                  onChanged: onChanged,
                  min: 0,
                  max: 1,
                  divisions: 10,
                  activeColor: theme.colorScheme.primary,
                  inactiveColor: theme.colorScheme.outlineVariant,
                ),
              ],
            ),
          ),
          Text(
            '${(value * 100).round()}%',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLanguageSelector(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.language_rounded, color: theme.colorScheme.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'settings_language'.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _LanguageOption(
                      code: 'ar',
                      label: 'settings_arabic'.tr(),
                      selected: _selectedLanguage == 'ar',
                      onTap: () => _changeLanguage('ar'),
                    ),
                    const SizedBox(width: 12),
                    _LanguageOption(
                      code: 'en',
                      label: 'settings_english'.tr(),
                      selected: _selectedLanguage == 'en',
                      onTap: () => _changeLanguage('en'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildParentalGateToggle(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.security_rounded, color: theme.colorScheme.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'settings_parental_gate'.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'settings_parental_gate_desc'.tr(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _parentalGateEnabled,
            onChanged: (value) {
              setState(() => _parentalGateEnabled = value);
              context.read<AudioManager>().playTap();
            },
            activeColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
  
  Widget _buildDangerZone(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.error.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          OutlinedButton.icon(
            onPressed: _resetProgress,
            icon: Icon(Icons.delete_forever_rounded, color: theme.colorScheme.error),
            label: Text(
              'settings_reset_progress'.tr(),
              style: TextStyle(color: theme.colorScheme.error),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: theme.colorScheme.error),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAppInfo(ThemeData theme) {
    return Center(
      child: Column(
        children: [
          Text(
            'app_name'.tr(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            'settings_version'.tr(args: ['1.0.0']),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              // Open privacy policy
            },
            icon: Icon(Icons.privacy_tip_rounded, size: 18, color: theme.colorScheme.onSurfaceVariant),
            label: Text(
              'settings_privacy_policy'.tr(),
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String code;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  
  const _LanguageOption({
    required this.code,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Expanded(
      child: Material(
        color: selected ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}