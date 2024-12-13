import 'package:flutter/material.dart';

/// @author: Sagar K.C.
/// @email: sagar.kc@fonepay.com
/// @created_at: 11/24/2024, Sunday

extension ColorNameExtension on Color {
  String get colorName {
    if (this == Colors.red) {
      return "red";
    } else if (this == Colors.green) {
      return "green";
    } else if (this == Colors.blue) {
      return "blue";
    } else if (this == Colors.yellow) {
      return "yellow";
    } else if (this == Colors.orange) {
      return "orange";
    } else if (this == Colors.purple) {
      return "purple";
    } else if (this == Colors.black) {
      return "black";
    } else if (this == Colors.white) {
      return "white";
    }  else {
      return "white";
    }
  }
}


