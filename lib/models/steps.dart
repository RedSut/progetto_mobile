
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:progetto_mobile/models/storage_service.dart';
import 'package:pedometer/pedometer.dart';                // pedometro reale

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
  StreamSubscription<StepCount>? _stepSub; // ascolta il pedometro
  int? _lastPedometerSteps;                // valore precedente del sensore

  // 📌 Costruttore
  StepsManager() {
    startMidnightTimer();
    loadSteps();
    loadGoals();
    _initPedometer();
  }

  // Carica il numero di passi salvato
  Future<void> loadSteps() async {
    _steps = await StorageService.getTotalSteps();
    _dailySteps = await StorageService.getDailySteps();
    _weeklySteps = await StorageService.getWeeklySteps();
    notifyListeners();
  }

  // Salva il numero di passi
  Future<void> saveSteps() async {
    StorageService.saveTotalSteps(_steps);
    StorageService.saveDailySteps(_dailySteps);
    StorageService.saveWeeklySteps(_weeklySteps);
  }

  // 📦 Carica gli obiettivi salvati
  Future<void> loadGoals() async {
    dailyGoal = await StorageService.getDailyGoal();
    weeklyGoal = await StorageService.getWeeklyGoal();
    notifyListeners();
  }

  void addSteps(int steps) {
    _steps += steps;
    _dailySteps += steps;
    _weeklySteps += steps;
    saveSteps();
    notifyListeners(); // Notifica i widget ascoltatori per aggiornare la UI
  }

  void resetDailySteps() {
    _dailySteps = 0;
    StorageService.saveDailySteps(_dailySteps);
    notifyListeners();
  }

  void resetWeeklySteps() {
    _weeklySteps = 0;
    StorageService.saveWeeklySteps(_weeklySteps);
    notifyListeners();
  }

  // Avvia l'ascolto del pedometro
  void _initPedometer() {
    _stepSub = Pedometer.stepCountStream.listen(_onStepCount);
  }

  // Gestisce i passi ricevuti dal sensore
  void _onStepCount(StepCount event) {
    if (_lastPedometerSteps == null) {
      _lastPedometerSteps = event.steps;
      return;
    }
    final diff = event.steps - _lastPedometerSteps!;
    if (diff > 0) {
      _lastPedometerSteps = event.steps;
      addSteps(diff); // aggiorna contatori interni e salva
    }
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
    _stepSub?.cancel(); // stop pedometro
    super.dispose();
  }
}