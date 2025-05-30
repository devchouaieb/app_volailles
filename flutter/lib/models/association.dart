class Association {
  final String? id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String number;
  final String registrationYear;

  Association({
    this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.number,
    required this.registrationYear,
  });

  factory Association.fromApi(Map<String, dynamic> json) {
    return Association(
      id: json['_id']?.toString(),
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      number: json['number']?.toString() ?? '',
      registrationYear: json['registrationYear']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'number': number,
      'registrationYear': registrationYear,
    };
  }

  Association copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? number,
    String? registrationYear,
  }) {
    return Association(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      number: number ?? this.number,
      registrationYear: registrationYear ?? this.registrationYear,
    );
  }
}
