// import 'package:fluent_ui/fluent_ui.dart' as fluent;

// ignore_for_file: avoid_web_libraries_in_flutter, library_prefixes

import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:lamatadmin/helpers/firebase_constants.dart';
// import 'package:mime_type/mime_type.dart';
// import 'package:path/path.dart' as Path;
import 'package:image_picker_web/image_picker_web.dart';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatadmin/helpers/config.dart';
import 'package:lamatadmin/models/app_settings_model.dart';
import 'package:lamatadmin/providers/app_settings_provider.dart';
import 'package:lamatadmin/core/constants/color_constants.dart';
import 'package:lamatadmin/views/dashboard/components/header.dart';
import 'package:lamatadmin/views/home/components/side_menu.dart';
import 'package:lamatadmin/views/others/other_widgets.dart';
import 'package:web_color_picker/web_color_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AppearancePage extends ConsumerStatefulWidget {
  final Function changeScreen;
  const AppearancePage({
    super.key,
    required this.changeScreen,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AppearancePageState();
}

class _AppearancePageState extends ConsumerState<AppearancePage> {
  int defaultTimer = 3;

  AppSettingsModel? appSettingsModel;

  String? _primaryColor;

  String? _primaryDarkColor;

  String? _tintColor;

  String? _secondaryDarkColor;

  String? _secondaryColor;

  @override
  void initState() {
    super.initState();
  }

  html.File? _cloudFile;
  Uint8List? _fileBytes;
  Image? _imageWidget;

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

  // Future<html.File?> pickImage() async {
  //   final image = await ImagePickerWeb.getImageInfo;
  //   String? mimeType = mime(Path.basename(image!.fileName!));
  //   html.File? mediaFile =
  //       html.File(image.data!, image.fileName!, {'type': mimeType});
  //   // Handle the picked image (if not null)
  //   return mediaFile;
  // }

  Future<Uint8List?> pickImage() async {
    final image = await ImagePickerWeb.getImageAsBytes();
    // String? mimeType = mime(Path.basename(image!.fileName!));
    // html.File? mediaFile =
    //     html.File(image.data!, image.fileName!, {'type': mimeType});
    // Handle the picked image (if not null)
    return image;
  }

  Future<void> updateAppSettings() async {
    // final appSettingsRef = ref.watch(appSettingsProvider);

    String? uploadedLogo;

    final storage = FirebaseStorage.instance;
    final SettableMetadata metadata = SettableMetadata(
      contentType:
          _cloudFile!.name.contains('.png') ? 'image/png' : 'image/jpeg',
    );
    if (_cloudFile != null && _fileBytes != null) {
      final reff = storage.ref().child("app_logos/${_cloudFile!.name}");
      final uploadTask = reff.putData(_fileBytes!, metadata);
      await uploadTask.whenComplete(() async {
        // uploadedLogo download Url
        uploadedLogo = await reff.getDownloadURL();
      });
    }

    if (_fileBytes != null) {
      if (uploadedLogo != null) {
        AppSettingsModel appSettingsModelUpdate = appSettingsModel!.copyWith(
            primaryColor: _primaryColor,
            primaryDarkColor: _primaryDarkColor,
            tintColor: _tintColor,
            secondaryDarkColor: _secondaryDarkColor,
            secondaryColor: _secondaryColor,
            appLogo: uploadedLogo);

        await AppSettingsProvider.addAppSettings(appSettingsModelUpdate)
            .then((value) {
          ref.invalidate(appSettingsProvider);
        });
      }
    } else {
      AppSettingsModel appSettingsModelUpdate = appSettingsModel!.copyWith(
        primaryColor: _primaryColor,
        primaryDarkColor: _primaryDarkColor,
        tintColor: _tintColor,
        secondaryDarkColor: _secondaryDarkColor,
        secondaryColor: _secondaryColor,
      );

      await AppSettingsProvider.addAppSettings(appSettingsModelUpdate)
          .then((value) {
        ref.invalidate(appSettingsProvider);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appSettingsRef = ref.watch(appSettingsProvider);

    return Scaffold(
      drawer: SideMenu(changeScreen: widget.changeScreen),
      // bottomSheet: Expanded(
      //   child: Container(
      //       height: 100,
      //       decoration: BoxDecoration(
      //         color: bgColor,
      //         borderRadius: BorderRadius.circular(25),
      //       ),
      //       child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      //         Expanded(
      //           child: ElevatedButton(
      //             onPressed: () async {
      //               await updateAppSettings();
      //               EasyLoading.showSuccess('Settings updated');
      //               Future.delayed(Duration(seconds: defaultTimer), () {
      //                 EasyLoading.dismiss();
      //               });
      //             },
      //             child: Text('Update',
      //                 style: Theme.of(context).textTheme.titleMedium),
      //           ),
      //         )
      //       ])),
      // ),
      body: appSettingsRef.when(
        data: (data) {
          if (data != null) {
            appSettingsModel = data;
            _primaryColor = data.primaryColor;
            _primaryDarkColor = data.primaryDarkColor;
            _secondaryColor = data.secondaryColor;
            _secondaryDarkColor = data.secondaryDarkColor;
            _tintColor = data.tintColor;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Header(changeScreen: widget.changeScreen),
                    const SizedBox(height: 16),
                    Expanded(
                        child: Container(
                      padding: const EdgeInsets.all(defaultPadding),
                      decoration: const BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            "Appearance Settings",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: GridView.count(
                              crossAxisCount: 5, // Two columns in the grid
                              mainAxisSpacing: 10.0, // Spacing between rows
                              crossAxisSpacing: 10.0, // Spacing between columns
                              children: [
                                Container(
                                  height: 150,
                                  width: 200,
                                  padding: const EdgeInsets.all(defaultPadding),
                                  decoration: const BoxDecoration(
                                    color: bgColor,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(
                                                defaultPadding * 0.75),
                                            height: 80,
                                            width: 80,
                                            decoration: BoxDecoration(
                                              color: appSettingsModel!
                                                          .primaryColor ==
                                                      null
                                                  ? AppConstants.primaryColor
                                                  : Color(int.parse(
                                                          appSettingsModel!
                                                              .primaryColor!))
                                                      .withOpacity(0.1),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(10)),
                                            ),
                                            child: Icon(
                                              Icons.ac_unit_rounded,
                                              color: appSettingsModel!
                                                          .primaryColor ==
                                                      null
                                                  ? AppConstants.primaryColor
                                                  : Color(int.parse(
                                                      appSettingsModel!
                                                          .primaryColor!)),
                                              size: 52,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Primary Color",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          WebColorPicker.builder(
                                            initialColor: appSettingsModel!
                                                        .primaryColor ==
                                                    null
                                                ? AppConstants.primaryColor
                                                : Color(int.parse(
                                                    appSettingsModel!
                                                        .primaryColor!)),
                                            builder: (context, selectedColor) {
                                              if (selectedColor != null) {
                                                _primaryColor = selectedColor
                                                    .value
                                                    .toString();
                                              }
                                              return ElevatedButton(
                                                onPressed: () {},
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: selectedColor !=
                                                          null
                                                      ? selectedColor
                                                          .withOpacity(0.1)
                                                      : AppConstants
                                                          .primaryColor
                                                          .withOpacity(
                                                              0.1), // background
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 20,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      width: 20,
                                                      height: 20,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        color: selectedColor,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 8,
                                                    ),
                                                    const Text(
                                                      "Pick Color",
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 150,
                                  width: 200,
                                  padding: const EdgeInsets.all(defaultPadding),
                                  decoration: const BoxDecoration(
                                    color: bgColor,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(
                                                defaultPadding * 0.75),
                                            height: 80,
                                            width: 80,
                                            decoration: BoxDecoration(
                                              color: appSettingsModel!
                                                          .primaryDarkColor ==
                                                      null
                                                  ? AppConstants.primaryColor
                                                  : Color(int.parse(
                                                          appSettingsModel!
                                                              .primaryDarkColor!))
                                                      .withOpacity(0.1),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(10)),
                                            ),
                                            child: Icon(
                                              Icons.ac_unit_rounded,
                                              color: appSettingsModel!
                                                          .primaryDarkColor ==
                                                      null
                                                  ? AppConstants.primaryColor
                                                  : Color(int.parse(
                                                      appSettingsModel!
                                                          .primaryDarkColor!)),
                                              size: 52,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Primary Dark Color",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          WebColorPicker.builder(
                                            initialColor: appSettingsModel!
                                                        .primaryDarkColor ==
                                                    null
                                                ? AppConstants.primaryColor
                                                : Color(int.parse(
                                                    appSettingsModel!
                                                        .primaryDarkColor!)),
                                            builder: (context, selectedColor) {
                                              if (selectedColor != null) {
                                                _primaryDarkColor =
                                                    selectedColor.value
                                                        .toString();
                                              }
                                              return ElevatedButton(
                                                onPressed: () {},
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: selectedColor !=
                                                          null
                                                      ? selectedColor
                                                          .withOpacity(0.1)
                                                      : AppConstants
                                                          .primaryColor
                                                          .withOpacity(
                                                              0.1), // background
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 20,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      width: 20,
                                                      height: 20,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        color: selectedColor,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 8,
                                                    ),
                                                    const Text(
                                                      "Pick Color",
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 150,
                                  width: 200,
                                  padding: const EdgeInsets.all(defaultPadding),
                                  decoration: const BoxDecoration(
                                    color: bgColor,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(
                                                defaultPadding * 0.75),
                                            height: 80,
                                            width: 80,
                                            decoration: BoxDecoration(
                                              color: appSettingsModel!
                                                          .secondaryColor ==
                                                      null
                                                  ? AppConstants.primaryColor
                                                  : Color(int.parse(
                                                          appSettingsModel!
                                                              .secondaryColor!))
                                                      .withOpacity(0.1),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(10)),
                                            ),
                                            child: Icon(
                                              Icons.ac_unit_rounded,
                                              color: appSettingsModel!
                                                          .secondaryColor ==
                                                      null
                                                  ? AppConstants.primaryColor
                                                  : Color(int.parse(
                                                      appSettingsModel!
                                                          .secondaryColor!)),
                                              size: 52,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Secondary Color",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          WebColorPicker.builder(
                                            initialColor: appSettingsModel!
                                                        .secondaryColor ==
                                                    null
                                                ? AppConstants.primaryColor
                                                : Color(int.parse(
                                                    appSettingsModel!
                                                        .secondaryColor!)),
                                            builder: (context, selectedColor) {
                                              if (selectedColor != null) {
                                                _secondaryColor = selectedColor
                                                    .value
                                                    .toString();
                                              }
                                              return ElevatedButton(
                                                onPressed: () {},
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: selectedColor !=
                                                          null
                                                      ? selectedColor
                                                          .withOpacity(0.1)
                                                      : AppConstants
                                                          .primaryColor
                                                          .withOpacity(
                                                              0.1), // background
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 20,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      width: 20,
                                                      height: 20,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        color: selectedColor,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 8,
                                                    ),
                                                    const Text(
                                                      "Pick Color",
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 150,
                                  width: 200,
                                  padding: const EdgeInsets.all(defaultPadding),
                                  decoration: const BoxDecoration(
                                    color: bgColor,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(
                                                defaultPadding * 0.75),
                                            height: 80,
                                            width: 80,
                                            decoration: BoxDecoration(
                                              color: appSettingsModel!
                                                          .secondaryDarkColor ==
                                                      null
                                                  ? AppConstants.primaryColor
                                                  : Color(int.parse(
                                                          appSettingsModel!
                                                              .secondaryDarkColor!))
                                                      .withOpacity(0.1),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(10)),
                                            ),
                                            child: Icon(
                                              Icons.ac_unit_rounded,
                                              color: appSettingsModel!
                                                          .secondaryDarkColor ==
                                                      null
                                                  ? AppConstants.primaryColor
                                                  : Color(int.parse(
                                                      appSettingsModel!
                                                          .secondaryDarkColor!)),
                                              size: 52,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Secondary Dark Color",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          WebColorPicker.builder(
                                            initialColor: appSettingsModel!
                                                        .secondaryDarkColor ==
                                                    null
                                                ? AppConstants.primaryColor
                                                : Color(int.parse(
                                                    appSettingsModel!
                                                        .secondaryDarkColor!)),
                                            builder: (context, selectedColor) {
                                              if (selectedColor != null) {
                                                _secondaryDarkColor =
                                                    selectedColor.value
                                                        .toString();
                                              }
                                              return ElevatedButton(
                                                onPressed: () {},
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: selectedColor !=
                                                          null
                                                      ? selectedColor
                                                          .withOpacity(0.1)
                                                      : AppConstants
                                                          .primaryColor
                                                          .withOpacity(
                                                              0.1), // background
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 20,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      width: 20,
                                                      height: 20,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        color: selectedColor,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 8,
                                                    ),
                                                    const Text(
                                                      "Pick Color",
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 150,
                                  width: 200,
                                  padding: const EdgeInsets.all(defaultPadding),
                                  decoration: const BoxDecoration(
                                    color: bgColor,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(
                                                defaultPadding * 0.75),
                                            height: 80,
                                            width: 80,
                                            decoration: BoxDecoration(
                                              color: appSettingsModel!
                                                          .tintColor !=
                                                      null
                                                  ? Color(int.parse(
                                                          appSettingsModel!
                                                              .tintColor!))
                                                      .withOpacity(0.1)
                                                  : AppConstants.primaryColor
                                                      .withOpacity(0.1),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(10)),
                                            ),
                                            child: Icon(
                                              Icons.ac_unit_rounded,
                                              color: appSettingsModel!
                                                          .tintColor !=
                                                      null
                                                  ? Color(int.parse(
                                                      appSettingsModel!
                                                          .tintColor!))
                                                  : AppConstants.primaryColor,
                                              size: 52,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Tint Color",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          WebColorPicker.builder(
                                            initialColor:
                                                appSettingsModel!.tintColor !=
                                                        null
                                                    ? Color(int.parse(
                                                        appSettingsModel!
                                                            .tintColor!))
                                                    : AppConstants.primaryColor,
                                            builder: (context, selectedColor) {
                                              if (selectedColor != null) {
                                                _tintColor = selectedColor.value
                                                    .toString();
                                              }
                                              return ElevatedButton(
                                                onPressed: () {},
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: selectedColor !=
                                                          null
                                                      ? selectedColor
                                                          .withOpacity(0.1)
                                                      : AppConstants
                                                          .primaryColor
                                                          .withOpacity(
                                                              0.1), // background
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 20,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      width: 20,
                                                      height: 20,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        color: selectedColor,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 8,
                                                    ),
                                                    const Text(
                                                      "Pick Color",
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    await getMultipleImageInfos();
                                  },
                                  child: Container(
                                    height: 150,
                                    width: 200,
                                    padding:
                                        const EdgeInsets.all(defaultPadding),
                                    decoration: const BoxDecoration(
                                      color: bgColor,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              // padding: const EdgeInsets.all(
                                              //     defaultPadding * 0.75),
                                              height: 100,
                                              width: 100,
                                              decoration: _cloudFile == null
                                                  ? BoxDecoration(
                                                      // color: AppConstants.primaryColor
                                                      //     .withOpacity(0.1),
                                                      image: DecorationImage(
                                                        image: appSettingsModel!
                                                                    .appLogo !=
                                                                null
                                                            ? NetworkImage(
                                                                appSettingsModel!
                                                                    .appLogo!)
                                                            : const AssetImage(
                                                                    "assets/logo/logo.png")
                                                                as ImageProvider,
                                                        fit: BoxFit.cover,
                                                      ),
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  10)),
                                                    )
                                                  : const BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10)),
                                                    ),
                                              child: _cloudFile != null
                                                  ? _imageWidget
                                                  : const SizedBox.shrink(),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Logo",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Card(
                            color: AppConstants.secondaryColor.withOpacity(.1),
                            child: ListTile(
                              tileColor: Colors.transparent,
                              title: const Text("Update",
                                  style: TextStyle(color: Colors.white)),
                              subtitle: const Text(
                                  "Update Appearance Settings Now",
                                  style: TextStyle(color: Colors.white)),
                              leading: const Icon(Icons.update_outlined,
                                  color: Colors.white),
                              trailing: const Icon(Icons.chevron_right,
                                  color: Colors.white),
                              onTap: () async {
                                EasyLoading.show(status: 'Updating...');
                                await updateAppSettings();

                                EasyLoading.dismiss();

                                EasyLoading.showSuccess('Settings updated');
                                Future.delayed(Duration(seconds: defaultTimer),
                                    () {
                                  EasyLoading.dismiss();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    )),

                    //       Expanded(
                    //   child: ElevatedButton(
                    //     onPressed: () async {
                    //       await updateAppSettings();
                    //       EasyLoading.showSuccess('Settings updated');
                    //       Future.delayed(Duration(seconds: defaultTimer), () {
                    //         EasyLoading.dismiss();
                    //       });
                    //     },
                    //     child: Text('Update',
                    //         style: Theme.of(context).textTheme.titleMedium),
                    //   ),
                    // )
                  ]),
            );
          } else {
            return const Center(child: Text("No data"));
          }
        },
        error: (error, stackTrace) => const MyErrorWidget(),
        loading: () => const MyLoadingWidget(),
      ),
    );
  }
}

  // @override
  // Widget build(BuildContext context) {
  //   final appSettingsRef = ref.watch(appSettingsProvider);
  //   return 
  //     appSettingsRef.when(
  //                             data: (data) {
  //                               return Card(
  //                                 child: fluent.ContentDialog(
  //     title: const Text("App Settings"),
  //     content: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         SwitchListTile(
  //           title: const Text("Enable Chatting Before Match"),
  //           subtitle: const Text(
  //               "Enable this if you want users to chat before they match"),
  //           value: _isChattingEnabledBeforeMatch,
  //           onChanged: (value) async {
  //             setState(() {
  //               _isChattingEnabledBeforeMatch = value;
  //             });
  //             AppSettingsModel appSettingsModel = AppSettingsModel(
  //             isChattingEnabledBeforeMatch: _isChattingEnabledBeforeMatch,
  //           );

  //           await AppSettingsProvider.addAppSettings(appSettingsModel)
  //               .then((value) {
  //             ref.invalidate(appSettingsProvider);
  //             Navigator.of(context).pop();
  //           });
  //           },
  //         ),

  //         // Save Button
  //       ],
  //     ),
  //     actions: [
  //       fluent.HyperlinkButton(
  //         onPressed: () {
  //           Navigator.of(context).pop();
  //         },
  //         child: const Text('Cancel'),
  //       ),
  //       fluent.HyperlinkButton(
  //         onPressed: () async {
  //           AppSettingsModel appSettingsModel = AppSettingsModel(
  //             isChattingEnabledBeforeMatch: _isChattingEnabledBeforeMatch,
  //           );

  //           await AppSettingsProvider.addAppSettings(appSettingsModel)
  //               .then((value) {
  //             ref.invalidate(appSettingsProvider);
  //             Navigator.of(context).pop();
  //           });
  //         },
  //         child: const Text('Update'),
  //       ),
  //     ],
  //   )
                                  
  //                                  ,
  //                               );
  //                             },
  //                             error: (error, stackTrace) => const SizedBox(),
  //                             loading: () => const SizedBox(),
  //                           )
                            
  //                            ;
  // }

// ListTile(
//                                     title: const Text("App Settings"),
//                                     subtitle:
//                                         const Text("Update app settings here"),
//                                     leading: const Icon(FluentIcons.edit),
//                                     trailing:
//                                         const Icon(FluentIcons.chevron_right),
//                                     onPressed: () {
//                                       showDialog(
//                                           context: context,
//                                           builder: (context) =>
//                                               AppSettingsDialog(
//                                                   appSettingsModel: data));
//                                     },
//                                   )
