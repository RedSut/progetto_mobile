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

  // 📌 Salva i passi orari
  static Future<void> saveHourlySteps(int steps) async {
    final prefs = await _prefs;
    prefs.setInt('hourlySteps', steps);
  }

  static Future<int> getHourlySteps() async {
    final prefs = await _prefs;
    return prefs.getInt('hourlySteps') ?? 0;
  }

  // 📌 Salva i passi al minuto
  static Future<void> saveMinuteSteps(int steps) async {
    final prefs = await _prefs;
    prefs.setInt('minuteSteps', steps);
  }

  static Future<int> getMinuteSteps() async {
    final prefs = await _prefs;
    return prefs.getInt('minuteSteps') ?? 0;
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

  // 📌 Salva il livello di evoluzione del pet (0 uovo, 1 Mostro, ...)
  static Future<void> savePetEvolutionStage(int stage) async {
    final prefs = await _prefs;
    prefs.setInt('petEvolutionStage', stage);
  }

  static Future<int> getPetEvolutionStage() async {
    final prefs = await _prefs;
    return prefs.getInt('petEvolutionStage') ?? 0;
  }

  // 📌 Salva l'ultimo aggiornamento dei valori del pet
  static Future<void> savePetLastUpdated(DateTime lastUpdated) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('lastUpdated', lastUpdated.toIso8601String());
  }

  static Future<DateTime> getPetLastUpdated() async {
    final prefs = await _prefs;
    return DateTime.tryParse(prefs.getString('lastUpdated') ?? '') ??
        DateTime.now();
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

  // 📌 Salva il punteggio massimo del gioco
  static Future<void> saveHighScore(int score) async {
    final prefs = await _prefs;
    prefs.setInt('highScore', score);
  }

  static Future<int> getHighScore() async {
    final prefs = await _prefs;
    return prefs.getInt('highScore') ?? 0;
  }

  // 📌 Salva il contenuto della bag
  static Future<void> saveBag(Map<Item, int> bag) async {
    final prefs = await _prefs;
    final Map<String, int> bagToSave = {
      for (var entry in bag.entries) entry.key.id: entry.value,
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
          orElse: () => Item(
            id: 'unknown',
            name: 'Sconosciuto',
            imagePath: '',
            description: '',
          ),
        );
        bag[item] = entry.value as int;
      }

      return bag;
    }
    return {};
  }

  // 📌 Salva le challenge claimate
  static Future<void> saveClaimedChallenges(List<String> claimedIds) async {
    final prefs = await _prefs;
    prefs.setStringList('claimedChallenges', claimedIds);
  }

  static Future<List<String>> getClaimedChallenges() async {
    final prefs = await _prefs;
    return prefs.getStringList('claimedChallenges') ?? [];
  }

  // Rimuove una challenge dalla lista delle completate
  static Future<void> removeClaimedChallenge(String id) async {
    final prefs = await _prefs;
    final claimed = prefs.getStringList('claimedChallenges') ?? [];
    claimed.remove(id);
    prefs.setStringList('claimedChallenges', claimed);
  }

  // Salva l'ultima data di reset giornaliero
  static Future<void> saveLastDailyReset(DateTime date) async {
    final prefs = await _prefs;
    prefs.setString('lastDailyReset', date.toIso8601String());
  }

  static Future<DateTime> getLastDailyReset() async {
    final prefs = await _prefs;
    final stored = prefs.getString('lastDailyReset');
    return stored != null
        ? DateTime.tryParse(stored) ?? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(0);
  }

  // Salva l'ultima data di reset settimanale
  static Future<void> saveLastWeeklyReset(DateTime date) async {
    final prefs = await _prefs;
    prefs.setString('lastWeeklyReset', date.toIso8601String());
  }

  static Future<DateTime> getLastWeeklyReset() async {
    final prefs = await _prefs;
    final stored = prefs.getString('lastWeeklyReset');
    return stored != null
        ? DateTime.tryParse(stored) ?? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(0);
  }

  // Salva l'ultima data di reset orario
  static Future<void> saveLastHourlyReset(DateTime date) async {
    final prefs = await _prefs;
    prefs.setString('lastHourlyReset', date.toIso8601String());
  }

  static Future<DateTime> getLastHourlyReset() async {
    final prefs = await _prefs;
    final stored = prefs.getString('lastHourlyReset');
    return stored != null
        ? DateTime.tryParse(stored) ?? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(0);
  }

  // Salva l'ultima data di reset al minuto
  static Future<void> saveLastMinuteReset(DateTime date) async {
    final prefs = await _prefs;
    prefs.setString('lastMinuteReset', date.toIso8601String());
  }

  static Future<DateTime> getLastMinuteReset() async {
    final prefs = await _prefs;
    final stored = prefs.getString('lastMinuteReset');
    return stored != null
        ? DateTime.tryParse(stored) ?? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(0);
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

  // 📌 Memorizza se il tutorial della home è stato mostrato
  static Future<void> saveHomeTutorialShown(bool shown) async {
    final prefs = await _prefs;
    prefs.setBool('homeTutorialShown', shown);
  }

  static Future<bool> getHomeTutorialShown() async {
    final prefs = await _prefs;
    return prefs.getBool('homeTutorialShown') ?? false;
  }

  // 📌 Memorizza se il tutorial delle statistiche è stato mostrato
  static Future<void> saveStatsTutorialShown(bool shown) async {
    final prefs = await _prefs;
    prefs.setBool('statsTutorialShown', shown);
  }

  static Future<bool> getStatsTutorialShown() async {
    final prefs = await _prefs;
    return prefs.getBool('statsTutorialShown') ?? false;
  }

  // 📌 Memorizza se il tutorial della pagina feed è stato mostrato
  static Future<void> saveFeedTutorialShown(bool shown) async {
    final prefs = await _prefs;
    prefs.setBool('feedTutorialShown', shown);
  }

  static Future<bool> getFeedTutorialShown() async {
    final prefs = await _prefs;
    return prefs.getBool('feedTutorialShown') ?? false;
  }

  // 📌 Funzione per resettare tutto (debug/reset)
  static Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}
