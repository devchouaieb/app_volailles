import 'package:app_volailles/models/bird.dart';

class Cage {
  final String? id;
  final Bird male;
  final Bird female;
  final String species;
  final String? createdAt;
  final String? status;
  final String? notes;
  final String cageNumber;

  Cage({
    this.id,
    required this.male,
    required this.female,
    required this.species,
    this.createdAt,
    this.status,
    this.notes,
    required this.cageNumber,
  });

  factory Cage.fromJson(Map<String, dynamic> json) {
    return Cage(
      id: json['_id'],
      male: Bird.fromApi(json['male']),
      female: Bird.fromApi(json['female']),
      species: json['species'] ?? '',
      createdAt: json['createdAt'],
      status: json['status'] ?? 'active',
      notes: json['notes'],
      cageNumber: json['cageNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'male': male.toJson(),
      'female': female.toJson(),
      'species': species,
      'createdAt': createdAt,
      'status': status,
      'notes': notes,
      'cageNumber': cageNumber,
    };
  }
}
