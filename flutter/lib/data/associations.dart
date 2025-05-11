// lib/data/associations.dart

class Association {
  final String? id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String number;
  final String registrationYear;

  const Association({
    this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.number,
    required this.registrationYear,
  });

  Map<String, dynamic> toJson() => {
    if (id != null) '_id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'address': address,
    'number': number,
    'registrationYear': registrationYear,
  };

  factory Association.fromJson(Map<String, dynamic> json) => Association(
    id: json['_id']?.toString(),
    name: json['name'] as String,
    phone: json['phone'] as String,
    email: json['email'] as String,
    address: json['address'] as String,
    number: json['number'] as String,
    registrationYear: json['registrationYear'] as String,
  );

  Association copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? number,
    String? registrationYear,
  }) => Association(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    address: address ?? this.address,
    number: number ?? this.number,
    registrationYear: registrationYear ?? this.registrationYear,
  );
}

final List<Association> associations = [
  Association(
    name: 'Association Ornithologique de Sfax (AOS)',
    phone: '52 919 204',
    email: 'aossfax@gmail.com',
    address: 'Route Taniour KM 3',
    number: '12345',
    registrationYear: '2024',
  ),
  Association(
    name: 'Association Ornithologique de Nabeul (AON)',
    phone: '22 886 342',
    email: 'aon.nabeul@gmail.com',
    address: 'Nabeul',
    number: '12346',
    registrationYear: '2024',
  ),
  Association(
    name: 'Association Ornithologique de Gabès (AOG)',
    phone: '00 000 000',
    email: 'ass.ornithologique.gabes@gmail.com',
    address: 'Gabès',
    number: '12347',
    registrationYear: '2024',
  ),
  Association(
    name: 'Association Ornithologique de Mahdia (AOM)',
    phone: '52 333 773',
    email: 'aom-tunisie@gmail.com',
    address: 'Mahdia',
    number: '12348',
    registrationYear: '2024',
  ),
];

// Fonctions utilitaires pour accéder aux données des associations
Association? getAssociationByName(String name) {
  try {
    return associations.firstWhere(
      (association) =>
          association.name.toLowerCase().contains(name.toLowerCase()),
    );
  } catch (e) {
    return null;
  }
}

List<Association> getAllAssociations() {
  return List<Association>.from(associations);
}
