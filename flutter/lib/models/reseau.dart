class Reseau {
  final String? id;
  final String name;
  final String matricule;
  final String address;
  final String siteWeb;
  final String president;
  final String comite;
  final String telephone;
  final String mail;
  final String registrationYear;

  Reseau({
    this.id,
    required this.name,
    required this.matricule,
    required this.address,
    required this.siteWeb,
    required this.president,
    required this.comite,
    required this.telephone,
    required this.mail,
    required this.registrationYear,
  });

  factory Reseau.fromApi(Map<String, dynamic> json) {
    return Reseau(
      id: json['_id']?.toString(),
      name: json['name']?.toString() ?? '',
      matricule: json['matricule']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      siteWeb: json['siteWeb']?.toString() ?? '',
      president: json['president']?.toString() ?? '',
      comite: json['comite']?.toString() ?? '',
      telephone: json['telephone']?.toString() ?? '',
      mail: json['mail']?.toString() ?? '',
      registrationYear: json['registrationYear']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'matricule': matricule,
      'address': address,
      'siteWeb': siteWeb,
      'president': president,
      'comite': comite,
      'telephone': telephone,
      'mail': mail,
      'registrationYear': registrationYear,
    };
  }

  Reseau copyWith({
    String? id,
    String? name,
    String? matricule,
    String? address,
    String? siteWeb,
    String? president,
    String? comite,
    String? telephone,
    String? mail,
    String? registrationYear,
  }) {
    return Reseau(
      id: id ?? this.id,
      name: name ?? this.name,
      matricule: matricule ?? this.matricule,
      address: address ?? this.address,
      siteWeb: siteWeb ?? this.siteWeb,
      president: president ?? this.president,
      comite: comite ?? this.comite,
      telephone: telephone ?? this.telephone,
      mail: mail ?? this.mail,
      registrationYear: registrationYear ?? this.registrationYear,
    );
  }
}
