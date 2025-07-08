import 'dart:math';

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:progetto_mobile/models/pet.dart';
import 'package:provider/provider.dart';

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
    "You are in the right way!",
    "Great, don't stop!",
  ];

  late String currentPhrase;
  int _highScore = 0;

  @override
  void initState() {
    super.initState();
    _generateRandomPhrase();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    _highScore = await StorageService.getHighScore();
    setState(() {});
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
  }) {
    double progress = 0;
    if (goal != null && goal > 0) {
      progress = (steps / goal).clamp(0.0, 1.0);
    }

    return Column(
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
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque, // importantissimo
        onHorizontalDragUpdate: (details) {
          if (details.delta.dx > 10) {
            Navigator.of(context).pop();
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                const SizedBox(height: 40),
                _buildStatItem(
                  "Daily steps to the goal:",
                  (stepsManager.dailyGoal - stepsManager.dailySteps).clamp(
                    0,
                    stepsManager.dailyGoal,
                  ),
                  goal: stepsManager.dailyGoal,
                ),
                SizedBox(height: 40),
                _buildStatItem(
                  "Weekly steps to the goal:",
                  (stepsManager.weeklyGoal - stepsManager.weeklySteps).clamp(
                    0,
                    stepsManager.weeklyGoal,
                  ),
                  goal: stepsManager.weeklyGoal,
                ),
                const SizedBox(height: 40),
                _buildStatItem(
                  "Lifetime steps",
                  stepsManager.lifetimeSteps,
                  showArc: false,
                ),
                const SizedBox(height: 12),
                RichText(
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
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
