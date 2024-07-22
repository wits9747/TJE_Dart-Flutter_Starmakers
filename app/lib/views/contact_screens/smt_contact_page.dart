// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/helpers/constants.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/models/e2ee.dart' as e2ee;
import 'package:lamatdating/providers/smart_contact_provider.dart';
import 'package:lamatdating/utils/chat_controller.dart';
import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/crc.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/utils/utils.dart';
import 'package:lamatdating/views/call_history/call_history.dart';
import 'package:lamatdating/views/calling/pickup_layout.dart';
import 'package:lamatdating/views/contact_screens/add_unsaved_contact.dart';
import 'package:lamatdating/views/contact_screens/contacts.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';
import 'package:lamatdating/views/tabs/chat/chat_scr/chat.dart';
import 'package:lamatdating/views/tabs/chat/chat_scr/pre_chat.dart';

class SmartContactsPage extends ConsumerStatefulWidget {
  final String currentUserNo;
  final DataModel model;
  final bool biometricEnabled;
  final SharedPreferences prefs;
  final Function onTapCreateGroup;
  final Function onTapCreateBroadcast;
  const SmartContactsPage({
    Key? key,
    required this.currentUserNo,
    required this.model,
    required this.biometricEnabled,
    required this.onTapCreateBroadcast,
    required this.prefs,
    required this.onTapCreateGroup,
  }) : super(key: key);

  @override
  SmartContactsPageState createState() => SmartContactsPageState();
}

class SmartContactsPageState extends ConsumerState<SmartContactsPage> {
  // Map<String?, String?>? contacts;
  // Map<String?, String?>? _filtered = Map<String, String>();

  // final TextEditingController _filter = TextEditingController();
  final scrollController = ScrollController();
  int inviteContactsCount = 30;
  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollListener);
  }

  FlutterSecureStorage storage = const FlutterSecureStorage();
  String? sharedSecret;
  String? privateKey;

  late encrypt.Encrypter cryptor;
  final iv = encrypt.IV.fromLength(8);
  readLocal() async {
    try {
      privateKey = await storage.read(key: Dbkeys.privateKey);
      sharedSecret = (await const e2ee.X25519().calculateSharedSecret(
              e2ee.Key.fromBase64(privateKey!, false),
              e2ee.Key.fromBase64(
                  widget.model.currentUser![Dbkeys.publicKey], true)))
          .toBase64();
      setState(() {});
    } catch (e) {
      sharedSecret = null;
      setState(() {});
    }
  }

  dynamic encryptWithCRC(String input) {
    try {
      String encrypted = cryptor.encrypt(input, iv: iv).base64;
      int crc = CRC32.compute(input);
      return '$encrypted${Dbkeys.crcSeperator}$crc';
    } catch (e) {
      Lamat.toast(
        'waitingpeer'.tr(),
      );
      return false;
    }
  }

  void scrollListener() {
    if (scrollController.offset >=
            scrollController.position.maxScrollExtent / 2 &&
        !scrollController.position.outOfRange) {
      setStateIfMounted(() {
        inviteContactsCount = inviteContactsCount + 250;
      });
    }
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availableContacts = ref.watch(smartContactProvider);
    // final groupList = ref.watch(groupsListProvider);
    // final observer = ref.watch(observerProvider);
    return PickupLayout(
        prefs: widget.prefs,
        scaffold: Lamat.getNTPWrappedWidget(ScopedModel<DataModel>(
            model: widget.model,
            child: ScopedModelDescendant<DataModel>(
                builder: (context, child, model) {
              return Scaffold(
                  backgroundColor: Teme.isDarktheme(widget.prefs)
                      ? AppConstants.backgroundColorDark
                      : AppConstants.backgroundColor,
                  appBar: AppBar(
                    elevation: 0,
                    titleSpacing: 5,
                    toolbarHeight: MediaQuery.of(context).padding.top + 120,
                    title: Text(
                      'selectsinglecontact'.tr(),
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        color: pickTextColorBasedOnBgColorAdvanced(
                            Teme.isDarktheme(widget.prefs)
                                ? AppConstants.backgroundColorDark
                                : AppConstants.backgroundColor),
                      ),
                    ),
                    leading: Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 0, top: 40, bottom: 40),
                      child: CustomIconButton(
                          padding: const EdgeInsets.all(
                              AppConstants.defaultNumericValue / 1.8),
                          onPressed: () => Navigator.pop(context),
                          color: AppConstants.primaryColor,
                          icon: leftArrowSvg),
                    ),
                    backgroundColor: Teme.isDarktheme(widget.prefs)
                        ? AppConstants.backgroundColorDark
                        : AppConstants.backgroundColor,
                    centerTitle: false,
                    actions: <Widget>[
                      IconButton(
                        icon: const Icon(
                          Icons.sync_rounded,
                          color: AppConstants.primaryColor,
                        ),
                        onPressed: () async {
                          if (widget.prefs.getBool('allowed-contacts') ==
                              true) {
                            Lamat.toast('loading'.tr());
                          }

                          await availableContacts.fetchContacts(
                            context,
                            widget.model,
                            widget.currentUserNo,
                            widget.prefs,
                            true,
                            isRequestAgain:
                                widget.prefs.getBool('allowed-contacts') == true
                                    ? false
                                    : true,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.person_add_rounded,
                          color: AppConstants.primaryColor,
                        ),
                        onPressed: () {
                          if (widget.prefs.getBool('allowed-contacts') ==
                              true) {
                            availableContacts.fetchContacts(
                              context,
                              widget.model,
                              widget.currentUserNo,
                              widget.prefs,
                              false,
                            );
                          }
                          // Lamat.toast(getTranslated(context, "loading"));

                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return AddunsavedNumber(
                                prefs: widget.prefs,
                                model: widget.model,
                                currentUserNo: widget.currentUserNo);
                          }));
                        },
                      ),
                      if (widget.prefs.getBool('allowed-contacts') == true)
                        IconButton(
                          icon: const Icon(
                            CupertinoIcons.search_circle,
                            color: AppConstants.primaryColor,
                          ),
                          onPressed: () {
                            availableContacts.fetchContacts(
                              context,
                              widget.model,
                              widget.currentUserNo,
                              widget.prefs,
                              false,
                            );
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return Contacts(
                                prefs: widget.prefs,
                                model: widget.model,
                                currentUserNo: widget.currentUserNo,
                                biometricEnabled: widget.biometricEnabled,
                              );
                            }));
                          },
                        )
                    ],
                  ),
                  body: availableContacts.searchingcontactsindatabase == true
                      ? loading()
                      : RefreshIndicator(
                          onRefresh:
                              widget.prefs.getBool('allowed-contacts') == true
                                  ? () async {
                                      return availableContacts.fetchContacts(
                                          context,
                                          model,
                                          widget.currentUserNo,
                                          widget.prefs,
                                          true);
                                    }
                                  : () async {},
                          child: availableContacts
                                  .contactsBookContactList!.isEmpty
                              ? ListView(children: [
                                  Padding(
                                      padding: EdgeInsets.only(
                                          top: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              2.5),
                                      child: Center(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text('nocontacts'.tr(),
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  color: lamatGrey,
                                                )),
                                            const SizedBox(
                                              height: 40,
                                            ),
                                            IconButton(
                                                onPressed: () async {
                                                  availableContacts
                                                      .setIsLoading(true);
                                                  await availableContacts
                                                      .fetchContacts(
                                                    context,
                                                    model,
                                                    widget.currentUserNo,
                                                    widget.prefs,
                                                    true,
                                                    isRequestAgain: true,
                                                  )
                                                      .then((d) {
                                                    Future.delayed(
                                                        const Duration(
                                                            milliseconds: 500),
                                                        () {
                                                      availableContacts
                                                          .setIsLoading(false);
                                                    });
                                                  });
                                                  setState(() {});
                                                },
                                                icon: const Icon(
                                                  Icons.refresh_rounded,
                                                  size: 40,
                                                  color: lamatPRIMARYcolor,
                                                ))
                                          ],
                                        ),
                                      ))
                                ])
                              : ListView(
                                  controller: scrollController,
                                  padding:
                                      const EdgeInsets.only(bottom: 15, top: 0),
                                  physics: const BouncingScrollPhysics(),
                                  children: [
                                    ListTile(
                                      tileColor: Teme.isDarktheme(widget.prefs)
                                          ? lamatCONTAINERboxColorDarkMode
                                          : lamatCONTAINERboxColorLightMode,
                                      leading: const CircleAvatar(
                                          backgroundColor: lamatSECONDARYolor,
                                          radius: 22.5,
                                          child: Icon(
                                            Icons.share_rounded,
                                            color: Colors.white,
                                          )),
                                      title: Text(
                                        'share'.tr(),
                                        style: TextStyle(
                                          color: pickTextColorBasedOnBgColorAdvanced(Teme
                                                  .isDarktheme(widget.prefs)
                                              ? lamatCONTAINERboxColorDarkMode
                                              : lamatCONTAINERboxColorLightMode),
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 22.0, vertical: 11.0),
                                      onTap: () {
                                        Lamat.invite(context, ref);
                                      },
                                    ),
                                    ListTile(
                                      tileColor: Teme.isDarktheme(widget.prefs)
                                          ? lamatCONTAINERboxColorDarkMode
                                          : lamatCONTAINERboxColorLightMode,
                                      leading: const CircleAvatar(
                                          backgroundColor: lamatSECONDARYolor,
                                          radius: 22.5,
                                          child: Icon(
                                            Icons.group,
                                            color: Colors.white,
                                          )),
                                      title: Text(
                                        'newgroup'.tr(),
                                        style: TextStyle(
                                          color: pickTextColorBasedOnBgColorAdvanced(Teme
                                                  .isDarktheme(widget.prefs)
                                              ? lamatCONTAINERboxColorDarkMode
                                              : lamatCONTAINERboxColorLightMode),
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 22.0, vertical: 11.0),
                                      onTap: () {
                                        widget.onTapCreateGroup();
                                      },
                                    ),
                                    ListTile(
                                      tileColor: Teme.isDarktheme(widget.prefs)
                                          ? lamatCONTAINERboxColorDarkMode
                                          : lamatCONTAINERboxColorLightMode,
                                      leading: const CircleAvatar(
                                          backgroundColor: lamatSECONDARYolor,
                                          radius: 22.5,
                                          child: Icon(
                                            Icons.campaign,
                                            color: Colors.white,
                                          )),
                                      title: Text(
                                        'newbroadcast'.tr(),
                                        style: TextStyle(
                                          color: pickTextColorBasedOnBgColorAdvanced(Teme
                                                  .isDarktheme(widget.prefs)
                                              ? lamatCONTAINERboxColorDarkMode
                                              : lamatCONTAINERboxColorLightMode),
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 22.0, vertical: 11.0),
                                      onTap: () {
                                        widget.onTapCreateBroadcast();
                                      },
                                    ),
                                    const SizedBox(
                                      height: 14,
                                    ),
                                    availableContacts
                                            .alreadyJoinedSavedUsersPhoneNameAsInServer
                                            .isEmpty
                                        ? const SizedBox(
                                            height: 0,
                                          )
                                        : ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            padding: const EdgeInsets.all(00),
                                            itemCount: availableContacts
                                                .alreadyJoinedSavedUsersPhoneNameAsInServer
                                                .length,
                                            itemBuilder: (context, idx) {
                                              DeviceContactIdAndName user =
                                                  availableContacts
                                                      .alreadyJoinedSavedUsersPhoneNameAsInServer
                                                      .elementAt(idx);
                                              String phone = user.phone;
                                              String name =
                                                  user.name ?? user.phone;
                                              return FutureBuilder<
                                                  LocalUserData?>(
                                                future: availableContacts
                                                    .fetchUserDataFromnLocalOrServer(
                                                        widget.prefs, phone),
                                                builder: (BuildContext context,
                                                    AsyncSnapshot<
                                                            LocalUserData?>
                                                        snapshot) {
                                                  if (snapshot.hasData &&
                                                      snapshot.data != null) {
                                                    return ListTile(
                                                      tileColor: Teme
                                                              .isDarktheme(
                                                                  widget.prefs)
                                                          ? lamatCONTAINERboxColorDarkMode
                                                          : lamatCONTAINERboxColorLightMode,
                                                      leading:
                                                          customCircleAvatar(
                                                              url: snapshot
                                                                  .data!
                                                                  .photoURL,
                                                              radius: 22),
                                                      title: Text(
                                                          snapshot.data!.name,
                                                          style: TextStyle(
                                                            color: pickTextColorBasedOnBgColorAdvanced(Teme
                                                                    .isDarktheme(
                                                                        widget
                                                                            .prefs)
                                                                ? lamatCONTAINERboxColorDarkMode
                                                                : lamatCONTAINERboxColorLightMode),
                                                          )),
                                                      subtitle: Text(phone,
                                                          style: const TextStyle(
                                                              color:
                                                                  lamatGrey)),
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 22.0,
                                                              vertical: 0.0),
                                                      onTap: () {
                                                        hidekeyboard(context);
                                                        dynamic wUser = model
                                                            .userData[phone];
                                                        if (wUser != null &&
                                                            wUser[Dbkeys
                                                                    .chatStatus] !=
                                                                null) {
                                                          if (model.currentUser![
                                                                      Dbkeys
                                                                          .locked] !=
                                                                  null &&
                                                              model
                                                                  .currentUser![
                                                                      Dbkeys
                                                                          .locked]
                                                                  .contains(
                                                                      phone)) {
                                                            ChatController.authenticate(
                                                                model,
                                                                'authneededchat'
                                                                    .tr(),
                                                                prefs: widget
                                                                    .prefs,
                                                                shouldPop:
                                                                    false,
                                                                state: Navigator
                                                                    .of(
                                                                        context),
                                                                type: Lamat
                                                                    .getAuthenticationType(
                                                                        widget
                                                                            .biometricEnabled,
                                                                        model),
                                                                onSuccess: () {
                                                              Navigator.pushAndRemoveUntil(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) => ChatScreen(
                                                                          isSharingIntentForwarded:
                                                                              false,
                                                                          prefs: widget
                                                                              .prefs,
                                                                          model:
                                                                              model,
                                                                          currentUserNo: widget
                                                                              .currentUserNo,
                                                                          peerNo:
                                                                              phone,
                                                                          unread:
                                                                              0)),
                                                                  (Route r) => r
                                                                      .isFirst);
                                                            });
                                                          } else {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) => ChatScreen(
                                                                        isSharingIntentForwarded:
                                                                            false,
                                                                        prefs: widget
                                                                            .prefs,
                                                                        model:
                                                                            model,
                                                                        currentUserNo:
                                                                            widget
                                                                                .currentUserNo,
                                                                        peerNo:
                                                                            phone,
                                                                        unread:
                                                                            0)));
                                                          }
                                                        } else {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) {
                                                            return PreChat(
                                                                prefs: widget
                                                                    .prefs,
                                                                model: widget
                                                                    .model,
                                                                name: name,
                                                                phone: phone,
                                                                currentUserNo:
                                                                    widget
                                                                        .currentUserNo);
                                                          }));
                                                        }
                                                      },
                                                    );
                                                  }
                                                  return ListTile(
                                                    tileColor: Teme.isDarktheme(
                                                            widget.prefs)
                                                        ? lamatCONTAINERboxColorDarkMode
                                                        : lamatCONTAINERboxColorLightMode,
                                                    leading: customCircleAvatar(
                                                        radius: 22),
                                                    title: Text(name,
                                                        style: TextStyle(
                                                          color: pickTextColorBasedOnBgColorAdvanced(Teme
                                                                  .isDarktheme(
                                                                      widget
                                                                          .prefs)
                                                              ? lamatCONTAINERboxColorDarkMode
                                                              : lamatCONTAINERboxColorLightMode),
                                                        )),
                                                    subtitle: Text(phone,
                                                        style: const TextStyle(
                                                            color: lamatGrey)),
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 22.0,
                                                            vertical: 0.0),
                                                    onTap: () {
                                                      hidekeyboard(context);
                                                      dynamic wUser =
                                                          model.userData[phone];
                                                      if (wUser != null &&
                                                          wUser[Dbkeys
                                                                  .chatStatus] !=
                                                              null) {
                                                        if (model.currentUser![
                                                                    Dbkeys
                                                                        .locked] !=
                                                                null &&
                                                            model.currentUser![
                                                                    Dbkeys
                                                                        .locked]
                                                                .contains(
                                                                    phone)) {
                                                          ChatController.authenticate(
                                                              model,
                                                              'authneededchat'
                                                                  .tr(),
                                                              prefs:
                                                                  widget.prefs,
                                                              shouldPop: false,
                                                              state:
                                                                  Navigator.of(
                                                                      context),
                                                              type: Lamat
                                                                  .getAuthenticationType(
                                                                      widget
                                                                          .biometricEnabled,
                                                                      model),
                                                              onSuccess: () {
                                                            Navigator.pushAndRemoveUntil(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) => ChatScreen(
                                                                        isSharingIntentForwarded:
                                                                            false,
                                                                        prefs: widget
                                                                            .prefs,
                                                                        model:
                                                                            model,
                                                                        currentUserNo:
                                                                            widget
                                                                                .currentUserNo,
                                                                        peerNo:
                                                                            phone,
                                                                        unread:
                                                                            0)),
                                                                (Route r) =>
                                                                    r.isFirst);
                                                          });
                                                        } else {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) => ChatScreen(
                                                                      isSharingIntentForwarded:
                                                                          false,
                                                                      prefs: widget
                                                                          .prefs,
                                                                      model:
                                                                          model,
                                                                      currentUserNo:
                                                                          widget
                                                                              .currentUserNo,
                                                                      peerNo:
                                                                          phone,
                                                                      unread:
                                                                          0)));
                                                        }
                                                      } else {
                                                        Navigator.push(context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) {
                                                          return PreChat(
                                                              prefs:
                                                                  widget.prefs,
                                                              model:
                                                                  widget.model,
                                                              name: name,
                                                              phone: phone,
                                                              currentUserNo: widget
                                                                  .currentUserNo);
                                                        }));
                                                      }
                                                    },
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          18, 24, 18, 18),
                                      child: Text(
                                        "${(LocaleKeys.inviteTo).tr()} $Appname",
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      padding: const EdgeInsets.all(0),
                                      itemCount: inviteContactsCount >=
                                              availableContacts
                                                  .contactsBookContactList!
                                                  .length
                                          ? availableContacts
                                              .contactsBookContactList!.length
                                          : inviteContactsCount,
                                      itemBuilder: (context, idx) {
                                        MapEntry user = availableContacts
                                            .contactsBookContactList!.entries
                                            .elementAt(idx);
                                        String phone = user.key;
                                        return availableContacts
                                                    .previouslyFetchedKEYPhoneInSharedPrefs
                                                    .indexWhere((element) =>
                                                        element.phone ==
                                                        phone) >=
                                                0
                                            ? Container(
                                                width: 0,
                                              )
                                            : Stack(
                                                children: [
                                                  ListTile(
                                                    tileColor: Teme.isDarktheme(
                                                            widget.prefs)
                                                        ? lamatCONTAINERboxColorDarkMode
                                                        : lamatCONTAINERboxColorLightMode,
                                                    leading: CircleAvatar(
                                                        backgroundColor:
                                                            lamatPRIMARYcolor,
                                                        radius: 22.5,
                                                        child: Text(
                                                          Lamat.getInitials(
                                                              user.value),
                                                          style: const TextStyle(
                                                              color:
                                                                  lamatWhite),
                                                        )),
                                                    title: Text(user.value,
                                                        style: TextStyle(
                                                          color: pickTextColorBasedOnBgColorAdvanced(Teme
                                                                  .isDarktheme(
                                                                      widget
                                                                          .prefs)
                                                              ? lamatCONTAINERboxColorDarkMode
                                                              : lamatCONTAINERboxColorLightMode),
                                                        )),
                                                    subtitle: Text(phone,
                                                        style: const TextStyle(
                                                            color: lamatGrey)),
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 22.0,
                                                            vertical: 0.0),
                                                    onTap: () {
                                                      hidekeyboard(context);
                                                      Lamat.invite(
                                                          context, ref);
                                                    },
                                                  ),
                                                  Positioned(
                                                    right: 19,
                                                    bottom: 19,
                                                    child: InkWell(
                                                        onTap: () {
                                                          hidekeyboard(context);
                                                          Lamat.invite(
                                                              context, ref);
                                                        },
                                                        child: const Icon(
                                                          Icons.person_add_alt,
                                                          color:
                                                              lamatPRIMARYcolor,
                                                        )),
                                                  )
                                                ],
                                              );
                                      },
                                    ),
                                  ],
                                )));
            }))));
  }

  loading() {
    return const Stack(children: [
      Center(
          child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(lamatSECONDARYolor),
      ))
    ]);
  }
}
