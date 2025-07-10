import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../models/pet.dart';
import '../../models/storage_service.dart';

class _Platform {
  double x;
  double y;
  double width;
  bool scored;
  _Platform(this.x, this.y, [this.width = 60]) : scored = false;
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  static const double _gravity = 0.4;
  static const double _jumpVelocity = -16;
  static const double _petSize = 75;
  static const double _platformGap = 160;

  late double _petX;
  late double _petY;
  double _vx = 0;
  double _vy = 0;

  late List<_Platform> _platforms;
  int _jumps = 0;
  StreamSubscription<AccelerometerEvent>? _accelSub;
  Timer? _timer;
  bool _started = false;
  bool _gameOver = false;
  int _highScore = 0;
  bool _restartScaling = false;
  bool _homeScaling = false;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    _resetGame();
  }

  Future<void> _loadHighScore() async {
    _highScore = await StorageService.getHighScore();
    setState(() {});
  }

  Future<void> _saveScore() async {
    if (_jumps > _highScore) {
      _highScore = _jumps;
      await StorageService.saveHighScore(_highScore);
    }

    if (context.mounted) {
      context.read<Pet>().updateExp(_jumps);
    }
  }

  void _resetGame() {
    final size =
        WidgetsBinding.instance.window.physicalSize /
        WidgetsBinding.instance.window.devicePixelRatio;
    _petX = size.width / 2 - _petSize / 2;
    // start a little lower than half screen so the camera can follow up
    _petY = size.height * 0.6 - _petSize / 2;
    _vx = 0;
    _vy = 0;
    final rnd = Random();
    _platforms = [
      _Platform(_petX - 20, _petY + _petSize + 5, 100),
      ...List.generate(
        4,
        (i) => _Platform(
          rnd.nextDouble() * (size.width - 60),
          size.height - i * _platformGap - 60,
          60,
        ),
      ),
    ];
    _jumps = 0;
    _gameOver = false;
    _started = false;
    _timer?.cancel();
    _accelSub?.cancel();
  }

  void _startGame() {
    setState(() => _started = true);
    _accelSub = accelerometerEvents.listen((event) {
      _vx = -event.x * 4; // tilt left/right
    });
    _timer = Timer.periodic(const Duration(milliseconds: 16), _update);
  }

  void _update(Timer timer) {
    final size = MediaQuery.of(context).size;
    _vy += _gravity;
    _petX += _vx;
    _petY += _vy;

    if (_petX < -_petSize) _petX = size.width;
    if (_petX > size.width) _petX = -_petSize;

    final rnd = Random();
    for (final p in _platforms) {
      if (_vy > 0 &&
          _petY + _petSize >= p.y &&
          _petY + _petSize <= p.y + 10 &&
          _petX + _petSize >= p.x &&
          _petX <= p.x + p.width) {
        _vy = _jumpVelocity;
        if (!p.scored) {
          _jumps++;
          p.scored = true;
        }
      }
    }

    // move camera up when the pet climbs higher than 40% of the screen
    final double followThreshold = size.height * 0.4;
    if (_petY < followThreshold) {
      final dy = followThreshold - _petY;
      _petY = followThreshold;
      for (final p in _platforms) {
        p.y += dy;
      }
    }

    for (final p in _platforms) {
      if (p.y > size.height) {
        final highest = _platforms.map((pl) => pl.y).reduce(min);
        p.x = rnd.nextDouble() * (size.width - p.width);
        p.y = highest - _platformGap;
        p.scored = false;
      }
    }

    if (_petY > size.height - _petSize) {
      _petY = size.height - _petSize;
      _gameOver = true;
      _timer?.cancel();
      _accelSub?.cancel();
      _saveScore();
    }

    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    _accelSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pet = context.watch<Pet>();
    final hour = DateTime.now().hour;
    final isDayTime = hour >= 6 && hour < 18;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Play'),
        backgroundColor: Colors.orange.shade200,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            isDayTime
                ? 'assets/BackgroundGameD.png'
                : 'assets/BackgroundGameN.png',
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withOpacity(0.2)),
          if (!_started && !_gameOver)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.orange.shade200,
                    child: Image.asset(pet.imagePath, width: 240, height: 240),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Tilt your phone to move and jump across platforms. Avoid falling! '
                      'You can check our high score in the stats page. '
                      'Also, every jump we make together gives me experience!\n',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _startGame,
                    child: const Text('Start'),
                  ),
                ],
              ),
            ),
          if (_started || _gameOver) ...[
            for (final p in _platforms)
              Positioned(
                left: p.x,
                top: p.y,
                child: Container(
                  width: p.width,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            Positioned(
              left: _petX,
              top: _petY,
              child: Image.asset(
                pet.imagePath,
                width: _petSize,
                height: _petSize,
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Jumps: $_jumps',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
          if (_gameOver)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Game Over',
                      style: TextStyle(fontSize: 32, color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'High score: $_highScore',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 16),
                    AnimatedScale(
                      scale: _restartScaling ? 1.1 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => _restartScaling = true);
                          Future.delayed(const Duration(milliseconds: 200), () {
                            if (!mounted) return;
                            setState(() => _restartScaling = false);
                            _resetGame();
                            _startGame();
                          });
                        },
                        child: const Text('Restart'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    AnimatedScale(
                      scale: _homeScaling ? 1.1 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => _homeScaling = true);
                          Future.delayed(const Duration(milliseconds: 200), () {
                            if (!mounted) return;
                            setState(() => _homeScaling = false);
                            Navigator.pop(context);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Home'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
