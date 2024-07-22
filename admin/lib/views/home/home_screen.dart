import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatadmin/helpers/config.dart';
import 'package:lamatadmin/providers/app_settings_provider.dart';
import 'package:lamatadmin/responsive.dart';
import 'package:lamatadmin/views/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:lamatadmin/views/others/other_widgets.dart';

import 'components/side_menu.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  Widget currentScreen =
      const DashboardScreen(); // Initially set to DashboardScreen

  void changeScreen(Widget screen) {
    setState(() {
      currentScreen = screen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appSettingsProviderRef = ref.watch(appSettingsProvider);
    return appSettingsProviderRef.when(
      data: (data) {
        if (data != null) {
          AppConstants.appLogo = data.appLogo!;
          return Scaffold(
            drawer: SideMenu(changeScreen: changeScreen),
            body: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // We want this side menu only for large screen
                  if (Responsive.isDesktop(context))
                    Expanded(
                      // default flex = 1
                      // and it takes 1/6 part of the screen
                      child: SideMenu(changeScreen: changeScreen),
                    ),

                  Expanded(
                    // It takes 5/6 part of the screen
                    flex: 5,
                    child: currentScreen,
                  ),
                ],
              ),
            ),
          );
        } else {
          return const MyLoadingWidget();
        }
      },
      error: (error, stackTrace) => const MyErrorWidget(),
      loading: () => const MyLoadingWidget(),
    );
  }
}
