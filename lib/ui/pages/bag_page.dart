import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/bag.dart';
import '../../models/item.dart';
import '../../models/pet.dart';

class BagPage extends StatelessWidget {
  BagPage({super.key});

  final List<String> motivationalPhrases = [
    "Forza, puoi farcela!",
    "Un passo alla volta!",
    "Hai già fatto molto, continua così!",
    "Sei un campione!",
    "Oggi è il tuo giorno!",
    "Riscatta più premi!",
  ];

  @override
  Widget build(BuildContext context) {
    final bag = Provider.of<Bag>(context);
    final pet = Provider.of<Pet>(context);
    final random = Random();
    final phrase = motivationalPhrases[random.nextInt(motivationalPhrases.length)];

    return Scaffold(
      backgroundColor: Colors.green.shade900,
      appBar: AppBar(
        title: const Text('La tua Borsa'),
        backgroundColor: Colors.green.shade900,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: bag.items.isEmpty
                ? const Center(
              child: Text(
                'La tua borsa è vuota!',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            )
                : GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.8,
              children: bag.items.entries.map((entry) {
                final item = entry.key;
                final quantity = entry.value;

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade800,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        item.imagePath,
                        width: 80,
                        height: 80,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.name,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'x$quantity',
                        style: const TextStyle(color: Colors.orange, fontSize: 18),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          // Mostriciattolo con fumetto motivazionale
          Positioned(
            left: 16,
            bottom: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(width: 8),
                // Mostriciattolo
                Image.asset(
                  pet.imagePath,
                  width: 64,
                  height: 64,
                ),
                // Fumetto
                Container(
                  padding: const EdgeInsets.all(12),
                  constraints: const BoxConstraints(maxWidth: 200),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    phrase,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
