// ...existing code...
class Herb {
  final int id;
  final String name;
  final String category;
  final String effect;
  final String taste;
  final String image;

  Herb({
    required this.id,
    required this.name,
    required this.category,
    required this.effect,
    required this.taste,
    required this.image,
  });

  factory Herb.fromJson(Map<String, dynamic> json) => Herb(
    id: json['id'],
    name: json['name'],
    category: json['category'],
    effect: json['effect'],
    taste: json['taste'],
    image: json['image'],
  );
}
