import 'dart:async';
import 'package:flutter/foundation.dart';            // kDebugMode
import 'package:flutter/material.dart';
import 'package:progetto_mobile/models/challenge.dart';
import 'package:progetto_mobile/models/storage_service.dart';
import 'package:progetto_mobile/ui/pages/settings_page.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import '../../models/bag.dart';
import '../../models/pet.dart';
import '../../models/steps.dart';
import 'bag_page.dart';
import 'claim_rewards.dart';
import 'stats_page.dart';
import 'feed_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showStats = false;
  bool _feedButtonScaling = false;
  bool _rewardsButtonScaling = false;
  Timer? _mockStepTimer;
  int _previousLevel = -1;                          // livello precedente; -1 se non caricato
  int _previousStage = -1;                          // evoluzione precedente
  bool _hatchDialogShown = false;
  late final Pet _pet;
  bool? _wasHungry;
  bool? _wasHappy;

  static const List<String> happyNotHungryPhrases = [
    'Today I am feeling great!',
    'What a beautiful day!',
    'Ready for new adventures!',
    'I am full and happy!',
    'Thanks for taking care of me!'
  ];

  static const List<String> happyHungryPhrases = [
    'Starting to be hungry...',
    'A snack should be cool!',
    'I could eat something.',
    'Have you something to eat?',
  ];

  static const List<String> sadNotHungryPhrases = [
    'I am not feeling so happy...',
    "I'm a little bored.",
    "I reaaly need to stay together .",
    'Sigh... what a sad day.',
    'Can you play with me?'
  ];

  static const List<String> sadHungryPhrases = [
    "I'm hungry and I'm feeling upset...",
    'my stomach is growling and I feel alone...',
    'Please, can you give me something to eat?',
    '😞😞...',
    'No food and no happyness today...'
  ];

  String _currentPhrase = '';
  Timer? _phraseTimer;
  Timer? _eggCheckTimer;
  static const String eggPhrase =
      "Wonder what's inside? It needs more time, and more steps!";

  @override
  void initState() {
    super.initState();
    _pet = Provider.of<Pet>(context, listen: false);
    _pet.addListener(_handlePetChange);
    _initAsync();
    _eggCheckTimer =
        Timer.periodic(const Duration(seconds: 5), (_) {
          if (!_pet.isEgg && _currentPhrase == eggPhrase) {
            _changePhrase();
          }
        });
  }

  Future<void> _initAsync() async {
    final stepsManager = Provider.of<StepsManager>(context, listen: false);
    await stepsManager.loadSteps();
    await stepsManager.loadGoals();

    final challengeManager = Provider.of<ChallengeManager>(context, listen: false);
    await challengeManager.loadClaimedStatuses();

    final bag = Provider.of<Bag>(context, listen: false);
    await bag.loadBag();

    await _pet.loadPet();
    setState(() {
      _previousLevel = _pet.level;
      _previousStage = _pet.evolutionStage;
      _wasHungry = _pet.hunger < 50;
      _wasHappy = _pet.happiness >= 50;
    });

    final hatchShown = await StorageService.getHatchShown();
    setState(() {
      _hatchDialogShown = hatchShown;
    });

    _updatePhrase();
  }

  void _handlePetChange() {
    if (!mounted) return;
    _updatePhrase();
  }

  void _updatePhrase() {
    if (_pet.isEgg) {
      _phraseTimer?.cancel();
      _phraseTimer = null;
      if (_currentPhrase != eggPhrase) {
        setState(() => _currentPhrase = eggPhrase);
      }
      _wasHungry = null;
      _wasHappy = null;
    } else {
      // Start phrase rotation only if not already active to avoid
      // restarting it whenever the pet's stats update.
      if (_phraseTimer == null) {
        final isHungry = _pet.hunger < 50;
        final isHappy = _pet.happiness >= 50;
        final shouldUpdate =
            _currentPhrase == eggPhrase ||
                _wasHungry == null ||
                isHungry != _wasHungry ||
                isHappy != _wasHappy ||
                _phraseTimer == null;

        if (shouldUpdate) {
          _changePhrase();
        }

        _wasHungry = isHungry;
        _wasHappy = isHappy;
      }
    }
  }

  void _changePhrase() {
    final pet = context.read<Pet>();
    if (pet.isEgg) {
      _phraseTimer?.cancel();
      return;
    }

    final random = Random();
    final isHungry = pet.hunger < 50;
    final isHappy = pet.happiness >= 50;

    List<String> phrases;
    if (isHappy && !isHungry) {
      phrases = happyNotHungryPhrases;
    } else if (isHappy && isHungry) {
      phrases = happyHungryPhrases;
    } else if (!isHappy && !isHungry) {
      phrases = sadNotHungryPhrases;
    } else {
      phrases = sadHungryPhrases;
    }

    _currentPhrase = phrases[random.nextInt(phrases.length)];
    setState(() {});

    _phraseTimer?.cancel();
    _phraseTimer = Timer(const Duration(seconds: 30), _changePhrase);
  }

  @override
  void dispose() {
    _mockStepTimer?.cancel();
    _phraseTimer?.cancel();
    _eggCheckTimer?.cancel();
    _pet.removeListener(_handlePetChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pet          = context.watch<Pet>();
    final stepsManager = context.watch<StepsManager>();

    // Calcolo dell'orario per l'immagine di sfondo, se tra le 6 e le 18 → giorno, altrimenti notte
    final hour = DateTime.now().hour;
    final isDayTime = hour >= 6 && hour < 18;

    // ─── Messaggio quando il pet passa da livello 0 a 1 ───
      if (!_hatchDialogShown &&
          _previousLevel != -1 &&
          _previousLevel == 0 &&
          pet.level == 1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              contentPadding: const EdgeInsets.all(24),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('🎉 Hatching!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Text('Your egg is hatched! Check the stats page.', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
                  SizedBox(height: 12),
                  Text('Take care of your pet and grow him up! 🐒', textAlign: TextAlign.center),
                ],
              ),
            ),

          ).then((_) {
          _hatchDialogShown = true;
          StorageService.saveHatchShown(true);
          });
        });
      }

    // ─── Evoluzione a Mostro1 (livello 25) ───
    if (_previousStage != -1 &&
        _previousStage == 1 &&
        pet.evolutionStage == 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            contentPadding: const EdgeInsets.all(24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('🎉 Evolution!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                Text('Your pet has evolved!', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
                SizedBox(height: 12),
                Text('You are on the right way, keep taking care of him! 🐒', textAlign: TextAlign.center),
              ],
            ),
          ),
        );
      });
    }

    // ─── Evoluzione a Mostro2 (livello 50) ───
    if (_previousStage != -1 &&
        _previousStage == 2 &&
        pet.evolutionStage == 3) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            contentPadding: const EdgeInsets.all(24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('🎉 Evolution!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                Text('Your pet has evolved!', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
                SizedBox(height: 12),
                Text('You are applying so much effort to take care of him! 🐒', textAlign: TextAlign.center),
              ],
            ),
          ),
        );
      });
    }

    _previousLevel = pet.level;
    _previousStage = pet.evolutionStage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Steps'),
        backgroundColor: Colors.orange.shade200,),
      drawer: const _AppDrawer(),
      drawerEdgeDragWidth: 30.0,

      // ─────────────── Corpo ───────────────
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! < -300) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,   // per farla full screen
              enableDrag: true,           // abilita lo swipe per chiudere
              backgroundColor: Colors.transparent, // opzionale: se vuoi sfondo trasparente
              builder: (context) => Container(
                height: MediaQuery.of(context).size.height * 0.95,  // 95% altezza schermo
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: const BagPage(),
              ),
            );
          }
        },
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
            // swipe da destra verso sinistra
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => StatsPage(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);  // parte da destra
                  const end = Offset.zero;
                  const curve = Curves.ease;

                  final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  final offsetAnimation = animation.drive(tween);

                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
              ),
            );
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              isDayTime
                  ? 'assets/imagePratoDay.png'
                  : 'assets/imagePratoNight.png',
            fit: BoxFit.cover,
            ),
            Container(
              color: Colors.black.withOpacity(0.2),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // avatar + overlay
                  Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      GestureDetector(
                        onLongPressStart: (_) => setState(() => _showStats = true),
                        onLongPressEnd:   (_) => setState(() => _showStats = false),
                        child: CircleAvatar(
                          radius: 80,
                          backgroundColor: Colors.orange.shade200,
                          child: Image.asset(
                            //pet.isEgg ? 'assets/egg.png' : 'assets/Monster.png',
                            pet.imagePath,
                            width: 240,
                            height: 240,
                          ),
                        ),
                      ),
                      if (_showStats && !pet.isEgg) // se è un uovo non mostro neanche le statistiche
                        Positioned(
                          top: -110,
                          child: Material(
                            color: Colors.black.withOpacity(0.75),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _StatBar(
                                    label: 'Hunger',
                                    value: pet.hunger,
                                    icon: Icons.restaurant,
                                  ),
                                  const SizedBox(height: 8),
                                  _StatBar(
                                    label: 'Happiness',
                                    value: pet.happiness,
                                    icon: Icons.emoji_emotions,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    child: Text(
                      _currentPhrase,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // livello & passi
                  Text('Level ${pet.level}',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: isDayTime
                            ? Colors.black
                            : Colors.white,
                      )
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 4),
                    child: LinearProgressIndicator(
                      value: pet.xp / Pet.xpPerLevel,
                      minHeight: 8,
                      backgroundColor: isDayTime ? Colors.black12 : Colors.white12,
                      valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('steps today: ${stepsManager.dailySteps}',
                      style: TextStyle(
                        color: isDayTime
                            ? Colors.black
                            : Colors.white,
                      )
                  ),

                  // pulsanti feed / rewards
                  AnimatedScale(
                    scale: _feedButtonScaling ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: FilledButton(
                      onPressed: () {
                      if (pet.isEgg){
                        showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (_) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              contentPadding: const EdgeInsets.all(24),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text('Your egg could not eat yet! Walk more and try to hatch it.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 12),
                                  Text('Your egg will hatch when it reach the level 1.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 16)),
                                ],
                              ),
                            ),
                        );
                      }else{
                        setState(() => _feedButtonScaling = true);
                        Future.delayed(const Duration(milliseconds: 200), () {
                          if (!mounted) return;
                          setState(() => _feedButtonScaling = false);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const FeedPage()),
                          );
                        });
                      }
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(150, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Feed him'),
                  ),
                  ),
                  const SizedBox(height: 12),
                  AnimatedScale(
                    scale: _rewardsButtonScaling ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() => _rewardsButtonScaling = true);
                        Future.delayed(const Duration(milliseconds: 200), () {
                          if (!mounted) return;
                          setState(() => _rewardsButtonScaling = false);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RewardsPage()),
                          );
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(150, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        backgroundColor: Colors.orange.shade100,
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                      ),
                      child: const Text('Claim rewards'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ───────────── Pulsanti debug ─────────────
      floatingActionButton: kDebugMode
      ? Column(
      mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'debugWalk',
            tooltip: '+500 passi',
            child: const Icon(Icons.directions_walk),
            onPressed: () {
              final stepsMgr = context.read<StepsManager>();
              final petRef   = context.read<Pet>();

              stepsMgr.addSteps(500);
              petRef.updateExp(500);
            },
          ),
          const SizedBox(height: 12),
          FloatingActionButton.small(
            heroTag: 'debugReset',
            tooltip: 'Reset app',
            backgroundColor: Colors.redAccent,
            child: const Icon(Icons.restart_alt),
            onPressed: () async {
              resetApp(context);

              setState(() {
                _previousLevel = -1;
                _previousStage = -1;
                _hatchDialogShown = false;
              });

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dati resettati')),
                );
              }
            },
          ),
        ],
      ): null,
    );
  }
}

/// Barra di progresso fame / felicità
class _StatBar extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;

  const _StatBar({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
        const SizedBox(width: 8),
        Container(
          width: 120,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value / 100,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.greenAccent,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Drawer invariato
class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.orange.shade200,
      child: ListView(
        children: [
          const DrawerHeader(
            child: Column(
              children: [
                Text('Pet Steps', style: TextStyle(fontSize: 24)),
                SizedBox(height: 8),
                Text('Is time to walk together!'),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.backpack),
            iconColor: Colors.black,
            title: const Text('Bag'),
            onTap: () {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BagPage()),
            );},
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            iconColor: Colors.black,
            title: const Text('Stats'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StatsPage()),
              );},
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            iconColor: Colors.black,
            title: const Text('Settings'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

Future<void> resetApp(BuildContext context) async {
  final stepsMgr = context.read<StepsManager>();
  final petRef   = context.read<Pet>();
  final challengeMgr   = context.read<ChallengeManager>();
  final bagMgr   = context.read<Bag>();

  await StorageService.clearAll();
  await stepsMgr.resetStepsAndGoals();
  await petRef.resetPet();
  await challengeMgr.resetClaimedChallenges();
  await bagMgr.resetBag();
}