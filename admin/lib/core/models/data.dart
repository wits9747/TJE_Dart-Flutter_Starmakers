import 'package:intl/intl.dart';

class CalendarData {
  final String name;

  final DateTime date;
  final String position;
  final String rating;

  String getDate() {
    final formatter = DateFormat('kk:mm');

    return formatter.format(date);
  }

  CalendarData({
    required this.name,
    required this.date,
    required this.position,
    required this.rating,
  });
}

final List<CalendarData> calendarData = [
  CalendarData(
    name: 'Deniz Çolak',
    date: DateTime.now().add(const Duration(days: -16, hours: 5)),
    position: "New",
    rating: '₽',
  ),
  CalendarData(
    name: 'John Doe',
    date: DateTime.now().add(const Duration(days: -5, hours: 8)),
    position: "New",
    rating: '₽',
  ),
  CalendarData(
    name: 'Joy Barker',
    date: DateTime.now().add(const Duration(days: -10, hours: 3)),
    position: "Trending",
    rating: '\$',
  ),
  CalendarData(
    name: 'Kate Hartley',
    date: DateTime.now().add(const Duration(days: 6, hours: 6)),
    position: "Creator",
    rating: '\$',
  ),
  CalendarData(
    name: 'Fletcher Robson',
    date: DateTime.now().add(const Duration(days: -18, hours: 9)),
    position: "Verified",
    rating: '\$',
  ),
  CalendarData(
    name: 'Aldrich Mason',
    date: DateTime.now().add(const Duration(days: -12, hours: 2)),
    position: "Verified",
    rating: '\$',
  ),
  CalendarData(
    name: 'Phyllis Leonard',
    date: DateTime.now().add(const Duration(days: -8, hours: 4)),
    position: "Creator",
    rating: '\$',
  ),
  CalendarData(
    name: 'Ken Rehbein',
    date: DateTime.now().add(const Duration(days: -3, hours: 6)),
    position: "New",
    rating: '₽',
  ),
  CalendarData(
    name: 'Sydney Blake',
    date: DateTime.now().add(const Duration(days: -2, hours: 6)),
    position: "Creator",
    rating: '₽',
  ),
  CalendarData(
    name: 'Megan Salazar',
    date: DateTime.now().add(const Duration(days: -2, hours: 7)),
    position: "Trending",
    rating: '₽',
  ),
  CalendarData(
    name: 'Celeste Pena',
    date: DateTime.now().add(const Duration(days: -14, hours: 5)),
    position: "Trending",
    rating: '₽',
  ),
];
