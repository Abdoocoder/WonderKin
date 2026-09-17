// Parental Gate - Math challenge for parent access
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/storage/database.dart';

class ParentalGateProvider extends ChangeNotifier {
  final AppDatabase _database;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  bool _isScreenTimeExceeded = false;
  bool _gateUnlocked = false;
  int _gateAttempts = 0;
  DateTime? _gateLockoutUntil;
  int _currentQuestionA = 0;
  int _currentQuestionB = 0;
  int _correctAnswer = 0;
  
  ParentalGateProvider(this._database) {
    _loadScreenTimeState();
    _generateNewQuestion();
  }
  
  bool get isScreenTimeExceeded => _isScreenTimeExceeded;
  bool get gateUnlocked => _gateUnlocked;
  int get gateAttempts => _gateAttempts;
  DateTime? get gateLockoutUntil => _gateLockoutUntil;
  int get currentQuestionA => _currentQuestionA;
  int get currentQuestionB => _currentQuestionB;
  String get questionText => '$_currentQuestionA + $_currentQuestionB = ?';
  
  Future<void> _loadScreenTimeState() async {
    final settings = await _database.settingsDao.getSettings();
    final lastReset = settings.lastResetDate;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    
    if (lastReset == null || lastReset < today) {
      // New day, reset screen time
      _isScreenTimeExceeded = false;
      await _database.settingsDao.updateSettings(lastResetDate: today);
    } else {
      // Check if today's play time exceeded limit
      // This would be tracked in a separate table in production
      // For now, we'll use a simple approach
      _isScreenTimeExceeded = false;
    }
    
    notifyListeners();
  }
  
  void _generateNewQuestion() {
    _currentQuestionA = (DateTime.now().millisecondsSinceEpoch % 9) + 1;
    _currentQuestionB = ((DateTime.now().millisecondsSinceEpoch ~/ 7) % 9) + 1;
    _correctAnswer = _currentQuestionA + _currentQuestionB;
  }
  
  Future<bool> checkAnswer(int answer) async {
    // Check lockout
    if (_gateLockoutUntil != null && DateTime.now().isBefore(_gateLockoutUntil!)) {
      return false;
    }
    
    if (answer == _correctAnswer) {
      _gateUnlocked = true;
      _gateAttempts = 0;
      _gateLockoutUntil = null;
      await _secureStorage.write(key: 'gate_unlocked', value: 'true');
      notifyListeners();
      return true;
    } else {
      _gateAttempts++;
      _generateNewQuestion();
      
      if (_gateAttempts >= AppConstants.maxGateAttempts) {
        _gateLockoutUntil = DateTime.now().add(AppConstants.gateLockoutDuration);
        await _secureStorage.write(
          key: 'gate_lockout_until', 
          value: _gateLockoutUntil!.millisecondsSinceEpoch.toString(),
        );
      }
      
      notifyListeners();
      return false;
    }
  }
  
  Future<void> lockGate() async {
    _gateUnlocked = false;
    _gateAttempts = 0;
    _generateNewQuestion();
    await _secureStorage.write(key: 'gate_unlocked', value: 'false');
    notifyListeners();
  }
  
  Future<void> setScreenTimeExceeded(bool exceeded) async {
    _isScreenTimeExceeded = exceeded;
    notifyListeners();
  }
  
  Future<void> resetScreenTime() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    await _database.settingsDao.updateSettings(lastResetDate: today);
    _isScreenTimeExceeded = false;
    notifyListeners();
  }
}

class ParentalGateScreen extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback? onCancel;
  
  const ParentalGateScreen({
    super.key,
    required this.onSuccess,
    this.onCancel,
  });

  @override
  State<ParentalGateScreen> createState() => _ParentalGateScreenState();
}

class _ParentalGateScreenState extends State<ParentalGateScreen>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  String _input = '';
  bool _isLocked = false;
  DateTime? _lockoutUntil;
  
  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    
    // Load lockout state
    _loadLockout();
  }
  
  Future<void> _loadLockout() async {
    final storage = const FlutterSecureStorage();
    final lockoutStr = await storage.read(key: 'gate_lockout_until');
    if (lockoutStr != null) {
      final lockout = DateTime.fromMillisecondsSinceEpoch(int.parse(lockoutStr));
      if (DateTime.now().isBefore(lockout)) {
        setState(() {
          _isLocked = true;
          _lockoutUntil = lockout;
        });
        _startLockoutCountdown();
      } else {
        await storage.delete(key: 'gate_lockout_until');
      }
    }
  }
  
  void _startLockoutCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _lockoutUntil != null) {
        if (DateTime.now().isBefore(_lockoutUntil!)) {
          setState(() {});
          _startLockoutCountdown();
        } else {
          setState(() {
            _isLocked = false;
            _lockoutUntil = null;
          });
        }
      }
    });
  }
  
  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }
  
  void _onNumberTap(String number) {
    if (_isLocked) return;
    
    setState(() {
      if (_input.length < 2) {
        _input += number;
      }
    });
    
    // Auto-submit when 2 digits entered (max answer is 18)
    if (_input.length == 2) {
      _submitAnswer();
    }
  }
  
  void _onBackspace() {
    setState(() {
      if (_input.isNotEmpty) {
        _input = _input.substring(0, _input.length - 1);
      }
    });
  }
  
  void _submitAnswer() async {
    final answer = int.tryParse(_input) ?? 0;
    final provider = context.read<ParentalGateProvider>();
    
    final success = await provider.checkAnswer(answer);
    
    if (success) {
      widget.onSuccess();
    } else {
      _shakeController.forward(from: 0);
      setState(() {
        _input = '';
        _isLocked = provider.gateLockoutUntil != null;
        _lockoutUntil = provider.gateLockoutUntil;
      });
      
      if (_isLocked) {
        _startLockoutCountdown();
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ParentalGateProvider>();
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Close button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (widget.onCancel != null)
                    IconButton(
                      onPressed: widget.onCancel,
                      icon: Icon(
                        Icons.close_rounded,
                        size: 28,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              
              const Spacer(),
              
              // Lock icon
              Icon(
                _isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
                size: 80,
                color: _isLocked 
                    ? theme.colorScheme.error 
                    : theme.colorScheme.primary,
              ),
              
              const SizedBox(height: 24),
              
              // Title
              Text(
                _isLocked ? 'مُقفل مؤقتاً' : 'بوابة الأهل',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: _isLocked ? theme.colorScheme.error : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Description
              Text(
                _isLocked
                    ? 'حاول مرة أخرى بعد ${_formatLockoutTime()}'
                    : 'للوصول إلى إعدادات الأهل، يرجى حل العملية الحسابية التالية:',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Math question (hidden when locked)
              if (!_isLocked) ...[
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_shakeAnimation.value * 10 * sin(_shakeAnimation.value * 20), 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: theme.colorScheme.primary,
                            width: 3,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${provider.currentQuestionA} + ${provider.currentQuestionB} = ',
                              style: theme.textTheme.displaySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              width: 80,
                              height: 64,
                              margin: const EdgeInsets.only(left: 16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: theme.colorScheme.outline,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _input.isEmpty ? '?' : _input,
                                  style: theme.textTheme.displaySmall?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Number pad
                _buildNumberPad(theme),
                
                // Attempts indicator
                if (provider.gateAttempts > 0) ...[
                  const SizedBox(height: 16),
                  Text(
                    'محاولات خاطئة: ${provider.gateAttempts} / ${AppConstants.maxGateAttempts}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ] else ...[
                // Lockout countdown
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.timer_rounded,
                        size: 48,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _formatLockoutTime(),
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.bold,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildNumberPad(ThemeData theme) {
    const numbers = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['⌫', '0', '✓'],
    ];
    
    return Column(
      children: numbers.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((num) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _NumberPadButton(
                  label: num,
                  onTap: () {
                    if (num == '⌫') {
                      _onBackspace();
                    } else if (num == '✓') {
                      _submitAnswer();
                    } else {
                      _onNumberTap(num);
                    }
                  },
                  isAction: num == '⌫' || num == '✓',
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
  
  String _formatLockoutTime() {
    if (_lockoutUntil == null) return '00:00';
    final remaining = _lockoutUntil!.difference(DateTime.now());
    final seconds = remaining.inSeconds.clamp(0, 9999);
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

class _NumberPadButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isAction;
  
  const _NumberPadButton({
    required this.label,
    required this.onTap,
    this.isAction = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: isAction ? theme.colorScheme.tertiaryContainer : theme.colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          child: Text(
            label,
            style: theme.textTheme.displaySmall?.copyWith(
              color: isAction 
                  ? theme.colorScheme.onTertiaryContainer 
                  : theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}