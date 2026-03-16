import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dice Roller',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: const SplashPage(),
    );
  }
}

/// ---------------- SPLASH / LOADING SCREEN ----------------
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
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
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
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6D28D9), Color(0xFF111827)],
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
                  child: const Icon(
                    Icons.casino,
                    size: 64,
                    color: Colors.white,
                  ),
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
    _timer = Timer.periodic(const Duration(milliseconds: 350), (_) {
      setState(() => _dots = (_dots % 3) + 1);
    });
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

/// ---------------- DICE PAGE (sounds + switch button under dice) ----------------
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

  // --- AUDIO ---
  late final AudioPlayer _rollPlayer;
  late final AudioPlayer _uiPlayer;

  @override
  void initState() {
    super.initState();

    _rollPlayer = AudioPlayer();
    _uiPlayer = AudioPlayer();

    // Preload (helps avoid delay on first play)
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
    // loop while rolling
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
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6D28D9), Color(0xFF4F46E5)],
            ),
          ),
        ),
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

            // Switch button under dice (with sound)
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

/// Dice UI widget
class _DiceBox extends StatelessWidget {
  final int value;
  const _DiceBox({required this.value});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: 150,
      height: 150,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary.withAlpha(46),
            primary.withAlpha(13),
          ],
        ),
        border: Border.all(width: 2.5, color: primary),
        boxShadow: [
          BoxShadow(
            blurRadius: 22,
            spreadRadius: 1,
            offset: const Offset(0, 10),
            color: Colors.black.withAlpha(31),
          ),
        ],
      ),
      child: Text(
        '$value',
        style: TextStyle(
          fontSize: 72,
          fontWeight: FontWeight.w900,
          color: primary,
        ),
      ),
    );
  }
}
