import 'package:intl/intl.dart';

String calculateAge(String birthDateString) {
  try {
    final birthDate = DateTime.parse(birthDateString);
    final now = DateTime.now();
    final difference = now.difference(birthDate);
    final years = (difference.inDays / 365).floor();
    final months = ((difference.inDays % 365) / 30).floor();

    if (years > 0) {
      return "$years an(s)";
    } else if (months > 0) {
      return "$months mois";
    } else {
      return "${difference.inDays} jours";
    }
  } catch (e) {
    return "Inconnu";
  }
}

String formatDate(String dateString) {
  try {
    final date = DateTime.parse(dateString);
    return DateFormat('dd/MM/yyyy').format(date);
  } catch (e) {
    return "Date inconnue";
  }
}
