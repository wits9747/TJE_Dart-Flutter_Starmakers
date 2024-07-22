import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:lamatadmin/helpers/config.dart';

void configLoading({
  required bool isDarkMode,
  required foregroundColor,
  required backgroundColor,
}) {
  EasyLoading.instance
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorColor = AppConstants.primaryColor
    ..backgroundColor = backgroundColor
    ..textColor = foregroundColor
    ..indicatorType = EasyLoadingIndicatorType.pumpingHeart
    ..progressColor = foregroundColor
    ..maskType = EasyLoadingMaskType.black
    ..animationStyle = EasyLoadingAnimationStyle.scale
    ..animationDuration = const Duration(milliseconds: 200)
    ..toastPosition = EasyLoadingToastPosition.bottom
    ..radius = 24
    ..boxShadow = const [
      BoxShadow(
        color: Colors.black12,
        offset: Offset(0, 4),
        blurRadius: 10,
        spreadRadius: 2,
      )
    ]
    ..dismissOnTap = false;
}
