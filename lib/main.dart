import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:dice_roller/dice_painter.dart';

class DiceTheme {
  final String id;
  final String name;
  final String emoji;
  final Color primary;
  final Color secondary;
  final List<Color> gradientColors;

  const DiceTheme({
    required this.id,
    required this.name,
    required this.emoji,
    required this.primary,
    required this.secondary,
    required this.gradientColors,
  });
}

final List<DiceTheme> kThemes = [
  DiceTheme(
    id: 'default',
    name: 'Default',
    emoji: '🟣',
    primary: const Color(0xFF6D28D9),
    secondary: const Color(0xFF4F46E5),
    gradientColors: [const Color(0xFF6D28D9), const Color(0xFF111827)],
  ),
  DiceTheme(
    id: 'fire',
    name: 'Fire',
    emoji: '🔥',
    primary: const Color(0xFFEA580C),
    secondary: const Color(0xFFDC2626),
    gradientColors: [const Color(0xFFEA580C), const Color(0xFF1C0A00)],
  ),
  DiceTheme(
    id: 'ocean',
    name: 'Ocean',
    emoji: '🌊',
    primary: const Color(0xFF0891B2),
    secondary: const Color(0xFF0284C7),
    gradientColors: [const Color(0xFF0891B2), const Color(0xFF0C1445)],
  ),
  DiceTheme(
    id: 'rose',
    name: 'Rose',
    emoji: '🌸',
    primary: const Color(0xFFE11D48),
    secondary: const Color(0xFF9F1239),
    gradientColors: [const Color(0xFFFFF1F2), const Color(0xFFFECDD3)],
  ),
  DiceTheme(
    id: 'white',
    name: 'White Clean',
    emoji: '⚪',
    primary: const Color(0xFF374151),
    secondary: const Color(0xFF111827),
    gradientColors: [const Color(0xFFFFFFFF), const Color(0xFFF3F4F6)],
  ),
];

class ThemeNotifier extends ChangeNotifier {
  DiceTheme _current = kThemes[0];
  DiceTheme get current => _current;

  void setTheme(DiceTheme theme) {
    _current = theme;
    notifyListeners();
  }
}

final themeNotifier = ThemeNotifier();

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeNotifier,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Dice Roller',
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: themeNotifier.current.primary,
          ),
          home: const SplashPage(),
        );
      },
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    Timer(const Duration(milliseconds: 3000), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 450),
          pageBuilder: (_, __, ___) => const DicePage(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeNotifier,
      builder: (context, _) {
        final theme = themeNotifier.current;
        return Scaffold(
          body: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: theme.gradientColors,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _controller,
                    child: Container(
                      width: 120,
                      height: 120,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(31),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white24, width: 2),
                      ),
                      child: const Icon(Icons.casino, size: 64, color: Colors.white),
                    ),
                    builder: (context, child) {
                      final t = _controller.value;
                      final scale = 0.95 + (sin(t * 2 * pi) * 0.06);
                      return Transform.rotate(
                        angle: t * 2 * pi,
                        child: Transform.scale(scale: scale, child: child),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Dice Roller',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const _LoadingDots(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots> {
  int _dots = 1;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(milliseconds: 350),
      (_) => setState(() => _dots = (_dots % 3) + 1),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      'Loading${'.' * _dots}',
      style: const TextStyle(color: Colors.white70, fontSize: 16),
    );
  }
}

class DicePage extends StatefulWidget {
  const DicePage({super.key});

  @override
  State<DicePage> createState() => _DicePageState();
}

class _DicePageState extends State<DicePage> {
  final _random = Random();
  bool _twoDice = false;
  bool _isRolling = false;
  int _d1 = 1;
  int _d2 = 1;
  double _angle = 0;

  late final AudioPlayer _rollPlayer;
  late final AudioPlayer _uiPlayer;

  @override
  void initState() {
    super.initState();
    _rollPlayer = AudioPlayer();
    _uiPlayer = AudioPlayer();
    _rollPlayer.setSource(AssetSource('sounds/roll.mp3'));
    _uiPlayer.setSource(AssetSource('sounds/switch.mp3'));
  }

  @override
  void dispose() {
    _rollPlayer.dispose();
    _uiPlayer.dispose();
    super.dispose();
  }

  Future<void> _playRollSound() async {
    await _rollPlayer.stop();
    await _rollPlayer.setReleaseMode(ReleaseMode.loop);
    await _rollPlayer.play(AssetSource('sounds/roll.mp3'), volume: 1.0);
  }

  Future<void> _stopRollSound() async {
    await _rollPlayer.stop();
  }

  Future<void> _playSwitchSound() async {
    await _uiPlayer.stop();
    await _uiPlayer.play(AssetSource('sounds/switch.mp3'), volume: 1.0);
  }

  Future<void> _rollDice() async {
    if (_isRolling) return;
    setState(() => _isRolling = true);
    await _playRollSound();

    for (int i = 0; i < 12; i++) {
      await Future.delayed(const Duration(milliseconds: 40));
      setState(() {
        _d1 = _random.nextInt(6) + 1;
        if (_twoDice) _d2 = _random.nextInt(6) + 1;
        _angle = (i % 2 == 0) ? -0.25 : 0.25;
      });
    }

    setState(() {
      _d1 = _random.nextInt(6) + 1;
      if (_twoDice) _d2 = _random.nextInt(6) + 1;
      _angle = 0;
      _isRolling = false;
    });

    await _stopRollSound();
  }

  Future<void> _toggleDiceMode() async {
    await _playSwitchSound();
    setState(() {
      _twoDice = !_twoDice;
      if (!_twoDice) _d2 = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final turns = _angle / (2 * pi);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Dice Roller',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        flexibleSpace: AnimatedBuilder(
          animation: themeNotifier,
          builder: (context, _) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  themeNotifier.current.primary,
                  themeNotifier.current.secondary,
                ],
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette),
            tooltip: 'Themes',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ShopPage()),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _rollDice,
              child: AnimatedRotation(
                turns: turns,
                duration: const Duration(milliseconds: 80),
                child: AnimatedScale(
                  scale: _isRolling ? 1.05 : 1.0,
                  duration: const Duration(milliseconds: 80),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _DiceBox(value: _d1),
                      if (_twoDice) const SizedBox(width: 18),
                      if (_twoDice) _DiceBox(value: _d2),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _toggleDiceMode,
              icon: Icon(_twoDice ? Icons.filter_1 : Icons.filter_2),
              label: Text(_twoDice ? 'Switch to 1 Dice' : 'Switch to 2 Dice'),
            ),
            const SizedBox(height: 12),
            Text(
              _twoDice ? 'Tap the dice to roll both' : 'Tap the dice to roll',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(140),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _rollDice,
        icon: const Icon(Icons.play_arrow),
        label: const Text('Roll'),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  DICE BOX
// ─────────────────────────────────────────
class _DiceBox extends StatelessWidget {
  final int value;
  const _DiceBox({required this.value});

  DiceStyle _getStyle() {
    final id = themeNotifier.current.id;
    switch (id) {
      case 'fire':  return DiceStyles.darkAmber;
      case 'ocean': return DiceStyles.mintFresh;
      case 'rose':  return DiceStyles.rose;
      case 'white': return DiceStyles.whiteClean;
      default:      return DiceStyles.darkLuxury;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DiceWidget(
      value: value,
      style: _getStyle(),
      size: 150,
    );
  }
}

// ─────────────────────────────────────────
//  SHOP PAGE
// ─────────────────────────────────────────
class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Themes',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        flexibleSpace: AnimatedBuilder(
          animation: themeNotifier,
          builder: (context, _) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  themeNotifier.current.primary,
                  themeNotifier.current.secondary,
                ],
              ),
            ),
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: themeNotifier,
        builder: (context, _) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Choose your style',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'All themes are free!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha(140),
                      ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.separated(
                    itemCount: kThemes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final theme = kThemes[index];
                      final isSelected = themeNotifier.current.id == theme.id;

                      return GestureDetector(
                        onTap: () {
                          themeNotifier.setTheme(theme);
                          Navigator.pop(context);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                theme.primary.withAlpha(40),
                                theme.secondary.withAlpha(20),
                              ],
                            ),
                            border: Border.all(
                              color: isSelected
                                  ? theme.primary
                                  : theme.primary.withAlpha(80),
                              width: isSelected ? 2.5 : 1.5,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: theme.primary.withAlpha(60),
                                      blurRadius: 12,
                                      spreadRadius: 1,
                                    )
                                  ]
                                : [],
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 60,
                                height: 60,
                                child: CustomPaint(
                                  painter: DicePainter(
                                    value: 5,
                                    style: _diceStyleForTheme(theme.id),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${theme.emoji} ${theme.name}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: theme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Free',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: theme.primary.withAlpha(180),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: theme.primary,
                                  size: 28,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  DiceStyle _diceStyleForTheme(String id) {
    switch (id) {
      case 'fire':  return DiceStyles.darkAmber;
      case 'ocean': return DiceStyles.mintFresh;
      case 'rose':  return DiceStyles.rose;
      case 'white': return DiceStyles.whiteClean;
      default:      return DiceStyles.darkLuxury;
    }
  }
}