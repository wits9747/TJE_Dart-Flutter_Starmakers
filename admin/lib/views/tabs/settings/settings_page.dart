import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatadmin/helpers/config.dart';
import 'package:lamatadmin/providers/admin_provider.dart';
// import 'package:lamatadmin/providers/app_settings_provider.dart';
import 'package:lamatadmin/providers/auth_provider.dart';
import 'package:lamatadmin/views/dashboard/components/header.dart';
import 'package:lamatadmin/views/home/components/side_menu.dart';
// import 'package:lamatadmin/providers/reset_database_provider.dart';
import 'package:lamatadmin/views/others/other_widgets.dart';
// import 'package:lamatadmin/views/tabs/app_settings/app_settings.dart';
import 'package:lamatadmin/views/tabs/account_settings/change_email.dart';
import 'package:lamatadmin/views/tabs/account_settings/change_name.dart';
import 'package:lamatadmin/views/tabs/account_settings/change_password.dart';
import 'package:restart_app/restart_app.dart';

class SettingsPage extends ConsumerWidget {
  final Function changeScreen;
  const SettingsPage({super.key, required this.changeScreen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminProfile = ref.watch(currentAdminProvider);
    // final appSettingsRef = ref.watch(appSettingsProvider);

    return Scaffold(
      drawer: SideMenu(changeScreen: changeScreen),
      body: adminProfile.when(
        data: (data) {
          if (data != null) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        Header(changeScreen: changeScreen),
                        const SizedBox(height: 32),
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text("Account Settings"),
                        ),
                        Card(
                          child: ListTile(
                            tileColor:
                                AppConstants.primaryColor.withOpacity(.1),
                            title: const Text("Change Name",
                                style: TextStyle(color: Colors.white)),
                            subtitle: const Text("Change your full name",
                                style: TextStyle(color: Colors.white)),
                            leading:
                                const Icon(Icons.edit, color: Colors.white),
                            trailing: const Icon(Icons.chevron_right,
                                color: Colors.white),
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) =>
                                      ChangeNameDialog(admin: data));
                            },
                          ),
                        ),
                        Card(
                          child: ListTile(
                            tileColor:
                                AppConstants.primaryColor.withOpacity(.1),
                            title: const Text("Change Email",
                                style: TextStyle(color: Colors.white)),
                            subtitle: const Text("Change your email address",
                                style: TextStyle(color: Colors.white)),
                            leading: const Icon(Icons.alternate_email_rounded,
                                color: Colors.white),
                            trailing: const Icon(Icons.chevron_right,
                                color: Colors.white),
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) =>
                                      ChangeEmailDialog(admin: data));
                            },
                          ),
                        ),
                        Card(
                          child: ListTile(
                            tileColor:
                                AppConstants.primaryColor.withOpacity(.1),
                            title: const Text("Change Password",
                                style: TextStyle(color: Colors.white)),
                            subtitle: const Text("Change your password",
                                style: TextStyle(color: Colors.white)),
                            leading:
                                const Icon(Icons.password, color: Colors.white),
                            trailing: const Icon(Icons.chevron_right,
                                color: Colors.white),
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) =>
                                      const ChangePasswordDialog());
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    tileColor: AppConstants.secondaryColor.withOpacity(.1),
                    title: const Text("Logout",
                        style: TextStyle(color: Colors.white)),
                    subtitle: const Text("Logout of your account",
                        style: TextStyle(color: Colors.white)),
                    leading:
                        const Icon(Icons.logout_rounded, color: Colors.white),
                    trailing:
                        const Icon(Icons.chevron_right, color: Colors.white),
                    onTap: () async {
                      EasyLoading.show(status: 'Logging out...');

                      await AuthProvider.logout().then((value) async {
                        if (value) {
                          await Restart.restartApp();
                        }
                      });

                      EasyLoading.dismiss();
                    },
                  ),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                const SizedBox(height: 16),
                Header(changeScreen: changeScreen),
                const SizedBox(height: 32),
                const Spacer(),
                const Center(
                  child: SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator()),
                ),
                const Spacer(),
              ],
            );
          }
        },
        error: (error, stackTrace) => const MyErrorWidget(),
        loading: () => const MyLoadingWidget(),
      ),
    );
  }
}
