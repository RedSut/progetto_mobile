
class Item{
  final String id;
  final String name;
  final String imagePath;
  final int feedValue;
  final String description;

  const Item({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.description,
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
      description: "It strongly resembles a peach, but it's much larger. It could feed your pet a lot.",
      feedValue: 20,
    ),
    const Item(
      id: 'it_002',
      name: 'Leppa',
      imagePath: 'assets/itemLeppa.png',
      description: 'It strongly resembles a tangerine, but it has different colors. It could feed your pet.',
      feedValue: 15,
    ),
    const Item(
      id: 'it_003',
      name: 'Rowap',
      imagePath: 'assets/itemRowap.png',
      description: "It strongly resembles grapes, but it's much stranger. It could feed your pet just a little.",
      feedValue: 10,
    ),
  ];

  Item getItemById(String id){
    for (Item item in items){
      if (item.id == id){
        return item;
      }
    }
    return Item(id: "notFound", name: "Not Found", imagePath: "", description: "");
  }
}