class Item{
  final String id;
  final String name;
  final String imagePath;

  Item({
    required this.id,
    required this.name,
    required this.imagePath,
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