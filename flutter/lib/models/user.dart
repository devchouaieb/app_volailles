// lib/models/user.dart

class User {
  final String id;
  final String nationalId; // Carte d'identité nationale
  final String fullName;
  final String email;
  final String role; // Par exemple: 'admin', 'user'
  final String association; // Association de l'utilisateur
  final String createdAt;

  User({
    required this.id,
    required this.nationalId,
    required this.fullName,
    required this.email,
    required this.role,
    required this.association,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nationalId': nationalId,
    'fullName': fullName,
    'email': email,
    'role': role,
    'association': association,
    'createdAt': createdAt,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['_id'],
    nationalId: json['nationalId'],
    fullName: json['fullName'],
    email: json['email'],
    role: json['role'],
    association: json['association'],
    createdAt: json['createdAt'],
  );
}
