
import 'dart:async';

import 'package:flutter/material.dart';
import 'pet.dart';

// TODO: da capire come linkare bene con pet, forse basta chiamare i due metodi ogni volta che si aggiornano i passi
class StepsManager extends ChangeNotifier {
  int _steps = 0;
  int _dailySteps = 0;
  int _weeklySteps = 0;
  int dailyGoal = 2000;
  int weeklyGoal = 10000;

  int get steps => _steps;
  int get dailySteps => _dailySteps;
  int get weeklySteps => _weeklySteps;

  double get dailyProgress => _dailySteps / dailyGoal;
  double get weeklyProgress => _weeklySteps / weeklyGoal;

  Timer? _midnightTimer;

  // 📌 Costruttore
  StepsManager() {
    startMidnightTimer();
  }

  void addSteps(int steps) {
    _steps += steps;
    _dailySteps += steps;
    _weeklySteps += steps;
    notifyListeners(); // Notifica i widget ascoltatori per aggiornare la UI
  }

  void resetDailySteps() {
    _dailySteps = 0;
    notifyListeners();
  }

  void resetWeeklySteps() {
    _weeklySteps = 0;
    notifyListeners();
  }

  void startMidnightTimer() {
    // Ogni minuto controlla se è mezzanotte
    _midnightTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      final now = DateTime.now();
      if (now.hour == 0 && now.minute == 0) {
        resetDailySteps();
        if (now.weekday == DateTime.monday) {
          resetWeeklySteps();
        }
      }
    });
  }
  @override
  void dispose() {
    // Per evitare memory leak quando il provider viene distrutto
    _midnightTimer?.cancel();
    super.dispose();
  }
}