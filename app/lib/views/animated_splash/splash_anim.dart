import 'package:flutter/material.dart';
import 'package:gif_view/gif_view.dart';
import 'package:lamatdating/main.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lamatdating/helpers/constants.dart';

class SplashAnimPage extends StatefulWidget {
  final SharedPreferences? prefs;
  final bool canSkip;
  const SplashAnimPage({Key? key, required this.prefs, required this.canSkip})
      : super(key: key);

  @override
  State<SplashAnimPage> createState() => SplashAnimState();
}

class SplashAnimState extends State<SplashAnimPage> {
  @override
  void initState() {
    if (widget.canSkip) {
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LandingWidget(),
          ),
        );
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        height: height,
        width: width,
        // color: Teme.isDarktheme(widget.prefs)
        //     ? AppConstants.backgroundColorDark
        //     : AppConstants.backgroundColor,
        decoration: BoxDecoration(
            color: AppConstants.backgroundColor,
            image: DecorationImage(
                image: AssetImage(widget.prefs == null
                    ? AppConstants.splashBg
                    : Teme.isDarktheme(widget.prefs!)
                        ? AppConstants.splashBgDark
                        : AppConstants.splashBg),
                fit: BoxFit.cover)),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultNumericValue * 2),
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              GifView.asset(
                widget.prefs == null
                    ? AppConstants.splashAnimLight
                    : Teme.isDarktheme(widget.prefs!)
                        ? AppConstants.splashAnimLight
                        : AppConstants.splashAnimDark,
                height: 150,
                width: 200,
                frameRate: 60, // default is 15 FPS
              ),
              const Spacer(),
            ],
          )),
        ),
      ),
    );
  }
}
