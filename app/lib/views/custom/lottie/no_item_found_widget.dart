import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lamatdating/helpers/constants.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/user_profile_provider.dart';
import 'package:lamatdating/utils/theme_management.dart';

class NoItemFoundWidget extends ConsumerWidget {
  final String? text;
  final bool isSmall;
  final SharedPreferences? prefs;
  final UserProfileModel? currentProfile;
  const NoItemFoundWidget(
      {Key? key,
      this.text,
      this.isSmall = false,
      this.prefs,
      this.currentProfile})
      : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final userRef = ref.watch(userProfileFutureProvider);
    // final box = Hive.box(HiveConstants.hiveBox);
    // final userProfileRef =
    //     box.get(HiveConstants.currentUserProf) as UserProfileModel;
    return Container(
        color: prefs != null
            ? Teme.isDarktheme(prefs!)
                ? AppConstants.backgroundColorDark
                : AppConstants.backgroundColor
            : Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: LottieBuilder.asset(
                    lottieSearch,
                    width: 250,
                    height: 250,
                    alignment: Alignment.center,
                    fit: BoxFit.cover,
                  ),
                ),
                userRef.when(
                  data: (data) => CircleAvatar(
                    radius: 25,
                    backgroundImage: const AssetImage(loading_gif),
                    child: ClipOval(
                        child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: (data != null &&
                              data.profilePicture != "" &&
                              data.profilePicture != null)
                          ? data.profilePicture!
                          : "",
                      placeholder: (context, url) => const SizedBox(),
                      errorWidget: (context, url, error) => const SizedBox(),
                    )),
                  ),
                  error: (error, stackTrace) => const CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage(loading_gif),
                  ),
                  loading: () => const CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage(loading_gif),
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}
