import 'package:flutter/material.dart';            // Necessario per ChangeNotifier
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'notification_service.dart';
import 'storage_service.dart';

class Pet extends ChangeNotifier {
  static const int maxLevel = 100;
  static const int xpPerLevel = 1000;
  static const int hungerNotificationThreshold = 30;

  int level = 0;
  int hunger = 100;
  int happiness = 100;
  bool isEgg = true;

  Timer? _happinessTimer;

  int _xp = 0;
  int get xp => _xp;

  String imagePath = 'assets/egg.png';
  DateTime lastUpdated = DateTime.now();

  Future<void> loadPet() async {
    level = await StorageService.getPetLevel();
    isEgg = await StorageService.getPetIsEgg();
    hunger = await StorageService.getPetHunger();
    happiness = await StorageService.getPetHappiness();
    lastUpdated = await StorageService.getPetLastUpdated();
    _xp = await StorageService.getPetXp();

    if (isEgg){
      imagePath = 'assets/egg.png';
    }else{
      imagePath = 'assets/Monster.png';
    }

    _updateStatsFromTime();  // Appena caricati, aggiorna valori da tempo passato
    notifyListeners();
  }

  Future<void> savePet() async {
    await StorageService.savePetLevel(level);
    await StorageService.savePetIsEgg(isEgg);
    await StorageService.savePetHunger(hunger);
    await StorageService.savePetHappiness(happiness);
    await StorageService.savePetLastUpdated(lastUpdated);
    await StorageService.savePetXp(_xp);
  }

  void _updateStatsFromTime() {
    final now = DateTime.now();
    final elapsedMinutes = now.difference(lastUpdated).inMinutes;

    if (elapsedMinutes > 0) {
      if (!isEgg) {
        _decreaseHunger(elapsedMinutes);
        _decreaseHappiness(elapsedMinutes);
        _checkPetStatus();
        _updateHappinessTimer();
      }
      lastUpdated = now;
      savePet();
    }
  }

  void _decreaseHunger(int minutes) {
    hunger = (hunger - minutes).clamp(0, 100);
    _updateHappinessTimer();
  }

  void _decreaseHappiness(int minutes) {
    happiness = (happiness - (minutes / 2).round()).clamp(0, 100);
  }

  void _updateHappinessTimer() {
    if (hunger < 50) {
      _happinessTimer ??= Timer.periodic(const Duration(seconds: 1), (_) {
        if (hunger < 50) {
          happiness = (happiness - 1).clamp(0, 100);
          savePet();
          notifyListeners();
        }
      });
    } else {
      _happinessTimer?.cancel();
      _happinessTimer = null;
    }
  }

  void applySteps(int steps) {
    if (!isEgg){
      hunger = (hunger - (steps * 2)).clamp(0, 100);
      happiness = (happiness + steps).clamp(0, 100);
      _updateHappinessTimer();
    }
    lastUpdated = DateTime.now();
    savePet();
    notifyListeners();
  }

  void updateExp(int amount) {
    if (level >= maxLevel) return;

    _xp += amount;
    while (_xp >= xpPerLevel && level < maxLevel) {
      _xp -= xpPerLevel;
      level++;
    }
    if (level > 0) {
      isEgg = false;
      imagePath = 'assets/Monster.png';
    }
    if (level >= 100) _xp = 0;

    savePet();
    notifyListeners();
  }

  void feed(int foodValue) {
    hunger = (hunger + foodValue).clamp(0, 100);
    happiness = (happiness + (foodValue ~/ 2)).clamp(0, 100);
    _updateHappinessTimer();
    savePet();
    notifyListeners();
  }

  /// PATCH: verifica e richiede il permesso ACTIVITY_RECOGNITION
  Future<bool> _ensureNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isGranted) return true;
    final result = await Permission.notification.request();
    return result.isGranted;
  }

  Future<void> _checkPetStatus() async {
    final granted = await _ensureNotificationPermission();
    if (granted) {
      if (hunger < hungerNotificationThreshold) {
        NotificationService().showNotification('Il tuo pet ha fame!', 'Vai a dargli da mangiare!');
      }
      if (happiness < hungerNotificationThreshold) {
        NotificationService().showNotification('Il tuo pet è triste!', 'Fallo giocare un po\'!');
      }
    } else {
      debugPrint('Permesso NOTIFICATION negato: le notifiche non verranno mostrate.');
    }
  }

  Future<void> resetPet() async {
    level = 0;
    _xp = 0;
    hunger = 100;
    happiness = 100;
    isEgg = true;
    imagePath = 'assets/egg.png';
    lastUpdated = DateTime.now();
    _updateHappinessTimer();
    await savePet();
    notifyListeners();
  }

  @override
  void dispose() {
    _happinessTimer?.cancel();
    super.dispose();
  }

}