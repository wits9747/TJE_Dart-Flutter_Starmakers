// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:image_picker_web/image_picker_web.dart';

import 'package:lamatadmin/helpers/config.dart';
import 'package:lamatadmin/models/admin_model.dart';
import 'package:lamatadmin/models/app_settings_model.dart';
import 'package:lamatadmin/providers/admin_provider.dart';
import 'package:lamatadmin/providers/app_settings_provider.dart';
import 'package:lamatadmin/providers/auth_provider.dart';

class SuperAdminRegistrationPage extends ConsumerStatefulWidget {
  const SuperAdminRegistrationPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SuperAdminRegistrationPageState();
}

class _SuperAdminRegistrationPageState
    extends ConsumerState<SuperAdminRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showPassword = false;
  bool showConfirmPassword = false;

  html.File? _cloudFile;
  Uint8List? _fileBytes;
  Image? _imageWidget;

  html.File? _cloudFileProfile;
  Uint8List? _fileBytesProfile;
  Image? _imageWidgetProfile;

  Future<void> getMultipleImageInfos() async {
    html.File? mediaData = await ImagePickerWeb.getImageAsFile();
    // String? mimeType = mime(Path.basename(mediaData!.name));
    html.File? mediaFile = mediaData;
    final reader = html.FileReader();
    reader.readAsArrayBuffer(mediaData!);
    await reader.onLoad.first;
    final image = reader.result as Uint8List;

    // html.File(mediaData.data!, mediaData.fileName!, {'type': mimeType});

    if (mediaFile != null) {
      setState(() {
        _cloudFile = mediaFile;
        _fileBytes = image;
        _imageWidget = Image.memory(image);
      });
    }
  }

  Future<void> getProfileImage() async {
    html.File? mediaData = await ImagePickerWeb.getImageAsFile();
    // String? mimeType = mime(Path.basename(mediaData!.name));
    html.File? mediaFile = mediaData;
    final reader = html.FileReader();
    reader.readAsArrayBuffer(mediaData!);
    await reader.onLoad.first;
    final image = reader.result as Uint8List;

    // html.File(mediaData.data!, mediaData.fileName!, {'type': mimeType});

    if (mediaFile != null) {
      setState(() {
        _cloudFileProfile = mediaFile;
        _fileBytesProfile = image;
        _imageWidgetProfile = Image.memory(image);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
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
            height: height * .85,
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
              height: height * .85,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(AppConstants.defaultNumericValue * 2),
                color: AppConstants.backgroundColor.withOpacity(0),
              ),
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: AppConstants.defaultNumericValue),
                      const SizedBox(height: 24),
                      Text(
                        'Super Admin Registration',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                // padding: const EdgeInsets.all(
                                //     defaultPadding * 0.75),
                                height: 100,
                                width: 100,
                                decoration: _cloudFile == null
                                    ? BoxDecoration(
                                        color: AppConstants.primaryColor
                                            .withOpacity(0.1),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(20)),
                                      )
                                    : const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)),
                                      ),
                                child: _cloudFile != null
                                    ? _imageWidget
                                    : const SizedBox.shrink(),
                              ),
                              //Edit Icon
                              if (_cloudFile == null)
                                TextButton(
                                  onPressed: () async {
                                    // Pick image from gallery
                                    await getMultipleImageInfos();
                                  },
                                  child: const Text(
                                    "LOGO",
                                    style: TextStyle(
                                        color: AppConstants.backgroundColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              if (_cloudFile != null)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: CircleAvatar(
                                    radius: 15,
                                    backgroundColor:
                                        AppConstants.backgroundColor,
                                    child: IconButton(
                                      onPressed: () async {
                                        // Pick image from gallery
                                        await getMultipleImageInfos();
                                      },
                                      icon: const Icon(
                                          Icons.mode_edit_outline_outlined),
                                      color: AppConstants.primaryColor,
                                    ),
                                  ),
                                )
                            ],
                          ),
                          const SizedBox(width: 24),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                // padding: const EdgeInsets.all(
                                //     defaultPadding * 0.75),
                                height: 100,
                                width: 100,
                                decoration: _cloudFileProfile == null
                                    ? BoxDecoration(
                                        color: AppConstants.primaryColor
                                            .withOpacity(0.1),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(20)),
                                      )
                                    : const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)),
                                      ),
                                child: _cloudFileProfile != null
                                    ? _imageWidgetProfile
                                    : const SizedBox.shrink(),
                              ),
                              //Edit Icon
                              if (_cloudFileProfile == null)
                                TextButton(
                                  onPressed: () async {
                                    // Pick image from gallery
                                    await getProfileImage();
                                  },
                                  child: const Text(
                                    "PROFILE\nPIC",
                                    style: TextStyle(
                                        color: AppConstants.backgroundColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              if (_cloudFileProfile != null)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: CircleAvatar(
                                    radius: 15,
                                    backgroundColor:
                                        AppConstants.backgroundColor,
                                    child: IconButton(
                                      onPressed: () async {
                                        // Pick image from gallery
                                        await getProfileImage();
                                      },
                                      icon: const Icon(
                                          Icons.mode_edit_outline_outlined),
                                      color: AppConstants.primaryColor,
                                    ),
                                  ),
                                )
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal:
                                  AppConstants.defaultNumericValue * 1.5),
                          filled: true,
                          fillColor: AppConstants.primaryColor.withOpacity(.05),
                          hintText: "Full Name",
                          hintStyle:
                              const TextStyle(color: AppConstants.hintColor),
                          border: OutlineInputBorder(
                            // Set outline border
                            borderRadius: BorderRadius.circular(
                                AppConstants.defaultNumericValue * 2),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal:
                                  AppConstants.defaultNumericValue * 1.5),
                          filled: true,
                          fillColor: AppConstants.primaryColor.withOpacity(.05),
                          hintText: "Enter Email",
                          hintStyle:
                              const TextStyle(color: AppConstants.hintColor),
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
                          } else if (!value.contains('@') ||
                              !value.contains('.')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        textInputAction: TextInputAction.done,
                        obscureText: !_showPassword,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal:
                                  AppConstants.defaultNumericValue * 1.5),
                          filled: true,
                          fillColor: AppConstants.primaryColor.withOpacity(.05),
                          hintText: "Password",
                          hintStyle:
                              const TextStyle(color: AppConstants.hintColor),
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
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        textInputAction: TextInputAction.done,
                        obscureText: !showConfirmPassword,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal:
                                  AppConstants.defaultNumericValue * 1.5),
                          filled: true,
                          fillColor: AppConstants.primaryColor.withOpacity(.05),
                          hintText: "Confirm Password",
                          hintStyle:
                              const TextStyle(color: AppConstants.hintColor),
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
                            return 'Please confirm your password';
                          } else if (value != _passwordController.text) {
                            return 'Passwords do not match';
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
                        child: Padding(
                          padding: const EdgeInsets.all(16 / 2),
                          child: Text("Register",
                              style: Theme.of(context).textTheme.titleMedium),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            if (_cloudFile != null) {
                              await AuthProvider.registerWithEmailAndPass(
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
                              ).then((user) async {
                                if (user != null) {
                                  String? uploadedProfilePic;
                                  EasyLoading.show(
                                      status: "Creating Super Admin...");
                                  final appsettings = await FirebaseFirestore
                                      .instance
                                      .collection("appSettings")
                                      .doc("settings")
                                      .get();
                                  final appsettingsSnap = appsettings.data();

                                  if (appsettingsSnap == null) {
                                    String? uploadedLogo;

                                    final storage = FirebaseStorage.instance;
                                    final SettableMetadata metadata =
                                        SettableMetadata(
                                      contentType:
                                          _cloudFile!.name.contains('.png')
                                              ? 'image/png'
                                              : 'image/jpeg',
                                    );
                                    final SettableMetadata metadataProfile =
                                        SettableMetadata(
                                      contentType: _cloudFileProfile!.name
                                              .contains('.png')
                                          ? 'image/png'
                                          : 'image/jpeg',
                                    );

                                    final reff = storage
                                        .ref()
                                        .child("app_logos/${_cloudFile!.name}");
                                    final reffProfile = storage.ref().child(
                                        "admin_profile/${_cloudFileProfile!.name}");
                                    final uploadTask =
                                        reff.putData(_fileBytes!, metadata);
                                    final uploadTaskProfile =
                                        reffProfile.putData(_fileBytesProfile!,
                                            metadataProfile);
                                    await uploadTask.whenComplete(() async {
                                      // uploadedLogo download Url
                                      uploadedLogo =
                                          await reff.getDownloadURL();
                                    });
                                    await uploadTaskProfile
                                        .whenComplete(() async {
                                      // uploadedLogo download Url
                                      uploadedProfilePic =
                                          await reffProfile.getDownloadURL();
                                    });
                                    AppSettingsModel appSettingsModel =
                                        AppSettingsModel(
                                            isChattingEnabledBeforeMatch: true,
                                            admobBanner: "",
                                            admobInt: "",
                                            admobIntIos: "",
                                            admobBannerIos: "",
                                            maxUploadDaily: int.parse("5"),
                                            liveMinViewers: int.parse("1"),
                                            liveTimeout: int.parse("60"),
                                            rewardVideoUpload: int.parse("3"),
                                            minFansForLive: int.parse("1"),
                                            minFansVerification: int.parse("1"),
                                            minRedeemCoins: int.parse("5"),
                                            minWithdrawal: int.parse("5"),
                                            coinValue: double.parse("0.5"),
                                            dailyWithdrawalLimit: int.parse(
                                                "999"),
                                            currency: "USD",
                                            agoraAppId: "",
                                            agoraAppCert: "",
                                            primaryColor: AppConstants
                                                .primaryColor.value
                                                .toString(),
                                            primaryDarkColor: AppConstants
                                                .primaryColorDark.value
                                                .toString(),
                                            secondaryColor: AppConstants
                                                .secondaryColor.value
                                                .toString(),
                                            tintColor:
                                                AppConstants
                                                    .secondaryColor.value
                                                    .toString(),
                                            secondaryDarkColor: AppConstants
                                                .secondaryColor.value
                                                .toString(),
                                            appLogo: uploadedLogo);

                                    await AppSettingsProvider.addAppSettings(
                                            appSettingsModel)
                                        .then((value) {
                                      ref.invalidate(appSettingsProvider);
                                    });
                                  }

                                  final userappSet = await FirebaseFirestore
                                      .instance
                                      .collection("appSettings")
                                      .doc("userapp")
                                      .get();
                                  final userappSetSnap = userappSet.data();

                                  if (userappSetSnap == null) {
                                    await FirebaseFirestore.instance
                                        .collection("appSettings")
                                        .doc("userapp")
                                        .set({
                                      "accountapprovalmessage":
                                          "Account Approved",
                                      "appShareMessageStringAndroid":
                                          "Find me on XOXO and Chat With People Nearby, Date People Nearby, Send Gifts, Earn Diamondz, Redeem Coins, Music, Videos, Games, Events and much more!",
                                      "appShareMessageStringiOS":
                                          "Find me on XOXO and Chat With People Nearby, Date People Nearby, Send Gifts, Earn Diamondz, Redeem Coins, Music, Videos, Games, Events and much more!",
                                      "broadcastMemberslimit": 999,
                                      "feedbackEmail": 'demo@abbble.co',
                                      "groupmemberslimit": 200,
                                      "is24hrsTimeformat": true,
                                      "isAllowCreatingBroadcasts": true,
                                      "isAllowCreatingGroups": true,
                                      "isAllowCreatingStatus": true,
                                      "isCallFeatureTotallyHide": false,
                                      "isCustomAppShareLink": true,
                                      "isLogoutButtonShowInSettingsPage": true,
                                      "isPercentProgressShowWhileUploading":
                                          true,
                                      "is_web_compatible": false,
                                      "isaccountapprovalbyadminneeded": false,
                                      "isadmobshow": true,
                                      "isappunderconstructionandroid": false,
                                      "isappunderconstructionios": false,
                                      "isappunderconstructionweb": false,
                                      "isblocknewlogins": false,
                                      "iscallsallowed": true,
                                      "isemlalwd": true,
                                      "ismediamessageallowed": true,
                                      "istextmessageallowed": true,
                                      "latestappversionandroid": "1.0.0",
                                      "latestappversionios": "1.0.0",
                                      "latestappversionweb": "1.0.0",
                                      "maintainancemessage":
                                          "Running System Upgrading! Please check back later",
                                      "maxFileSizeAllowedInMB": 250,
                                      "maxNoOfContactsSelectForForward": 29,
                                      "maxNoOfFilesInMultiSharing": 29,
                                      "newapplinkandroid": "https://google.com",
                                      "newapplinkios": "https://google.com",
                                      "newapplinkweb": "https://google.com",
                                      "ppl": "https://google.com",
                                      "pplType": "url",
                                      "statusDeleteAfterInHours": 24,
                                      "tnc": "https://google.com",
                                      "tncType": "url"
                                    }, SetOptions(merge: true));
                                  }

                                  final AdminModel admin = AdminModel(
                                    id: user.uid,
                                    name: _nameController.text.trim(),
                                    email: _emailController.text.trim(),
                                    profilePic: uploadedProfilePic!,
                                    permissions: permissions,
                                    isSuperAdmin: true,
                                    createdAt: DateTime.now(),
                                  );

                                  await AdminProvider.addAdmin(admin: admin)
                                      .then((value) {
                                    ref.invalidate(superAdminProvider);
                                    ref.invalidate(
                                        isUserAdminProvider(user.uid));
                                    EasyLoading.dismiss();
                                  });
                                }
                              });
                            } else {
                              EasyLoading.showError(
                                  "Please upload app logo & profile pic");
                            }
                          }
                        },
                      ),
                      SizedBox(height: height * .1),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
