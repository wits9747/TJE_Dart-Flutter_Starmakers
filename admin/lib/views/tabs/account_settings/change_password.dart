import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:lamatadmin/helpers/config.dart';
import 'package:lamatadmin/helpers/demo_constants.dart';
import 'package:lamatadmin/providers/auth_provider.dart';

class ChangePasswordDialog extends ConsumerStatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends ConsumerState<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return GlassmorphicContainer(
        width: width * .5,
        height: height * .5,
        borderRadius: 20,
        blur: 20,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFffffff).withOpacity(0.1),
              const Color(0xFFFFFFFF).withOpacity(0.05),
            ],
            stops: const [
              0.1,
              1,
            ]),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFffffff).withOpacity(0.5),
            const Color((0xFFFFFFFF)).withOpacity(0.5),
          ],
        ), // Adjust blur strength
        child: AlertDialog(
          title: const Text('Change Password'),
          content: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _oldPasswordController,
                    // header: "Old Password",
                    decoration: InputDecoration(
                      hintText:
                          'Enter your old password', // Use labelText for placeholder
                      hintStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: AppConstants.primaryColor.withOpacity(.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            AppConstants.defaultNumericValue * 2),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your old password';
                      } else if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _newPasswordController,
                    // header: "New Password",
                    decoration: InputDecoration(
                      hintText:
                          'Enter your new password', // Use labelText for placeholder
                      hintStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: AppConstants.primaryColor.withOpacity(.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            AppConstants.defaultNumericValue * 2),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your new password';
                      } else if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    // header: "Confirm Password",
                    decoration: InputDecoration(
                      hintText:
                          'Confirm your new mail', // Use labelText for placeholder
                      hintStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: AppConstants.primaryColor.withOpacity(.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            AppConstants.defaultNumericValue * 2),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please confirm your new password';
                      } else if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      } else if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (DemoConstants.isDemo) {
                    EasyLoading.showInfo(
                        'This feature is not available for public demo!');
                  } else {
                    await AuthProvider.verifyPassword(
                            password: _oldPasswordController.text.trim())
                        .then((value) async {
                      if (value) {
                        await AuthProvider.changePassword(
                                password: _newPasswordController.text.trim())
                            .then((value) {
                          if (value) {
                            Navigator.of(context).pop();
                          }
                        });
                      }
                    });
                  }
                }
              },
              child:
                  const Text('Update', style: TextStyle(color: Colors.white)),
            ),
          ],
        ));
  }
}
