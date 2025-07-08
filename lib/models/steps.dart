import 'dart:async';
import 'pet.dart';
import 'package:flutter/material.dart';
import 'package:progetto_mobile/models/storage_service.dart';
import 'challenge.dart';
import 'package:pedometer/pedometer.dart';                // sensore pedometro reale
import 'package:permission_handler/permission_handler.dart';

class StepsManager extends ChangeNotifier {
  Pet pet;
  ChallengeManager? challengeManager;
  int _steps = 0;
  int _dailySteps = 0;
  int _weeklySteps = 0;
  int _hourlySteps = 0;
  int _minuteSteps = 0;
  int dailyGoal = 2000;
  int weeklyGoal = 10000;
  int hourlyGoal = 500;
  int minuteGoal = 50;

  // 🔄 Costruttore 1: richiede l'istanza di Pet e chiama _init()
  StepsManager(this.pet) {
    _init();                         // Inizializzazione personalizzata
  }

  void attachPet(Pet p) {
    pet = p;
  }

  int get steps => _steps;
  int get dailySteps => _dailySteps;
  int get lifetimeSteps => _steps;
  int get weeklySteps => _weeklySteps;
  int get hourlySteps => _hourlySteps;
  int get minuteSteps => _minuteSteps;

  double get dailyProgress => _dailySteps / dailyGoal;
  double get weeklyProgress => _weeklySteps / weeklyGoal;
  double get hourlyProgress => _hourlySteps / hourlyGoal;
  double get minuteProgress => _minuteSteps / minuteGoal;

  Timer? _midnightTimer;
  Timer? _hourlyTimer;
  Timer? _minuteTimer;
  StreamSubscription<StepCount>? _pedometerSub;
  int _lastDeviceSteps = 0;           // valore precedente del sensore

  // 📌 Costruttore 2 (già presente)
  StepsManager.second(this.pet) {
    startMidnightTimer();
    startHourlyTimer();
    startMinuteTimer();
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
    _hourlySteps = await StorageService.getHourlySteps();
    _minuteSteps = await StorageService.getMinuteSteps();

    final lastDaily = await StorageService.getLastDailyReset();
    final lastWeekly = await StorageService.getLastWeeklyReset();
    final lastHourly = await StorageService.getLastHourlyReset();
    final lastMinute = await StorageService.getLastMinuteReset();
    final now = DateTime.now();

    if (!_isSameDay(now, lastDaily)) {
      resetDailySteps();
    }

    if (!_isSameWeek(now, lastWeekly)) {
      resetWeeklySteps();
    }

    if (!_isSameHour(now, lastHourly)) {
      resetHourlySteps();
    }

    if (!_isSameMinute(now, lastMinute)) {
      resetMinuteSteps();
    }

    notifyListeners();
  }

  // Salva il numero di passi
  Future<void> saveSteps() async {
    StorageService.saveTotalSteps(_steps);
    StorageService.saveDailySteps(_dailySteps);
    StorageService.saveWeeklySteps(_weeklySteps);
    StorageService.saveHourlySteps(_hourlySteps);
    StorageService.saveMinuteSteps(_minuteSteps);
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
    _hourlySteps += steps;
    _minuteSteps += steps;
    pet.applySteps(steps);
    saveSteps();
    notifyListeners(); // Notifica i widget ascoltatori per aggiornare la UI
  }

  void resetDailySteps() {
    _dailySteps = 0;
    StorageService.saveDailySteps(_dailySteps);
    StorageService.saveLastDailyReset(DateTime.now());
    StorageService.removeClaimedChallenge('daily');
    challengeManager?.unclaimChallengeById('daily');
    notifyListeners();
  }

  void resetWeeklySteps() {
    _weeklySteps = 0;
    StorageService.saveWeeklySteps(_weeklySteps);
    StorageService.saveLastWeeklyReset(DateTime.now());
    StorageService.removeClaimedChallenge('weekly');
    challengeManager?.unclaimChallengeById('weekly');
    notifyListeners();
  }

  void resetHourlySteps() {
    _hourlySteps = 0;
    StorageService.saveHourlySteps(_hourlySteps);
    StorageService.saveLastHourlyReset(DateTime.now());
    StorageService.removeClaimedChallenge('hourly');
    challengeManager?.unclaimChallengeById('hourly');
    notifyListeners();
  }

  void resetMinuteSteps() {
    _minuteSteps = 0;
    StorageService.saveMinuteSteps(_minuteSteps);
    StorageService.saveLastMinuteReset(DateTime.now());
    StorageService.removeClaimedChallenge('minute');
    challengeManager?.unclaimChallengeById('minute');
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

  void startHourlyTimer() {
    final now = DateTime.now();
    final nextHour = DateTime(now.year, now.month, now.day, now.hour + 1);
    final duration = nextHour.difference(now);

    _hourlyTimer?.cancel();
    _hourlyTimer = Timer(duration, () {
      resetHourlySteps();
      startHourlyTimer();
    });
  }

  void startMinuteTimer() {
    final now = DateTime.now();
    final nextMinute = DateTime(now.year, now.month, now.day, now.hour, now.minute + 1);
    final duration = nextMinute.difference(now);

    _minuteTimer?.cancel();
    _minuteTimer = Timer(duration, () {
      resetMinuteSteps();
      startMinuteTimer();
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

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isSameWeek(DateTime a, DateTime b) {
    final weekDayA = a.subtract(Duration(days: a.weekday - DateTime.monday));
    final weekDayB = b.subtract(Duration(days: b.weekday - DateTime.monday));
    return _isSameDay(weekDayA, weekDayB);
  }

  bool _isSameHour(DateTime a, DateTime b) {
    return _isSameDay(a, b) && a.hour == b.hour;
  }

  bool _isSameMinute(DateTime a, DateTime b) {
    return _isSameHour(a, b) && a.minute == b.minute;
  }

  // Funzione per resettare i passi
  Future<void> resetStepsAndGoals() async {
    _steps = 0;
    _dailySteps = 0;
    _weeklySteps = 0;
    _hourlySteps = 0;
    _minuteSteps = 0;
    dailyGoal = 2000;
    weeklyGoal = 10000;
    hourlyGoal = 500;
    minuteGoal = 50;
    await StorageService.saveDailyGoal(dailyGoal);
    await StorageService.saveWeeklyGoal(weeklyGoal);
    await StorageService.saveHourlySteps(_hourlySteps);
    await StorageService.saveMinuteSteps(_minuteSteps);
    await saveSteps();
    StorageService.saveLastDailyReset(DateTime.now());
    StorageService.saveLastWeeklyReset(DateTime.now());
    StorageService.saveLastHourlyReset(DateTime.now());
    StorageService.saveLastMinuteReset(DateTime.now());
    StorageService.removeClaimedChallenge('daily');
    StorageService.removeClaimedChallenge('weekly');
    StorageService.removeClaimedChallenge('hourly');
    StorageService.removeClaimedChallenge('debug_minute');
    challengeManager?.unclaimChallengeById('daily');
    challengeManager?.unclaimChallengeById('weekly');
    challengeManager?.unclaimChallengeById('hourly');
    challengeManager?.unclaimChallengeById('debug_minute');
    notifyListeners();
  }

  @override
  void dispose() {
    // Per evitare memory leak quando il provider viene distrutto
    _midnightTimer?.cancel();
    _hourlyTimer?.cancel();
    _minuteTimer?.cancel();
    _stopListening();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // 🔧  Metodo di inizializzazione originale (non modificato)
  // ---------------------------------------------------------------------------
  Future<void> _init() async {
    startMidnightTimer();
    startHourlyTimer();
    startMinuteTimer();
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
