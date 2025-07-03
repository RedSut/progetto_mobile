import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/bag.dart';

class BagPage extends StatelessWidget {
  const BagPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bag = Provider.of<Bag>(context);

    return Scaffold(
      backgroundColor: Colors.green.shade900,
      appBar: AppBar(
        title: const Text('La tua Borsa'),
        backgroundColor: Colors.green.shade900,
        elevation: 0,
      ),
      body: Padding(
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
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'x$quantity',
                    style:
                    const TextStyle(color: Colors.orange, fontSize: 18),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
