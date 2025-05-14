// lib/models/bird.dart

class Bird {
  final String? id; // Changé de int à String? pour MongoDB _id
  final String identifier;
  String gender;
  String category ;
  String species;
  String color;
  String status;
  String cageNumber;
  String? cage ;
  String birthDate;
  double price;
  bool sold;
  String? soldDate;
  double? soldPrice;
  Map<String, dynamic>? buyerInfo;
  bool forSale; // Indique si l'oiseau est mis en vente
  double? askingPrice; // Prix demandé pour la vente
  String? sellerId; // ID du vendeur original
  String? userId;
  String? motherId;

  String? fatherId;
  String? lastCageNumber;
  String? lastCageEntryDate;
  String? lastCageExitDate;

  Bird({
    this.id,
    required this.identifier,
    required this.gender,
    required this.category,
    required this.species,
    required this.color,
    required this.status,
    required this.cageNumber,
    this.cage,
    required this.birthDate,
    this.price = 0.0,
    this.sold = false,
    this.soldDate,
    this.soldPrice,
    this.buyerInfo,
    this.forSale = false,
    this.askingPrice,
    this.sellerId,
    this.userId,
    this.motherId,
    this.fatherId,
    this.lastCageNumber,
    this.lastCageEntryDate,
    this.lastCageExitDate,
  });

  // Conversion pour l'API
  Map<String, dynamic> toJson() {
    final map = {
      'identifier': identifier,
      'gender': gender,
      'category': category,
      'species': species,
      'color': color,
      'status': status,
      'cageNumber': cageNumber,
      'birthDate': birthDate,
      'price': price,
      'sold': sold,
      'soldDate': soldDate,
      'soldPrice': soldPrice,
      'buyerInfo': buyerInfo,
      'forSale': forSale,
      'askingPrice': askingPrice,
    };
    if(cage !=null){
      map['cage']= cage;
    }
    if (sellerId !=null){
      map['seller']= sellerId;
    }

    if (motherId != null) {
      map["mother"] = motherId;
    }
    if (fatherId != null) {
      map["father"] = fatherId;
    }

    if (userId != null) {
      map["user"] = userId;
    }
    if (sellerId != null) {
      map["seller"] = sellerId;
    }

    if (id != null && id!.isNotEmpty) {
      map['_id'] = id;
    }

    if (lastCageNumber != null) {
      map["lastCageNumber"] = lastCageNumber;
    }
    if (lastCageEntryDate != null) {
      map["lastCageEntryDate"] = lastCageEntryDate;
    }
    if (lastCageExitDate != null) {
      map["lastCageExitDate"] = lastCageExitDate;
    }

    return map;
  }

  String getStatus(String? currentUserId) {
    if (status == "sold" || sold || currentUserId == sellerId) {
      return 'Vendu';
    } else if (status == "Mort") {
      return status;
    }
    else if (status == "Owned" || currentUserId == userId) {
      return 'Possédé';
    } else {
      return status;
    }
  }

  bool isAvailable() {
    return status != "Mort";
  }

  // Création depuis la réponse API
  factory Bird.fromApi(Map<String, dynamic> json) {
    return Bird(
      id: json['_id'],
      identifier: json['identifier'],
      gender: json['gender'] ?? 'unknown',
      category: json['category'] ?? '',
      species: json['species'] ?? '',
      color: json['color'] ?? '',
      status: json['status'] ?? 'active',
      cageNumber: json['cageNumber'] ?? '',
      cage: json['cage'],
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
      sellerId: json['seller'],
      userId: json["user"],
      motherId: json["mother"],
      fatherId: json['fatherId'],
      lastCageNumber: json['lastCageNumber'],
      lastCageEntryDate: json['lastCageEntryDate'],
      lastCageExitDate: json['lastCageExitDate'],
    );
  }

  // Clone avec modifications
  Bird copyWith({
    String? id,
    String? identifier,
    String? gender,
    String? category,
    String? species,
    String? color,
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
      category: category ?? this.category,
      species: species ?? this.species,
      color: color ?? this.color,
      status: status ?? this.status,
      cageNumber: cage ?? this.cageNumber,
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
