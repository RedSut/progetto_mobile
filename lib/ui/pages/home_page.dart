import 'dart:async';
import 'package:flutter/foundation.dart';            // kDebugMode
import 'package:flutter/material.dart';
import 'package:progetto_mobile/models/challenge.dart';
import 'package:progetto_mobile/models/storage_service.dart';
import 'package:progetto_mobile/ui/pages/settings_page.dart';
import 'package:provider/provider.dart';

import '../../models/bag.dart';
import '../../models/pet.dart';
import '../../models/steps.dart';
import 'bag_page.dart';
import 'claim_rewards.dart';
import 'stats_page.dart';
import 'feed_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showStats = false;
  Timer? _mockStepTimer;
  int _previousLevel = -1;                          // livello precedente; -1 se non caricato
  bool _hatchDialogShown = false;

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  Future<void> _initAsync() async {
    final stepsManager = Provider.of<StepsManager>(context, listen: false);
    await stepsManager.loadSteps();
    await stepsManager.loadGoals();

    final challengeManager = Provider.of<ChallengeManager>(context, listen: false);
    await challengeManager.loadClaimedStatuses();

    final bag = Provider.of<Bag>(context, listen: false);
    await bag.loadBag();

    final pet = Provider.of<Pet>(context, listen: false);
    await pet.loadPet();
    setState(() {
      _previousLevel = pet.level;
    });

    final hatchShown = await StorageService.getHatchShown();
    setState(() {
      _hatchDialogShown = hatchShown;
    });
  }


  @override
  void dispose() {
    _mockStepTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pet          = context.watch<Pet>();
    final stepsManager = context.watch<StepsManager>();

    // ─── Messaggio quando il pet passa da livello 0 a 1 ───
      if (!_hatchDialogShown &&
          _previousLevel != -1 &&
          _previousLevel == 0 &&
          pet.level == 1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              contentPadding: const EdgeInsets.all(24),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('🎉 Evoluzione!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Text('Il tuo pet si è schiuso!', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
                  SizedBox(height: 12),
                  Text('Prenditene cura e fallo crescere! 🐣', textAlign: TextAlign.center),
                ],
              ),
            ),

          ).then((_) {
          _hatchDialogShown = true;
          StorageService.saveHatchShown(true);
          });
        });
      }

    _previousLevel = pet.level;

    return Scaffold(
      appBar: AppBar(title: const Text('Pet Steps')),
      drawer: const _AppDrawer(),

      // ─────────────── Corpo ───────────────
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // avatar + overlay
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onLongPressStart: (_) => setState(() => _showStats = true),
                  onLongPressEnd:   (_) => setState(() => _showStats = false),
                  child: CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.indigo.shade100,
                    child: Image.asset(
                      pet.isEgg ? 'assets/egg.png' : 'assets/Monster.png',
                      width: 240,
                      height: 240,
                    ),
                  ),
                ),
                if (_showStats)
                  Positioned(
                    top: -110,
                    child: Material(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _StatBar(
                              label: 'Fame',
                              value: pet.hunger,
                              icon: Icons.restaurant,
                            ),
                            const SizedBox(height: 8),
                            _StatBar(
                              label: 'Felicità',
                              value: pet.happiness,
                              icon: Icons.emoji_emotions,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // livello & passi
            Text('Livello ${pet.level}',
                style: Theme.of(context).textTheme.titleLarge),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 4),
              child: LinearProgressIndicator(
                value: pet.xp / Pet.xpPerLevel,
                minHeight: 8,
                backgroundColor: Colors.black12,
                valueColor:
                const AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
              ),
            ),
            const SizedBox(height: 4),
            Text('Passi oggi: ${stepsManager.dailySteps}'),
            const SizedBox(height: 24),

            // pulsanti feed / rewards
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FeedPage()),
                );
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size(150, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: const Text('Feed him'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RewardsPage()),
                );
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(150, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: const Text('Claim rewards'),
            ),
          ],
        ),
      ),

      // ───────────── Pulsanti debug ─────────────
      floatingActionButton: kDebugMode
      ? Column(
      mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'debugWalk',
            tooltip: '+500 passi',
            child: const Icon(Icons.directions_walk),
            onPressed: () {
              final stepsMgr = context.read<StepsManager>();
              final petRef   = context.read<Pet>();

              stepsMgr.addSteps(500);
              petRef.updateExp(500);
            },
          ),
          const SizedBox(height: 12),
          FloatingActionButton.small(
            heroTag: 'debugReset',
            tooltip: 'Reset app',
            backgroundColor: Colors.redAccent,
            child: const Icon(Icons.restart_alt),
            onPressed: () async {
              resetApp(context);

              setState(() {
                _previousLevel = -1;
                _hatchDialogShown = false;
              });

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dati resettati')),
                );
              }
            },
          ),
        ],
      ): null,
    );
  }
}

/// Barra di progresso fame / felicità
class _StatBar extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;

  const _StatBar({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
        const SizedBox(width: 8),
        Container(
          width: 120,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value / 100,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.greenAccent,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Drawer invariato
class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            child: Column(
              children: [
                Text('Pet Steps', style: TextStyle(fontSize: 24)),
                SizedBox(height: 8),
                Text('Ciao, allenati!'),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.backpack),
            title: const Text('Bag'),
            onTap: () {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BagPage()),
            );},
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Stats'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StatsPage()),
              );},
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

Future<void> resetApp(BuildContext context) async {
  final stepsMgr = context.read<StepsManager>();
  final petRef   = context.read<Pet>();
  final challengeMgr   = context.read<ChallengeManager>();
  final bagMgr   = context.read<Bag>();

  await StorageService.clearAll();
  await stepsMgr.resetStepsAndGoals();
  await petRef.resetPet();
  await challengeMgr.resetClaimedChallenges();
  await bagMgr.resetBag();
}