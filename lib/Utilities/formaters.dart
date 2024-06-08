import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Formatters {
  String extractDate(Timestamp timestamp) {
    try {
      final dateTime = timestamp.toDate();
      final dateFormatter = DateFormat('dd/MM');
      return dateFormatter.format(dateTime);
    } catch (e) {
      return 'Invalid timestamp';
    }
  }

  String formatDateDDMM(DateTime date) {
    final dateFormatter = DateFormat('dd/MM');
    return dateFormatter.format(date);
  }

  String formatTimestampTime(Timestamp timestamp) {
    try {
      final dateTime = timestamp.toDate();
      final timeFormatter = DateFormat('HH:mm');
      return timeFormatter.format(dateTime);
    } catch (e) {
      return 'Invalid timestamp';
    }
  }

  int calculateAge(String birthDate) {
    if (birthDate.isEmpty) return 0;
    DateTime birthDateTime = DateTime.parse(birthDate);
    DateTime today = DateTime.now();
    int years = today.year - birthDateTime.year;
    if (today.month < birthDateTime.month ||
        (today.month == birthDateTime.month && today.day < birthDateTime.day)) {
      years--;
    }
    return years;
  }

  int getTimestampFromTimeOfDayAndDate(TimeOfDay hora, DateTime fecha) {
    return DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute)
        .millisecondsSinceEpoch;
  }

  DateTime combineDateTime(DateTime fecha, TimeOfDay hora) {
    final year = fecha.year;
    final month = fecha.month;
    final day = fecha.day;
    final hour = hora.hour;
    final minute = hora.minute;
    return DateTime(year, month, day, hour, minute);
  }
}
