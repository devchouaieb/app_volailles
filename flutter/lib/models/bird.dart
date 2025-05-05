// lib/models/bird.dart
class Bird {
  final String? id; // Changé de int à String? pour MongoDB _id
  final String identifier;
  String gender;
  String species;
  String variety;
  String status;
  String cage;
  String birthDate;
  double price;
  bool sold;
  String? soldDate;
  double? soldPrice;
  Map<String, dynamic>? buyerInfo;
  bool forSale; // Indique si l'oiseau est mis en vente
  double? askingPrice; // Prix demandé pour la vente
  String? sellerId; // ID du vendeur original

  Bird({
    this.id,
    required this.identifier,
    required this.gender,
    required this.species,
    required this.variety,
    required this.status,
    required this.cage,
    required this.birthDate,
    this.price = 0.0,
    this.sold = false,
    this.soldDate,
    this.soldPrice,
    this.buyerInfo,
    this.forSale = false,
    this.askingPrice,
    this.sellerId,
  });

  // Conversion pour l'API
  Map<String, dynamic> toJson() {
    return {
      "_id": id ??"",
      'identifier': identifier,
      'gender': gender,
      'species': species,
      'variety': variety,
      'status': status,
      'cage': cage,
      'birthDate': birthDate,
      'price': price,
      'sold': sold,
      'soldDate': soldDate,
      'soldPrice': soldPrice,
      'buyerInfo': buyerInfo,
      'forSale': forSale,
      'askingPrice': askingPrice,
      'sellerId': sellerId,
    };
  }

  // Création depuis la réponse API
  factory Bird.fromApi(Map<String, dynamic> json) {
    return Bird(
      id: json['_id'],
      identifier: json['identifier'],
      gender: json['gender'] ?? 'unknown',
      species: json['species'],
      variety: json['variety'] ?? '',
      status: json['status'] ?? 'active',
      cage: json['cage'] ?? '',
      birthDate: json['birthDate'],
      price: json['price']?.toDouble() ?? 0.0,
      sold: json['sold'] ?? false,
      soldDate: json['soldDate'],
      soldPrice: json['soldPrice']?.toDouble(),
      buyerInfo:
          json['buyerInfo'] != null
              ? Map<String, dynamic>.from(json['buyerInfo'])
              : null,
      forSale: json['forSale'] ?? false,
      askingPrice: json['askingPrice']?.toDouble(),
      sellerId: json['sellerId'],
    );
  }

  // Clone avec modifications
  Bird copyWith({
    String? id,
    String? identifier,
    String? gender,
    String? species,
    String? variety,
    String? status,
    String? cage,
    String? birthDate,
    double? price,
    bool? sold,
    String? soldDate,
    double? soldPrice,
    Map<String, dynamic>? buyerInfo,
    bool? forSale,
    double? askingPrice,
    String? sellerId,
  }) {
    return Bird(
      id: id ?? this.id,
      identifier: identifier ?? this.identifier,
      gender: gender ?? this.gender,
      species: species ?? this.species,
      variety: variety ?? this.variety,
      status: status ?? this.status,
      cage: cage ?? this.cage,
      birthDate: birthDate ?? this.birthDate,
      price: price ?? this.price,
      sold: sold ?? this.sold,
      soldDate: soldDate ?? this.soldDate,
      soldPrice: soldPrice ?? this.soldPrice,
      buyerInfo: buyerInfo ?? this.buyerInfo,
      forSale: forSale ?? this.forSale,
      askingPrice: askingPrice ?? this.askingPrice,
      sellerId: sellerId ?? this.sellerId,
    );
  }
}
