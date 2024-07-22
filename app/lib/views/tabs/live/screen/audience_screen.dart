// ignore_for_file: deprecated_member_use

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/helpers/constants.dart';
import 'package:lamatdating/modal/live_stream/live_stream.dart';
import 'package:lamatdating/models/broad_cast_screen_view_model.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/other_users_provider.dart';
import 'package:lamatdating/providers/user_profile_provider.dart';
import 'package:lamatdating/views/tabs/live/widgets/audience_top_bar.dart';
import 'package:lamatdating/views/tabs/live/widgets/live_stream_bottom_filed.dart';
import 'package:lamatdating/views/tabs/live/widgets/live_stream_chat_list.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:websafe_svg/websafe_svg.dart';

class AudienceScreen extends ConsumerWidget {
  final String? agoraToken;
  final String? channelName;
  final LiveStreamUser user;

  const AudienceScreen({
    Key? key,
    this.agoraToken,
    this.channelName,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final UserProfileModel? userProf =
        ref.watch(userProfileFutureProvider).value;
    final UserProfileModel? liveHost =
        ref.watch(otherUserProfileFutureProvider(user.phoneNumber!)).value;
    return ViewModelBuilder<BroadCastScreenViewModel>.reactive(
      onViewModelReady: (model) {
        if (liveHost != null) {
          model.init(
              ref: ref,
              isBroadCast: false,
              isCoHost: false,
              agoraToken: user.agoraToken!,
              channelName: user.hostIdentity!,
              context: context,
              registrationUser: liveHost);
        }
      },
      viewModelBuilder: () => BroadCastScreenViewModel(
          isHost: false,
          isCoHost: false,
          userProfile: userProf!,
          channelId: user.hostIdentity!,
          ref: ref),
      builder: (context, model, child) {
        return WillPopScope(
          onWillPop: () async {
            model.audienceExit(context);
            return false;
          },
          child: Scaffold(
            body: Stack(
              alignment: Alignment.center,
              children: [
                model.videoPanel(context),
                SafeArea(
                  child: Column(
                    children: [
                      AudienceTopBar(
                          model: model, user: user, userProf: liveHost!),
                      const Spacer(),
                      LiveStreamChatList(
                          commentList: model.commentList, pageContext: context),
                      Visibility(
                        visible:
                            (model.liveStreamUser!.battleUsers!.length == 2),
                        child: Row(
                          children: [
                            const Expanded(child: SizedBox()),
                            InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap: () => model.onGiftTap(context, ref),
                              child: Container(
                                height: 45,
                                width: 45,
                                margin: const EdgeInsets.all(2),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: AppConstants.defaultGradient,
                                ),
                                child: WebsafeSvg.asset(
                                  height: 36,
                                  width: 36,
                                  fit: BoxFit.fitHeight,
                                  giftIcon,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const Expanded(child: SizedBox()),
                            InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap: () =>
                                  model.onGiftTap(context, ref, userId: 2),
                              child: Container(
                                height: 45,
                                width: 45,
                                margin: const EdgeInsets.all(2),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: AppConstants.defaultGradient,
                                ),
                                child: WebsafeSvg.asset(
                                  height: 36,
                                  width: 36,
                                  fit: BoxFit.fitHeight,
                                  giftIcon,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const Expanded(child: SizedBox()),
                          ],
                        ),
                      ),
                      LiveStreamBottomField(
                        model: model,
                      ),
                    ],
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
