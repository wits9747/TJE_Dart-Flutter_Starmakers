import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';

import 'package:lamatdating/main.dart';
import 'package:lamatdating/helpers/constants.dart';
import 'package:lamatdating/helpers/date_formater.dart';
import 'package:lamatdating/models/notification_model.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/providers/notifiaction_provider.dart';
import 'package:lamatdating/providers/other_users_provider.dart';
import 'package:lamatdating/views/custom/custom_app_bar.dart';
import 'package:lamatdating/views/custom/custom_headline.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';
import 'package:lamatdating/views/tabs/live/widgets/user_circle_widg.dart';
import 'package:lamatdating/views/notifications/notifs.dart';
import 'package:lamatdating/views/otherProfile/user_details_page.dart';
import 'package:lamatdating/views/tabs/messages/components/chat_page.dart';

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage> {
  final CustomPopupMenuController _moreMenuController =
      CustomPopupMenuController();

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(sharedPreferencesProvider).value;
    final currentUserRef = ref.watch(currentUserStateProvider);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppConstants.defaultNumericValue),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultNumericValue),
            child: CustomAppBar(
              leading: CustomIconButton(
                  padding: const EdgeInsets.all(
                      AppConstants.defaultNumericValue / 1.8),
                  onPressed: () => Navigator.pop(context),
                  color: AppConstants.primaryColor,
                  icon: leftArrowSvg),
              title: Center(
                  child: CustomHeadLine(
                text: LocaleKeys.notifications.tr(),
              )),
              trailing: CustomPopupMenu(
                menuBuilder: () => ClipRRect(
                  borderRadius: BorderRadius.circular(
                      AppConstants.defaultNumericValue / 2),
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.white),
                    child: IntrinsicWidth(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          MoreMenuTitle(
                            title: LocaleKeys.markallasread.tr(),
                            onTap: () async {
                              _moreMenuController.hideMenu();
                              await markAllAsRead(currentUserRef!.phoneNumber!);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                pressType: PressType.singleClick,
                verticalMargin: 0,
                controller: _moreMenuController,
                showArrow: true,
                arrowColor: Colors.white,
                barrierColor: AppConstants.primaryColor.withOpacity(0.1),
                child: GestureDetector(
                  child: const Icon(CupertinoIcons.ellipsis_vertical),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.defaultNumericValue),
          ListTile(
            onTap: () {
              Navigator.push(
                  this.context,
                  MaterialPageRoute(
                      builder: (context) => AllNotifications(
                            prefs: prefs!,
                          )));
            },
            contentPadding: const EdgeInsets.fromLTRB(
                AppConstants.defaultNumericValue,
                3,
                AppConstants.defaultNumericValue,
                3),
            trailing: const Padding(
              padding: EdgeInsets.only(top: 3),
              child: Icon(
                Icons.notifications_none,
                color: AppConstants.primaryColor,
                size: 29,
              ),
            ),
            title: Text(LocaleKeys.promotionalEventsAlerts.tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                )),
          ),
          const SizedBox(height: AppConstants.defaultNumericValue),
          const Expanded(child: NotificationBody()),
        ],
      ),
    );
  }
}

class NotificationBody extends ConsumerWidget {
  const NotificationBody({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final prefs = ref.watch(sharedPreferencesProvider).value;
    void deleteNotificationDialog(NotificationModel item) {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              padding: const EdgeInsets.all(AppConstants.defaultNumericValue),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(LocaleKeys.areyousureyouwanttodeletethisnotification
                      .tr()),
                  const SizedBox(height: AppConstants.defaultNumericValue),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        child: Text(
                          LocaleKeys.cancel.tr(),
                          style: const TextStyle(color: Colors.black),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: AppConstants.defaultNumericValue),
                      TextButton(
                        child: Text(LocaleKeys.delete.tr()),
                        onPressed: () {
                          Navigator.pop(context);
                          deleteNotification(item.phoneNumber!);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          });
    }

    void onTapNotification(WidgetRef ref, NotificationModel item) {
      if (item.isMatchingNotification) {
        final otherUsers = ref.watch(otherUsersProvider);

        UserProfileModel? otherUser;
        otherUsers.whenData((value) {
          otherUser = value.firstWhere(
              (element) => element.phoneNumber == item.phoneNumber!);
        });

        if (otherUser != null) {
          if (!item.isRead) {
            updateNotification(item.copyWith(isRead: true));
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserDetailsPage(
                user: otherUser!,
                matchId: item.matchId,
              ),
            ),
          );
        }
      }

      if (item.isInteractionNotification) {
        if (!item.isRead) {
          updateNotification(item.copyWith(isRead: true));
        }
        Navigator.pop(context);
      }
    }

    final notifications = ref.watch(notificationsStreamProvider);
    return notifications.when(
      data: (data) {
        if (data.isEmpty) {
          return Center(child: Text(LocaleKeys.nonotifications.tr()));
        } else {
          return ListView.separated(
            itemBuilder: (context, index) {
              NotificationModel item = data[index];

              return ListTile(
                onLongPress: () {
                  deleteNotificationDialog(item);
                },
                onTap: () {
                  onTapNotification(ref, item);
                },
                title: Text(item.title),
                tileColor: item.isRead
                    ? null
                    : AppConstants.primaryColor.withOpacity(0.2),
                subtitle: Text(item.body),
                trailing: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormatter.toTime(item.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      DateFormatter.toYearMonthDay2(item.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                leading: item.image == null
                    ? CircleAvatar(
                        radius: AppConstants.defaultNumericValue * 1.5,
                        backgroundColor: AppConstants.primaryColor,
                        child: Text(
                          item.title.substring(0, 1),
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(color: Colors.white),
                        ),
                      )
                    : UserCirlePicture(
                        imageUrl: item.image,
                        size: AppConstants.defaultNumericValue * 2.5),
              );
            },
            itemCount: data.length,
            separatorBuilder: (context, index) => const Divider(height: 0),
          );
        }
      },
      error: (e, st) {
        return const SizedBox();
      },
      loading: () {
        return const SizedBox();
      },
    );
  }
}
