class Resep {
  final int id;
  final String name;
  final String category;
  final String bahan;
  final String steps;
  final String image;

  Resep({
    required this.id,
    required this.name,
    required this.category,
    required this.bahan,
    required this.steps,
    required this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'bahan': bahan,
      'steps': steps,
      'image': image,
    };
  }

  factory Resep.fromMap(Map<String, dynamic> map) {
    return Resep(
      id: map['id'] as int,
      name: map['name'] as String,
      category: map['category'] as String,
      bahan: map['bahan'] as String,
      steps: map['steps'] as String,
      image: map['image'] as String,
    );
  }
}
