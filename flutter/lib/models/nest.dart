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
  final Cage? cage;
  final String? nestNumber;
  final DateTime? firstEggDate;
  final int maleExits;
  final int femaleExits;

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
    this.cage,
    this.nestNumber,
    this.firstEggDate,
    this.maleExits = 0,
    this.femaleExits = 0
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
      cage: json['cage'] != null ? Cage.fromJson(json['cage']) : null,
      nestNumber: json['nestNumber'],
      firstEggDate: json['firstEggDate'] != null ? DateTime.parse(json['firstEggDate']) : null,
      maleExits: json['maleExits'] ?? 0,
      femaleExits: json['femaleExits'] ?? 0
    );
  }

  Map<String, dynamic> toJson() {
    return  {
      'cageNumber': cageNumber,
      'numberOfEggs': numberOfEggs,
      'fertilizedEggs': fertilizedEggs,
      'exclusionDate': exclusionDate.toIso8601String(),
      'extractedEggs': extractedEggs,
      'firstBirdExitDate': firstBirdExitDate?.toIso8601String(),
      'birdsExited': birdsExited,
      'status': status,
      'notes': notes,
      'cage': cage?.id,
      'nestNumber': nestNumber,
      'firstEggDate': firstEggDate?.toIso8601String(),
      'maleExits': maleExits,
      'femaleExits': femaleExits
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
    String? nestNumber,
    DateTime? firstEggDate,
    int? maleExits,
    int? femaleExits,
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
      cage: cage,
      nestNumber: nestNumber ?? this.nestNumber,
      firstEggDate: firstEggDate ?? this.firstEggDate,
      maleExits: maleExits ?? this.maleExits,
      femaleExits: femaleExits ?? this.femaleExits,
    );
  }
}
