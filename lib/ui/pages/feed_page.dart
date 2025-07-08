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
  bool _showStars = false;
  final Set<int> _scalingItems = {}; // indices of items currently animating

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

  void _triggerStarAnimation() {
    setState(() => _showStars = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _showStars = false);
      }
    });
  }

  @override
  void dispose() {
    _phraseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pet = context.watch<Pet>();
    final hour = DateTime.now().hour;
    final isDayTime = hour >= 6 && hour < 18;

    return Scaffold(
      appBar: AppBar(title: const Text('Feed'),
        backgroundColor: Colors.blue.shade200,),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            isDayTime
                ? 'assets/imageCucciaDay.png'
                : 'assets/imageCucciaNight.png',
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.2),
          ),
          Column(
            children: [
              const SizedBox(height: 24),
              Text('Fame: ${pet.hunger}/100',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Colors.white,
                  ),),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: pet.hunger / 100,
                minHeight: 10,
                color: Colors.orange,
              ),
              const SizedBox(height: 24),
              Column(
                children: [
                Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    pet.imagePath,
                    width: 240,
                    height: 240,
                  ),
                  if (_showStars) ...[
                    Positioned(
                      top: 10,
                      left: 50,
                      child: AnimatedOpacity(
                        opacity: _showStars ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: const Icon(Icons.star,
                            color: Colors.yellow, size: 32),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      right: 40,
                      child: AnimatedOpacity(
                        opacity: _showStars ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: const Icon(Icons.star,
                            color: Colors.yellow, size: 28),
                      ),
                    ),
                    Positioned(
                      bottom: 40,
                      left: 60,
                      child: AnimatedOpacity(
                        opacity: _showStars ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: const Icon(Icons.star,
                            color: Colors.yellow, size: 24),
                      ),
                    ),
                  ],
                ],
                ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      _currentPhrase,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child : Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade200,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Consumer<Bag>(
                    builder: (context, bag, _) {
                      final entries = bag.items.entries.toList();
                      return bag.items.isEmpty
                        ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text('La tua borsa è vuota!',
                                style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),),
                              SizedBox(height: 16),
                              Text('Prova a completare quanche challenge o ritirare le ricompense di quelle già completate',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black, fontSize: 20, fontStyle: FontStyle.italic)),
                            ]
                          ),
                        ) : GridView.builder(
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
                          final isScaling = _scalingItems.contains(index);
                          return AnimatedScale(
                            scale: isScaling ? 1.1 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: GestureDetector(
                              onTap: () {
                                final pet = context.read<Pet>();
                                if (pet.hunger >= 100) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Il tuo pet è già sazio!'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                  return;
                                }

                                final bag = context.read<Bag>();
                                if (bag.removeItem(food, 1)) {
                                  final value =
                                      FeedPage.feedValues[food.name] ?? food.feedValue;
                                  pet.feed(value);
                                  _changePhrase();
                                  _triggerStarAnimation();
                                  setState(() {
                                    _scalingItems.add(index);
                                  });
                                  Future.delayed(const Duration(milliseconds: 200), () {
                                    if (!mounted) return;
                                    setState(() {
                                      _scalingItems.remove(index);
                                    });
                                  });
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
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}