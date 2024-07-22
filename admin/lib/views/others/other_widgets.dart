import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatadmin/helpers/config.dart';
import 'package:lamatadmin/providers/auth_provider.dart';
import 'package:restart_app/restart_app.dart';

class MyErrorWidget extends StatelessWidget {
  const MyErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: 150,
          child: Column(
            children: [
              const Text(
                "Something went wrong!\nPlease try again later!",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              //Restart App Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor:
                      AppConstants.primaryColor, // Set primary color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        AppConstants.defaultNumericValue * 2),
                  ),
                ),
                onPressed: () async {
                  await Restart.restartApp();
                },
                child: Padding(
                  padding: const EdgeInsets.all(16 / 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.restart_alt, color: Colors.white),
                      const SizedBox(width: 8),
                      Text("Reload",
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MyLoadingWidget extends StatelessWidget {
  const MyLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 50, width: 50);
  }
}

class NotAdminWidget extends StatelessWidget {
  const NotAdminWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "You are not an admin!\nPlease contact the admin!",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              child: const Text("Logout"),
              onPressed: () async {
                EasyLoading.show(status: "Logging out...");
                await AuthProvider.logout().then((value) {
                  EasyLoading.dismiss();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class NotEmailVerifiedWidget extends ConsumerWidget {
  const NotEmailVerifiedWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Please verify your email address!",
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              child: const Text("Send verification email"),
              onPressed: () async {
                if (currentUser != null) {
                  EasyLoading.show(status: "Sending verification email...");
                  await AuthProvider.sendEmailVerification(currentUser)
                      .then((value) {
                    if (value) {
                      EasyLoading.showSuccess("Verification email sent!");
                    }
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            FilledButton(
              child: const Text("Logout"),
              onPressed: () async {
                EasyLoading.show(status: "Logging out...");
                await AuthProvider.logout().then((value) {
                  EasyLoading.dismiss();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
