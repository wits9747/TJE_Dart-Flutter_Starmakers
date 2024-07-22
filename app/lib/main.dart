// ignore_for_file: unused_field, no_leading_underscores_for_local_identifiers, deprecated_member_use, unused_local_variable, use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_translate/components/google_translate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lamatdating/firebase_options.dart';
import 'package:lamatdating/helpers/config_loading.dart';
import 'package:lamatdating/helpers/constants.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/key_res.dart';
import 'package:lamatdating/helpers/session_manager.dart';
import 'package:lamatdating/models/user_interaction_model.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/app_settings_provider.dart';
import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/providers/broadcast_provider.dart';
import 'package:lamatdating/providers/group_chat_provider.dart';
import 'package:lamatdating/providers/user_profile_provider.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/animated_splash/splash_anim.dart';
import 'package:lamatdating/views/auth/login_page.dart';
import 'package:lamatdating/views/loading_error/error_page.dart';
import 'package:lamatdating/views/tabs/bottom_nav_bar_page.dart';
import 'package:lamatdating/views/tabs/chat/chat_home.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (message.data['title'] == 'Call Ended' ||
      message.data['title'] == 'Missed Call') {
    flutterLocalNotificationsPlugin.cancelAll();
    final data = message.data;
    final titleMultilang = data['titleMultilang'];
    final bodyMultilang = data['bodyMultilang'];

    await showNotificationWithDefaultSound(
        'Missed Call', 'You have Missed a Call', titleMultilang, bodyMultilang);
  } else {
    if (message.data['title'] == 'You have message(s)' ||
        message.data['title'] == 'message in Group') {
      //-- need not to do anythig for these message type as it will be automatically popped up.
    } else if (message.data['title'] == 'Incoming Audio Call...' ||
        message.data['title'] == 'Incoming Video Call...') {
      final data = message.data;
      final title = data['title'];
      final body = data['body'];
      final titleMultilang = data['titleMultilang'];
      final bodyMultilang = data['bodyMultilang'];

      await showNotificationWithDefaultSound(
          title, body, titleMultilang, bodyMultilang);
    }
  }

  return Future<void>.value();
}

DocumentSnapshot<Map<String, dynamic>>? docu;

SessionManager sessionManager = SessionManager();

final FirebaseGroupServices firebaseGroupServices = FirebaseGroupServices();
final FirebaseBroadcastServices firebaseBroadcastServices =
    FirebaseBroadcastServices();

// final Future<FirebaseApp> _initialization = Firebase.initializeApp();

// final initializationProvider = FutureProvider<FirebaseApp>((ref) async {
//   return _initialization;
// });

final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

final broadcastsListProvider = StreamProvider<List<BroadcastModel>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).value;
  final phone = prefs?.getString(Dbkeys.phone) ?? '';
  return firebaseBroadcastServices.getBroadcastsList(phone);
});

final groupsListProvider = StreamProvider<List<GroupModel>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).value;
  final phone = prefs?.getString(Dbkeys.phone) ?? '';
  return firebaseGroupServices.getGroupsList(phone);
});

final channelsListProvider = StreamProvider<List<GroupModel>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).value;
  final phone = prefs?.getString(Dbkeys.phone) ?? '';
  return firebaseGroupServices.getChannelsList(phone);
});

final allChannelsListProvider = StreamProvider<List<GroupModel>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).value;
  final phone = prefs?.getString(Dbkeys.phone) ?? '';
  return firebaseGroupServices.getAllChannelsList(phone);
});

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  final WidgetsBinding binds = WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();

  binds.renderView.automaticSystemUiAdjustment = false;

  FlutterNativeSplash.preserve(widgetsBinding: binds);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // final PendingDynamicLinkData? initialLink =
  //     await FirebaseDynamicLinks.instance.getInitialLink();

  await FirebaseAppCheck.instance.activate(
    // You can also use a `ReCaptchaEnterpriseProvider` provider instance as an
    // argument for `webProvider`
    webProvider:
        ReCaptchaV3Provider('6LdnvOwpAAAAAAL_8JOhedHmiDPBtRpKG_u72IQB'),
    // Default provider for Android is the Play Integrity provider. You can use the "AndroidProvider" enum to choose
    // your preferred provider. Choose from:
    // 1. Debug provider
    // 2. Safety Net provider
    // 3. Play Integrity provider
    androidProvider: AndroidProvider.debug,
    // Default provider for iOS/macOS is the Device Check provider. You can use the "AppleProvider" enum to choose
    // your preferred provider. Choose from:
    // 1. Debug provider
    // 2. Device Check provider
    // 3. App Attest provider
    // 4. App Attest provider with fallback to Device Check provider (App Attest provider is only available on iOS 14.0+, macOS 14.0+)
    appleProvider: AppleProvider.appAttest,
  );
  if (!kIsWeb) {
    await FlutterDownloader.initialize(
      ignoreSsl: true,
    );
  }
  if (!kIsWeb) {
    if (Platform.isAndroid) {
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
    }
  }
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundNotification);
  }

  GoogleTranslate.initialize(
    apiKey: GoogleTransalteAPIkey,
    sourceLanguage: "",
    targetLanguage: "",
  );

  if (IsBannerAdShow == true && kIsWeb == false ||
      IsInterstitialAdShow == true && kIsWeb == false ||
      IsVideoAdShow == true && kIsWeb == false ||
      isAdmobAvailable == true && kIsWeb == false) {
    MobileAds.instance.initialize();
  }

  await Hive.initFlutter();
  await Hive.openBox(HiveConstants.hiveBox);

  Stripe.publishableKey = Stripe_PublishableKey;

  await dotenv.load(fileName: 'assets/.env');

  configLoading(
    isDarkMode: false,
    foregroundColor: AppConstants.primaryColor,
    backgroundColor: Colors.white,
  );
  await sessionManager.initPref();
  String? languageCode = sessionManager.getString(KeyRes.languageCode);
  if (languageCode == "" || languageCode == " ") {
    AppRes.selectedLanguage = "en";
  } else {
    AppRes.selectedLanguage =
        sessionManager.getString(KeyRes.languageCode) ?? "en";
  }
  HttpOverrides.global = MyHttpOverrides();
  FlutterNativeSplash.remove();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(EasyLocalization(
        supportedLocales: const [
          Locale('en'),
          Locale('ar'),
          Locale('da'),
          Locale('de'),
          Locale('el'),
          Locale('es'),
          Locale('fr'),
          Locale('hi'),
          Locale('id'),
          Locale('it'),
          Locale('ja'),
          Locale('ko'),
          Locale('nb'),
          Locale('nl'),
          Locale('pl'),
          Locale('pt'),
          Locale('ru'),
          Locale('th'),
          Locale('tr'),
          Locale('vi'),
          Locale('zh'),
        ],
        path: 'assets/translations',
        fallbackLocale: const Locale('ko'),
        child: const ProviderScope(child: MyApp())));
  });
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MyApp> createState() => MyAppState();

  static MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>();
}

class MyAppState extends ConsumerState<MyApp> {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();
  SharedPreferences? prefss;

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
  }

  Box<dynamic>? box;

  @override
  void initState() {
    super.initState();
    getCurrentAppTheme();
    box = Hive.box(HiveConstants.hiveBox);
  }

  @override
  void didChangeDependencies() async {
    final appSettings = ref.watch(appSettingsProvider).value;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final themeChange = ref.read(darkThemeProvider.notifier);
    context.setLocale(Locale(AppRes.selectedLanguage));
    themeChange.darkTheme = Teme.isDarktheme(prefs);
    setState(() {
      prefss = prefs;
    });
    if (appSettings != null && appSettings.primaryColor != null) {
      debugPrint("setting colors in Hive");
      box!.put("primaryColor", appSettings.primaryColor);
      box!.put("primaryDarkColor", appSettings.primaryDarkColor);
      box!.put("secondaryColor", appSettings.secondaryColor);
      box!.put("secondaryDarkColor", appSettings.secondaryDarkColor);
      box!.put("tintColor", appSettings.tintColor);
      box!.put("appLogo", appSettings.appLogo);
      debugPrint("setting colors in AppRes");
      AppRes.primaryColor = appSettings.primaryColor;
      AppRes.primaryDarkColor = appSettings.primaryDarkColor;
      AppRes.secondaryColor = appSettings.secondaryColor;
      AppRes.secondaryDarkColor = appSettings.secondaryDarkColor;
      AppRes.tintColor = appSettings.tintColor;
      AppRes.appLogo = appSettings.appLogo;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(sharedPreferencesProvider).value;
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
      statusBarBrightness: Brightness.light, // For iOS (dark icons)
    ));
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    final darkTheme = ref.watch(darkThemeProvider);

    return OKToast(
      child: MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        title: Appname,
        debugShowCheckedModeBanner: false,
        builder: EasyLoading.init(),
        theme: Styles.themeData(darkTheme == true ? true : false, context),
        home: SelectionArea(child: SplashScreen(prefs: prefs)),
      ),
    );
  }
}

class SplashScreen extends ConsumerStatefulWidget {
  final SharedPreferences? prefs;
  const SplashScreen({Key? key, this.prefs}) : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  // @override
  // void initState() {
  //   Future.delayed(const Duration(seconds: 5), () {
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => const LandingWidget(),
  //       ),
  //     );
  //   });

  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: SplashAnimPage(
      canSkip: true,
      prefs: widget.prefs!,
    ));
  }
}

class LandingWidget extends ConsumerStatefulWidget {
  const LandingWidget({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<LandingWidget> createState() => _LandingWidgetState();
}

class _LandingWidgetState extends ConsumerState<LandingWidget> {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final fireIns = FirebaseFirestore.instance;
  List<UserProfileModel> oldUsersList = [];
  List<UserInteractionModel> oldInterList = [];
  Box<dynamic>? box;

  @override
  void initState() {
    box = Hive.box(HiveConstants.hiveBox);
    final users = box!.get(HiveConstants.cachedProfiles);
    final interactions = box!.get(HiveConstants.cachedInterationFilter);

    int i = 0;

    if (users != null) {
      for (final doc in users) {
        if (i < 5) {
          final userProfile = UserProfileModel.fromJson(doc);
          oldUsersList.add(userProfile);
          // debugPrint("cachedOtherUser: $userProfile");
          i++;
        } else {
          break;
        }
      }
    }

    if (interactions != null) {
      for (final doc in interactions) {
        final userProfile = UserInteractionModel.fromJson(doc);
        oldInterList.add(userProfile);
        // debugPrint("cachedOtherUser: $userProfile");
      }
    }
    // _setupInteractedMessage();
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      showNotification(message);
    });
    FirebaseMessaging.onMessage.listen((message) {
      showNotification(message);
    });

    super.initState();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> initialise() async {
    return await fireIns.collection("appSettings").doc("userapp").get();
  }

  // Future<void> _setupInteractedMessage() async {
  //   RemoteMessage? initialMessage =
  //       await FirebaseMessaging.instance.getInitialMessage();

  //   if (initialMessage != null) {
  //     _handleMessage(initialMessage);
  //   }

  //   FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  // }

  // void _handleMessage(RemoteMessage message) {
  //   if (message.data['type'] == 'message') {
  //     final otherUserId = message.data["phoneNumber"]!;
  //     final matchId = message.data["matchId"]!;
  //     Navigator.of(context).push(
  //                                     MaterialPageRoute(
  //                                       builder: (context) => PreChat(
  //                                         name: otherUser.fullName,
  //                                         phone: otherUser.phoneNumber,
  //                                         currentUserNo: ref
  //                                             .watch(currentUserStateProvider)!
  //                                             .phoneNumber,
  //                                         model: cachedModel,
  //                                         prefs: prefs!,
  //                                       ),
  //                                     ),
  //                                   );
  //   } else if (message.data['type'] == 'notification') {
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => const NotificationPage(),
  //       ),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final authState = ref.watch(authStateProvider);
    final prefss = ref.watch(sharedPreferencesProvider).value;
    final phone = prefss?.getString(Dbkeys.phone) ?? '';
    final appSettingsSnapshot = ref.watch(appSettingsDocProvider);
    final doc = appSettingsSnapshot.value;
    final isUserAdded = ref.watch(isUserAddedProvider);

    return authState.when(
      data: (data) {
        if (data != null) {
          if (doc == null) {
            return const SplashAnimPage(canSkip: false, prefs: null);
          } else {
            if (prefss == null) {
              return const SplashAnimPage(canSkip: false, prefs: null);
            } else {
              if (data.phoneNumber == "" || data.phoneNumber == null) {
                return PhoneLoginLandingWidget(
                  user: data,
                  isVerifying: true,
                  prefs: prefss,
                  accountApprovalMessage: doc[Dbkeys.accountapprovalmessage],
                  isaccountapprovalbyadminneeded:
                      doc.data()![Dbkeys.isblocknewlogins],
                  isblocknewlogins: doc.data()![Dbkeys.isblocknewlogins],
                  title: LocaleKeys.verifyPhone.tr(),
                  doc: doc,
                );
              } else {
                box = Hive.box(HiveConstants.hiveBox);
                box!.put(Dbkeys.phone, data.phoneNumber!);
                return BottomNavBarPage(
                    user: data,
                    prefs: prefss,
                    doc: doc,
                    phoneNumber: data.phoneNumber!,
                    phone: phone);
              }
            }
          }
        } else {
          if (doc == null) {
            return const SplashAnimPage(canSkip: false, prefs: null);
          } else {
            return LoginPage(
              prefs: prefss!,
              accountApprovalMessage: doc[Dbkeys.accountapprovalmessage],
              isaccountapprovalbyadminneeded:
                  doc.data()![Dbkeys.isblocknewlogins],
              isblocknewlogins: doc.data()![Dbkeys.isblocknewlogins],
              title: 'signIn'.tr(),
              doc: doc,
            );
          }
        }
      },
      error: (_, e) {
        return const ErrorPage();
      },
      loading: () => const SplashAnimPage(canSkip: false, prefs: null),
    );
  }
}

Future<void> _handleBackgroundNotification(RemoteMessage message) async {
  await Firebase.initializeApp();
  showNotification(message);
}

void showNotification(RemoteMessage message) {
  debugPrint("Notification type: ${message.data["type"]}");
  debugPrint("Other User Id ${message.data["phoneNumber"]}");
  debugPrint("MatchId ${message.data["matchId"]}");
}

void logError(String code, String? message) {
  if (message != null) {
    debugPrint('Error: $code\nError Message: $message');
  } else {
    debugPrint('Error: $code');
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
