//import 'dart:developer';

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

  TimeOfDay timestampToTimeOfDay(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  DateTime parseTimeFromString(String timeString) {
    if (RegExp(r'^[0-9]{1,2}:[0-5]{1,2}$').hasMatch(timeString)) {
      List<String> timeParts = timeString.split(':');
      int hours = int.parse(timeParts[0]);
      int minutes = int.parse(timeParts[1]);

      DateTime parsedTime;

      if (timeString.contains('PM')) {
        hours += 12;
        parsedTime = DateTime(2024, 6, 19, hours, minutes);
      } else {
        parsedTime = DateTime(2024, 6, 19, hours, minutes);
      }

      return parsedTime;
    } else {
      throw FormatException('Invalid time format: $timeString');
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

  String to24hs(DateTime time) {
    final DateFormat formatter = DateFormat('HH:mm');
    return formatter.format(time);
  }
}
