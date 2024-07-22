// ignore_for_file: deprecated_member_use

import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:lamatadmin/core/constants/color_constants.dart';
import 'package:lamatadmin/helpers/config.dart';
import 'package:lamatadmin/providers/account_delete_request_provider.dart';
import 'package:lamatadmin/providers/admin_provider.dart';
import 'package:lamatadmin/providers/user_reports_provider.dart';
import 'package:lamatadmin/providers/user_verification_forms_provider.dart';
import 'package:lamatadmin/views/dashboard/dashboard_screen.dart';
import 'package:lamatadmin/views/others/other_widgets.dart';
import 'package:lamatadmin/views/tabs/account_delete_requests/account_delete_requests_page.dart';
import 'package:lamatadmin/views/tabs/admins/admins_page.dart';
import 'package:lamatadmin/views/tabs/app_settings/app_settings.dart';
import 'package:lamatadmin/views/tabs/appearance/appearance.dart';
import 'package:lamatadmin/views/tabs/boosters/boosters.dart';
import 'package:lamatadmin/views/tabs/coin_plans/plans.dart';
import 'package:lamatadmin/views/tabs/feeds/recent_feeds.dart';
import 'package:lamatadmin/views/tabs/gifts/gifts_page.dart';
import 'package:lamatadmin/views/tabs/reports/reports_page.dart';
import 'package:lamatadmin/views/tabs/settings/settings_page.dart';
import 'package:lamatadmin/views/tabs/sounds/sounds_categories.dart';
import 'package:lamatadmin/views/tabs/teels/recent_teels.dart';
import 'package:lamatadmin/views/tabs/users/users_page.dart';
import 'package:lamatadmin/views/tabs/verifications/verification_page.dart';
import 'package:lamatadmin/views/tabs/widrawals/withdrawal_feeds.dart';

class SideMenu extends ConsumerWidget {
  final Function changeScreen;
  const SideMenu({Key? key, required this.changeScreen}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final currentUser = ref.watch(currentAdminProvider);
    final allReportsRef = ref.watch(allReportsProvider);
    final verificationsref = ref.watch(pendingVerificationFormsStreamProvider);
    final allAccDelReqs = ref.watch(accountDeleteRequestsProvider);
    // final appSettingsProviderRef = ref.watch(appSettingsProvider);
    return Drawer(
        child: currentUser.when(
      data: (user) {
        return user != null
            ? SingleChildScrollView(
                // it enables scrolling
                child: Column(
                  children: [
                    DrawerHeader(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: defaultPadding,
                        ),
                        AppConstants.appLogo != ""
                            ? CachedNetworkImage(
                                imageUrl: AppConstants.appLogo,
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              )
                            : SizedBox(
                                width: 120,
                                height: 120,
                                child: Image.asset("assets/logo/logo.png"),
                              ),
                        const SizedBox(
                          height: defaultPadding,
                        ),
                      ],
                    )),
                    DrawerListTile(
                      title: "Dashboard",
                      svgSrc: "assets/icons/menu_dashbord.svg",
                      press: () => changeScreen(
                          DashboardScreen(changeScreen: changeScreen)),
                    ),
                    if (user.isSuperAdmin)
                      DrawerListTile(
                        title: "Admins",
                        svgSrc: AppConstants.menuProfile,
                        press: () {
                          changeScreen(AdminsPage(changeScreen: changeScreen));
                        },
                      ),
                    DrawerListTile(
                      title: "All Users",
                      svgSrc: AppConstants.menuProfile,
                      press: () {
                        changeScreen(UsersPage(changeScreen: changeScreen));
                      },
                    ),
                    DrawerListTile(
                      title: "Trending Teels",
                      svgSrc: AppConstants.menuTrendingTeels,
                      press: () {
                        changeScreen(TeelsPage(changeScreen: changeScreen));
                      },
                    ),
                    DrawerListTile(
                      title: "Trending Posts",
                      svgSrc: AppConstants.menuTrendingPosts,
                      press: () {
                        changeScreen(FeedsPage(changeScreen: changeScreen));
                      },
                    ),
                    verificationsref.when(
                      data: (verifications) {
                        return badges.Badge(
                            showBadge: verifications.isNotEmpty ? true : false,
                            position:
                                badges.BadgePosition.topEnd(top: 0, end: 10),
                            badgeContent: Text('${verifications.length}'),
                            child: DrawerListTile(
                              title: "Verify Users",
                              svgSrc: AppConstants.menuVerified,
                              press: () {
                                changeScreen(VerificationsPage(
                                    changeScreen: changeScreen));
                              },
                            ));
                      },
                      loading: () => DrawerListTile(
                        title: "Verify Users",
                        svgSrc: AppConstants.menuVerified,
                        press: () {
                          changeScreen(
                              VerificationsPage(changeScreen: changeScreen));
                        },
                      ),
                      error: (error, stack) => DrawerListTile(
                        title: "Verify Users",
                        svgSrc: AppConstants.menuVerified,
                        press: () {
                          changeScreen(
                              VerificationsPage(changeScreen: changeScreen));
                        },
                      ),
                    ),
                    DrawerListTile(
                      title: "Appearance",
                      svgSrc: AppConstants.menuAppearance,
                      press: () {
                        changeScreen(
                            AppearancePage(changeScreen: changeScreen));
                      },
                    ),
                    allReportsRef.when(
                      data: (allReports) {
                        return badges.Badge(
                            showBadge: allReports.isNotEmpty ? true : false,
                            position:
                                badges.BadgePosition.topEnd(top: 0, end: 10),
                            badgeContent: Text('${allReports.length}'),
                            child: DrawerListTile(
                              title: "Reports",
                              svgSrc: AppConstants.menuFlagged,
                              press: () {
                                changeScreen(
                                    ReportsPage(changeScreen: changeScreen));
                              },
                            ));
                      },
                      loading: () => DrawerListTile(
                        title: "Reports",
                        svgSrc: AppConstants.menuFlagged,
                        press: () {
                          changeScreen(ReportsPage(changeScreen: changeScreen));
                        },
                      ),
                      error: (error, stack) => DrawerListTile(
                        title: "Reports",
                        svgSrc: AppConstants.menuFlagged,
                        press: () {
                          changeScreen(ReportsPage(changeScreen: changeScreen));
                        },
                      ),
                    ),
                    DrawerListTile(
                      title: "Coin Plans",
                      svgSrc: AppConstants.menuStore,
                      press: () {
                        changeScreen(PlansPage(changeScreen: changeScreen));
                      },
                    ),
                    DrawerListTile(
                      title: "Gifts",
                      svgSrc: AppConstants.menuStore,
                      press: () {
                        changeScreen(GiftsPage(changeScreen: changeScreen));
                      },
                    ),
                    DrawerListTile(
                      title: "Boosters",
                      svgSrc: AppConstants.menuStore,
                      press: () {
                        changeScreen(BoostersPage(changeScreen: changeScreen));
                      },
                    ),
                    DrawerListTile(
                      title: "Songs",
                      svgSrc: AppConstants.menuStore,
                      press: () {
                        changeScreen(SoundsScreen(changeScreen: changeScreen));
                      },
                    ),
                    DrawerListTile(
                      title: "Withdrawals",
                      svgSrc: AppConstants.menuStore,
                      press: () {
                        changeScreen(
                            WithdrawalsPage(changeScreen: changeScreen));
                      },
                    ),
                    DrawerListTile(
                      title: "Account",
                      svgSrc: AppConstants.menuAccount,
                      press: () {
                        changeScreen(SettingsPage(changeScreen: changeScreen));
                      },
                    ),
                    DrawerListTile(
                      title: "App Settings",
                      svgSrc: AppConstants.menuAppSettings,
                      press: () {
                        changeScreen(
                            AppSettingsPage(changeScreen: changeScreen));
                      },
                    ),
                    allAccDelReqs.when(
                      data: (allAccountDeleteRequests) {
                        return badges.Badge(
                            showBadge: allAccountDeleteRequests.isNotEmpty
                                ? true
                                : false,
                            position:
                                badges.BadgePosition.topEnd(top: 0, end: 10),
                            badgeContent:
                                Text('${allAccountDeleteRequests.length}'),
                            child: DrawerListTile(
                              title: "Removal Request",
                              svgSrc: AppConstants.menuAppSettings,
                              press: () {
                                changeScreen(AccountDeleteRequestsPage(
                                    changeScreen: changeScreen));
                              },
                            ));
                      },
                      loading: () => DrawerListTile(
                        title: "Removal Request",
                        svgSrc: AppConstants.menuAppSettings,
                        press: () {},
                      ),
                      error: (error, stack) => DrawerListTile(
                        title: "Removal Request",
                        svgSrc: AppConstants.menuAppSettings,
                        press: () {},
                      ),
                    ),
                  ],
                ),
              )
            : const MyErrorWidget();
      },
      loading: () => const MyLoadingWidget(),
      error: (error, stack) => const MyErrorWidget(),
    ));
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    // For selecting those three line once press "Command+D"
    required this.title,
    required this.svgSrc,
    required this.press,
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(
        svgSrc,
        color: Colors.white54,
        height: 16,
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white54),
      ),
    );
  }
}
