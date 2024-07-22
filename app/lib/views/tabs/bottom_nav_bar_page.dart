// ignore_for_file: use_build_context_synchronously,, unused_local_variable

import 'dart:async';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lamatdating/models/app_settings_model.dart';
import 'package:lamatdating/providers/other_users_provider.dart';
import 'package:lamatdating/views/custom/lottie/no_item_found_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:redacted/redacted.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:websafe_svg/websafe_svg.dart';

import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/helpers/constants.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/main.dart';
import 'package:lamatdating/modal/battle/battle_live.dart';
import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/providers/banned_users_provider.dart';
import 'package:lamatdating/providers/call_history_provider.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/providers/match_provider.dart';
import 'package:lamatdating/providers/observer.dart';
import 'package:lamatdating/providers/smart_contact_provider.dart';
import 'package:lamatdating/providers/status_provider.dart';
import 'package:lamatdating/providers/subscriptions/init_purchase_conf.dart';
import 'package:lamatdating/providers/user_profile_provider.dart';
import 'package:lamatdating/providers/user_provider.dart';
import 'package:lamatdating/responsive.dart';
import 'package:lamatdating/translate_notifs.dart';
import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/custom_url_launcher.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/tabs/live/screen/broad_cast_screen.dart';
import 'package:lamatdating/views/tabs/live/screen/live_stream_screen.dart';
import 'package:lamatdating/views/loading_error/error_page.dart';
import 'package:lamatdating/views/others/user_is_banned_page.dart';
import 'package:lamatdating/views/tabs/chat/chat_home.dart';
import 'package:lamatdating/views/tabs/feeds/feeds_home_page.dart';
import 'package:lamatdating/views/tabs/home/home_page.dart';
import 'package:lamatdating/views/tabs/matches/matches_page.dart';
import 'package:lamatdating/views/tabs/profile/first_time_update_profile_page.dart'
    if (dart.library.html) 'package:lamatdating/views/tabs/profile/first_time_update_profile_page_web.dart';
import 'package:lamatdating/views/tabs/profile/profile_nested_page.dart';
import 'package:lamatdating/views/tabs/teels/home_screen.dart';

class BottomNavBarPage extends ConsumerStatefulWidget {
  final String phoneNumber;
  final User? user;
  final String? phone;
  final SharedPreferences prefs;
  final DocumentSnapshot<Map<String, dynamic>> doc;
  final int? index;
  const BottomNavBarPage(
      {Key? key,
      required this.phoneNumber,
      this.phone,
      required this.prefs,
      required this.doc,
      this.index,
      required this.user})
      : super(key: key);

  @override
  ConsumerState<BottomNavBarPage> createState() => _BottomNavBarPageState();
}

class _BottomNavBarPageState extends ConsumerState<BottomNavBarPage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  int? _currentIndex;

  String? deviceid;
  var mapDeviceInfo = {};
  SharedPreferences? prefs;
  TabController? controller;

  TabController? _tabController;

  int? _currentIndexTabs;
  bool get wantKeepAlive => true;
  bool isFetching = true;
  List phoneNumberVariants = [];
  bool isAuthenticating = false;
  StreamSubscription? spokenSubscription;
  List<StreamSubscription> unreadSubscriptions =
      List.from(<StreamSubscription>[]);
  List<StreamController> controllers = List.from(<StreamController>[]);
  String? maintainanceMessage;
  bool isNotAllowEmulator = false;
  bool? isblockNewlogins = false;
  bool? isApprovalNeededbyAdminForNewUser = false;
  String? accountApprovalMessage = 'Account Approved';
  String? accountstatus;
  String? accountactionmessage;
  String? userPhotourl;
  String? userFullname;
  String? myphoneNumber;
  DataModel? _cachedModel;
  Box<dynamic>? box;
  bool userSet = false;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  bool userBanned = false;

  @override
  void initState() {
    _currentIndex = widget.index ?? 0;
    _currentIndexTabs = 0;
    _tabController = TabController(length: 2, vsync: this);
    debugPrint("First ===> phone: ${widget.phone}");
    getPrefs();
    if (!kIsWeb) {
      setdeviceinfo();
      registerNotification();
      initPlatformStateForPurchases(widget.phoneNumber);
    }
    box = Hive.box(HiveConstants.hiveBox);
    userSet = box!.get(HiveConstants.userSet) == null
        ? false
        : box!.get(HiveConstants.userSet) as bool;
    debugPrint("userSet: $userSet");
    WidgetsBinding.instance.addObserver(this);
    setState(() {
      prefs = widget.prefs;
    });

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      myphoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber!;

      final collection = FirebaseFirestore.instance
          .collection(FirebaseConstants.appSettingsCollection)
          .doc("settings");
      final snapshot = await collection.get();
      debugPrint("Second ===> phone: ${widget.phone}");
      if (!snapshot.exists) {
        EasyLoading.showError("App settings not found");
      }
      debugPrint("snapshot: ${snapshot.data()}");
      final appSettings = AppSettingsModel.fromMap(snapshot.data()!);
      debugPrint("Third ===> phone: ${widget.phone}");
      AppRes.primaryColor = appSettings.primaryColor;
      AppRes.primaryDarkColor = appSettings.primaryDarkColor;
      AppRes.secondaryColor = appSettings.secondaryColor;
      AppRes.secondaryDarkColor = appSettings.secondaryDarkColor;
      AppRes.tintColor = appSettings.tintColor;
      AppRes.appLogo = appSettings.appLogo;
      AppConfig.currency = appSettings.currency ?? "ZAR";

      getModel();
      getSignedInUserOrRedirect();
      debugPrint("Fourth ===> phone: ${widget.phone}");
      userBanned = await isUserBanned(widget.phoneNumber);
      setState(() {});
    });
  }

  void exitApp() async {
    // SystemNavigator.pop();
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text(
            'Are you sure you want to reject T&Cs and exit the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(LocaleKeys.no.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(LocaleKeys.yes.tr()),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      // Call exit(0) only if user confirms
      exit(0);
    }
  }

  getSignedInUserOrRedirect() async {
    final settingsDoc = widget.doc.data()!;
    try {
      setState(() {
        isblockNewlogins = settingsDoc[Dbkeys.isblocknewlogins];
        isApprovalNeededbyAdminForNewUser =
            settingsDoc[Dbkeys.isaccountapprovalbyadminneeded];
        accountApprovalMessage = settingsDoc[Dbkeys.accountapprovalmessage];
      });
      if (settingsDoc[Dbkeys.isemulatorallowed] == false &&
          mapDeviceInfo[Dbkeys.deviceInfoISPHYSICAL] == false) {
        setState(() {
          isNotAllowEmulator = true;
        });
      } else {
        if (!kIsWeb) {
          if (settingsDoc[Platform.isAndroid
                  ? Dbkeys.isappunderconstructionandroid
                  : Platform.isIOS
                      ? Dbkeys.isappunderconstructionios
                      : Dbkeys.isappunderconstructionweb] ==
              true) {
            await unsubscribeToNotification(
                widget.prefs.getString(Dbkeys.phone));
            maintainanceMessage = settingsDoc[Dbkeys.maintainancemessage];
            setState(() {});
          } else {
            final PackageInfo info = await PackageInfo.fromPlatform();
            widget.prefs.setString('app_version', info.version);

            int currentAppVersionInPhone = int.tryParse(info.version
                        .trim()
                        .split(".")[0]
                        .toString()
                        .padLeft(3, '0') +
                    info.version
                        .trim()
                        .split(".")[1]
                        .toString()
                        .padLeft(3, '0') +
                    info.version
                        .trim()
                        .split(".")[2]
                        .toString()
                        .padLeft(3, '0')) ??
                0;
            int currentNewAppVersionInServer =
                int.tryParse(settingsDoc[Platform.isAndroid
                                ? Dbkeys.latestappversionandroid
                                : Platform.isIOS
                                    ? Dbkeys.latestappversionios
                                    : Dbkeys.latestappversionweb]
                            .trim()
                            .split(".")[0]
                            .toString()
                            .padLeft(3, '0') +
                        settingsDoc[Platform.isAndroid
                                ? Dbkeys.latestappversionandroid
                                : Platform.isIOS
                                    ? Dbkeys.latestappversionios
                                    : Dbkeys.latestappversionweb]
                            .trim()
                            .split(".")[1]
                            .toString()
                            .padLeft(3, '0') +
                        settingsDoc[Platform.isAndroid
                                ? Dbkeys.latestappversionandroid
                                : Platform.isIOS
                                    ? Dbkeys.latestappversionios
                                    : Dbkeys.latestappversionweb]
                            .trim()
                            .split(".")[2]
                            .toString()
                            .padLeft(3, '0')) ??
                    0;
            if (currentAppVersionInPhone < currentNewAppVersionInServer) {
              showDialog<String>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  String title = LocaleKeys.updateAvailable.tr();
                  String message = LocaleKeys.updateavlmsg.tr();
                  String btnLabel = LocaleKeys.updatnow.tr();

                  return PopScope(
                      canPop: false,
                      child: AlertDialog(
                        backgroundColor: Teme.isDarktheme(widget.prefs)
                            ? lamatDIALOGColorDarkMode
                            : lamatDIALOGColorLightMode,
                        title: Text(
                          title,
                          style: TextStyle(
                            color: pickTextColorBasedOnBgColorAdvanced(
                                Teme.isDarktheme(widget.prefs)
                                    ? lamatDIALOGColorDarkMode
                                    : lamatDIALOGColorLightMode),
                          ),
                        ),
                        content: Text(message),
                        actions: <Widget>[
                          TextButton(
                              child: Text(
                                btnLabel,
                                style:
                                    const TextStyle(color: lamatPRIMARYcolor),
                              ),
                              onPressed: () => custom_url_launcher(
                                  settingsDoc[Platform.isAndroid
                                      ? Dbkeys.newapplinkandroid
                                      : Platform.isIOS
                                          ? Dbkeys.newapplinkios
                                          : Dbkeys.newapplinkweb])),
                        ],
                      ));
                },
              );
            } else {
              final observer = ref.watch(observerProvider);

              observer.setObserver(
                getuserAppSettingsDoc: widget.doc,
                getisWebCompatible: settingsDoc.containsKey('is_web_compatible')
                    ? settingsDoc['is_web_compatible']
                    : false,
                getandroidapplink: settingsDoc[Dbkeys.newapplinkandroid],
                getiosapplink: settingsDoc[Dbkeys.newapplinkios],
                getisadmobshow: settingsDoc[Dbkeys.isadmobshow],
                getismediamessagingallowed:
                    settingsDoc[Dbkeys.ismediamessageallowed],
                getistextmessagingallowed:
                    settingsDoc[Dbkeys.istextmessageallowed],
                getiscallsallowed: settingsDoc[Dbkeys.iscallsallowed],
                gettnc: settingsDoc[Dbkeys.tnc],
                gettncType: settingsDoc[Dbkeys.tncTYPE],
                getprivacypolicy: settingsDoc[Dbkeys.privacypolicy],
                getprivacypolicyType: settingsDoc[Dbkeys.privacypolicyTYPE],
                getis24hrsTimeformat: settingsDoc[Dbkeys.is24hrsTimeformat],
                getmaxFileSizeAllowedInMB:
                    settingsDoc[Dbkeys.maxFileSizeAllowedInMB],
                getisPercentProgressShowWhileUploading:
                    settingsDoc[Dbkeys.isPercentProgressShowWhileUploading],
                getisCallFeatureTotallyHide:
                    settingsDoc[Dbkeys.isCallFeatureTotallyHide],
                getgroupMemberslimit: settingsDoc[Dbkeys.groupMemberslimit],
                getbroadcastMemberslimit:
                    settingsDoc[Dbkeys.broadcastMemberslimit],
                getstatusDeleteAfterInHours:
                    settingsDoc[Dbkeys.statusDeleteAfterInHours],
                getfeedbackEmail: settingsDoc[Dbkeys.feedbackEmail],
                getisLogoutButtonShowInSettingsPage:
                    settingsDoc[Dbkeys.isLogoutButtonShowInSettingsPage],
                getisAllowCreatingGroups:
                    settingsDoc[Dbkeys.isAllowCreatingGroups],
                getisAllowCreatingBroadcasts:
                    settingsDoc[Dbkeys.isAllowCreatingBroadcasts],
                getisAllowCreatingStatus:
                    settingsDoc[Dbkeys.isAllowCreatingStatus],
                getmaxNoOfFilesInMultiSharing:
                    settingsDoc[Dbkeys.maxNoOfFilesInMultiSharing],
                getmaxNoOfContactsSelectForForward:
                    settingsDoc[Dbkeys.maxNoOfContactsSelectForForward],
                getappShareMessageStringAndroid:
                    settingsDoc[Dbkeys.appShareMessageStringAndroid],
                getappShareMessageStringiOS:
                    settingsDoc[Dbkeys.appShareMessageStringiOS],
                getisCustomAppShareLink:
                    settingsDoc[Dbkeys.isCustomAppShareLink],
              );
              if (userSet == true) {
                getuid(context);
                setIsActive();

                incrementSessionCount(widget.phoneNumber);
              }
            }
          }
        } else {
          {
            final PackageInfo info = await PackageInfo.fromPlatform();
            widget.prefs.setString('app_version', info.version);

            int currentAppVersionInPhone = int.tryParse(info.version
                        .trim()
                        .split(".")[0]
                        .toString()
                        .padLeft(3, '0') +
                    info.version
                        .trim()
                        .split(".")[1]
                        .toString()
                        .padLeft(3, '0') +
                    info.version
                        .trim()
                        .split(".")[2]
                        .toString()
                        .padLeft(3, '0')) ??
                0;
            int currentNewAppVersionInServer = int.tryParse(widget
                        .doc[Dbkeys.latestappversionweb]
                        .trim()
                        .split(".")[0]
                        .toString()
                        .padLeft(3, '0') +
                    settingsDoc[Dbkeys.latestappversionweb]
                        .trim()
                        .split(".")[1]
                        .toString()
                        .padLeft(3, '0') +
                    settingsDoc[Dbkeys.latestappversionweb]
                        .trim()
                        .split(".")[2]
                        .toString()
                        .padLeft(3, '0')) ??
                0;
            if (currentAppVersionInPhone < currentNewAppVersionInServer) {
              showDialog<String>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  String title = LocaleKeys.updateAvailable.tr();
                  String message = LocaleKeys.updateavlmsg.tr();
                  String btnLabel = LocaleKeys.updatnow.tr();

                  return PopScope(
                      canPop: false,
                      child: AlertDialog(
                        backgroundColor: Teme.isDarktheme(widget.prefs)
                            ? lamatDIALOGColorDarkMode
                            : lamatDIALOGColorLightMode,
                        title: Text(
                          title,
                          style: TextStyle(
                            color: pickTextColorBasedOnBgColorAdvanced(
                                Teme.isDarktheme(widget.prefs)
                                    ? lamatDIALOGColorDarkMode
                                    : lamatDIALOGColorLightMode),
                          ),
                        ),
                        content: Text(message),
                        actions: <Widget>[
                          TextButton(
                              child: Text(
                                btnLabel,
                                style:
                                    const TextStyle(color: lamatPRIMARYcolor),
                              ),
                              onPressed: () => custom_url_launcher(
                                  settingsDoc[Dbkeys.newapplinkweb])),
                        ],
                      ));
                },
              );
            } else {
              final observer = ref.watch(observerProvider);

              observer.setObserver(
                getuserAppSettingsDoc: widget.doc,
                getisWebCompatible: settingsDoc.containsKey('is_web_compatible')
                    ? settingsDoc['is_web_compatible']
                    : false,
                getandroidapplink: settingsDoc[Dbkeys.newapplinkandroid],
                getiosapplink: settingsDoc[Dbkeys.newapplinkios],
                getisadmobshow: settingsDoc[Dbkeys.isadmobshow],
                getismediamessagingallowed:
                    settingsDoc[Dbkeys.ismediamessageallowed],
                getistextmessagingallowed:
                    settingsDoc[Dbkeys.istextmessageallowed],
                getiscallsallowed: settingsDoc[Dbkeys.iscallsallowed],
                gettnc: settingsDoc[Dbkeys.tnc],
                gettncType: settingsDoc[Dbkeys.tncTYPE],
                getprivacypolicy: settingsDoc[Dbkeys.privacypolicy],
                getprivacypolicyType: settingsDoc[Dbkeys.privacypolicyTYPE],
                getis24hrsTimeformat: settingsDoc[Dbkeys.is24hrsTimeformat],
                getmaxFileSizeAllowedInMB:
                    settingsDoc[Dbkeys.maxFileSizeAllowedInMB],
                getisPercentProgressShowWhileUploading:
                    settingsDoc[Dbkeys.isPercentProgressShowWhileUploading],
                getisCallFeatureTotallyHide:
                    settingsDoc[Dbkeys.isCallFeatureTotallyHide],
                getgroupMemberslimit: settingsDoc[Dbkeys.groupMemberslimit],
                getbroadcastMemberslimit:
                    settingsDoc[Dbkeys.broadcastMemberslimit],
                getstatusDeleteAfterInHours:
                    settingsDoc[Dbkeys.statusDeleteAfterInHours],
                getfeedbackEmail: settingsDoc[Dbkeys.feedbackEmail],
                getisLogoutButtonShowInSettingsPage:
                    settingsDoc[Dbkeys.isLogoutButtonShowInSettingsPage],
                getisAllowCreatingGroups:
                    settingsDoc[Dbkeys.isAllowCreatingGroups],
                getisAllowCreatingBroadcasts:
                    settingsDoc[Dbkeys.isAllowCreatingBroadcasts],
                getisAllowCreatingStatus:
                    settingsDoc[Dbkeys.isAllowCreatingStatus],
                getmaxNoOfFilesInMultiSharing:
                    settingsDoc[Dbkeys.maxNoOfFilesInMultiSharing],
                getmaxNoOfContactsSelectForForward:
                    settingsDoc[Dbkeys.maxNoOfContactsSelectForForward],
                getappShareMessageStringAndroid:
                    settingsDoc[Dbkeys.appShareMessageStringAndroid],
                getappShareMessageStringiOS:
                    settingsDoc[Dbkeys.appShareMessageStringiOS],
                getisCustomAppShareLink:
                    settingsDoc[Dbkeys.isCustomAppShareLink],
              );
              if (userSet == true) {
                getuid(context);
                setIsActive();

                incrementSessionCount(widget.phoneNumber);
              }
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("SIGNED IN ERROR: $e");
      }
      // showERRORSheet(context, "", message: e.toString());
    }
  }

  logout(BuildContext context) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    await firebaseAuth.signOut();

    await widget.prefs.clear();

    FlutterSecureStorage storage = const FlutterSecureStorage();
    // ignore: await_only_futures
    await storage.delete;

    await FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc(widget.phoneNumber)
        .update({
      Dbkeys.notificationTokens: [],
    });

    await widget.prefs.setBool(Dbkeys.isTokenGenerated, false);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (BuildContext context) => const LandingWidget(),
      ),
      (Route route) => false,
    );
  }

  incrementSessionCount(String myphone) async {
    final statusProvider = ref.watch(statusProviderProvider);
    final contactsProvider = ref.watch(smartContactProvider);
    final FirestoreDataProviderCALLHISTORY firestoreDataProviderCALLHISTORY =
        ref.watch(firestoreDataProviderCALLHISTORYProvider);

    await FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc(widget.prefs.getString(Dbkeys.phone))
        .set({
      Dbkeys.isNotificationStringsMulitilanguageEnabled: true,
      Dbkeys.notificationStringsMap:
          getTranslateNotificationStringsMap(context),
    }, SetOptions(merge: true));

    await contactsProvider.fetchContacts(
        context, _cachedModel, myphone, widget.prefs, false,
        currentuserphoneNumberVariants: phoneNumberVariants);

    statusProvider.triggerDeleteMyExpiredStatus(myphone);
    statusProvider.triggerDeleteOtherUsersExpiredStatus(myphone);
  }

  unsubscribeToNotification(String? userphone) async {
    if (userphone != null) {
      await FirebaseMessaging.instance
          .unsubscribeFromTopic(userphone.replaceFirst(RegExp(r'\+'), ''));
    }

    await FirebaseMessaging.instance
        .unsubscribeFromTopic(Dbkeys.topicUSERS)
        .catchError((err) {
      debugPrint(err.toString());
    });
    await FirebaseMessaging.instance
        .unsubscribeFromTopic(Platform.isAndroid
            ? Dbkeys.topicUSERSandroid
            : Platform.isIOS
                ? Dbkeys.topicUSERSios
                : Dbkeys.topicUSERSweb)
        .catchError((err) {
      debugPrint(err.toString());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      myphoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber!;
      getModel();
      setIsActive();
      userSet == true ? setUserOnlineStatus(true) : {};
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      myphoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber!;
      userSet == true ? setUserOnlineStatus(false) : {};
      setLastSeen();
    }

    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void setUserOnlineStatus(bool status) async {
    final userRef = ref.watch(userProfileFutureProvider);

    UserProfileModel? newModel;

    userRef.whenData((value) {
      if (value != null) {
        if (value.userAccountSettingsModel.showOnlineStatus != false) {
          debugPrint("User Online Status: ${value.isOnline}");
          newModel = value.copyWith(isOnline: status);
        }
      }
    });

    if (newModel != null) {
      debugPrint("Updating user online status to $status");

      await ref.read(userProfileNotifier).updateUserProfile(newModel!);
    }
  }

  DataModel? getModel() {
    myphoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber!;
    _cachedModel ??= DataModel(myphoneNumber);
    return _cachedModel;
  }

  void setIsActive() async {
    myphoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber!;
    if (myphoneNumber != null || myphoneNumber != '') {
      {
        await FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(prefs!.getString(Dbkeys.phone))
            .set(
          {
            Dbkeys.lastSeen: true,
            Dbkeys.lastOnline: DateTime.now().millisecondsSinceEpoch
          },
          SetOptions(merge: true),
        );
      }
    }
  }

  void setLastSeen() async {
    if (myphoneNumber != null || myphoneNumber != '') {
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(prefs!.getString(Dbkeys.phone))
          .set(
        {Dbkeys.lastSeen: DateTime.now().millisecondsSinceEpoch},
        SetOptions(merge: true),
      );
    }
  }

  Future<SharedPreferences> getPrefs() async {
    if (!kIsWeb) {
      var status = await Permission.storage.status;

      if (!status.isGranted) {
        prefs = await SharedPreferences.getInstance();
        return prefs!;
      } else {
        await Permission.storage.request();
        prefs = await SharedPreferences.getInstance();
        return prefs!;
      }
    } else {
      prefs = await SharedPreferences.getInstance();
      return prefs!;
    }
  }

  void registerNotification() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );
  }

  // @override
  // void didChangeDependencies() async {
  //   myphoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber!;
  //   getModel();
  //   getSignedInUserOrRedirect();
  //   setState(() {});
  //   super.didChangeDependencies();
  // }

  getuid(BuildContext context) {
    final UserProvider userProvider = ref.watch(userProviderProvider);

    userProvider.getUserDetails(prefs!.getString(Dbkeys.phone));
  }

  setdeviceinfo() async {
    if (!kIsWeb) {
      if (Platform.isAndroid == true) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        setState(() {
          deviceid = androidInfo.id + androidInfo.device;
          mapDeviceInfo = {
            Dbkeys.deviceInfoMODEL: androidInfo.model,
            Dbkeys.deviceInfoOS: 'android',
            Dbkeys.deviceInfoISPHYSICAL: androidInfo.isPhysicalDevice,
            Dbkeys.deviceInfoDEVICEID: androidInfo.id,
            Dbkeys.deviceInfoOSID: androidInfo.id,
            Dbkeys.deviceInfoOSVERSION: androidInfo.version.baseOS,
            Dbkeys.deviceInfoMANUFACTURER: androidInfo.manufacturer,
            Dbkeys.deviceInfoLOGINTIMESTAMP: DateTime.now(),
          };
        });
      } else if (Platform.isIOS == true) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        setState(() {
          deviceid =
              "${iosInfo.systemName}${iosInfo.model ?? ""}${iosInfo.systemVersion ?? ""}";
          mapDeviceInfo = {
            Dbkeys.deviceInfoMODEL: iosInfo.model,
            Dbkeys.deviceInfoOS: 'ios',
            Dbkeys.deviceInfoISPHYSICAL: iosInfo.isPhysicalDevice,
            Dbkeys.deviceInfoDEVICEID: iosInfo.identifierForVendor,
            Dbkeys.deviceInfoOSID: iosInfo.name,
            Dbkeys.deviceInfoOSVERSION: iosInfo.name,
            Dbkeys.deviceInfoMANUFACTURER: iosInfo.name,
            Dbkeys.deviceInfoLOGINTIMESTAMP: DateTime.now(),
          };
        });
      }
    } else {
      WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;
      setState(() {
        deviceid = webBrowserInfo.browserName.toString();
        mapDeviceInfo = {
          Dbkeys.deviceInfoMODEL: webBrowserInfo.appName ?? "web",
          Dbkeys.deviceInfoOS: 'web',
          Dbkeys.deviceInfoISPHYSICAL: true,
          Dbkeys.deviceInfoDEVICEID: deviceid ??
              widget.phoneNumber + ref.watch(currentUserStateProvider)!.uid,
          Dbkeys.deviceInfoOSID: webBrowserInfo.productSub ?? "web",
          Dbkeys.deviceInfoOSVERSION: webBrowserInfo.productSub ?? "web",
          Dbkeys.deviceInfoMANUFACTURER: webBrowserInfo.appName ?? "web",
          Dbkeys.deviceInfoLOGINTIMESTAMP: DateTime.now(),
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUserAdded = ref.watch(isUserAddedProvider);
    // final isMeBanned = ref.watch(isMeBannedProvider);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final arrangemennt = ref.watch(arrangementProvider);
    final arrangementExtend = ref.watch(arrangementProviderExtend);
    final newIndex = ref.watch(currentIndexProvider);
    final battleInvite = ref.watch(liveBattleInviteStream);

    final List<_BottomNavBarItem> navItems = [
      // Swipe Page
      _BottomNavBarItem(
          title: '',
          icon: WebsafeSvg.asset(
            height: 28,
            width: 28,
            fit: BoxFit.fitHeight,
            homeIcon,
            color: Colors.grey,
          ),
          activeIcon: WebsafeSvg.asset(
            height: 28,
            width: 28,
            fit: BoxFit.fitHeight,
            homeActiveIcon,
            color: AppConstants.primaryColor,
          ),
          page: SwipePage(
            prefs: widget.prefs,
            doc: widget.doc,
          )),
      // Live Streams Page
      _BottomNavBarItem(
          title: '',
          icon: WebsafeSvg.asset(
            height: 28,
            width: 28,
            fit: BoxFit.fitHeight,
            liveIcon,
            color: Colors.grey,
          ),
          activeIcon: WebsafeSvg.asset(
            height: 28,
            width: 28,
            fit: BoxFit.fitHeight,
            liveIcon,
            color: AppConstants.primaryColor,
          ),
          page: LiveStreamScreen(
            isHome: true,
            currentUserNo: widget.phoneNumber,
            prefs: widget.prefs,
            doc: widget.doc,
          )),
      //Explore
      _BottomNavBarItem(
        title: '',
        icon: WebsafeSvg.asset(
          height: 28,
          width: 28,
          fit: BoxFit.fitHeight,
          feedsIcon,
          color: Colors.grey,
        ),
        activeIcon: WebsafeSvg.asset(
          height: 28,
          width: 28,
          fit: BoxFit.fitHeight,
          feedsActiveIcon,
          color: AppConstants.primaryColor,
        ),
        page: FeedsPage(prefs: widget.prefs, currentUserNo: widget.phoneNumber),
      ),
      //Favourites
      _BottomNavBarItem(
        title: '',
        icon: WebsafeSvg.asset(
          height: 28,
          width: 28,
          fit: BoxFit.fitHeight,
          reelsIcon,
          color: Colors.grey,
        ),
        activeIcon: WebsafeSvg.asset(
          height: 28,
          width: 28,
          fit: BoxFit.fitHeight,
          reelsActiveIcon,
          color: AppConstants.primaryColor,
        ),
        page: const TeelsPage(),
      ),
      // Messages
      _BottomNavBarItem(
        title: '',
        icon: WebsafeSvg.asset(
          height: 28,
          width: 28,
          fit: BoxFit.fitHeight,
          mailIcon,
          color: Colors.grey,
        ),
        activeIcon: WebsafeSvg.asset(
          height: 28,
          width: 28,
          fit: BoxFit.fitHeight,
          mailActiveIcon,
          color: AppConstants.primaryColor,
        ),
        page: ChatHomePage(
          currentUserNo: widget.phoneNumber,
          prefs: widget.prefs,
          doc: widget.doc,
        ),
        // const MessageConsumerPage(),
      ),
      //Proile
      _BottomNavBarItem(
        title: '',
        icon: WebsafeSvg.asset(
          height: 28,
          width: 28,
          fit: BoxFit.fitHeight,
          profileIcon,
          color: Colors.grey,
        ),
        activeIcon: WebsafeSvg.asset(
          height: 28,
          width: 28,
          fit: BoxFit.fitHeight,
          profileActiveIcon,
          color: AppConstants.primaryColor,
        ),
        page: const ProfileNested(),
      ),
    ];

    // WEB NAVIGATOR
    final List<_BottomNavBarItem> navItemsWeb = [
      //Swipe Page
      _BottomNavBarItem(
          title: '',
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.black45,
              shape: BoxShape.circle,
            ),
            child: WebsafeSvg.asset(
              height: 28,
              width: 28,
              fit: BoxFit.fitHeight,
              homeIcon,
              color: Colors.white,
            ),
          ),
          activeIcon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.black45,
              shape: BoxShape.circle,
            ),
            child: WebsafeSvg.asset(
              height: 28,
              width: 28,
              fit: BoxFit.fitHeight,
              homeActiveIcon,
              color: AppConstants.secondaryColor,
            ),
          ),
          page: SwipePage(
            prefs: widget.prefs,
            doc: widget.doc,
          ).redacted(context: context, redact: true)),
      // Live Streams
      _BottomNavBarItem(
          title: '',
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.black45,
              shape: BoxShape.circle,
            ),
            child: WebsafeSvg.asset(
              height: 28,
              width: 28,
              fit: BoxFit.fitHeight,
              liveIcon,
              color: Colors.white,
            ),
          ),
          activeIcon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.black45,
              shape: BoxShape.circle,
            ),
            child: WebsafeSvg.asset(
              height: 28,
              width: 28,
              fit: BoxFit.fitHeight,
              liveIcon,
              color: AppConstants.secondaryColor,
            ),
          ),
          page: LiveStreamScreen(
            isHome: true,
            currentUserNo: widget.phoneNumber,
            prefs: widget.prefs,
            doc: widget.doc,
          )),

      //Explore
      _BottomNavBarItem(
        title: '',
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.black45,
            shape: BoxShape.circle,
          ),
          child: WebsafeSvg.asset(
            height: 28,
            width: 28,
            fit: BoxFit.fitHeight,
            feedsIcon,
            color: Colors.white,
          ),
        ),
        activeIcon: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.black45,
            shape: BoxShape.circle,
          ),
          child: WebsafeSvg.asset(
            height: 28,
            width: 28,
            fit: BoxFit.fitHeight,
            feedsActiveIcon,
            color: AppConstants.secondaryColor,
          ),
        ),
        page: FeedsPage(prefs: widget.prefs, currentUserNo: widget.phoneNumber),
      ),
      //Favourites
      _BottomNavBarItem(
        title: '',
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.black45,
            shape: BoxShape.circle,
          ),
          child: WebsafeSvg.asset(
            height: 28,
            width: 28,
            fit: BoxFit.fitHeight,
            reelsIcon,
            color: Colors.white,
          ),
        ),
        activeIcon: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.black45,
            shape: BoxShape.circle,
          ),
          child: WebsafeSvg.asset(
            height: 28,
            width: 28,
            fit: BoxFit.fitHeight,
            reelsActiveIcon,
            color: AppConstants.secondaryColor,
          ),
        ),
        page: const TeelsPage(),
      ),
      //Messages
      // _BottomNavBarItem(
      //   title: '',
      //   icon: WebsafeSvg.asset(
      //     height: 28,
      //     width: 28,
      //     fit: BoxFit.fitHeight,
      //     mailIcon,
      //     color: Colors.white,
      //   ),
      //   activeIcon: WebsafeSvg.asset(
      //     height: 28,
      //     width: 28,
      //     fit: BoxFit.fitHeight,
      //     mailActiveIcon,
      //     color: AppConstants.secondaryColor,
      //   ),
      //   page: ChatHomePage(
      //     currentUserNo: widget.phoneNumber,
      //     prefs: widget.prefs,
      //     doc: widget.doc,
      //   ),
      //   // const MessageConsumerPage(),
      // ),
      //Proile
      _BottomNavBarItem(
        title: '',
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.black45,
            shape: BoxShape.circle,
          ),
          child: WebsafeSvg.asset(
            height: 28,
            width: 28,
            fit: BoxFit.fitHeight,
            profileIcon,
            color: Colors.white,
          ),
        ),
        activeIcon: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.black45,
            shape: BoxShape.circle,
          ),
          child: WebsafeSvg.asset(
            height: 28,
            width: 28,
            fit: BoxFit.fitHeight,
            profileActiveIcon,
            color: AppConstants.secondaryColor,
          ),
        ),
        page: const ProfileNested(),
      ),
    ];

    return userBanned
        ? const UserIsBannedPage()
        : isUserAdded.when(
            loading: () => Center(
              child: NoItemFoundWidget(text: LocaleKeys.noCardFound.tr()),
            ),
            error: (e, _) => const ErrorPage(),
            data: (data) {
              final userRef = ref.watch(userProfileFutureProvider);
              ref.watch(filteredOtherUsersProvider).value;
              return data
                  ? userRef.value != null
                      ? PopScope(
                          canPop: false,
                          child: Scaffold(
                              body: SizedBox(
                                  height: height,
                                  width: width,
                                  child: Responsive.isMobile(context)
                                      ? Stack(
                                          alignment: Alignment.bottomCenter,
                                          children: [
                                              Container(
                                                height: 1,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Opacity(
                                                  opacity: 0,
                                                  child: PreloadPage(
                                                    currentUserNo: userRef
                                                        .value!.phoneNumber,
                                                    prefs: widget.prefs,
                                                    doc: widget.doc,
                                                  ),
                                                ),
                                              ),
                                              PageTransitionSwitcher(
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                transitionBuilder: (child,
                                                        primaryAnimation,
                                                        secondaryAnimation) =>
                                                    FadeThroughTransition(
                                                  fillColor: Theme.of(context)
                                                      .scaffoldBackgroundColor,
                                                  animation: primaryAnimation,
                                                  secondaryAnimation:
                                                      secondaryAnimation,
                                                  child: child,
                                                ),
                                                child:
                                                    navItems[_currentIndex ?? 0]
                                                        .page,
                                              ),
                                              Container(
                                                // height: 50,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topLeft: Radius.circular(0),
                                                    topRight:
                                                        Radius.circular(0),
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.05),
                                                      blurRadius: 10,
                                                      spreadRadius: 2,
                                                      offset:
                                                          const Offset(0, -5),
                                                    ),
                                                  ],
                                                  color: (_currentIndex == 0 ||
                                                          _currentIndex == 3)
                                                      ? Colors.black
                                                      : Teme.isDarktheme(prefs!)
                                                          ? AppConstants
                                                              .backgroundColorDark
                                                          : AppConstants
                                                              .backgroundColor,
                                                ),
                                                child: BottomNavigationBar(
                                                  showSelectedLabels:
                                                      false, // <-- HERE
                                                  showUnselectedLabels:
                                                      false, // <-- AND HERE
                                                  unselectedLabelStyle:
                                                      const TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                  selectedLabelStyle:
                                                      const TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  elevation: 0,
                                                  type: BottomNavigationBarType
                                                      .fixed,
                                                  currentIndex:
                                                      _currentIndex ?? 0,
                                                  unselectedItemColor:
                                                      Colors.grey,
                                                  selectedItemColor:
                                                      AppConstants.primaryColor,
                                                  onTap: (index) async {
                                                    setState(() {
                                                      ref.invalidate(
                                                          arrangementProviderExtend);
                                                      ref.invalidate(
                                                          arrangementProvider);
                                                      _currentIndex = index;
                                                      updateCurrentIndex(
                                                          ref, index);
                                                    });
                                                  },
                                                  items: navItems.map((e) {
                                                    return BottomNavigationBarItem(
                                                      icon: navItems
                                                                  .indexOf(e) ==
                                                              3
                                                          ? MessageConsumerBottomNavIcon(
                                                              icon: e.icon)
                                                          : e.icon,
                                                      label: e.title,
                                                      activeIcon: navItems
                                                                  .indexOf(e) ==
                                                              3
                                                          ? MessageConsumerBottomNavIcon(
                                                              icon:
                                                                  e.activeIcon)
                                                          : e.activeIcon,
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                              battleInvite.when(
                                                  data: (snapshot) {
                                                    if (snapshot!
                                                        .docs.isEmpty) {
                                                      return const SizedBox();
                                                    } else {
                                                      final battleInvite =
                                                          snapshot.docs.first
                                                              .data();
                                                      return Align(
                                                        alignment:
                                                            Alignment.topCenter,
                                                        child: Visibility(
                                                          visible: battleInvite
                                                                      .status ==
                                                                  "pending"
                                                              ? true
                                                              : false,
                                                          child: Container(
                                                            height: 150,
                                                            width: width * .8,
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(20),
                                                            decoration:
                                                                BoxDecoration(
                                                                    color: Teme.isDarktheme(
                                                                            prefs!)
                                                                        ? AppConstants
                                                                            .backgroundColorDark
                                                                        : AppConstants
                                                                            .backgroundColor,
                                                                    borderRadius:
                                                                        const BorderRadius
                                                                            .all(
                                                                      Radius.circular(
                                                                          AppConstants
                                                                              .defaultNumericValue),
                                                                    )),
                                                            child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                      "${battleInvite.userProfile!.userName} has invited you to battle!"),
                                                                  const Spacer(),
                                                                  Row(
                                                                      children: [
                                                                        Expanded(
                                                                            child:
                                                                                ElevatedButton(
                                                                          onPressed:
                                                                              () async {
                                                                            Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                builder: (c) => BroadCastScreen(isHost: false, isCoHost: true, registrationUser: battleInvite.userProfile, guestUser: userRef.value, agoraToken: battleInvite.userProfile!.agoraToken, channelId: battleInvite.channelId, channelName: battleInvite.userProfile!.phoneNumber, goalModel: battleInvite.goalModel),
                                                                              ),
                                                                            );
                                                                            await acceptLiveBattle(
                                                                                inviteId: userRef.value!.phoneNumber,
                                                                                context: context);
                                                                          },
                                                                          child: Text(LocaleKeys
                                                                              .acpt
                                                                              .tr()),
                                                                        )),
                                                                        const SizedBox(
                                                                          width:
                                                                              10,
                                                                        ),
                                                                        Expanded(
                                                                            child:
                                                                                ElevatedButton(
                                                                          onPressed:
                                                                              () async {
                                                                            Navigator.pop(context);
                                                                          },
                                                                          child: Text(LocaleKeys
                                                                              .rjt
                                                                              .tr()),
                                                                        ))
                                                                      ])
                                                                ]),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  error: (e, _) =>
                                                      const SizedBox(),
                                                  loading: () =>
                                                      const SizedBox()),
                                            ])
                                      : Row(
                                          children: [
                                            SizedBox(
                                                height: height,
                                                width: width * .25,
                                                child: Column(children: [
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.all(
                                                      AppConstants
                                                              .defaultNumericValue /
                                                          2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(
                                                                  0.05),
                                                          blurRadius: 10,
                                                          spreadRadius: 2,
                                                          offset: const Offset(
                                                              0, -5),
                                                        ),
                                                      ],
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                        Radius.circular(AppConstants
                                                            .defaultNumericValue),
                                                      ),
                                                      // gradient:
                                                      //     const LinearGradient(
                                                      //   colors: [
                                                      //     AppConstants
                                                      //         .primaryColor,
                                                      //     AppConstants
                                                      //         .primaryColor2
                                                      //   ],
                                                      //   begin:
                                                      //       Alignment.topLeft,
                                                      //   end: Alignment
                                                      //       .bottomRight,
                                                      // ),
                                                      // color: (_currentIndex ==
                                                      //             0 ||
                                                      //         _currentIndex ==
                                                      //             2)
                                                      //     ? Colors.black
                                                      //     : Teme.isDarktheme(
                                                      //             prefs!)
                                                      //         ? AppConstants
                                                      //             .backgroundColorDark
                                                      //         : AppConstants
                                                      //             .backgroundColor,
                                                      color: AppConstants
                                                          .primaryColor,
                                                    ),
                                                    child: BottomNavigationBar(
                                                      showSelectedLabels:
                                                          false, // <-- HERE
                                                      showUnselectedLabels:
                                                          false, // <-- AND HERE
                                                      unselectedLabelStyle:
                                                          const TextStyle(
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                      selectedLabelStyle:
                                                          const TextStyle(
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      elevation: 0,
                                                      type:
                                                          BottomNavigationBarType
                                                              .fixed,
                                                      currentIndex:
                                                          _currentIndex ?? 0,
                                                      unselectedItemColor:
                                                          Colors.white,
                                                      selectedItemColor:
                                                          AppConstants
                                                              .primaryColor,
                                                      onTap: (index) async {
                                                        ref.invalidate(
                                                            arrangementProvider);
                                                        setState(() {
                                                          ref.invalidate(
                                                              arrangementProviderExtend);
                                                          ref.invalidate(
                                                              arrangementProvider);
                                                          _currentIndex = index;
                                                          Future.delayed(
                                                              const Duration(
                                                                  milliseconds:
                                                                      100), () {
                                                            updateCurrentIndex(
                                                                ref, index);
                                                          });
                                                        });
                                                      },
                                                      items:
                                                          navItemsWeb.map((e) {
                                                        return BottomNavigationBarItem(
                                                          icon: e.icon,
                                                          label: e.title,
                                                          activeIcon:
                                                              e.activeIcon,
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  TabBar(
                                                    controller: _tabController,
                                                    tabAlignment:
                                                        TabAlignment.center,
                                                    dividerColor:
                                                        Colors.transparent,
                                                    indicatorColor:
                                                        Colors.transparent,
                                                    isScrollable: true,
                                                    splashFactory:
                                                        NoSplash.splashFactory,
                                                    overlayColor:
                                                        WidgetStateProperty
                                                            .resolveWith<
                                                                Color?>(
                                                      (Set<WidgetState>
                                                          states) {
                                                        return states.contains(
                                                                WidgetState
                                                                    .focused)
                                                            ? null
                                                            : Colors
                                                                .transparent;
                                                      },
                                                    ),
                                                    onTap: (index) {
                                                      setState(() {
                                                        _currentIndexTabs =
                                                            index;
                                                      });
                                                    },
                                                    tabs: [
                                                      Tab(
                                                        height: 30,
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 5,
                                                                  horizontal:
                                                                      10),
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30),
                                                              color: _currentIndexTabs ==
                                                                      1
                                                                  ? Colors
                                                                      .transparent
                                                                  : AppConstants
                                                                      .primaryColor
                                                                      .withOpacity(
                                                                          .5)),
                                                          child: Align(
                                                            alignment: Alignment
                                                                .center,
                                                            child: Text(
                                                                LocaleKeys.msges
                                                                    .tr(),
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .titleSmall!
                                                                    .copyWith(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color: _currentIndexTabs ==
                                                                                0
                                                                            ? Colors.white
                                                                            : Teme.isDarktheme(widget.prefs)
                                                                                ? Colors.white
                                                                                : Colors.black)),
                                                          ),
                                                        ),
                                                      ),
                                                      Tab(
                                                        height: 30,
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 5,
                                                                  horizontal:
                                                                      10),
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30),
                                                              color: _currentIndexTabs ==
                                                                      0
                                                                  ? Colors
                                                                      .transparent
                                                                  : AppConstants
                                                                      .primaryColor
                                                                      .withOpacity(
                                                                          .5)),
                                                          child: Align(
                                                            alignment: Alignment
                                                                .center,
                                                            child: Text(
                                                                LocaleKeys
                                                                    .matches
                                                                    .tr(),
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .titleSmall!
                                                                    .copyWith(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color: _currentIndexTabs ==
                                                                                1
                                                                            ? Colors.white
                                                                            : Teme.isDarktheme(widget.prefs)
                                                                                ? Colors.white
                                                                                : Colors.black)),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Expanded(
                                                    child: TabBarView(
                                                      controller:
                                                          _tabController,
                                                      children: [
                                                        Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .all(
                                                            AppConstants
                                                                    .defaultNumericValue /
                                                                2,
                                                          ),
                                                          child: ChatHomePage(
                                                            currentUserNo: widget
                                                                .phoneNumber,
                                                            prefs: widget.prefs,
                                                            doc: widget.doc,
                                                          ),
                                                        ),
                                                        Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .all(
                                                            AppConstants
                                                                    .defaultNumericValue /
                                                                2,
                                                          ),
                                                          child:
                                                              const MatchesConsumerPage(
                                                                  isHome: true),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ])),
                                            // const Spacer(),
                                            // const SizedBox(
                                            //   width: AppConstants
                                            //       .defaultNumericValue,
                                            // ),
                                            Expanded(
                                              child: Container(
                                                  padding: const EdgeInsets.all(
                                                    AppConstants
                                                            .defaultNumericValue /
                                                        2,
                                                  ),
                                                  margin: const EdgeInsets.all(
                                                      AppConstants
                                                              .defaultNumericValue /
                                                          2),
                                                  decoration: BoxDecoration(
                                                    color: !Teme.isDarktheme(
                                                            widget.prefs)
                                                        ? AppConstants
                                                            .primaryColor
                                                            .withOpacity(.1)
                                                        : AppConstants.textColor
                                                            .withOpacity(.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      AppConstants
                                                          .defaultNumericValue,
                                                    ),
                                                  ),
                                                  height: height,
                                                  // width: width * .25,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      if (newIndex != 10)
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            topLeft: const Radius
                                                                .circular(
                                                                AppConstants
                                                                        .defaultNumericValue /
                                                                    2),
                                                            bottomLeft: const Radius
                                                                .circular(
                                                                AppConstants
                                                                        .defaultNumericValue /
                                                                    2),
                                                            topRight: Radius.circular(
                                                                (arrangemennt !=
                                                                            null ||
                                                                        arrangementExtend !=
                                                                            null)
                                                                    ? 0
                                                                    : AppConstants
                                                                        .defaultNumericValue),
                                                            bottomRight: Radius.circular(
                                                                (arrangemennt !=
                                                                            null ||
                                                                        arrangementExtend !=
                                                                            null)
                                                                    ? 0
                                                                    : AppConstants
                                                                        .defaultNumericValue),
                                                          ),
                                                          child: PageTransitionSwitcher(
                                                              duration: const Duration(milliseconds: 300),
                                                              transitionBuilder: (child, primaryAnimation, secondaryAnimation) => FadeThroughTransition(
                                                                    fillColor: Theme.of(
                                                                            context)
                                                                        .scaffoldBackgroundColor,
                                                                    animation:
                                                                        primaryAnimation,
                                                                    secondaryAnimation:
                                                                        secondaryAnimation,
                                                                    child:
                                                                        child,
                                                                  ),
                                                              child: ClipRRect(
                                                                  borderRadius: BorderRadius.only(
                                                                    topLeft: const Radius
                                                                        .circular(
                                                                        AppConstants.defaultNumericValue /
                                                                            2),
                                                                    bottomLeft: const Radius
                                                                        .circular(
                                                                        AppConstants.defaultNumericValue /
                                                                            2),
                                                                    topRight: Radius.circular((arrangemennt !=
                                                                                null ||
                                                                            arrangementExtend !=
                                                                                null)
                                                                        ? 0
                                                                        : AppConstants
                                                                            .defaultNumericValue),
                                                                    bottomRight: Radius.circular((arrangemennt !=
                                                                                null ||
                                                                            arrangementExtend !=
                                                                                null)
                                                                        ? 0
                                                                        : AppConstants
                                                                            .defaultNumericValue),
                                                                  ),
                                                                  child: SizedBox(
                                                                      width: width * .25,
                                                                      child: AnimatedContainer(
                                                                        duration:
                                                                            const Duration(milliseconds: 500),
                                                                        curve: Curves
                                                                            .easeInOut,
                                                                        width: _currentIndex ==
                                                                                newIndex
                                                                            ? width *
                                                                                .25
                                                                            : 0,
                                                                        child: navItemsWeb[newIndex].page.redacted(
                                                                            context:
                                                                                context,
                                                                            redact:
                                                                                true),
                                                                      )))
                                                              // : Expanded(
                                                              //     child:
                                                              //         ClipRRect(
                                                              //             borderRadius: BorderRadius
                                                              //                 .only(
                                                              //               topLeft:
                                                              //                   const Radius.circular(AppConstants.defaultNumericValue),
                                                              //               bottomLeft:
                                                              //                   const Radius.circular(AppConstants.defaultNumericValue),
                                                              //               topRight: Radius.circular((arrangemennt != null || arrangementExtend != null)
                                                              //                   ? 0
                                                              //                   : AppConstants.defaultNumericValue),
                                                              //               bottomRight: Radius.circular((arrangemennt != null || arrangementExtend != null)
                                                              //                   ? 0
                                                              //                   : AppConstants.defaultNumericValue),
                                                              //             ),
                                                              //             child:
                                                              //                 navItemsWeb[newIndex].page))
                                                              ),
                                                        ),
                                                      AnimatedContainer(
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    500),
                                                        curve: Curves.easeInOut,
                                                        width:
                                                            arrangemennt != null
                                                                ? width * .25
                                                                : 0,
                                                        child: SizedBox(
                                                            // width:
                                                            //     arrangemennt !=
                                                            //             null
                                                            //         ? width *
                                                            //             .25
                                                            //         : 0,
                                                            child: ClipRRect(
                                                                borderRadius: BorderRadius.horizontal(
                                                                    left: Radius.circular((newIndex ==
                                                                            10
                                                                        ? AppConstants.defaultNumericValue /
                                                                            2
                                                                        : 0)),
                                                                    right: Radius.circular((arrangementExtend !=
                                                                            null)
                                                                        ? 0
                                                                        : AppConstants.defaultNumericValue /
                                                                            2)),
                                                                child:
                                                                    arrangemennt)),
                                                      ),
                                                      Expanded(
                                                        child:
                                                            AnimatedContainer(
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      500),
                                                          curve:
                                                              Curves.easeInOut,
                                                          width:
                                                              arrangementExtend !=
                                                                      null
                                                                  ? double
                                                                      .infinity
                                                                  : 0,
                                                          child: SizedBox(
                                                              child: ClipRRect(
                                                                  borderRadius: const BorderRadius
                                                                      .horizontal(
                                                                      right: Radius.circular(
                                                                          AppConstants.defaultNumericValue /
                                                                              2)),
                                                                  child:
                                                                      arrangementExtend)),
                                                        ),
                                                      ),
                                                      // if (arrangementExtend !=
                                                      //     null)
                                                      //   Expanded(
                                                      //     child: SizedBox(
                                                      //         // width: width * .25,
                                                      //         child: ClipRRect(
                                                      //             borderRadius: const BorderRadius
                                                      //                 .horizontal(
                                                      //                 right: Radius.circular(
                                                      //                     AppConstants.defaultNumericValue /
                                                      //                         2)),
                                                      //             child:
                                                      //                 arrangementExtend)),
                                                      //   ),
                                                    ],
                                                  )),
                                            ),
                                            const SizedBox(
                                              width: AppConstants
                                                  .defaultNumericValue,
                                            ),
                                          ],
                                        ))),
                        )
                      : Center(
                          child: NoItemFoundWidget(
                              text: LocaleKeys.noCardFound.tr()),
                        )
                  : FirstTimeUserProfilePage(prefs: widget.prefs);
            },
          );
  }
}

class _BottomNavBarItem {
  final String title;
  final Widget icon;
  final Widget activeIcon;
  final Widget page;
  // final SharedPreferences? prefs;
  _BottomNavBarItem({
    required this.title,
    required this.icon,
    required this.activeIcon,
    required this.page,
  });
}

class MessageConsumerBottomNavIcon extends ConsumerWidget {
  final Widget icon;
  const MessageConsumerBottomNavIcon({
    Key? key,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchStream = ref.watch(matchStreamProvider);

    return matchStream.when(
      data: (data) {
        // final List<MessageViewModel> messages = [];

        // messages.addAll(getAllMessages(ref, data));
        int unreadCount = 0;
        // for (var e in messages) {
        //   unreadCount += e.unreadCount;
        // }

        return MessageIcon(unreadCount: unreadCount, icon: icon);
      },
      error: (_, __) => MessageIcon(unreadCount: 0, icon: icon),
      loading: () => MessageIcon(unreadCount: 0, icon: icon),
    );
  }
}

class MessageIcon extends StatelessWidget {
  final int unreadCount;
  final Widget icon;
  const MessageIcon({
    Key? key,
    required this.unreadCount,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        icon,
        if (unreadCount > 0)
          Positioned(
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor,
                borderRadius: BorderRadius.circular(6),
              ),
              constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
              child: Center(
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 7,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
