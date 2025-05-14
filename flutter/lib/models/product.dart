class Product {
  String? id;
  String name;
  double prix;
  String userId;

  Product({
    this.id,
    required this.name,
    required this.prix,
    required this.userId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      name: json['name'],
      prix: (json['prix'] as num).toDouble(),
      userId: json['user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'prix': prix,
      'user': userId,
    };
  }
}
