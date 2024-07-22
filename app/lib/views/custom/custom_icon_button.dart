import 'package:flutter/material.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'package:lamatdating/helpers/constants.dart';
// import 'package:websafe_svg/websafe_svg.dart';

class CustomIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String icon;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Color? backgroundColor;

  const CustomIconButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.padding,
    this.margin,
    this.color,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.defaultNumericValue),
        splashColor: color?.withOpacity(0.3) ?? Colors.black38,
        onTap: onPressed,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(AppConstants.defaultNumericValue),
            color: backgroundColor ??
                color?.withOpacity(0.1) ??
                Colors.black.withOpacity(0.07),
          ),
          child: WebsafeSvg.asset(
            icon,
            color: color == AppConstants.primaryColor
                ? AppConstants.primaryColor
                : AppConstants.secondaryColor,
            height: 32,
            width: 32,
            fit: BoxFit.scaleDown,
          ),
        ),
      ),
    );
  }
}
