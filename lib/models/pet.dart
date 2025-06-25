import 'package:flutter/material.dart';               // Necessario per ChangeNotifier

class Pet extends ChangeNotifier {                    // Modello che rappresenta il mostro e notifica i listener
  int level = 0;                                      // Livello di esperienza attuale
  int stepsToday = 0;                                 // Passi accumulati nell’arco della giornata
  int hunger = 100;                                   // Stato di fame (0 = affamato, 100 = sazio)
  int happiness = 100;                                // Stato di felicità (0 = triste, 100 = felice)

  /// Aggiorna i passi ricevuti dal pedometro
  void addSteps(int amount) {                         // Metodo pubblico per incrementare i passi
    stepsToday += amount;                             // Somma i nuovi passi al contatore giornaliero
    _gainExperience(amount);                          // Converte i passi in esperienza/level-up
    notifyListeners();                                // Avvisa i widget che devono ridisegnarsi
  }

  void feed(int foodValue) {                          // Nutre il mostro con un valore di cibo
    hunger = (hunger + foodValue).clamp(0, 100);      // Aumenta hunger e ne limita il range 0-100
    notifyListeners();                                // Notifica eventuali listener del cambiamento
  }

  void _gainExperience(int xp) {                      // Logica interna di aumento livello
    level += (xp ~/ 1000);                            // Converte 1000 passi in 1 livello (es. 2500 passi → +2)
  }
}
