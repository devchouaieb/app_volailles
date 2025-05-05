import 'package:app_volailles/models/cage.dart';

class Nest {
  final String? id;
  final String cageNumber;
  final int numberOfEggs;
  final int fertilizedEggs;
  final DateTime exclusionDate;
  final int extractedEggs;
  final DateTime? firstBirdExitDate;
  final int birdsExited;
  final String? status;
  final String? notes;

  Nest({
    this.id,
    required this.cageNumber,
    required this.numberOfEggs,
    required this.fertilizedEggs,
    required this.exclusionDate,
    required this.extractedEggs,
    this.firstBirdExitDate,
    this.birdsExited = 0,
    this.status = 'active',
    this.notes,
  });

  factory Nest.fromJson(Map<String, dynamic> json) {
    return Nest(
      id: json['_id'],
      cageNumber: json['cageNumber'],
      numberOfEggs: json['numberOfEggs'],
      fertilizedEggs: json['fertilizedEggs'],
      exclusionDate: DateTime.parse(json['exclusionDate']),
      extractedEggs: json['extractedEggs'],
      firstBirdExitDate:
          json['firstBirdExitDate'] != null
              ? DateTime.parse(json['firstBirdExitDate'])
              : null,
      birdsExited: json['birdsExited'] ?? 0,
      status: json['status'] ?? 'active',
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cageNumber': cageNumber,
      'numberOfEggs': numberOfEggs,
      'fertilizedEggs': fertilizedEggs,
      'exclusionDate': exclusionDate.toIso8601String(),
      'extractedEggs': extractedEggs,
      'firstBirdExitDate': firstBirdExitDate?.toIso8601String(),
      'birdsExited': birdsExited,
      'status': status,
      'notes': notes,
    };
  }

  Nest copyWith({
    String? id,
    String? cageNumber,
    int? numberOfEggs,
    int? fertilizedEggs,
    DateTime? exclusionDate,
    int? extractedEggs,
    DateTime? firstBirdExitDate,
    int? birdsExited,
    String? status,
    String? notes,
  }) {
    return Nest(
      id: id ?? this.id,
      cageNumber: cageNumber ?? this.cageNumber,
      numberOfEggs: numberOfEggs ?? this.numberOfEggs,
      fertilizedEggs: fertilizedEggs ?? this.fertilizedEggs,
      exclusionDate: exclusionDate ?? this.exclusionDate,
      extractedEggs: extractedEggs ?? this.extractedEggs,
      firstBirdExitDate: firstBirdExitDate ?? this.firstBirdExitDate,
      birdsExited: birdsExited ?? this.birdsExited,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}
