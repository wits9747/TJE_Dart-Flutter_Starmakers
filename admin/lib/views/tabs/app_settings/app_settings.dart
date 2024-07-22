// import 'package:fluent_ui/fluent_ui.dart' as fluent;

import 'dart:async';

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

class AppSettingsPage extends ConsumerStatefulWidget {
  final Function changeScreen;
  const AppSettingsPage({
    super.key,
    required this.changeScreen,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AppSettingsPageState();
}

class _AppSettingsPageState extends ConsumerState<AppSettingsPage> {
  late bool _isChattingEnabledBeforeMatch;
  late String _admobBanner;
  late String _admobInt;
  late String _admobIntIos;
  late String _admobBannerIos;
  late int _maxUploadDaily;
  late int _liveMinViewers;
  late int _liveTimeout;
  late int _rewardVideoUpload;
  late int _minFansForLive;
  late int _minFansVerification;
  late int _minRedeemCoins;
  late int _minWithdrawal;
  late double _coinValue;
  late int _dailyWithdrawalLimit;
  late String _currency;
  late String _agoraAppId;
  late String _agoraAppCert;

  late TextEditingController admobBannerController;
  late TextEditingController admobIntController;
  late TextEditingController admobIntIosController;
  late TextEditingController admobBannerIosController;
  late TextEditingController liveMinViewersController;
  late TextEditingController liveTimeoutController;
  late TextEditingController maxUploadDailyController;
  late TextEditingController minFansForLiveController;
  late TextEditingController minFansVerificationController;
  late TextEditingController minRedeemCoinsController;
  late TextEditingController minWithdrawalController;
  late TextEditingController rewardVideoUploadController;
  late TextEditingController dailyWithdrawalLimitController;
  late TextEditingController coinValueController;
  late TextEditingController currencyController;
  late TextEditingController agoraAppIdController;
  late TextEditingController agoraAppCertController;

  int defaultTimer = 3;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
  }

  void updateAppSettings() async {
    // final appSettingsRef = ref.watch(appSettingsProvider);

    AppSettingsModel appSettingsModel = AppSettingsModel(
      isChattingEnabledBeforeMatch: _isChattingEnabledBeforeMatch,
      admobBanner: admobBannerController.text,
      admobInt: admobIntController.text,
      admobIntIos: admobIntIosController.text,
      admobBannerIos: admobBannerIosController.text,
      maxUploadDaily: int.parse(maxUploadDailyController.text),
      liveMinViewers: int.parse(liveMinViewersController.text),
      liveTimeout: int.parse(liveTimeoutController.text),
      rewardVideoUpload: int.parse(rewardVideoUploadController.text),
      minFansForLive: int.parse(minFansForLiveController.text),
      minFansVerification: int.parse(minFansVerificationController.text),
      minRedeemCoins: int.parse(minRedeemCoinsController.text),
      minWithdrawal: int.parse(minWithdrawalController.text),
      coinValue: double.parse(coinValueController.text),
      dailyWithdrawalLimit: int.parse(dailyWithdrawalLimitController.text),
      currency: currencyController.text,
      agoraAppId: agoraAppIdController.text,
      agoraAppCert: agoraAppCertController.text,
    );

    await AppSettingsProvider.addAppSettings(appSettingsModel).then((value) {
      ref.invalidate(appSettingsProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appSettingsRef = ref.watch(appSettingsProvider);

    return Scaffold(
      drawer: SideMenu(changeScreen: widget.changeScreen),
      body: appSettingsRef.when(
        data: (data) {
          if (data != null) {
            _isChattingEnabledBeforeMatch =
                data.isChattingEnabledBeforeMatch ?? false;
            _admobBanner = data.admobBanner ?? '';
            _admobInt = data.admobInt ?? '';
            _admobIntIos = data.admobIntIos ?? '';
            _admobBannerIos = data.admobBannerIos ?? '';
            _maxUploadDaily = data.maxUploadDaily ?? 0;
            _liveMinViewers = data.liveMinViewers ?? 0;
            _liveTimeout = data.liveTimeout ?? 0;
            _rewardVideoUpload = data.rewardVideoUpload ?? 0;
            _minFansForLive = data.minFansForLive ?? 0;
            _minFansVerification = data.minFansVerification ?? 0;
            _minRedeemCoins = data.minRedeemCoins ?? 0;
            _minWithdrawal = data.minWithdrawal ?? 0;
            _coinValue = data.coinValue ?? 0.0;
            _dailyWithdrawalLimit = data.dailyWithdrawalLimit ?? 0;
            _currency = data.currency ?? '';
            _agoraAppId = data.agoraAppId ?? '';
            _agoraAppCert = data.agoraAppCert ?? '';

            admobBannerController = TextEditingController(text: _admobBanner);
            admobIntController = TextEditingController(text: _admobInt);
            admobIntIosController = TextEditingController(
              text: _admobIntIos,
            );
            admobBannerIosController =
                TextEditingController(text: _admobBannerIos);
            maxUploadDailyController =
                TextEditingController(text: _maxUploadDaily.toString());
            liveMinViewersController =
                TextEditingController(text: _liveMinViewers.toString());
            liveTimeoutController =
                TextEditingController(text: _liveTimeout.toString());
            rewardVideoUploadController =
                TextEditingController(text: _rewardVideoUpload.toString());
            minFansForLiveController =
                TextEditingController(text: _minFansForLive.toString());
            minFansVerificationController =
                TextEditingController(text: _minFansVerification.toString());
            minRedeemCoinsController =
                TextEditingController(text: _minRedeemCoins.toString());
            minWithdrawalController =
                TextEditingController(text: _minWithdrawal.toString());
            coinValueController =
                TextEditingController(text: _coinValue.toString());
            dailyWithdrawalLimitController =
                TextEditingController(text: _dailyWithdrawalLimit.toString());
            currencyController = TextEditingController(text: _currency);
            agoraAppIdController = TextEditingController(text: _agoraAppId);
            agoraAppCertController = TextEditingController(text: _agoraAppCert);

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
                            "Mobile App Settings",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //Chat Before Match
                                  SwitchListTile(
                                    title: const Text(
                                        "Enable Chatting Before Match"),
                                    subtitle: const Text(
                                        "Enable this if you want users to chat before they match"),
                                    value: _isChattingEnabledBeforeMatch,
                                    onChanged: (value) async {
                                      EasyLoading.show(status: "Updating");
                                      setState(() {
                                        _isChattingEnabledBeforeMatch = value;
                                      });
                                      updateAppSettings();
                                      Future.delayed(const Duration(seconds: 2),
                                          () {
                                        EasyLoading.dismiss();
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  //AdMob Banner Id
                                  Text(
                                    "Android AdMob Banner ID",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                      height:
                                          AppConstants.defaultNumericValue / 2),
                                  TextFormField(
                                    controller: admobBannerController,
                                    autofocus: false,
                                    onChanged: (value) {
                                      _debounceTimer?.cancel();
                                      _debounceTimer = Timer(
                                          Duration(seconds: defaultTimer), () {
                                        if (value.length >= 10) {
                                          EasyLoading.show(status: "Updating");
                                          setState(() {
                                            _admobBanner = value;
                                          });
                                          updateAppSettings();
                                          Future.delayed(
                                              const Duration(seconds: 2), () {
                                            EasyLoading.dismiss();
                                          });
                                        }
                                      });
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: AppConstants.primaryColor
                                          .withOpacity(.1),
                                      hintText: "Enter Admob Banner ID",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            AppConstants.defaultNumericValue),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                      height: AppConstants.defaultNumericValue),

                                  //AdMob Interstitial Id
                                  Text(
                                    "Android AdMob Interstitial ID",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                      height:
                                          AppConstants.defaultNumericValue / 2),
                                  TextFormField(
                                    controller: admobIntController,
                                    autofocus: false,
                                    onChanged: (value) {
                                      _debounceTimer?.cancel();
                                      _debounceTimer = Timer(
                                          Duration(seconds: defaultTimer), () {
                                        if (value.length == 12) {
                                          EasyLoading.show(status: "Updating");
                                          setState(() {
                                            _admobInt = value;
                                          });
                                          updateAppSettings();
                                          Future.delayed(
                                              const Duration(seconds: 2), () {
                                            EasyLoading.dismiss();
                                          });
                                        }
                                      });
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: AppConstants.primaryColor
                                          .withOpacity(.1),
                                      hintText: "Enter Admob Interstitial ID",
                                      border: OutlineInputBorder(
                                        // Set outline border
                                        borderRadius: BorderRadius.circular(
                                            AppConstants.defaultNumericValue),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                      height: AppConstants.defaultNumericValue),

                                  //AdMob Interstitial IOS ID
                                  Text(
                                    "AdMob Interstitial IOS ID",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                      height:
                                          AppConstants.defaultNumericValue / 2),
                                  TextFormField(
                                    controller: admobIntIosController,
                                    autofocus: false,
                                    onChanged: (value) async {
                                      _debounceTimer?.cancel();
                                      _debounceTimer =
                                          Timer(Duration(seconds: defaultTimer),
                                              () async {
                                        if (value.length == 12) {
                                          EasyLoading.show(status: "Updating");
                                          setState(() {
                                            _admobIntIos = value;
                                          });
                                          updateAppSettings();
                                          Future.delayed(
                                              const Duration(seconds: 2), () {
                                            EasyLoading.dismiss();
                                          });
                                        }
                                      });
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: AppConstants.primaryColor
                                          .withOpacity(.1),
                                      hintText:
                                          "Enter Admob Interstitial IOS ID",
                                      border: OutlineInputBorder(
                                        // Set outline border
                                        borderRadius: BorderRadius.circular(
                                            AppConstants.defaultNumericValue),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                      height: AppConstants.defaultNumericValue),

                                  //AdMob Banner Ios Id
                                  Text(
                                    "AdMob Banner IOS ID",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                      height:
                                          AppConstants.defaultNumericValue / 2),
                                  TextFormField(
                                    controller: admobBannerIosController,
                                    autofocus: false,
                                    onChanged: (value) async {
                                      _debounceTimer?.cancel();
                                      _debounceTimer =
                                          Timer(Duration(seconds: defaultTimer),
                                              () async {
                                        if (value.length == 12) {
                                          EasyLoading.show(status: "Updating");
                                          setState(() {
                                            _admobBannerIos = value;
                                          });
                                          updateAppSettings();
                                          Future.delayed(
                                              const Duration(seconds: 2), () {
                                            EasyLoading.dismiss();
                                          });
                                        }
                                      });
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: AppConstants.primaryColor
                                          .withOpacity(.1),
                                      hintText: "Enter Admob Banner IOS ID",
                                      border: OutlineInputBorder(
                                        // Set outline border
                                        borderRadius: BorderRadius.circular(
                                            AppConstants.defaultNumericValue),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                      height: AppConstants.defaultNumericValue),

                                  //Daily Max Upload
                                  Text(
                                    "Daily Max Upload",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                      height:
                                          AppConstants.defaultNumericValue / 2),
                                  TextFormField(
                                    controller: maxUploadDailyController,
                                    autofocus: false,
                                    onChanged: (value) async {
                                      _debounceTimer?.cancel();
                                      _debounceTimer =
                                          Timer(Duration(seconds: defaultTimer),
                                              () async {
                                        if (value.isNotEmpty) {
                                          EasyLoading.show(status: "Updating");
                                          setState(() {
                                            _maxUploadDaily = int.parse(value);
                                          });
                                          updateAppSettings();
                                          Future.delayed(
                                              const Duration(seconds: 2), () {
                                            EasyLoading.dismiss();
                                          });
                                        }
                                      });
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: AppConstants.primaryColor
                                          .withOpacity(.1),
                                      hintText: "Enter Daily Max Upload Limit",
                                      border: OutlineInputBorder(
                                        // Set outline border
                                        borderRadius: BorderRadius.circular(
                                            AppConstants.defaultNumericValue),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                      height: AppConstants.defaultNumericValue),

                                  //Live Minimum Viewers
                                  Text(
                                    "Live Minimum Viewers",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                      height:
                                          AppConstants.defaultNumericValue / 2),
                                  TextFormField(
                                    controller: liveMinViewersController,
                                    autofocus: false,
                                    onChanged: (value) async {
                                      _debounceTimer?.cancel();
                                      _debounceTimer =
                                          Timer(Duration(seconds: defaultTimer),
                                              () async {
                                        if (value.isNotEmpty) {
                                          EasyLoading.show(status: "Updating");
                                          setState(() {
                                            _liveMinViewers = int.parse(value);
                                          });
                                          updateAppSettings();
                                          Future.delayed(
                                              const Duration(seconds: 2), () {
                                            EasyLoading.dismiss();
                                          });
                                        }
                                      });
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: AppConstants.primaryColor
                                          .withOpacity(.1),
                                      hintText: "Enter Live Minimum Viewers",
                                      border: OutlineInputBorder(
                                        // Set outline border
                                        borderRadius: BorderRadius.circular(
                                            AppConstants.defaultNumericValue),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                      height: AppConstants.defaultNumericValue),

                                  //Max Live Duration
                                  Text(
                                    "Max Live Duration (Minutes)",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                      height:
                                          AppConstants.defaultNumericValue / 2),
                                  TextFormField(
                                    controller: liveTimeoutController,
                                    autofocus: false,
                                    onChanged: (value) async {
                                      _debounceTimer?.cancel();
                                      _debounceTimer =
                                          Timer(Duration(seconds: defaultTimer),
                                              () async {
                                        if (value.isNotEmpty) {
                                          EasyLoading.show(status: "Updating");
                                          setState(() {
                                            _liveTimeout = int.parse(value);
                                          });
                                          updateAppSettings();
                                          Future.delayed(
                                              const Duration(seconds: 2), () {
                                            EasyLoading.dismiss();
                                          });
                                        }
                                      });
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: AppConstants.primaryColor
                                          .withOpacity(.1),
                                      hintText: "Max Live Duration (Minutes)",
                                      border: OutlineInputBorder(
                                        // Set outline border
                                        borderRadius: BorderRadius.circular(
                                            AppConstants.defaultNumericValue),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                      height: AppConstants.defaultNumericValue),

                                  //Teel Upload Reward
                                  Text(
                                    "Teel Upload Reward",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                      height:
                                          AppConstants.defaultNumericValue / 2),
                                  TextFormField(
                                    controller: rewardVideoUploadController,
                                    autofocus: false,
                                    onChanged: (value) async {
                                      _debounceTimer?.cancel();
                                      _debounceTimer =
                                          Timer(Duration(seconds: defaultTimer),
                                              () async {
                                        if (value.isNotEmpty) {
                                          EasyLoading.show(status: "Updating");
                                          setState(() {
                                            _rewardVideoUpload =
                                                int.parse(value);
                                          });
                                          updateAppSettings();
                                          Future.delayed(
                                              const Duration(seconds: 2), () {
                                            EasyLoading.dismiss();
                                          });
                                        }
                                      });
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: AppConstants.primaryColor
                                          .withOpacity(.1),
                                      hintText: "Enter Teel Upload Reward",
                                      border: OutlineInputBorder(
                                        // Set outline border
                                        borderRadius: BorderRadius.circular(
                                            AppConstants.defaultNumericValue),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                      height: AppConstants.defaultNumericValue),

                                  //Minimum Followers for Live
                                  Text(
                                    "Minimum Followers for Live",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                      height:
                                          AppConstants.defaultNumericValue / 2),
                                  TextFormField(
                                    controller: minFansForLiveController,
                                    autofocus: false,
                                    onChanged: (value) async {
                                      _debounceTimer?.cancel();
                                      _debounceTimer =
                                          Timer(Duration(seconds: defaultTimer),
                                              () async {
                                        if (value.isNotEmpty) {
                                          EasyLoading.show(status: "Updating");
                                          setState(() {
                                            _minFansForLive = int.parse(value);
                                          });
                                          updateAppSettings();
                                          Future.delayed(
                                              const Duration(seconds: 2), () {
                                            EasyLoading.dismiss();
                                          });
                                        }
                                      });
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: AppConstants.primaryColor
                                          .withOpacity(.1),
                                      hintText:
                                          "Enter Minimum Followers for Live",
                                      border: OutlineInputBorder(
                                        // Set outline border
                                        borderRadius: BorderRadius.circular(
                                            AppConstants.defaultNumericValue),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                      height: AppConstants.defaultNumericValue),

                                  //Minimum Followers for Verification
                                  Text(
                                    "Minimum Followers for Verification",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                      height:
                                          AppConstants.defaultNumericValue / 2),
                                  TextFormField(
                                    controller: minFansVerificationController,
                                    autofocus: false,
                                    onChanged: (value) async {
                                      _debounceTimer?.cancel();
                                      _debounceTimer =
                                          Timer(Duration(seconds: defaultTimer),
                                              () async {
                                        if (value.isNotEmpty) {
                                          EasyLoading.show(status: "Updating");
                                          setState(() {
                                            _minFansVerification =
                                                int.parse(value);
                                          });
                                          updateAppSettings();
                                          Future.delayed(
                                              const Duration(seconds: 2), () {
                                            EasyLoading.dismiss();
                                          });
                                        }
                                      });
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: AppConstants.primaryColor
                                          .withOpacity(.1),
                                      hintText:
                                          "Enter Minimum Followers for Verification",
                                      border: OutlineInputBorder(
                                        // Set outline border
                                        borderRadius: BorderRadius.circular(
                                            AppConstants.defaultNumericValue),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                      height: AppConstants.defaultNumericValue),

                                  //Minimum Coins for Redeem
                                  Text(
                                    "Minimum Coins for Redeem",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                      height:
                                          AppConstants.defaultNumericValue / 2),
                                  TextFormField(
                                    controller: minRedeemCoinsController,
                                    autofocus: false,
                                    onChanged: (value) async {
                                      _debounceTimer?.cancel();
                                      _debounceTimer =
                                          Timer(Duration(seconds: defaultTimer),
                                              () async {
                                        if (value.isNotEmpty) {
                                          EasyLoading.show(status: "Updating");
                                          setState(() {
                                            _minRedeemCoins = int.parse(value);
                                          });
                                          updateAppSettings();
                                          Future.delayed(
                                              const Duration(seconds: 2), () {
                                            EasyLoading.dismiss();
                                          });
                                        }
                                      });
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: AppConstants.primaryColor
                                          .withOpacity(.1),
                                      hintText:
                                          "Enter Minimum Coins for Redeem",
                                      border: OutlineInputBorder(
                                        // Set outline border
                                        borderRadius: BorderRadius.circular(
                                            AppConstants.defaultNumericValue),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                      height: AppConstants.defaultNumericValue),

                                  //Minimum Withdrawal
                                  Text(
                                    "Minimum Withdrawal",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                      height:
                                          AppConstants.defaultNumericValue / 2),
                                  TextFormField(
                                    controller: minWithdrawalController,
                                    autofocus: false,
                                    onChanged: (value) async {
                                      _debounceTimer?.cancel();
                                      _debounceTimer =
                                          Timer(Duration(seconds: defaultTimer),
                                              () async {
                                        if (value.isNotEmpty) {
                                          EasyLoading.show(status: "Updating");
                                          setState(() {
                                            _minWithdrawal = int.parse(value);
                                          });
                                          updateAppSettings();
                                          Future.delayed(
                                              const Duration(seconds: 2), () {
                                            EasyLoading.dismiss();
                                          });
                                        }
                                      });
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: AppConstants.primaryColor
                                          .withOpacity(.1),
                                      hintText:
                                          "Enter Minimum Withdrawal Amount",
                                      border: OutlineInputBorder(
                                        // Set outline border
                                        borderRadius: BorderRadius.circular(
                                            AppConstants.defaultNumericValue),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                      height: AppConstants.defaultNumericValue),

                                  //Coin Value
                                  Text(
                                    "Coin Value",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                      height:
                                          AppConstants.defaultNumericValue / 2),
                                  TextFormField(
                                    controller: coinValueController,
                                    autofocus: false,
                                    onChanged: (value) async {
                                      _debounceTimer?.cancel();
                                      _debounceTimer =
                                          Timer(Duration(seconds: defaultTimer),
                                              () async {
                                        if (value.isNotEmpty) {
                                          EasyLoading.show(status: "Updating");
                                          setState(() {
                                            _coinValue = double.parse(value);
                                          });
                                          updateAppSettings();
                                          Future.delayed(
                                              const Duration(seconds: 2), () {
                                            EasyLoading.dismiss();
                                          });
                                        }
                                      });
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: AppConstants.primaryColor
                                          .withOpacity(.1),
                                      hintText: "Enter Coin Value",
                                      border: OutlineInputBorder(
                                        // Set outline border
                                        borderRadius: BorderRadius.circular(
                                            AppConstants.defaultNumericValue),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                      height: AppConstants.defaultNumericValue),

                                  //Daily Withdrawal Limit
                                  Text(
                                    "Daily Withdrawal Limit",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                      height:
                                          AppConstants.defaultNumericValue / 2),
                                  TextFormField(
                                    controller: dailyWithdrawalLimitController,
                                    autofocus: false,
                                    onChanged: (value) async {
                                      _debounceTimer?.cancel();
                                      _debounceTimer =
                                          Timer(Duration(seconds: defaultTimer),
                                              () async {
                                        if (value.isNotEmpty) {
                                          EasyLoading.show(status: "Updating");
                                          setState(() {
                                            _dailyWithdrawalLimit =
                                                int.parse(value);
                                          });
                                          updateAppSettings();
                                          Future.delayed(
                                              const Duration(seconds: 2), () {
                                            EasyLoading.dismiss();
                                          });
                                        }
                                      });
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: AppConstants.primaryColor
                                          .withOpacity(.1),
                                      hintText:
                                          "Enter Daily Withdrawal Limit Amount",
                                      border: OutlineInputBorder(
                                        // Set outline border
                                        borderRadius: BorderRadius.circular(
                                            AppConstants.defaultNumericValue),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                      height: AppConstants.defaultNumericValue),

                                  //Currency Abbreviation
                                  Text(
                                    "Currency Abbreviation",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                      height:
                                          AppConstants.defaultNumericValue / 2),
                                  TextFormField(
                                    controller: currencyController,
                                    autofocus: false,
                                    onChanged: (value) async {
                                      _debounceTimer?.cancel();
                                      _debounceTimer =
                                          Timer(Duration(seconds: defaultTimer),
                                              () async {
                                        if (value.length == 3) {
                                          EasyLoading.show(status: "Updating");
                                          setState(() {
                                            _currency = value;
                                          });
                                          updateAppSettings();
                                          Future.delayed(
                                              const Duration(seconds: 2), () {
                                            EasyLoading.dismiss();
                                          });
                                        }
                                      });
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: AppConstants.primaryColor
                                          .withOpacity(.1),
                                      hintText:
                                          "Enter Currency Abbreviation (USD e.g.)",
                                      border: OutlineInputBorder(
                                        // Set outline border
                                        borderRadius: BorderRadius.circular(
                                            AppConstants.defaultNumericValue),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                      height: AppConstants.defaultNumericValue),

                                  //Agora App Id
                                  Text(
                                    "Agora App Id",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                      height:
                                          AppConstants.defaultNumericValue / 2),
                                  TextFormField(
                                    controller: agoraAppIdController,
                                    autofocus: false,
                                    onChanged: (value) async {
                                      _debounceTimer?.cancel();
                                      _debounceTimer =
                                          Timer(Duration(seconds: defaultTimer),
                                              () async {
                                        if (value.length >= 8) {
                                          EasyLoading.show(status: "Updating");
                                          setState(() {
                                            _agoraAppId = value;
                                          });
                                          updateAppSettings();
                                          Future.delayed(
                                              const Duration(seconds: 2), () {
                                            EasyLoading.dismiss();
                                          });
                                        }
                                      });
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: AppConstants.primaryColor
                                          .withOpacity(.1),
                                      hintText: "Enter Agora App Id",
                                      border: OutlineInputBorder(
                                        // Set outline border
                                        borderRadius: BorderRadius.circular(
                                            AppConstants.defaultNumericValue),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                      height: AppConstants.defaultNumericValue),

                                  //Agora App Certificate
                                  Text(
                                    "Agora App Certificate",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                      height:
                                          AppConstants.defaultNumericValue / 2),
                                  TextFormField(
                                    controller: agoraAppCertController,
                                    autofocus: false,
                                    onChanged: (value) async {
                                      _debounceTimer?.cancel();
                                      _debounceTimer =
                                          Timer(Duration(seconds: defaultTimer),
                                              () async {
                                        if (value.length >= 8) {
                                          EasyLoading.show(status: "Updating");
                                          setState(() {
                                            _agoraAppCert = value;
                                          });
                                          updateAppSettings();
                                          Future.delayed(
                                              const Duration(seconds: 2), () {
                                            EasyLoading.dismiss();
                                          });
                                        }
                                      });
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: AppConstants.primaryColor
                                          .withOpacity(.1),
                                      hintText: "Enter Agora App Certificate",
                                      border: OutlineInputBorder(
                                        // Set outline border
                                        borderRadius: BorderRadius.circular(
                                            AppConstants.defaultNumericValue),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                      height: AppConstants.defaultNumericValue),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
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
