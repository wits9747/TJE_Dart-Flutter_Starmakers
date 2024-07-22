import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatadmin/helpers/config.dart';
import 'package:lamatadmin/firebase_options.dart';
import 'package:lamatadmin/helpers/config_loading.dart';
import 'package:lamatadmin/views/wrapper/landing_widget.dart';
import 'package:lamatadmin/core/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' as g;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    configLoading(
      isDarkMode: false,
      foregroundColor: Colors.white,
      backgroundColor: AppConstants.primaryColorDark,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DIASPORAM Dashboard - Admin Panel v1.0',
      theme: ThemeData.dark().copyWith(
        appBarTheme: const AppBarTheme(backgroundColor: bgColor, elevation: 0),
        scaffoldBackgroundColor: bgColor,
        primaryColor: greenColor,
        dialogBackgroundColor: secondaryColor,
        buttonTheme: const ButtonThemeData(buttonColor: greenColor),
        textTheme: g.GoogleFonts.openSansTextTheme(Theme.of(context).textTheme)
            .apply(bodyColor: Colors.white),
        canvasColor: secondaryColor,
      ),
      home: const SuperAdminLandingWidget(),
      builder: EasyLoading.init(),
    );
  }
}
