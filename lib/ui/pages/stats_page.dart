import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:progetto_mobile/models/pet.dart';
import 'dart:math';
import 'package:provider/provider.dart';

import '../../models/steps.dart'; // importa la tua classe StepsManager

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final List<String> motivationalPhrases = [
    "Grande energia oggi!",
    "Continua così, sei una macchina!",
    "Ogni passo conta!",
    "Il tuo pet è fiero di te!",
    "Sei sulla strada giusta!",
    "Ottimo ritmo, non fermarti!"
  ];

  late String currentPhrase;

  @override
  void initState() {
    super.initState();
    _generateRandomPhrase();
  }

  void _generateRandomPhrase() {
    final random = Random();
    currentPhrase = motivationalPhrases[random.nextInt(motivationalPhrases.length)];
  }

  Widget _buildStatItem(String label, int steps, {int? goal, bool showArc = true}) {
    double progress = 0;
    if (goal != null && goal > 0) {
      progress = (steps / goal).clamp(0.0, 1.0);
    }

    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
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

  @override
  Widget build(BuildContext context) {
    // Prendo l'istanza aggiornata di StepsManager da Provider
    final stepsManager = context.watch<StepsManager>();
    final pet = Provider.of<Pet>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF688D92),
      appBar: AppBar(
        title:
        const Text("Stats", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF688D92),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatItem("Daily steps", stepsManager.dailySteps,
                  goal: stepsManager.dailyGoal),
              const SizedBox(height: 40),
              _buildStatItem("Weekly steps", stepsManager.weeklySteps,
                  goal: stepsManager.weeklyGoal),
              const SizedBox(height: 40),
              _buildStatItem("Lifetime steps", stepsManager.steps,
                  showArc: false),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: const Color(0xFF688D92),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Image.asset(
              pet.imagePath,
              width: 60,
              height: 60,
            ),
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
    );
  }
}

