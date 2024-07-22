import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism/glassmorphism.dart';

import 'package:lamatadmin/helpers/config.dart';
import 'package:lamatadmin/helpers/demo_constants.dart';
import 'package:lamatadmin/helpers/email_verifier.dart';
import 'package:lamatadmin/providers/admin_provider.dart';
import 'package:lamatadmin/providers/app_settings_provider.dart';
import 'package:lamatadmin/providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final appSettingsProviderRef = ref.watch(appSettingsProvider).value;
    return Scaffold(
        body: Container(
      width: width,
      height: height,
      // color: AppConstants.primaryColor,
      decoration: const BoxDecoration(
          image: DecorationImage(
        fit: BoxFit.cover,
        image: AssetImage(AppConstants.bgImage),
      )),
      child: Center(
        child: GlassmorphicContainer(
          width: width * .8,
          height: height * .8,
          borderRadius: 20,
          blur: 20,
          alignment: Alignment.bottomCenter,
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
          child: Container(
            width: width * .8,
            height: height * .8,
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(AppConstants.defaultNumericValue * 2),
              color: AppConstants.backgroundColor.withOpacity(0),
            ),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: AppConstants.defaultNumericValue),
                  if (appSettingsProviderRef!.appLogo != null)
                    CachedNetworkImage(
                      imageUrl: appSettingsProviderRef.appLogo!,
                      imageBuilder: (context, imageProvider) => Container(
                        width: 40,
                        height: 40,
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
                    ),
                  SizedBox(height: height * 0.1),
                  TextFormField(
                    controller: _emailController,
                    autofillHints: const <String>[AutofillHints.email],
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(color: AppConstants.textColor),
                    cursorColor: AppConstants.secondaryColor,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.defaultNumericValue * 1.5),
                      filled: true,
                      fillColor: AppConstants.primaryColor.withOpacity(.05),
                      hintText: "Enter Email",
                      hintStyle: const TextStyle(color: AppConstants.hintColor),
                      border: OutlineInputBorder(
                        // Set outline border
                        borderRadius: BorderRadius.circular(
                            AppConstants.defaultNumericValue * 2),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your email';
                      } else if (!value.contains('@') || !value.contains('.')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    autofillHints: const <String>[AutofillHints.password],
                    textInputAction: TextInputAction.done,
                    obscureText: !_showPassword,
                    style: const TextStyle(color: AppConstants.textColor),
                    cursorColor: AppConstants.secondaryColor,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.defaultNumericValue * 1.5),
                      filled: true,
                      fillColor: AppConstants.primaryColor.withOpacity(.05),
                      hintText: "Password",
                      hintStyle: const TextStyle(color: AppConstants.hintColor),
                      border: OutlineInputBorder(
                        // Set outline border
                        borderRadius: BorderRadius.circular(
                            AppConstants.defaultNumericValue * 2),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 18.0),
                        child: IconButton(
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your password';
                      } else if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
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
                    child: const Padding(
                      padding: EdgeInsets.all(16 / 2),
                      child:
                          Text("Login", style: TextStyle(color: Colors.white)),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await AuthProvider.loginWithEmailAndPass(
                          email: _emailController.text.trim(),
                          password: _passwordController.text.trim(),
                        ).then((value) {
                          if (value != null) {
                            ref.invalidate(isUserAdminProvider(value.uid));
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const ResetPasswordForm(),
                      );
                    },
                    style: TextButton.styleFrom(

                        // Optionally customize text style and color here
                        // textStyle: TextStyle(decoration: TextDecoration.underline),
                        ),
                    child: const Text('Forgot password?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppConstants.textColor,
                        )),
                  ),
                  const SizedBox(height: 16),
                  if (DemoConstants.isDemo)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Demo Email: ",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Flexible(
                              child: SelectableText("demo@abbble.co",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(fontWeight: FontWeight.bold)),
                            ),
                            IconButton(
                                icon: const Icon(Icons.copy),
                                onPressed: () {
                                  _emailController.text = "demo@abbble.co";
                                })
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Demo Password: ",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Flexible(
                              child: SelectableText("123456789",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(fontWeight: FontWeight.bold)),
                            ),
                            IconButton(
                                icon: const Icon(Icons.copy),
                                onPressed: () {
                                  _passwordController.text = "123456789";
                                })
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }
}

class ResetPasswordForm extends ConsumerStatefulWidget {
  const ResetPasswordForm({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ResetPasswordFormState();
}

class _ResetPasswordFormState extends ConsumerState<ResetPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

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
          title: const Center(
              child: Text(
            'Reset Password',
            style: TextStyle(color: Colors.white),
          )),
          backgroundColor: Colors.transparent,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText:
                            'Enter your email', // Use labelText for placeholder
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
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your email';
                        } else if (emailVerifier().hasMatch(value) == false) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await AuthProvider.forgotPassword(
                              email: _emailController.text.trim())
                          .then((value) {
                        Navigator.of(context).pop();
                      });
                    }
                  },
                  child: const Text('Reset',
                      style: TextStyle(color: Colors.white)),
                ),
              ]),
            ],
          ),
        ));
  }
}
