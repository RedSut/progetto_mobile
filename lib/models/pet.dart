import 'package:flutter/material.dart';            // Necessario per ChangeNotifier
import 'storage_service.dart';

class Pet extends ChangeNotifier {
  int level      = 0;
  int hunger     = 100;
  int happiness  = 100;
  bool isEgg     = true;

  int _xp = 0;                     // esperienza accumulata

  String imagePath = 'assets/mostro.png'; //TODO: da mettere l'immagine del pet ed aggiornarla alla schiusura

  Future<void> loadPet() async {
    level  = await StorageService.getPetLevel();
    isEgg  = await StorageService.getPetIsEgg();
    notifyListeners();
  }

  Future<void> savePet() async {
    await StorageService.savePetLevel(level);
    await StorageService.savePetIsEgg(isEgg);
  }

  /// Aggiunge [amount] passi/XP e gestisce il livello (max 100)
  void updateExp(int amount) {
    if (level >= 100) return;      // già al massimo → esci

    _xp += amount;

    // Converte 1000 XP = +1 livello finché resta XP e level < 100
    while (_xp >= 1000 && level < 100) {
      _xp -= 1000;
      level++;
    }

    if (level > 0) isEgg = false;

    // Se si è appena raggiunto il livello 100, azzera l’XP residuo
    if (level >= 100) _xp = 0;

    savePet();
    notifyListeners();
  }

  void feed(int foodValue) {
    hunger     = (hunger    + foodValue      ).clamp(0, 100);
    happiness  = (happiness + foodValue ~/ 2 ).clamp(0, 100);
    notifyListeners();
  }
}
