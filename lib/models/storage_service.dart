import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'item.dart';

class StorageService {
  static Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  // 📌 Salva i passi giornalieri
  static Future<void> saveDailySteps(int steps) async {
    final prefs = await _prefs;
    prefs.setInt('dailySteps', steps);
  }

  static Future<int> getDailySteps() async {
    final prefs = await _prefs;
    return prefs.getInt('dailySteps') ?? 0;
  }

  // 📌 Salva i passi settimanali
  static Future<void> saveWeeklySteps(int steps) async {
    final prefs = await _prefs;
    prefs.setInt('weeklySteps', steps);
  }

  // 📌 Salva il livello del pet
  static Future<void> savePetLevel(int level) async {
    final prefs = await _prefs;
    prefs.setInt('petLevel', level);
  }

  static Future<int> getPetLevel() async {
    final prefs = await _prefs;
    return prefs.getInt('petLevel') ?? 0;
  }

  // 📌 Salva se il pet è ancora un uovo
  static Future<void> savePetIsEgg(bool isEgg) async {
    final prefs = await _prefs;
    prefs.setBool('petIsEgg', isEgg);
  }

  static Future<bool> getPetIsEgg() async {
    final prefs = await _prefs;
    return prefs.getBool('petIsEgg') ?? true;
  }

  // 📌 Salva l'ultimo aggiornamento dei valori del pet
  static Future<void> savePetLastUpdated(DateTime lastUpdated) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('lastUpdated', lastUpdated.toIso8601String());
  }

  static Future<DateTime> getPetLastUpdated() async {
    final prefs = await _prefs;
    return DateTime.tryParse(prefs.getString('lastUpdated') ?? '') ?? DateTime.now();
  }

  static Future<void> savePetHunger(int fame) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('petHunger', fame);
  }

  static Future<int> getPetHunger() async {
    final prefs = await _prefs;
    return prefs.getInt('petHunger') ?? 100;
  }

  static Future<void> savePetHappiness(int felicita) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('petHappyness', felicita);
  }

  static Future<int> getPetHappiness() async {
    final prefs = await _prefs;
    return prefs.getInt('petHappyness') ?? 100;
  }

  static Future<void> savePetXp(int xp) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('petXp', xp);
  }

  static Future<int> getPetXp() async {
    final prefs = await _prefs;
    return prefs.getInt('petXp') ?? 0;
  }

  // 📌 Memorizza se il messaggio di schiusa è già stato mostrato
  static Future<void> saveHatchShown(bool shown) async {
    final prefs = await _prefs;
    prefs.setBool('hatchShown', shown);
  }

  static Future<bool> getHatchShown() async {
    final prefs = await _prefs;
    return prefs.getBool('hatchShown') ?? false;
  }

  static Future<int> getWeeklySteps() async {
    final prefs = await _prefs;
    return prefs.getInt('weeklySteps') ?? 0;
  }

  // 📌 Salva passi totali
  static Future<void> saveTotalSteps(int steps) async {
    final prefs = await _prefs;
    prefs.setInt('totalSteps', steps);
  }

  static Future<int> getTotalSteps() async {
    final prefs = await _prefs;
    return prefs.getInt('totalSteps') ?? 0;
  }

  // 📌 Salva il contenuto della bag
  static Future<void> saveBag(Map<Item, int> bag) async {
    final prefs = await _prefs;
    final Map<String, int> bagToSave = {
      for (var entry in bag.entries) entry.key.id: entry.value
    };
    prefs.setString('bag', jsonEncode(bagToSave));
  }

  static Future<Map<Item, int>> getBag() async {
    final prefs = await _prefs;
    final bagData = prefs.getString('bag');
    if (bagData != null) {
      final Map<String, dynamic> decoded = jsonDecode(bagData);
      final Map<Item, int> bag = {};

      for (var entry in decoded.entries) {
        final item = ItemManager().items.firstWhere(
              (element) => element.id == entry.key,
          orElse: () => Item(id: 'unknown', name: 'Sconosciuto', imagePath: ''),
        );
        bag[item] = entry.value as int;
      }

      return bag;
    }
    return {};
  }

  // 📌 Salva le challenge completate
  static Future<void> saveClaimedChallenges(List<String> claimedIds) async {
    final prefs = await _prefs;
    prefs.setStringList('claimedChallenges', claimedIds);
  }

  static Future<List<String>> getClaimedChallenges() async {
    final prefs = await _prefs;
    return prefs.getStringList('claimedChallenges') ?? [];
  }

  // 📌 Salva il dayly goal
  static Future<void> saveDailyGoal(int goal) async {
    final prefs = await _prefs;
    prefs.setInt('dailyGoal', goal);
  }

  static Future<int> getDailyGoal() async {
    final prefs = await _prefs;
    return prefs.getInt('dailyGoal') ?? 2000; // valore di default
  }

  // 📌 Salva il weekly goal
  static Future<void> saveWeeklyGoal(int goal) async {
    final prefs = await _prefs;
    prefs.setInt('weeklyGoal', goal);
  }

  static Future<int> getWeeklyGoal() async {
    final prefs = await _prefs;
    return prefs.getInt('weeklyGoal') ?? 10000; // valore di default
  }

  // 📌 Funzione per resettare tutto (debug/reset)
  static Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}
