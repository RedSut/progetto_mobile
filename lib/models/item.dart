
class Item{
  final String id;
  final String name;
  final String imagePath;
  final int feedValue;

  const Item({
  required this.id,
  required this.name,
  required this.imagePath,
  this.feedValue = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Item &&
              runtimeType == other.runtimeType &&
              name == other.name &&
              imagePath == other.imagePath;

  @override
  int get hashCode => name.hashCode ^ imagePath.hashCode;
}

class ItemManager{
  final List<Item> items = [
    const Item(
      id: 'it_001',
      name: 'Pecha',
      imagePath: 'assets/itemPecha.png',
      feedValue: 20,
    ),
    const Item(
      id: 'it_002',
      name: 'Leppa',
      imagePath: 'assets/itemLeppa.png',
      feedValue: 15,
    ),
    const Item(
      id: 'it_003',
      name: 'Rowap',
      imagePath: 'assets/itemRowap.png',
      feedValue: 10,
    ),
  ];

  Item getItemById(String id){
    for (Item item in items){
      if (item.id == id){
        return item;
      }
    }
    return Item(id: "notFound", name: "Not Found", imagePath: "");
  }
}