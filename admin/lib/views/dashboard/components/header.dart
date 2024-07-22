// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:lamatadmin/core/constants/color_constants.dart';
import 'package:lamatadmin/helpers/config.dart';
import 'package:lamatadmin/models/admin_model.dart';
import 'package:lamatadmin/providers/admin_provider.dart';
import 'package:lamatadmin/providers/auth_provider.dart';
import 'package:lamatadmin/providers/search_text_provider.dart';
import 'package:lamatadmin/providers/user_profiles_provider.dart';
import 'package:lamatadmin/responsive.dart';
import 'package:lamatadmin/views/others/other_widgets.dart';
// import 'package:lamatadmin/views/tabs/app_settings/app_settings.dart';
import 'package:lamatadmin/views/tabs/settings/settings_page.dart';
import 'package:restart_app/restart_app.dart';

class Header extends ConsumerWidget {
  final Function? changeScreen;

  const Header({
    Key? key,
    required this.changeScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final currentUser = ref.watch(currentAdminProvider);
    return currentUser.when(
      data: (user) {
        return user != null
            ? AppBar(
                automaticallyImplyLeading:
                    (Responsive.isMobile(context)) ? true : false,
                title: Row(
                  children: [
                    // if (Responsive.isMobile(context))
                    //         AppBar(
                    //           automaticallyImplyLeading:
                    //               true, // This enables the default menu button
                    //         ),

                    if (!Responsive.isMobile(context))
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hello, ${user.name} 👋",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            "Wellcome to your dashboard",
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                    if (!Responsive.isMobile(context))
                      Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),

                    // const Expanded(child: SearchField()),
                    const Expanded(
                      child: SizedBox(),
                    ),
                    InkWell(
                      onTap: () {
                        cleanDatabase();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(defaultPadding * 0.75),
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: AppConstants.secondaryColor.withOpacity(0.1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: const Icon(
                          CupertinoIcons.refresh,
                          color: AppConstants.secondaryColor,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: defaultPadding),
                    ProfileCard(user: user, changeScreen: changeScreen!)
                  ],
                ))
            : const MyErrorWidget();
      },
      loading: () => const MyLoadingWidget(),
      error: (error, stack) => const MyErrorWidget(),
    );
  }
}

class ProfileCard extends StatelessWidget {
  final AdminModel user;
  final Function changeScreen;
  const ProfileCard({
    Key? key,
    required this.user,
    required this.changeScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        offset: const Offset(0, 60),
        onSelected: (value) {
          // your logic
        },
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16))),
        itemBuilder: (BuildContext bc) {
          return [
            PopupMenuItem(
              value: '/profile',
              onTap: () {
                changeScreen(SettingsPage(changeScreen: changeScreen));
              },
              child: const Text("Profile"),
            ),
            // const PopupMenuItem(
            //   value: '/accsetting',
            //   child: Text("App Settings"),
            // ),
            PopupMenuItem(
              value: '/logout',
              onTap: () async {
                EasyLoading.show(status: 'Logging out...');

                await AuthProvider.logout().then((value) async {
                  if (value) {
                    await Restart.restartApp();
                  }
                });

                EasyLoading.dismiss();
              },
              child: const Text("Logout"),
            )
          ];
        },
        child: Container(
          // margin: const EdgeInsets.only(left: defaultPadding),
          padding: const EdgeInsets.symmetric(
            horizontal: defaultPadding,
            vertical: defaultPadding / 2,
          ),
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(user.profilePic),
              ),
              if (!Responsive.isMobile(context))
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: defaultPadding / 2),
                  child: Text(user.name),
                ),
              const Icon(Icons.keyboard_arrow_down),
            ],
          ),
        ));
  }
}

class SearchField extends ConsumerWidget {
  const SearchField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final controller = ref.watch(textControllerProvider);
    final controllerNotifier = ref.read(textControllerProvider.notifier);

    return TextField(
      controller: controller,
      // onChanged: (value) {
      //   controllerNotifier.updateText(controller.text);

      //   print(controller.text);
      // },
      decoration: InputDecoration(
        hintText: "Search",
        fillColor: secondaryColor,
        filled: true,
        border: const OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        suffixIcon: InkWell(
          onTap: () {
            controllerNotifier.updateText(controller.text);
          },
          child: Container(
            padding: const EdgeInsets.all(defaultPadding * 0.75),
            margin: const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
            decoration: BoxDecoration(
              color: AppConstants.secondaryColor.withOpacity(.1),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: SvgPicture.asset(
              "assets/icons/Search.svg",
              color: AppConstants.secondaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
