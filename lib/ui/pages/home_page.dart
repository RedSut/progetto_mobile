import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart'; // kDebugMode
import 'package:flutter/material.dart';
import 'package:progetto_mobile/models/challenge.dart';
import 'package:progetto_mobile/models/storage_service.dart';
import 'package:progetto_mobile/ui/pages/settings_page.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../models/bag.dart';
import '../../models/pet.dart';
import '../../models/steps.dart';
import 'bag_page.dart';
import 'claim_rewards.dart';
import 'feed_page.dart';
import 'game_page.dart';
import 'stats_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showStats = false;
  bool _feedButtonScaling = false;
  bool _rewardsButtonScaling = false;
  bool _playButtonScaling = false;
  Timer? _mockStepTimer;
  int _previousLevel = -1; // livello precedente; -1 se non caricato
  int _previousStage = -1; // evoluzione precedente
  bool _hatchDialogShown = false;
  late final Pet _pet;
  bool? _wasHungry;
  bool? _wasHappy;
  bool _tutorialStarted = false;
  final GlobalKey _playKey = GlobalKey();
  final GlobalKey _feedKey = GlobalKey();
  final GlobalKey _rewardsKey = GlobalKey();
  final GlobalKey _menuKey = GlobalKey();
  final GlobalKey _petKey = GlobalKey();
  final GlobalKey _helpKey = GlobalKey();

  static const List<String> happyNotHungryPhrases = [
    'Today I am feeling great!',
    'What a beautiful day!',
    'Ready for new adventures!',
    'I am full and happy!',
    'Thanks for taking care of me!',
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
    'Can you play with me?',
  ];

  static const List<String> sadHungryPhrases = [
    "I'm hungry and I'm feeling upset...",
    'my stomach is growling and I feel alone...',
    'Please, can you give me something to eat?',
    '😞😞...',
    'No food and no happyness today...',
  ];

  String _currentPhrase = '';
  Timer? _phraseTimer;
  Timer? _eggCheckTimer;
  Timer? _hungerHappinessTimer;
  static const String eggPhrase =
      "Wonder what's inside? It needs more time, and more steps!";

  @override
  void initState() {
    super.initState();
    _pet = Provider.of<Pet>(context, listen: false);
    _pet.addListener(_handlePetChange);
    _initAsync();
    _eggCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_pet.isEgg && _currentPhrase == eggPhrase) {
        _changePhrase();
      }
    });
    _hungerHappinessTimer = Timer.periodic(const Duration(minutes: 10), (_) {
      _pet.updateStatsFromTime();
    });
  }

  Future<void> _initAsync() async {
    final stepsManager = Provider.of<StepsManager>(context, listen: false);
    await stepsManager.loadSteps();
    await stepsManager.loadGoals();

    final challengeManager = Provider.of<ChallengeManager>(
      context,
      listen: false,
    );
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
    final tutorialShown = await StorageService.getHomeTutorialShown();
    if (!tutorialShown && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showTutorial());
    }

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

  bool _hasUnclaimedRewards(
    StepsManager stepsManager,
    ChallengeManager challengeManager,
  ) {
    for (final challenge in challengeManager.challenges) {
      if (challenge.isClaimed) continue;

      final stepsTarget = challenge.getStepsTarget(stepsManager);
      double progress;
      if (challenge.id == 'minute') {
        progress = stepsManager.minuteProgress.clamp(0.0, 1.0);
      } else if (challenge.id == 'hourly') {
        progress = stepsManager.hourlyProgress.clamp(0.0, 1.0);
      } else if (challenge.id == 'daily' ||
          challenge.id == 'daily_leppa' ||
          challenge.id == 'daily_rowap') {
        progress = stepsManager.dailyProgress.clamp(0.0, 1.0);
      } else if (challenge.id == 'weekly') {
        progress = stepsManager.weeklyProgress.clamp(0.0, 1.0);
      } else if (challenge.id == 'ch_001') {
        progress = stepsManager.hourlyProgress.clamp(0.0, 1.0);
      } else if (challenge.id == 'ch_002') {
        progress = stepsManager.hourlyProgress.clamp(0.0, 1.0);
      } else if (challenge.id == 'ch_003') {
        progress = stepsManager.hourlyProgress.clamp(0.0, 1.0);
      } else {
        progress = (stepsManager.steps / stepsTarget).clamp(0.0, 1.0);
      }

      if (progress >= 1.0) {
        return true;
      }
    }
    return false;
  }

  void _showTutorial() {
    if (_tutorialStarted) return;
    _tutorialStarted = true;
    final size = MediaQuery.of(context).size;

    final targets = [
      TargetFocus(
        identify: 'welcome',
        targetPosition: TargetPosition(
          Size.zero,
          Offset(size.width / 2, size.height / 2),
        ),
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Welcome to Pet Steps!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'You have recived a strange egg, try to hatch it! It will become your personal pet, '
                  'so take care of him while you stay active.\n'
                  'Click on the highlighted zones to complete this tutorial, or if you have already'
                      'played this game, just skip it with the button!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'pet-status',
        keyTarget: _petKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Pet status',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'This is your pet! Press and hold the pet to see if it\'s happy or hungry. Remember that eggs have nothing to say,'
                  ' so try to hatch it! You can earn exp by walking with him.',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'feed',
        keyTarget: _feedKey,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Feed him',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Remember to not let him starve, and this is the place where you can do it. '
                      'Of course, for now, you cant feed an egg.',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'rewards',
        keyTarget: _rewardsKey,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Claim rewards',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Collect prizes for your steps progress. If you see a red dot on this icon,'
                      ' it seems that you have something to claim!',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'play',
        keyTarget: _playKey,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Play',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Here you can play a minigame with your pet to earn more exp, when the egg will hatch.',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'menu',
        keyTarget: _menuKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Side menu',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'You can swipe right or tap here to open settings, view your bag with your food and your stats.',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'bag',
        targetPosition: TargetPosition(
          Size.zero,
          Offset(size.width / 2, size.height * 0.8),
        ),
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Bag',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Also you can swipe up here to open your bag.',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'stats',
        targetPosition: TargetPosition(
          Size.zero,
          Offset(size.width * 0.8, size.height / 2),
        ),
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Statistics',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'You can swipe left here to view your progress.',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'help',
        keyTarget: _helpKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Need help?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Click here to see this tutorial again.',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    ];

    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      textSkip: 'SKIP TUTORIAL',
      hideSkip: false,
      onFinish: () {
        StorageService.saveHomeTutorialShown(true);
      },
      onSkip: () {
        StorageService.saveHomeTutorialShown(true);
        return true;
      },
    ).show(context: context);
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
    final pet = context.watch<Pet>();
    final stepsManager = context.watch<StepsManager>();
    final challengeManager = context.watch<ChallengeManager>();

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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: const EdgeInsets.all(24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  '🎉 Hatching!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  'Your egg has hatched!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 12),
                Text(
                  'Now you can take care of your pet, play with him and grow it up! 🐒'
                  ' Remember that you can see his feelings just press and hold on him.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ).then((_) {
          _hatchDialogShown = true;
          StorageService.saveHatchShown(true);
          _changePhrase();
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: const EdgeInsets.all(24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  '🎉 Evolution!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  'Your pet has evolved!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 12),
                Text(
                  'You are on the right way, keep taking care of him! 🐒',
                  textAlign: TextAlign.center,
                ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: const EdgeInsets.all(24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  '🎉 Evolution!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  'Your pet has evolved!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 12),
                Text(
                  'You are applying so much effort to take care of him! 🐒',
                  textAlign: TextAlign.center,
                ),
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
        backgroundColor: Colors.orange.shade200,
        leading: Builder(
          builder: (context) => IconButton(
            key: _menuKey,
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            key: _helpKey,
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              setState(() => _tutorialStarted = false);
              _showTutorial();
            },
          ),
        ],
      ),
      drawer: const _AppDrawer(),
      drawerEdgeDragWidth: MediaQuery.of(context).size.width * 0.2,

      // ─────────────── Corpo ───────────────
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! < -300) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true, // per farla full screen
              enableDrag: true, // abilita lo swipe per chiudere
              backgroundColor:
                  Colors.transparent, // opzionale: se vuoi sfondo trasparente
              builder: (context) => Container(
                height:
                    MediaQuery.of(context).size.height *
                    0.95, // 95% altezza schermo
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
                pageBuilder: (context, animation, secondaryAnimation) =>
                    StatsPage(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0); // parte da destra
                      const end = Offset.zero;
                      const curve = Curves.ease;

                      final tween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(CurveTween(curve: curve));
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
            Container(color: Colors.black.withOpacity(0.2)),
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
                        key: _petKey,
                        onLongPressStart: (_) =>
                            setState(() => _showStats = true),
                        onLongPressEnd: (_) =>
                            setState(() => _showStats = false),
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
                      if (_showStats &&
                          !pet.isEgg) // se è un uovo non mostro neanche le statistiche
                        Positioned(
                          top: -110,
                          child: Material(
                            color: Colors.black.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
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
                    child: Text(_currentPhrase, textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 24),

                  // livello & passi
                  Text(
                    'Level ${pet.level}',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32.0,
                      vertical: 4,
                    ),
                    child: LinearProgressIndicator(
                      value: pet.xp / Pet.xpPerLevel,
                      minHeight: 8,
                      backgroundColor: isDayTime
                          ? Colors.black12
                          : Colors.white12,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.lightBlueAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (kDebugMode) ...[
                    Text(
                      'XP: ${pet.xp}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    'steps today: ${stepsManager.dailySteps}',
                    style: TextStyle(
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // pulsanti feed / rewards / play
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedScale(
                        scale: _feedButtonScaling ? 1.1 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: SizedBox(
                          width: 105,
                          height: 80,
                          child: FilledButton(
                            key: _feedKey,
                            onPressed: () {
                              if (pet.isEgg) {
                                showDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (_) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    contentPadding: const EdgeInsets.all(24),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Text(
                                          'Your egg can\'t eat yet! Walk more and try to hatch it.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          'Your egg will hatch when it reaches level 1.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                setState(() => _feedButtonScaling = true);
                                Future.delayed(
                                  const Duration(milliseconds: 200),
                                  () {
                                    if (!mounted) return;
                                    setState(() => _feedButtonScaling = false);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const FeedPage(),
                                      ),
                                    );
                                  },
                                );
                              }
                            },
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.black,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.restaurant),
                                SizedBox(height: 4),
                                Text('Feed'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      AnimatedScale(
                        scale: _rewardsButtonScaling ? 1.1 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: SizedBox(
                          width: 100,
                          height: 80,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              OutlinedButton(
                                key: _rewardsKey,
                                onPressed: () {
                                  setState(() => _rewardsButtonScaling = true);
                                  Future.delayed(
                                    const Duration(milliseconds: 200),
                                        () {
                                      if (!mounted) return;
                                      setState(() => _rewardsButtonScaling = false);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const RewardsPage(),
                                        ),
                                      );
                                    },
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: Colors.orange.shade100,
                                  foregroundColor: Colors.black,
                                  side: const BorderSide(color: Colors.orange),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.card_giftcard),
                                    SizedBox(height: 4),
                                    Text('Rewards', textAlign: TextAlign.center),
                                  ],
                                ),
                              ),
                              if (challengeManager.hasReadyToClaim(stepsManager))
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      AnimatedScale(
                        scale: _playButtonScaling ? 1.1 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: SizedBox(
                          width: 105,
                          height: 80,
                          child: ElevatedButton(
                            key: _playKey,
                            onPressed: () {
                              final pet = context.read<Pet>();
                              if (pet.isEgg) {
                                showDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (_) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    contentPadding: const EdgeInsets.all(24),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Text(
                                          'Your egg cannot play games. Try to hatch it!',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                setState(() => _playButtonScaling = true);
                                Future.delayed(
                                  const Duration(milliseconds: 200),
                                  () {
                                    if (!mounted) return;
                                    setState(() => _playButtonScaling = false);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const GamePage(),
                                      ),
                                    );
                                  },
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.videogame_asset),
                                SizedBox(height: 4),
                                Text('Play', textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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
                    final petRef = context.read<Pet>();

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
            )
          : null,
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
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            iconColor: Colors.black,
            title: const Text('Stats'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StatsPage()),
              );
            },
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
  final petRef = context.read<Pet>();
  final challengeMgr = context.read<ChallengeManager>();
  final bagMgr = context.read<Bag>();

  await StorageService.clearAll();
  await stepsMgr.resetStepsAndGoals();
  await petRef.resetPet();
  await challengeMgr.resetClaimedChallenges();
  await bagMgr.resetBag();
}
