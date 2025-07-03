import 'package:flutter/material.dart';            // Necessario per ChangeNotifier
import 'notification_service.dart';
import 'storage_service.dart';

class Pet extends ChangeNotifier {
  int level = 0;
  int hunger = 100;
  int happiness = 100;
  bool isEgg = true;

  int _xp = 0;
  String imagePath = 'assets/mostro.png';
  DateTime lastUpdated = DateTime.now();

  Future<void> loadPet() async {
    level = await StorageService.getPetLevel();
    isEgg = await StorageService.getPetIsEgg();
    hunger = await StorageService.getPetHunger();
    happiness = await StorageService.getPetHappiness();
    lastUpdated = await StorageService.getPetLastUpdated();

    _updateStatsFromTime();  // Appena caricati, aggiorna valori da tempo passato
    notifyListeners();
  }

  Future<void> savePet() async {
    await StorageService.savePetLevel(level);
    await StorageService.savePetIsEgg(isEgg);
    await StorageService.savePetHunger(hunger);
    await StorageService.savePetHappiness(happiness);
    await StorageService.savePetLastUpdated(lastUpdated);
  }

  void _updateStatsFromTime() {
    final now = DateTime.now();
    final elapsedMinutes = now.difference(lastUpdated).inMinutes;

    if (elapsedMinutes > 0) {
      hunger = (hunger - elapsedMinutes).clamp(0, 100);
      happiness = (happiness - (elapsedMinutes / 2).round()).clamp(0, 100);
      lastUpdated = now;
      savePet();
      _checkPetStatus();
    }
  }

  void updateExp(int amount) {
    if (level >= 100) return;

    _xp += amount;
    while (_xp >= 1000 && level < 100) {
      _xp -= 1000;
      level++;
    }
    if (level > 0) isEgg = false;
    if (level >= 100) _xp = 0;

    savePet();
    notifyListeners();
  }

  void feed(int foodValue) {
    hunger = (hunger + foodValue).clamp(0, 100);
    happiness = (happiness + (foodValue ~/ 2)).clamp(0, 100);
    savePet();
    notifyListeners();
  }

  void _checkPetStatus() {
    if (hunger < 30) {
      NotificationService().showNotification(
          'Il tuo pet ha fame!', 'Vai a dargli da mangiare!'
      );
    }
    if (happiness < 30) {
      NotificationService().showNotification(
          'Il tuo pet è triste!', 'Fallo giocare un po\'!'
      );
    }
  }
}
