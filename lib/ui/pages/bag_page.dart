import 'package:flutter/material.dart';
import 'package:progetto_mobile/ui/pages/home_page.dart';
import 'package:provider/provider.dart';
import '../../models/bag.dart';

class BagPage extends StatelessWidget {
  const BagPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bag = Provider.of<Bag>(context);

    return Container(
      height: MediaQuery.of(context).size.height,  // full height
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Scaffold(
        backgroundColor: Colors.green.shade900,
        appBar: AppBar(
          title: const Text('Your bag', style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.green.shade900,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        body: GestureDetector(
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity! > 300) {
              // swipe verso il basso → chiudi pagina
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: bag.items.isEmpty
                ? const Center(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('Your bag is empty!',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),
                    SizedBox(height: 16),
                    Text('Try to complete some challenges or claim the already finished ones.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 20, fontStyle: FontStyle.italic)),
                  ]
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

                return InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(item.name),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(item.imagePath, width: 80, height: 80),
                            const SizedBox(height: 8),
                            Text(item.description),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
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
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
