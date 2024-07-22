import 'package:flutter/material.dart';

Color getRoleColor(String? role) {
  if (role == "New") {
    return Colors.green;
  } else if (role == "Creator") {
    return Colors.red;
  } else if (role == "Trending") {
    return Colors.orange;
  } else if (role == "Verified") {
    return Colors.cyanAccent;
  }
  return Colors.black38;
}

Color getActionColor(String? action) {
  if (action == "Post") {
    return Colors.green;
  } else if (action == "Teel") {
    return Colors.red;
  } else if (action == "Live") {
    return Colors.orange;
  } else if (action == "XOXO") {
    return Colors.cyanAccent;
  }
  return Colors.black38;
}
