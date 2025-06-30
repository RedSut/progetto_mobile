import 'package:flutter/material.dart';                               // Widget e tema Material
import 'package:progetto_mobile/models/challenge.dart';
import 'package:provider/provider.dart';                              // Provider per dependency injection e stato

import 'models/pet.dart';                                             // Modello Pet (logica di gioco)
import 'models/steps.dart';                                           // Modello StepsManager (logica per i passi)
import 'models/bag.dart';
import 'ui/pages/home_page.dart';                                     // Pagina Home dell’app

void main() {                                                         // Entry point dell’app
  runApp(const PetStepsApp());                                        // Avvia il widget radice PetStepsApp
}

class PetStepsApp extends StatelessWidget {                           // Widget principale, senza stato interno
  const PetStepsApp({super.key});                                     // Costruttore costante (chiave facoltativa)

  @override
  Widget build(BuildContext context) {                                // Descrive l’albero di widget
    return MultiProvider(                                             // Consente più provider a livello globale
      providers: [                                                    // Elenco dei provider disponibili
        ChangeNotifierProvider(create: (_) => Pet()),                 // Istanza di Pet, osservabile dai widget
        ChangeNotifierProvider(create: (_) => StepsManager()),        // Istanza di StepsManager, osservabile dai widget
        ChangeNotifierProvider(create: (_) => Bag()),
        ChangeNotifierProvider(create: (_) => ChallengeManager()),
      ],
      child: MaterialApp(                                             // App Material (gestisce routing, tema, ecc.)
        title: 'Pet Steps',                                           // Titolo mostrato su Android task-switcher
        theme: ThemeData(                                             // Tema globale per colori e stile
          colorSchemeSeed: Colors.indigo,                             // Seed per generare palette Material 3
          useMaterial3: true,                                         // Abilita componenti Material You
        ),
        home: const HomePage(),                                       // Prima schermata visualizzata
      ),
    );
  }
}
