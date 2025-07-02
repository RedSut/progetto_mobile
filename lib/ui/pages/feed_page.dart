import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/pet.dart';
import '../../models/bag.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  /// Valori di nutrimento per ogni cibo. Utile se gli oggetti nella borsa
  /// dovessero avere un `feedValue` non valorizzato (ad es. versioni vecchie
  /// salvate prima dell'introduzione di questa proprietà).
  static const Map<String, int> feedValues = {
    'peach': 20,
    'carrot': 15,
    'strawberry': 10,
  };


  static const List<String> veryHungryPhrases = [
    'Sto morendo di fame...',
    'Mi sento debole, ho bisogno di cibo!',
    'Per favore, fammi mangiare presto!',
    'Ho il vuoto nello stomaco!',
    'Non resisto più dalla fame!'
  ];

  static const List<String> normalHungryPhrases = [
    'Potrei mangiare qualcosina.',
    'Un altro boccone non sarebbe male.',
    'Non ho molta fame, ma potrei assaggiare qualcosa.',
    'Sono abbastanza sazio, grazie!',
    'Forse più tardi avrò fame.'
  ];

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  late String _currentPhrase;
  Timer? _phraseTimer;

  @override
  void initState() {
    super.initState();
    _changePhrase();
  }

  void _changePhrase() {
    final random = Random();
    final pet = context.read<Pet>();
    final phrases = pet.hunger < 50
        ? FeedPage.veryHungryPhrases
        : FeedPage.normalHungryPhrases;
    _currentPhrase = phrases[random.nextInt(phrases.length)];
    setState(() {});

    _phraseTimer?.cancel();
    final seconds = 15 + random.nextInt(16); // 15-30 seconds
    _phraseTimer = Timer(Duration(seconds: seconds), _changePhrase);
  }

  @override
  void dispose() {
    _phraseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pet = context.watch<Pet>();

    return Scaffold(
      appBar: AppBar(title: const Text('Feed')),
      body: Column(
        children: [
          const SizedBox(height: 24),
          Text('Fame: ${pet.hunger}/100',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: pet.hunger / 100,
            minHeight: 10,
          ),
          const SizedBox(height: 24),
          Column(
            children: [
              Text(
                pet.isEgg ? '🥚' : '😺',
                style: const TextStyle(fontSize: 72),
              ),
              const SizedBox(height: 8),
              Text(
                _currentPhrase,
                textAlign: TextAlign.center,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Consumer<Bag>(
              builder: (context, bag, _) {
                final entries = bag.items.entries.toList();
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final food = entry.key;
                    final quantity = entry.value;
                    return GestureDetector(
                      onTap: () {
                        final bag = context.read<Bag>();
                        if (bag.removeItem(food, 1)) {
                          final value =
                              FeedPage.feedValues[food.name] ?? food.feedValue;
                          context.read<Pet>().feed(value);
                          _changePhrase();
                          setState(() {}); // aggiorna la barra della fame
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${food.name} dato al pet!'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Image.asset(food.imagePath, width: 64, height: 64),
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'x$quantity',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            food.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}