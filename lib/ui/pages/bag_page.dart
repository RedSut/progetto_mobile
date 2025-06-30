import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/bag.dart';

class BagPage extends StatelessWidget {
  const BagPage({super.key});

  // Lista di frasi motivazionali
  static final List<String> motivationalQuotes = [
    '"Ogni passo ti avvicina alla vittoria!"',
    '"Non mollare mai, campione!"',
    '"Sei più forte di quanto credi!"',
    '"Ogni sfida è un\'occasione!"',
    '"La costanza vince sempre!"',
    '"Oggi dai il meglio di te!"',
    '"Sei una leggenda in cammino!"',
  ];

  @override
  Widget build(BuildContext context) {
    final bag = Provider.of<Bag>(context);
    final random = Random();
    final String selectedQuote = motivationalQuotes[random.nextInt(motivationalQuotes.length)];

    return Scaffold(
      backgroundColor: Colors.green.shade900,
      appBar: AppBar(
        title: const Text(
          'Bag',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.orange,
            fontSize: 26,
          ),
        ),
        backgroundColor: Colors.green.shade900,
        iconTheme: const IconThemeData(color: Colors.orange),
      ),
      body: Column(
        children: [
          // Griglia borsa
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: bag.items.isEmpty
                  ? const Center(
                child: Text(
                  'La borsa è vuota!',
                  style: TextStyle(color: Colors.white70, fontSize: 20),
                ),
              )
                  : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: bag.items.length,
                itemBuilder: (context, index) {
                  final entry = bag.items.entries.elementAt(index);
                  final item = entry.key;
                  final quantity = entry.value;

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.green.shade800,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          item.imagePath,
                          width: 64,
                          height: 64,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'x$quantity',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // Pet e frase motivazionale
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.green.shade800,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/pet.png', // tua immagine pet
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 8),
                Text(
                  selectedQuote,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                    fontSize: 16,
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
