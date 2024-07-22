// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/models/stream_goal_model.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/responsive.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/tabs/chat/chat_home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:stacked/stacked.dart';

import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/helpers/constants.dart';
import 'package:lamatdating/modal/live_stream/live_stream.dart';
import 'package:lamatdating/models/live_stream_view_model.dart';
import 'package:lamatdating/providers/user_profile_provider.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';
import 'package:lamatdating/views/custom/lottie/lottie_button.dart';
import 'package:lamatdating/views/tabs/live/screen/broad_cast_screen.dart';

enum GoalType { none, diamonds, gift }

class LiveStreamScreen extends ConsumerStatefulWidget {
  final String? currentUserNo;
  final SharedPreferences? prefs;
  final DocumentSnapshot<Map<String, dynamic>>? doc;
  final bool? isHome;
  const LiveStreamScreen({
    this.currentUserNo,
    this.prefs,
    this.doc,
    this.isHome,
    Key? key,
  }) : super(key: key);

  @override
  LiveStreamScreenState createState() => LiveStreamScreenState();
}

class LiveStreamScreenState extends ConsumerState<LiveStreamScreen> {
  final goalTypeProvider = StateProvider<GoalType>((ref) => GoalType.none);
  final goalValueProvider = StateProvider<double>((ref) => 0.0);
  final goalValueProvider2 = StateProvider<double>((ref) => 0.0);
  final goalExplanationProvider = StateProvider<String>((ref) => '');
  final goalTitleProvider = StateProvider<String>((ref) => '');

  @override
  void initState() {
    super.initState();
  }

  void showGoalDialog(BuildContext context, UserProfileModel data) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Teme.isDarktheme(widget.prefs!)
              ? AppConstants.backgroundColorDark
              : AppConstants.backgroundColor,
          title: const Center(
              child: Text(
            'Set Your Goal',
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer(builder: (context, watch, child) {
                return TextField(
                  decoration: InputDecoration(
                      hintText: 'Stream Title',
                      filled: true,
                      fillColor: AppConstants.primaryColor.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            AppConstants.defaultNumericValue),
                        borderSide: BorderSide.none,
                      )),
                  onChanged: (value) =>
                      watch.watch(goalTitleProvider.notifier).state = value,
                );
              }),
              const SizedBox(height: 10),
              Row(
                children: [
                  Consumer(builder: (context, watch, child) {
                    final isSelected =
                        watch.watch(goalTypeProvider) == GoalType.diamonds;
                    return Checkbox(
                        value: isSelected,
                        shape: const CircleBorder(),
                        onChanged: (value) => value == true
                            ? watch.watch(goalTypeProvider.notifier).state =
                                GoalType.diamonds
                            : watch.watch(goalTypeProvider.notifier).state =
                                GoalType.none);
                  }),
                  Text(LocaleKeys.diamonds.tr()),
                  const Spacer(),
                  Consumer(builder: (context, watch, child) {
                    final isSelected =
                        watch.watch(goalTypeProvider) == GoalType.gift;
                    return Checkbox(
                        value: isSelected,
                        shape: const CircleBorder(),
                        onChanged: (value) => value == true
                            ? watch.watch(goalTypeProvider.notifier).state =
                                GoalType.gift
                            : watch.watch(goalTypeProvider.notifier).state =
                                GoalType.none);
                  }),
                  Text(LocaleKeys.gifts.tr()),
                  const SizedBox(width: 5),
                ],
              ),
              const SizedBox(height: 10),
              Consumer(builder: (context, watch, child) {
                final value = watch.watch(goalValueProvider);
                final value2 = watch.watch(goalValueProvider2);
                return (watch.watch(goalTypeProvider) == GoalType.diamonds ||
                        watch.watch(goalTypeProvider) == GoalType.gift)
                    ? Container(
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(
                              AppConstants.defaultNumericValue),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Slider(
                          value: watch.watch(goalTypeProvider) == GoalType.gift
                              ? value
                              : value2,
                          min: 0.0,
                          max: watch.watch(goalTypeProvider) == GoalType.gift
                              ? 200.0
                              : 10000,
                          divisions:
                              watch.watch(goalTypeProvider) == GoalType.gift
                                  ? 200
                                  : 10000,
                          label: watch.watch(goalTypeProvider) == GoalType.gift
                              ? value.toStringAsFixed(0)
                              : value2.toStringAsFixed(0),
                          onChanged: (value) => watch.watch(goalTypeProvider) ==
                                  GoalType.gift
                              ? watch.watch(goalValueProvider.notifier).state =
                                  value
                              : watch.watch(goalValueProvider2.notifier).state =
                                  value,
                        ),
                      )
                    : Container();
              }),
              const SizedBox(height: 10),
              Consumer(builder: (context, watch, child) {
                return TextField(
                  decoration: InputDecoration(
                      hintText: 'Goal Explanation',
                      filled: true,
                      fillColor: AppConstants.primaryColor.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            AppConstants.defaultNumericValue),
                        borderSide: BorderSide.none,
                      )),
                  maxLines: 3,
                  onChanged: (value) =>
                      ref.watch(goalExplanationProvider.notifier).state = value,
                );
              }),
              const SizedBox(height: 10),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
                onPressed: () {
                  final goalModel = GoalModel(
                      streamTitle: ref.read(goalTitleProvider).trim(),
                      streamGoal: ref.watch(goalTypeProvider) == GoalType.gift
                          ? ref.watch(goalValueProvider).toInt()
                          : ref.watch(goalValueProvider2).toInt(),
                      streamGoalType: ref.watch(goalTypeProvider).name,
                      goalDescription:
                          ref.watch(goalExplanationProvider).trim());
                  debugPrint("Goal Model ====>> $goalModel");
                  if (!kIsWeb) {
                    (Responsive.isDesktop(context))
                        ? {
                            ref
                                .read(arrangementProvider.notifier)
                                .setArrangement(BroadCastScreen(
                                    isHost: true,
                                    registrationUser: data,
                                    agoraToken: "",
                                    channelId: "",
                                    channelName: data.phoneNumber,
                                    goalModel: goalModel)),
                            updateCurrentIndex(ref, 10),
                          }
                        : {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (c) => BroadCastScreen(
                                    isHost: true,
                                    registrationUser: data,
                                    agoraToken: "",
                                    channelId: "",
                                    channelName: data.phoneNumber,
                                    goalModel: goalModel),
                              ),
                            )
                          };
                  } else {
                    EasyLoading.showError("Under Development for web");
                  }
                  ref.invalidate(goalTitleProvider);
                  ref.invalidate(goalTypeProvider);
                  ref.invalidate(goalValueProvider);
                  ref.invalidate(goalValueProvider2);
                  ref.invalidate(goalExplanationProvider);
                },
                child: Text(
                  LocaleKeys.continu.tr(),
                )),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // void goLiveTap() async {
    //   // final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
    //   final registrationUser = ref.watch(userProfileFutureProvider);

    //   return registrationUser.when(data: (data) async {
    //     if (data != null) {
    //       EasyLoading.show(status: LocaleKeys.loading.tr());
    //       final regUser = data;
    //       await LiveStream()
    //           .generateAgoraToken(regUser.phoneNumber, regUser.phoneNumber)
    //           .then(
    //         (value) async {
    //           final String agoraTkn = value.token;
    //           final String channelId = value.channelId;
    //           if (kDebugMode) {
    //             print(agoraTkn);
    //           }
    //           await ref.read(userProfileNotifier).updateAgoraToken(
    //               agoraToken: agoraTkn, phoneNumber: regUser.phoneNumber);

    //           // Navigator.pop(context);
    //           EasyLoading.dismiss();
    //           return Navigator.push(
    //             context,
    //             MaterialPageRoute(
    //               builder: (c) => BroadCastScreen(
    //                   registrationUser: regUser,
    //                   agoraToken: agoraTkn,
    //                   channelId: channelId,
    //                   channelName: regUser.phoneNumber),
    //             ),
    //           );
    //         },
    //       );
    //     }
    //   }, error: (Object error, StackTrace stackTrace) {
    //     return null;
    //   }, loading: () {
    //     return null;
    //   });
    // }

    return ViewModelBuilder<LiveStreamScreenViewModel>.reactive(
      onViewModelReady: (model) {
        return model.init();
      },
      viewModelBuilder: () => LiveStreamScreenViewModel(),
      builder: (context, model, child) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  padding: const EdgeInsets.only(top: 10, bottom: 2),
                  child: Row(
                    children: [
                      if (widget.isHome == null)
                        CustomIconButton(
                            padding: const EdgeInsets.all(
                                AppConstants.defaultNumericValue / 1.8),
                            onPressed: () {
                              (!Responsive.isDesktop(context))
                                  ? Navigator.pop(context)
                                  : ref.invalidate(arrangementProviderExtend);
                            },
                            color: AppConstants.primaryColor,
                            icon: leftArrowSvg),
                      const SizedBox(
                        width: AppConstants.defaultNumericValue,
                      ),
                      RichText(
                        text: TextSpan(
                          text: Appname,
                          style: const TextStyle(
                              color: AppConstants.primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              fontFamily: fNSfUiBold),
                          children: <TextSpan>[
                            TextSpan(
                              text: "  ${LocaleKeys.live.tr().toUpperCase()}",
                              style: const TextStyle(
                                  fontFamily: fNSfUiMedium,
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 17),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      LottieButton(
                        onPressed: () {
                          ref.watch(userProfileFutureProvider).when(
                              data: (data) {
                                if (data != null) {
                                  // _data = data;
                                  if (data.followersCount! >=
                                      SettingRes.minFansForLive!) {
                                    showGoalDialog(context, data);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text(AppRes.minimumCoinRequired),
                                      ),
                                    );
                                  }
                                }
                              },
                              error: (Object error, StackTrace stackTrace) {},
                              loading: () {});
                        },
                        lottieAsset: 'assets/json/lottie/button.json',
                        child: Text(LocaleKeys.goLive.tr()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 18,
                ),
                CustomGridView(
                  model: model,
                ),
                const SizedBox(
                  height: 10,
                ),
                if (model.bannerAd != null)
                  Container(
                    alignment: Alignment.center,
                    width: model.bannerAd?.size.width.toDouble(),
                    height: model.bannerAd?.size.height.toDouble(),
                    child: AdWidget(ad: model.bannerAd!),
                  ),
                Container(
                  height: 1,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Opacity(
                    opacity: 0,
                    child: PreloadPage(
                      currentUserNo: widget.currentUserNo,
                      prefs: widget.prefs,
                      doc: widget.doc,
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class PreloadPage extends ConsumerWidget {
  final String? currentUserNo;
  final SharedPreferences? prefs;
  final DocumentSnapshot<Map<String, dynamic>>? doc;
  const PreloadPage({
    Key? key,
    required this.currentUserNo,
    required this.prefs,
    required this.doc,
  }) : super(key: key);
  @override
  Widget build(BuildContext context, ref) {
    return ChatHomePage(
      currentUserNo: currentUserNo!,
      prefs: prefs!,
      doc: doc!,
    );
  }
}

class CustomGridView extends ConsumerWidget {
  final LiveStreamScreenViewModel model;

  const CustomGridView({
    Key? key,
    required this.model,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    return Expanded(
        child: model.liveUsers.isEmpty
            ? Center(
                child: Text(
                  LocaleKeys.noUserLive.tr(),
                  style:
                      const TextStyle(fontSize: 18, fontFamily: fNSfUiSemiBold),
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: GridView.builder(
                  itemCount: model.liveUsers.length,
                  itemBuilder: (context, index) {
                    final user = model.liveUsers[index];
                    return gridTile(
                      ref: ref,
                      data: user,
                      context: context,
                    );
                  },
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 0.7,
                    crossAxisCount: 2, // Two columns
                    mainAxisSpacing: 12, // Spacing between rows
                    crossAxisSpacing: 12, // Spacing between columns
                  ),
                ),
              ));
  }

  Widget gridTile(
      {required LiveStreamUser data,
      required BuildContext context,
      required WidgetRef ref}) {
    return GestureDetector(
      onTap: () {
        model.onImageTap(context, data, ref);
      },
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            // height: MediaQuery.of(context).size.height * .15,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              // color: Colors.grey.withOpacity(0.6),
              image: DecorationImage(
                image: NetworkImage(data.userImage ?? icUserPlaceHolder),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            child: Container(
              color: AppConstants.primaryColor,
              padding: const EdgeInsets.fromLTRB(10, 12, 0, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        data.fullName ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                      Image.asset(
                        verifiedIcon,
                        height: 16,
                        width: 16,
                      ),
                    ],
                  ),
                  Text(
                    '${data.followers ?? 0} ${LocaleKeys.followers.tr()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      WebsafeSvg.asset(
                          height: 36,
                          width: 36,
                          fit: BoxFit.fitHeight,
                          unhidenIcon,
                          color: Colors.white),
                      const SizedBox(width: 3.5),
                      Text(
                        '${data.watchingCount ?? 0}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
