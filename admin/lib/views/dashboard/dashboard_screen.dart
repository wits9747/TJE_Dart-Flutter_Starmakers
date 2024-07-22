import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lamatadmin/core/constants/color_constants.dart';
import 'package:lamatadmin/responsive.dart';
import 'package:lamatadmin/views/dashboard/components/mini_information_card.dart';
import 'package:lamatadmin/views/dashboard/components/recent_forums.dart';
import 'package:lamatadmin/views/dashboard/components/recent_users.dart';
import 'package:lamatadmin/views/dashboard/components/user_details_widget.dart';

import 'components/header.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final Function? changeScreen;
  const DashboardScreen({
    super.key,
    this.changeScreen,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => DashboardScreenState();
}

class DashboardScreenState extends ConsumerState<DashboardScreen> {
  Widget currentScreen =
      const DashboardScreen(); // Initially set to DashboardScreen

  void changeScreen(Widget screen) {
    setState(() {
      currentScreen = screen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        //padding: EdgeInsets.all(defaultPadding),
        child: Container(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            children: [
              Header(changeScreen: widget.changeScreen ?? changeScreen),
              const SizedBox(height: defaultPadding),
              const MiniInformation(),
              const SizedBox(height: defaultPadding),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        //MyFiels(),
                        //SizedBox(height: defaultPadding),
                        const RecentUsers(),
                        const SizedBox(height: defaultPadding),
                        const RecentDiscussions(),
                        if (Responsive.isMobile(context))
                          const SizedBox(height: defaultPadding),
                        if (Responsive.isMobile(context))
                          const UserDetailsWidget(),
                      ],
                    ),
                  ),
                  if (!Responsive.isMobile(context))
                    const SizedBox(width: defaultPadding),
                  // On Mobile means if the screen is less than 850 we dont want to show it
                  if (!Responsive.isMobile(context))
                    const Expanded(
                      flex: 2,
                      child: UserDetailsWidget(),
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
