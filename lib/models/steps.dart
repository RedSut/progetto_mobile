import 'dart:async';

import 'package:flutter/material.dart';
import 'package:progetto_mobile/models/storage_service.dart';
import 'package:pedometer/pedometer.dart';                // sensore pedometro reale
import 'package:permission_handler/permission_handler.dart';

// TODO: da capire come linkare bene con pet, forse basta chiamare i due metodi ogni volta che si aggiornano i passi
class StepsManager extends ChangeNotifier {
  int _steps = 0;
  int _dailySteps = 0;
  int _weeklySteps = 0;
  int dailyGoal = 2000;
  int weeklyGoal = 10000;

  // 🔄 Costruttore 1 (già presente): chiama _init()
  StepsManager() {
    _init();                         // Inizializzazione personalizzata
  }

  int get steps => _steps;
  int get dailySteps => _dailySteps;
  int get weeklySteps => _weeklySteps;

  double get dailyProgress => _dailySteps / dailyGoal;
  double get weeklyProgress => _weeklySteps / weeklyGoal;

  Timer? _midnightTimer;
  StreamSubscription<StepCount>? _pedometerSub;
  int _lastDeviceSteps = 0;           // valore precedente del sensore

  // 📌 Costruttore 2 (già presente)
  StepsManager.second() {
    startMidnightTimer();
    loadSteps();
    loadGoals();
    // PATCH: richiede permesso e avvia il contapassi solo se concesso
    _ensureActivityPermission().then((granted) {
      if (granted) {
        _startListening();
      } else {
        debugPrint('Permesso ACTIVITY_RECOGNITION negato: il contapassi non verrà avviato.');
      }
    });
  }

  // ---------------------------------------------------------------------------
  // ⬇️  Metodi esistenti (INVARIATI)  ⬇️
  // ---------------------------------------------------------------------------

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

  void startMidnightTimer() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final duration = tomorrow.difference(now);

    _midnightTimer?.cancel();
    _midnightTimer = Timer(duration, () {
      resetDailySteps();
      if (DateTime.now().weekday == DateTime.monday) {
        resetWeeklySteps();
      }
      // Riavvia il timer automaticamente
      startMidnightTimer();
    });
  }

  /// PATCH: verifica e richiede il permesso ACTIVITY_RECOGNITION
  Future<bool> _ensureActivityPermission() async {
    final status = await Permission.activityRecognition.status;
    if (status.isGranted) return true;
    final result = await Permission.activityRecognition.request();
    return result.isGranted;
  }

  void _startListening() {
    _pedometerSub = Pedometer.stepCountStream.listen((event) {
      if (_lastDeviceSteps == 0) {
        _lastDeviceSteps = event.steps;
        return;
      }
      final delta = event.steps - _lastDeviceSteps;
      _lastDeviceSteps = event.steps;
      if (delta > 0) addSteps(delta);
    });
  }

  void _stopListening() {
    _pedometerSub?.cancel();
    _pedometerSub = null;
    _lastDeviceSteps = 0;
  }

  @override
  void dispose() {
    // Per evitare memory leak quando il provider viene distrutto
    _midnightTimer?.cancel();
    _stopListening();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // 🔧  Metodo di inizializzazione originale (non modificato)
  // ---------------------------------------------------------------------------
  Future<void> _init() async {
    startMidnightTimer();
    loadSteps();
    loadGoals();
    // PATCH: avvia _startListening solo se il permesso è concesso
    _ensureActivityPermission().then((granted) {
      if (granted) {
        _startListening();
      } else {
        debugPrint('Permesso ACTIVITY_RECOGNITION negato: il contapassi non verrà avviato.');
      }
    });
  }
}
