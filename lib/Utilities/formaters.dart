import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Formatters {
  // Extract only the date part (without time)
  String extractDate(Timestamp timestamp) {
    try {
      final dateTime = timestamp.toDate();
      final dateFormatter = DateFormat('dd/MM'); // Format for date
      return dateFormatter.format(dateTime);
    } catch (e) {
      return 'Invalid timestamp'; // Or a more user-friendly message
    }
  }

  // Modified formatTimestampDate to only output time (24-hour)
  String formatTimestampTime(Timestamp timestamp) {
    try {
      final dateTime = timestamp.toDate();
      final timeFormatter = DateFormat('HH:mm'); // Format for time (24-hour)
      return timeFormatter.format(dateTime);
    } catch (e) {
      return 'Invalid timestamp'; // Or a more user-friendly message
    }
  }
}
