import 'package:flutter/material.dart';                                   // Widget Material di base
import 'package:provider/provider.dart';                                  // Per consumare il modello Pet
import '../../models/pet.dart';                                           // Importa la logica del pet

class HomePage extends StatelessWidget {                                  // Home screen senza stato dedicato
  const HomePage({super.key});                                            // Costruttore const

  @override
  Widget build(BuildContext context) {                                    // Descrive la UI
    final pet = context.watch<Pet>();                                     // Ascolta i cambiamenti del modello Pet

    return Scaffold(                                                      // Layout base con AppBar e Drawer
      appBar: AppBar(title: const Text('Pet Steps')),                     // Barra superiore con titolo fisso
      drawer: const _AppDrawer(),                                         // Menu laterale con voci Bag/Stats/Settings
      body: Center(                                                       // Centra il contenuto
        child: Column(                                                    // Dispone i widget in verticale
          mainAxisSize: MainAxisSize.min,                                 // Occupa solo lo spazio necessario
          children: [
            const CircleAvatar(                                           // Avatar circolare (placeholder creature)
              radius: 80,                                                 // Raggio di 80 px
              child: Text('🥚', style: TextStyle(fontSize: 64)),           // Emoji uovo come asset temporaneo
            ),
            const SizedBox(height: 16),                                   // Spazio verticale
            Text(                                                         // Mostra il livello corrente
              'Livello ${pet.level}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),                                    // Altro spacing
            Text('Passi oggi: ${pet.stepsToday}'),                        // Conta passi giornalieri
            const SizedBox(height: 24),                                   // Spazio prima dei pulsanti
            FilledButton(                                                 // Pulsante “Feed him”
              onPressed: () => pet.feed(20),                              // Nutre il pet con valore 20
              child: const Text('Feed him'),
            ),
            const SizedBox(height: 8),                                    // Spazio
            OutlinedButton(                                               // Pulsante “Claim rewards”
              onPressed: () {                                             // Handler ancora da implementare
                // TODO: apri schermata ricompense
              },
              child: const Text('Claim rewards'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {                                // Drawer personalizzato
  const _AppDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(                                                        // Drawer laterale
      child: ListView(                                                    // Lista scrollabile di opzioni
        children: [
          DrawerHeader(                                                   // Testata del menu
            child: Column(                                                // Contenuto in colonna
              children: [
                const Text('Pet Steps', style: TextStyle(fontSize: 24)),  // Titolo dell’app
                const SizedBox(height: 8),                                // Spazio
                Text('Ciao, allenati!'),                                  // Messaggio di benvenuto
              ],
            ),
          ),
          ListTile(                                                       // Opzione “Bag”
            leading: const Icon(Icons.backpack),                          // Icona zaino
            title: const Text('Bag'),                                     // Testo voce
            onTap: () {/* TODO */},                                       // Callback da implementare
          ),
          ListTile(                                                       // Opzione “Stats”
            leading: const Icon(Icons.bar_chart),                         // Icona grafico
            title: const Text('Stats'),
            onTap: () {/* TODO */},
          ),
          ListTile(                                                       // Opzione “Settings”
            leading: const Icon(Icons.settings),                          // Icona ingranaggio
            title: const Text('Settings'),
            onTap: () {/* TODO */},
          ),
        ],
      ),
    );
  }
}
