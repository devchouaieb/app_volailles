import 'package:app_volailles/models/bird.dart';
import 'package:intl/intl.dart';

class Cage {
  final String? id;
  final Bird? male;
  final Bird? female;
  final String species;
  final DateTime? createdAt;
  final String? status;
  final String? notes;
  final String cageNumber;

  Cage({
    this.id,
    this.male,
    this.female,
    required this.species,
    this.createdAt,
    this.status,
    this.notes,
    required this.cageNumber,
  });

  factory Cage.fromJson(Map<String, dynamic> json) {
    return Cage(
      id: json['_id'],
      male: json['male'] != null ? Bird.fromApi(json['male']) : null,
      female: json['female'] != null ? Bird.fromApi(json['female']) : null,
      species: json['species'] ?? '',
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt']).toLocal()
              : null,
      status: json['status'] ?? 'active',
      notes: json['notes'],
      cageNumber: json['cageNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'male': male?.toJson(),
      'female': female?.toJson(),
      'species': species,
      'createdAt': createdAt?.toIso8601String(),
      'status': status,
      'notes': notes,
      'cageNumber': cageNumber,
    };
  }

  String get formattedCreatedAt {
    if (createdAt == null) return '';
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(createdAt!);
  }
}
