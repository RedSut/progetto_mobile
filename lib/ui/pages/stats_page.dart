import 'dart:math';

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:progetto_mobile/models/pet.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../models/steps.dart'; // importa la tua classe StepsManager
import '../../models/storage_service.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final List<String> motivationalPhrases = [
    "Great energy today!",
    "Keep going, you are great!",
    "Every step count!",
    "Your pet is proud of you!",
    "Great, don't stop!",
  ];

  late String currentPhrase;
  int _highScore = 0;
  bool _tutorialStarted = false;
  final GlobalKey _evolutionKey = GlobalKey();
  final GlobalKey _dailyKey = GlobalKey();
  final GlobalKey _weeklyKey = GlobalKey();
  final GlobalKey _lifetimeKey = GlobalKey();
  final GlobalKey _helpKey = GlobalKey();
  final GlobalKey _scoreKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _generateRandomPhrase();
    _loadHighScore();
    _initTutorial();
  }

  Future<void> _initTutorial() async {
    final shown = await StorageService.getStatsTutorialShown();
    if (!shown && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showTutorial());
    }
  }

  Future<void> _loadHighScore() async {
    _highScore = await StorageService.getHighScore();
    setState(() {});
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _generateRandomPhrase() {
    final random = Random();
    currentPhrase =
        motivationalPhrases[random.nextInt(motivationalPhrases.length)];
  }

  Widget _buildStatItem(
    String label,
    int steps, {
    int? goal,
    bool showArc = true,
    Key? key,
  }) {
    double progress = 0;
    if (goal != null && goal > 0) {
      progress = (steps / goal).clamp(0.0, 1.0);
    }

    return Column(
      key: key,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        if (showArc)
          ClipRect(
            child: SizedBox(
              height: 90, // metà diametro per il semicerchio
              child: CircularPercentIndicator(
                radius: 90.0,
                lineWidth: 22.0,
                percent: progress,
                backgroundColor: Colors.yellowAccent,
                progressColor: Colors.orangeAccent,
                circularStrokeCap: CircularStrokeCap.round,
                startAngle: 180,
                arcType: ArcType.HALF,
                animation: true,
                animateFromLastPercent: true,
              ),
            ),
          ),
        const SizedBox(height: 2), // piccolo spazio tra semicerchio e testo
        Text(
          "$steps steps",
          style: const TextStyle(fontSize: 22, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildEvolutionImage(String asset, int stage, int currentStage) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(
          color: currentStage == stage ? Colors.orange : Colors.transparent,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Image.asset(asset, width: 50, height: 50),
    );
  }

  void _showTutorial() {
    if (_tutorialStarted) return;
    _tutorialStarted = true;
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    Future.delayed(const Duration(milliseconds: 350), _showTutorialPart1);
  }

  void _showTutorialPart1() {
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
                  'This is your stats page!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'These sections show your whole statistics. Track your progress here!\n',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'evolution',
        keyTarget: _evolutionKey,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Pet evolution',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Here you can see your discovered evolution of the pet.',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'daily',
        keyTarget: _dailyKey,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Daily goal',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'This arc shows how many steps are left to do today. You can change '
                  'your daily goal in the settings.',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'weekly',
        keyTarget: _weeklyKey,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Weekly goal',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Keep walking to reach the weekly goal! You can change '
                  'your weekly goal in the settings.',
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
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
        Future.delayed(const Duration(milliseconds: 350), _showTutorialPart2);
      },
      onSkip: () {
        StorageService.saveStatsTutorialShown(true);
        return true;
      },
    ).show(context: context);
  }

  void _showTutorialPart2() {
    final targets = [
      TargetFocus(
        identify: 'lifetime',
        keyTarget: _lifetimeKey,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Lifetime stats',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Here you have your total steps!',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'Game high score',
        keyTarget: _scoreKey,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Game high score',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Here is your high score in the minigame.',
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
        shape: ShapeLightFocus.RRect,
        radius: 12,
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
                  'Tap here to view this tutorial again.',
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
        StorageService.saveStatsTutorialShown(true);
      },
      onSkip: () {
        StorageService.saveStatsTutorialShown(true);
        return true;
      },
    ).show(context: context);
  }

  @override
  Widget build(BuildContext context) {
    // Prendo l'istanza aggiornata di StepsManager da Provider
    final stepsManager = context.watch<StepsManager>();
    final pet = Provider.of<Pet>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF688D92),
      appBar: AppBar(
        title: const Text(
          "Stats",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF688D92),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (details) {
          if (details.delta.dx > 10) {
            Navigator.of(context).pop();
          }
        },
        child: Center(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  key: _evolutionKey,
                  child: Column(
                    children: [
                      const Text(
                        'Knowed evolution of pet:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 0; i <= pet.evolutionStage; i++)
                            _buildEvolutionImage(
                              i == 0
                                  ? 'assets/egg.png'
                                  : i == 1
                                  ? 'assets/Monster.png'
                                  : i == 2
                                  ? 'assets/Monster1.png'
                                  : 'assets/Monster2.png',
                              i,
                              pet.evolutionStage,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                _buildStatItem(
                  "Daily goal:",
                  (stepsManager.dailySteps).clamp(0, stepsManager.dailyGoal),
                  goal: stepsManager.dailyGoal,
                  key: _dailyKey,
                ),
                SizedBox(height: 40),
                _buildStatItem(
                  "Weekly goal:",
                  (stepsManager.weeklySteps).clamp(0, stepsManager.weeklyGoal),
                  goal: stepsManager.weeklyGoal,
                  key: _weeklyKey,
                ),
                const SizedBox(height: 40),
                _buildStatItem(
                  "Lifetime steps",
                  stepsManager.lifetimeSteps,
                  showArc: false,
                  key: _lifetimeKey,
                ),
                const SizedBox(height: 40),
                Container(
                  key: _scoreKey,
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 22, color: Colors.white),
                      children: [
                        const TextSpan(
                          text: 'High score in the game: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: '$_highScore'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: pet.isEgg
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                color: const Color(0xFF688D92),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Image.asset(pet.imagePath, width: 60, height: 60),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          currentPhrase,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
