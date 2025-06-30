import 'package:flutter/material.dart';
import 'item.dart';

class Bag extends ChangeNotifier {
  final Map<Item, int> items = {};

  // Aggiunge un item alla borsa, incrementando la quantità se già presente
  void addItem(Item item, int quantity) {
    if (items.containsKey(item)) {
      items[item] = items[item]! + quantity;
    } else {
      items[item] = quantity;
    }
    notifyListeners();
  }
  // Rimuove un item dalla borsa, decrementando la quantità o eliminandolo se arriva a 0
  // Rimuove [quantity] unità di [item] se presenti.
  // Restituisce `true` se la rimozione ha avuto successo.
  bool removeItem(Item item, int quantity) {
    final currentQuantity = items[item];
    if (currentQuantity == null) return false;

    if (currentQuantity > quantity) {
      items[item] = currentQuantity - quantity;
    } else {
      items.remove(item);
    }
    notifyListeners();
    return true;
  }

  // Metodo opzionale per ottenere la quantità di un item specifico
  int getItemQuantity(Item item) {
    return items[item] ?? 0;
  }
}
