import 'dart:convert';

import 'package:lamatadmin/helpers/config.dart';

class AppSettingsModel {
  bool? isChattingEnabledBeforeMatch;
  String? admobBanner;
  String? admobInt;
  String? admobIntIos;
  String? admobBannerIos;
  int? maxUploadDaily;
  int? liveMinViewers;
  int? liveTimeout;
  int? rewardVideoUpload;
  int? minFansForLive;
  int? minFansVerification;
  int? minRedeemCoins;
  int? minWithdrawal;
  double? coinValue;
  int? dailyWithdrawalLimit;
  String? currency;
  String? agoraAppId;
  String? agoraAppCert;
  String? primaryColor;
  String? primaryDarkColor;
  String? secondaryColor;
  String? secondaryDarkColor;
  String? tintColor;
  String? appLogo;

  AppSettingsModel({
    this.admobBanner,
    this.admobBannerIos,
    this.admobInt,
    this.admobIntIos,
    this.agoraAppId,
    this.coinValue,
    this.dailyWithdrawalLimit,
    this.currency,
    this.agoraAppCert,
    this.liveMinViewers,
    this.liveTimeout,
    this.maxUploadDaily,
    this.minFansForLive,
    this.minFansVerification,
    this.minRedeemCoins,
    this.minWithdrawal,
    this.rewardVideoUpload,
    this.isChattingEnabledBeforeMatch,
    this.primaryColor,
    this.primaryDarkColor,
    this.secondaryColor,
    this.secondaryDarkColor,
    this.tintColor,
    this.appLogo,
  });

  AppSettingsModel copyWith({
    bool? isChattingEnabledBeforeMatch,
    String? admobBanner,
    String? admobInt,
    String? admobIntIos,
    String? admobBannerIos,
    int? maxUploadDaily,
    int? liveMinViewers,
    int? liveTimeout,
    int? rewardVideoUpload,
    int? minFansForLive,
    int? minFansVerification,
    int? minRedeemCoins,
    int? minWithdrawal,
    double? coinValue,
    int? dailyWithdrawalLimit,
    String? currency,
    String? agoraAppId,
    String? agoraAppCert,
    String? primaryColor,
    String? primaryDarkColor,
    String? secondaryColor,
    String? secondaryDarkColor,
    String? tintColor,
    String? appLogo,
  }) {
    return AppSettingsModel(
        isChattingEnabledBeforeMatch:
            isChattingEnabledBeforeMatch ?? this.isChattingEnabledBeforeMatch,
        admobBanner: admobBanner ?? this.admobBanner,
        admobInt: admobInt ?? this.admobInt,
        admobIntIos: admobIntIos ?? this.admobIntIos,
        admobBannerIos: admobBannerIos ?? this.admobBannerIos,
        maxUploadDaily: maxUploadDaily ?? this.maxUploadDaily,
        liveMinViewers: liveMinViewers ?? this.liveMinViewers,
        liveTimeout: liveTimeout ?? this.liveTimeout,
        rewardVideoUpload: rewardVideoUpload ?? this.rewardVideoUpload,
        minFansForLive: minFansForLive ?? this.minFansForLive,
        minFansVerification: minFansVerification ?? this.minFansVerification,
        minRedeemCoins: minRedeemCoins ?? this.minRedeemCoins,
        minWithdrawal: minWithdrawal ?? this.minWithdrawal,
        coinValue: coinValue ?? this.coinValue,
        dailyWithdrawalLimit: dailyWithdrawalLimit ?? this.dailyWithdrawalLimit,
        currency: currency ?? this.currency,
        agoraAppId: agoraAppId ?? this.agoraAppId,
        agoraAppCert: agoraAppCert ?? this.agoraAppCert,
        primaryColor: primaryColor ?? this.primaryColor,
        primaryDarkColor: primaryDarkColor ?? this.primaryDarkColor,
        secondaryColor: secondaryColor ?? this.secondaryColor,
        secondaryDarkColor: secondaryDarkColor ?? this.secondaryDarkColor,
        tintColor: tintColor ?? this.tintColor,
        appLogo: appLogo ?? this.appLogo);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'isChattingEnabledBeforeMatch': isChattingEnabledBeforeMatch,
      'admobBanner': admobBanner,
      'admobInt': admobInt,
      'admobIntIos': admobIntIos,
      'admobBannerIos': admobBannerIos,
      'maxUploadDaily': maxUploadDaily,
      'liveMinViewers': liveMinViewers,
      'liveTimeout': liveTimeout,
      'rewardVideoUpload': rewardVideoUpload,
      'minFansForLive': minFansForLive,
      'minFansVerification': minFansVerification,
      'minRedeemCoins': minRedeemCoins,
      'minWithdrawal': minWithdrawal,
      'coinValue': coinValue,
      'dailyWithdrawalLimit': dailyWithdrawalLimit,
      'currency': currency,
      'agoraAppId': agoraAppId,
      'agoraAppCert': agoraAppCert,
      'primaryColor': primaryColor,
      'primaryDarkColor': primaryDarkColor,
      'secondaryColor': secondaryColor,
      'secondaryDarkColor': secondaryDarkColor,
      'tintColor': tintColor,
      'appLogo': appLogo
    };
  }

  factory AppSettingsModel.fromMap(Map<String, dynamic> map) {
    return AppSettingsModel(
        isChattingEnabledBeforeMatch:
            map['isChattingEnabledBeforeMatch'] as bool,
        admobBanner: map['admobBanner'] ?? '',
        admobInt: map['admobInt'] ?? '',
        admobIntIos: map['admobIntIos'] ?? '',
        admobBannerIos: map['admobBannerIos'] ?? '',
        maxUploadDaily: map['maxUploadDaily'] as int,
        liveMinViewers: map['liveMinViewers'] as int,
        liveTimeout: map['liveTimeout'] as int,
        rewardVideoUpload: map['rewardVideoUpload'] as int,
        minFansForLive: map['minFansForLive'] as int,
        minFansVerification: map['minFansVerification'] as int,
        minRedeemCoins: map['minRedeemCoins'] as int,
        minWithdrawal: map['minWithdrawal'] as int,
        coinValue: map['coinValue'] as double,
        dailyWithdrawalLimit: map['dailyWithdrawalLimit'] as int,
        currency: map['currency'] ?? '',
        agoraAppId: map['agoraAppId'] ?? '',
        agoraAppCert: map['agoraAppCert'] ?? '',
        primaryColor:
            map['primaryColor'] ?? AppConstants.primaryColor.value.toString(),
        primaryDarkColor: map['primaryDarkColor'] ??
            AppConstants.primaryColorDark.value.toString,
        secondaryColor:
            map['secondaryColor'] ?? AppConstants.secondaryColor.value.toString,
        secondaryDarkColor:
            map['secondaryDarkColor'] ?? AppConstants.midColor.value.toString,
        tintColor:
            map['tintColor'] ?? AppConstants.secondaryColor.value.toString,
        appLogo: map['appLogo'] ??
            'https://cdn-icons-png.freepik.com/256/6399/6399428.png');
  }

  String toJson() => json.encode(toMap());

  factory AppSettingsModel.fromJson(String source) =>
      AppSettingsModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'AppSettingsModel(isChattingEnabledBeforeMatch: $isChattingEnabledBeforeMatch, admobBanner: $admobBanner , admobInt: $admobInt , admobIntIos: $admobIntIos , admobBannerIos: $admobBannerIos, maxUploadDaily: $maxUploadDaily, liveMinViewers: $liveMinViewers, liveTimeout: $liveTimeout, rewardVideoUpload: $rewardVideoUpload, minFansForLive: $minFansForLive, minFansVerification: $minFansVerification, minRedeemCoins: $minRedeemCoins, minWithdrawal: $minWithdrawal, coinValue: $coinValue, dailyWithdrawalLimit: $dailyWithdrawalLimit, currency: $currency, agoraAppId: $agoraAppId, agoraAppCert: $agoraAppCert, primaryColor: $primaryColor, primaryDarkColor: $primaryDarkColor, secondaryColor: $secondaryColor, secondaryDarkColor: $secondaryDarkColor, tintColor: $tintColor, appLogo: $appLogo)';

  @override
  bool operator ==(covariant AppSettingsModel other) {
    if (identical(this, other)) return true;

    return other.isChattingEnabledBeforeMatch == isChattingEnabledBeforeMatch &&
        other.admobBanner == admobBanner &&
        other.admobInt == admobInt &&
        other.admobIntIos == admobIntIos &&
        other.admobBannerIos == admobBannerIos &&
        other.maxUploadDaily == maxUploadDaily &&
        other.liveMinViewers == liveMinViewers &&
        other.liveTimeout == liveTimeout &&
        other.rewardVideoUpload == rewardVideoUpload &&
        other.minFansForLive == minFansForLive &&
        other.minFansVerification == minFansVerification &&
        other.minRedeemCoins == minRedeemCoins &&
        other.minWithdrawal == minWithdrawal &&
        other.coinValue == coinValue &&
        other.dailyWithdrawalLimit == dailyWithdrawalLimit &&
        other.currency == currency &&
        other.agoraAppId == agoraAppId &&
        other.agoraAppCert == agoraAppCert &&
        other.primaryColor == primaryColor &&
        other.primaryDarkColor == primaryDarkColor &&
        other.secondaryColor == secondaryColor &&
        other.secondaryDarkColor == secondaryDarkColor &&
        other.tintColor == tintColor &&
        other.appLogo == appLogo;
  }

  @override
  int get hashCode =>
      isChattingEnabledBeforeMatch.hashCode ^
      admobBanner.hashCode ^
      admobInt.hashCode ^
      admobIntIos.hashCode ^
      admobBannerIos.hashCode ^
      maxUploadDaily.hashCode ^
      liveMinViewers.hashCode ^
      liveTimeout.hashCode ^
      rewardVideoUpload.hashCode ^
      minFansForLive.hashCode ^
      minFansVerification.hashCode ^
      minRedeemCoins.hashCode ^
      minWithdrawal.hashCode ^
      coinValue.hashCode ^
      dailyWithdrawalLimit.hashCode ^
      currency.hashCode ^
      agoraAppId.hashCode ^
      agoraAppCert.hashCode ^
      primaryColor.hashCode ^
      primaryDarkColor.hashCode ^
      secondaryColor.hashCode ^
      secondaryDarkColor.hashCode ^
      tintColor.hashCode ^
      appLogo.hashCode;
}
