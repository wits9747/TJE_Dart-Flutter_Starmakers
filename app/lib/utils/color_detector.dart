import 'package:lamatdating/helpers/constants.dart';
import 'package:flutter/material.dart';

Color pickTextColorBasedOnBgColorAdvanced(Color bgColor,
    {Color? lightColor, Color? darkColor}) {
  Color myColor = bgColor;

  var grayscale =
      (0.299 * myColor.red) + (0.587 * myColor.green) + (0.114 * myColor.blue);
  if (grayscale > 128) {
    // color is light
    return darkColor ?? lamatBlack;
  } else {
    // color is dark
    return lightColor ?? lamatWhite;
  }
}

bool isDarkColor(Color color) {
  Color myColor = color;

  var grayscale =
      (0.299 * myColor.red) + (0.587 * myColor.green) + (0.114 * myColor.blue);
  if (grayscale > 128) {
    // color is light
    return false;
  } else {
    // color is dark
    return true;
  }
}
