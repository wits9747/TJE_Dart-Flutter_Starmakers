// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers, prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localstorage/localstorage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lamatdating/helpers/constants.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/utils/open_settings.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/utils/utils.dart';

class LocalUserData {
  final lastUpdated, userType;
  final Int8List? photoBytes;
  final String id, name, photoURL, aboutUser;
  final List<dynamic> idVariants;

  LocalUserData({
    required this.id,
    required this.idVariants,
    required this.userType,
    required this.aboutUser,
    required this.lastUpdated,
    required this.name,
    required this.photoURL,
    this.photoBytes,
  });

  factory LocalUserData.fromJson(Map<String, dynamic> jsonData) {
    return LocalUserData(
      id: jsonData['id'],
      aboutUser: jsonData['about'],
      idVariants: jsonData['idVars'],
      name: jsonData['name'],
      photoURL: jsonData['url'],
      photoBytes: jsonData['bytes'],
      userType: jsonData['type'],
      lastUpdated: jsonData['time'],
    );
  }

  Map<String, dynamic> toMapp(LocalUserData user) {
    return {
      'id': user.id,
      'about': user.aboutUser,
      'idVars': user.idVariants,
      'name': user.name,
      'url': user.photoURL,
      'bytes': user.photoBytes,
      'type': user.userType,
      'time': user.lastUpdated,
    };
  }

  static Map<String, dynamic> toMap(LocalUserData user) => {
        'id': user.id,
        'about': user.aboutUser,
        'idVars': user.idVariants,
        'name': user.name,
        'url': user.photoURL,
        'bytes': user.photoBytes,
        'type': user.userType,
        'time': user.lastUpdated,
      };

  static String encode(List<LocalUserData> users) => json.encode(
        users
            .map<Map<String, dynamic>>((user) => LocalUserData.toMap(user))
            .toList(),
      );

  static List<LocalUserData> decode(String users) =>
      (json.decode(users) as List<dynamic>)
          .map<LocalUserData>((item) => LocalUserData.fromJson(item))
          .toList();
}

// final smartContactProvider = StateNotifierProvider<
//     SmartContactProviderWithLocalStoreData, List<LocalUserData>>((ref) {
//   return SmartContactProviderWithLocalStoreData();
// });

// final smartContactProviderFamily = StateNotifierProvider.family<SmartContactProviderWithLocalStoreData, List<LocalUserData>, String>((ref, id) {
//   return SmartContactProviderWithLocalStoreData(id);
// });

final smartContactProvider =
    Provider<SmartContactProviderWithLocalStoreData>((ref) {
  return SmartContactProviderWithLocalStoreData();
});

class SmartContactProviderWithLocalStoreData {
  int daysToUpdateCache = 7;
  var usersDocsRefinServer =
      FirebaseFirestore.instance.collection(DbPaths.collectionusers);
  List<LocalUserData> localUsersLIST = [];
  String localUsersSTRING = "";

  addORUpdateLocalUserDataMANUALLY(
      {required SharedPreferences prefs,
      required LocalUserData localUserData,
      required bool isNotifyListener}) {
    int ind =
        localUsersLIST.indexWhere((element) => element.id == localUserData.id);
    if (ind >= 0) {
      if (localUsersLIST[ind].name.toString() !=
              localUserData.name.toString() ||
          localUsersLIST[ind].photoURL.toString() !=
              localUserData.photoURL.toString()) {
        localUsersLIST.removeAt(ind);
        localUsersLIST.insert(ind, localUserData);
        localUsersLIST.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        if (isNotifyListener == true) {}
        saveFetchedLocalUsersInPrefs(prefs);
      }
    } else {
      localUsersLIST.add(localUserData);
      localUsersLIST
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      if (isNotifyListener == true) {}
      saveFetchedLocalUsersInPrefs(prefs);
    }
  }

  Future<LocalUserData?> fetchUserDataFromnLocalOrServer(
      SharedPreferences prefs, String phoneNumber) async {
    int ind = localUsersLIST.indexWhere((element) => element.id == phoneNumber);
    if (ind >= 0) {
      // print("LOADED ${localUsersLIST[ind].id} LOCALLY ");
      LocalUserData localUser = localUsersLIST[ind];
      if (DateTime.now()
              .difference(
                  DateTime.fromMillisecondsSinceEpoch(localUser.lastUpdated))
              .inDays >
          daysToUpdateCache) {
        DocumentSnapshot<Map<String, dynamic>> doc =
            await usersDocsRefinServer.doc(localUser.id).get();
        if (doc.exists) {
          var updatedUserData = LocalUserData(
              aboutUser: doc.data()![Dbkeys.aboutMe] ?? "",
              idVariants:
                  doc.data()![Dbkeys.phonenumbervariants] ?? [phoneNumber],
              id: localUser.id,
              userType: 0,
              lastUpdated: DateTime.now().millisecondsSinceEpoch,
              name: doc.data()![Dbkeys.nickname],
              photoURL: doc.data()![Dbkeys.photoUrl] ?? "");
          // print("UPDATED ${localUser.id} LOCALLY AFTER EXPIRED");
          addORUpdateLocalUserDataMANUALLY(
              prefs: prefs,
              isNotifyListener: false,
              localUserData: updatedUserData);
          return Future.value(updatedUserData);
        } else {
          return Future.value(localUser);
        }
      } else {
        return Future.value(localUser);
      }
    } else {
      DocumentSnapshot<Map<String, dynamic>> doc =
          await usersDocsRefinServer.doc(phoneNumber).get();
      if (doc.exists) {
        // print("LOADED ${doc.data()![Dbkeys.phone]} SERVER ");
        var updatedUserData = LocalUserData(
            aboutUser: doc.data()![Dbkeys.aboutMe] ?? "",
            idVariants:
                doc.data()![Dbkeys.phonenumbervariants] ?? [phoneNumber],
            id: doc.data()![Dbkeys.phone],
            userType: 0,
            lastUpdated: DateTime.now().millisecondsSinceEpoch,
            name: doc.data()![Dbkeys.nickname],
            photoURL: doc.data()![Dbkeys.photoUrl] ?? "");

        addORUpdateLocalUserDataMANUALLY(
            prefs: prefs,
            isNotifyListener: false,
            localUserData: updatedUserData);
        return Future.value(updatedUserData);
      } else {
        return Future.value(null);
      }
    }
  }

  fetchFromFiretsoreAndReturnData(SharedPreferences prefs, String phoneNumber,
      Function(DocumentSnapshot<Map<String, dynamic>> doc) onReturnData) async {
    var doc = await usersDocsRefinServer.doc(phoneNumber).get();
    if (doc.exists && doc.data() != null) {
      onReturnData(doc);
      addORUpdateLocalUserDataMANUALLY(
          isNotifyListener: true,
          prefs: prefs,
          localUserData: LocalUserData(
              id: phoneNumber,
              idVariants: doc.data()![Dbkeys.phonenumbervariants],
              userType: 0,
              aboutUser: doc.data()![Dbkeys.aboutMe],
              lastUpdated: DateTime.now().millisecondsSinceEpoch,
              name: doc.data()![Dbkeys.nickname],
              photoURL: doc.data()![Dbkeys.photoUrl] ?? ""));
    }
  }

  Future<bool?> fetchLocalUsersFromPrefs(SharedPreferences prefs) async {
    localUsersSTRING = prefs.getString('localUsersSTRING') ?? "";

    if (localUsersSTRING != "") {
      localUsersLIST = LocalUserData.decode(localUsersSTRING);
      localUsersLIST
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      return true;
    } else {
      return true;
    }
  }

  saveFetchedLocalUsersInPrefs(SharedPreferences prefs) async {
    if (searchingcontactsindatabase == false) {
      localUsersSTRING = LocalUserData.encode(localUsersLIST);
      await prefs.setString('localUsersSTRING', localUsersSTRING);
    }
  }

  //********---DEVICE CONTACT FETCH STARTS BELOW::::::::-----

  List<DeviceContactIdAndName> previouslyFetchedKEYPhoneInSharedPrefs = [];
  List<DeviceContactIdAndName> alreadyJoinedSavedUsersPhoneNameAsInServer = [];

//-------
  Map<String?, String?>? contactsBookContactList = <String, String>{};
  bool searchingcontactsindatabase = true;
  List<dynamic> currentUserPhoneNumberVariants = [];

  getContactsIfAgreed(BuildContext context, DataModel? model,
      String currentuserphone, SharedPreferences prefs, bool isForceFetch,
      {List<dynamic>? currentuserphoneNumberVariants}) async {
    if (currentuserphoneNumberVariants != null) {
      currentUserPhoneNumberVariants = currentuserphoneNumberVariants;
    }
    if (!kIsWeb) {
      await getContactsFromDevice(context, model, prefs).then((value) async {
        final List<DeviceContactIdAndName> decodedPhoneStrings =
            prefs.getString('availablePhoneString') == null ||
                    prefs.getString('availablePhoneString') == ''
                ? []
                : DeviceContactIdAndName.decode(
                    prefs.getString('availablePhoneString')!);
        final List<DeviceContactIdAndName> decodedPhoneAndNameStrings =
            prefs.getString('availablePhoneAndNameString') == null ||
                    prefs.getString('availablePhoneAndNameString') == ''
                ? []
                : DeviceContactIdAndName.decode(
                    prefs.getString('availablePhoneAndNameString')!);
        previouslyFetchedKEYPhoneInSharedPrefs = decodedPhoneStrings;
        alreadyJoinedSavedUsersPhoneNameAsInServer = decodedPhoneAndNameStrings;

        var a = alreadyJoinedSavedUsersPhoneNameAsInServer;
        var b = previouslyFetchedKEYPhoneInSharedPrefs;

        alreadyJoinedSavedUsersPhoneNameAsInServer = a;
        previouslyFetchedKEYPhoneInSharedPrefs = b;

        await fetchLocalUsersFromPrefs(prefs).then((b) async {
          if (b == true) {
            await searchAvailableContactsInDb(
                context, currentuserphone, prefs, isForceFetch);
          }
        });
      });
    }
  }

  fetchContacts(BuildContext context, DataModel? model, String currentuserphone,
      SharedPreferences prefs, bool isForceFetch,
      {List<dynamic>? currentuserphoneNumberVariants,
      bool? isRequestAgain = false}) async {
    if (prefs.getBool('allowed-contacts') == null || isRequestAgain == true) {
      showDialog(
          context: context,
          builder: (context) {
            double width = MediaQuery.of(context).size.width;
            return PopScope(
              canPop: false,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Dialog(
                  insetPadding: EdgeInsets.symmetric(horizontal: width * .15),
                  backgroundColor: Colors.transparent,
                  child: AspectRatio(
                    aspectRatio: 1 / 1.2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Teme.isDarktheme(prefs)
                            ? AppConstants.backgroundColorDark
                            : AppConstants.backgroundColor,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(22)),
                      ),
                      child: Column(
                        children: [
                          const Spacer(),
                          AppRes.appLogo != null
                              ? Image.network(
                                  AppRes.appLogo!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.contain,
                                )
                              : Image.asset(
                                  AppConstants.logo,
                                  color: AppConstants.primaryColor,
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.contain,
                                ),
                          // WebsafeSvg.asset(
                          //   logoIcon,
                          //   height: 90,
                          //   width: 90,
                          //   fit: BoxFit.contain,
                          // ),
                          const Spacer(),
                          const Divider(),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.all(13.0),
                            child: Text(
                              "Do you allow?",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  height: 1.3,
                                  color: Teme.isDarktheme(prefs)
                                      ? AppConstants.textColor
                                      : const Color(0xFF594F62)),
                            ),
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.all(13.0),
                            child: Text(
                              "Allow $Appname to fetch contact list to make recommendations to people you can follow and connect with.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  height: 1.3,
                                  color: Teme.isDarktheme(prefs)
                                      ? AppConstants.textColor
                                      : const Color(0xFF594F62)),
                            ),
                          ),
                          const Spacer(),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: InkWell(
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  overlayColor: WidgetStateProperty.all(
                                      Colors.transparent),
                                  onTap: () async {
                                    await prefs.setBool(
                                        'allowed-contacts', false);
                                    Navigator.of(context).pop();
                                    searchingcontactsindatabase = false;
                                  },
                                  child: Container(
                                    height: 55,
                                    decoration: const BoxDecoration(
                                      color: AppConstants.secondaryColor,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(20),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'no'.tr(),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.none,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  overlayColor: WidgetStateProperty.all(
                                      Colors.transparent),
                                  onTap: () async {
                                    await prefs.setBool(
                                        'allowed-contacts', true);
                                    Navigator.pop(context);
                                    await getContactsIfAgreed(context, model,
                                        currentuserphone, prefs, isForceFetch,
                                        currentuserphoneNumberVariants:
                                            currentuserphoneNumberVariants);
                                  },
                                  child: Container(
                                    height: 55,
                                    decoration: const BoxDecoration(
                                      color: AppConstants.primaryColor,
                                      borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(20)),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'yes'.tr(),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.none,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          barrierDismissible: true);
    } else if (prefs.getBool('allowed-contacts') == false) {
      setIsLoading(false);
    } else if (prefs.getBool('allowed-contacts') == true) {
      await getContactsIfAgreed(
          context, model, currentuserphone, prefs, isForceFetch,
          currentuserphoneNumberVariants: currentuserphoneNumberVariants);
    } else {}
  }

  setIsLoading(bool val) {
    searchingcontactsindatabase = val;
  }

  Future<Map<String?, String?>> getContactsFromDevice(
      BuildContext context, DataModel? model, SharedPreferences prefs,
      {bool refresh = false}) async {
    Completer<Map<String?, String?>> completer =
        Completer<Map<String?, String?>>();

    LocalStorage storage = LocalStorage(Dbkeys.cachedContacts);

    Map<String?, String?> _cachedContacts = {};

    completer.future.then((c) {
      c.removeWhere((key, val) => _isHidden(key, model));

      contactsBookContactList = c;
      if (contactsBookContactList!.isEmpty) {
        searchingcontactsindatabase = false;
      }
    });

    Lamat.checkAndRequestPermission(Permission.contacts).then((res) {
      if (res) {
        storage.ready.then((ready) async {
          if (ready) {
            String? getNormalizedNumber(String? number) {
              if (number == null) return null;
              return number.replaceAll(RegExp('[^0-9+]'), '');
            }

            ContactsService.getContacts(withThumbnails: false)
                .then((Iterable<Contact> contacts) async {
              for (Contact p in contacts.where((c) => c.phones!.isNotEmpty)) {
                if (p.displayName != null && p.phones!.isNotEmpty) {
                  List<String?> numbers = p.phones!
                      .map((number) {
                        String? _phone = getNormalizedNumber(number.value);

                        return _phone;
                      })
                      .toList()
                      .where((s) => s != null)
                      .toList();
                  for (var number in numbers) {
                    _cachedContacts[number] = p.displayName;
                  }
                }
              }

              completer.complete(_cachedContacts);
            });
          }
          // }
        });
      } else {
        Lamat.showRationale(
          "Permission to access contacts is needed to connect with people you know.",
        );
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OpenSettings(
                      permtype: 'contact',
                      prefs: prefs,
                    )));
      }
    }).catchError((onError) {
      Lamat.showRationale('Error occured: $onError');
    });

    return completer.future;
  }

  String? getNormalizedNumber(String number) {
    if (number.isEmpty) {
      return null;
    }

    return number.replaceAll(RegExp('[^0-9+]'), '');
  }

  _isHidden(String? phoneNo, DataModel? model) {
    return false;
  }

  Future<List<QueryDocumentSnapshot>?> getUsersUsingChunks(
      List<String> chunks) async {
    QuerySnapshot result = await FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .where(Dbkeys.phonenumbervariants, arrayContainsAny: chunks)
        .get();
    if (result.docs.isNotEmpty) {
      return result.docs;
    } else {
      return null;
    }
  }

  searchAvailableContactsInDb(
    BuildContext context,
    String currentuserphone,
    SharedPreferences existingPrefs,
    bool isForceFetch,
  ) async {
    if (existingPrefs.getString('lastTimeCheckedContactBookSavedCopy') ==
            contactsBookContactList.toString() &&
        isForceFetch == false) {
      searchingcontactsindatabase = false;
      if (previouslyFetchedKEYPhoneInSharedPrefs.isEmpty ||
          alreadyJoinedSavedUsersPhoneNameAsInServer.isEmpty) {
        final List<DeviceContactIdAndName> decodedPhoneStrings =
            existingPrefs.getString('availablePhoneString') == null ||
                    existingPrefs.getString('availablePhoneString') == ''
                ? []
                : DeviceContactIdAndName.decode(
                    existingPrefs.getString('availablePhoneString')!);
        final List<DeviceContactIdAndName> decodedPhoneAndNameStrings =
            existingPrefs.getString('availablePhoneAndNameString') == null ||
                    existingPrefs.getString('availablePhoneAndNameString') == ''
                ? []
                : DeviceContactIdAndName.decode(
                    existingPrefs.getString('availablePhoneAndNameString')!);
        previouslyFetchedKEYPhoneInSharedPrefs = decodedPhoneStrings;
        alreadyJoinedSavedUsersPhoneNameAsInServer = decodedPhoneAndNameStrings;
      }
    } else {
      List<String> myArray = contactsBookContactList!.entries
          .toList()
          .map((e) => e.key.toString())
          .toList();
      List<List<String>> chunkList = Lamat.divideIntoChuncks(myArray, 10);

      List<List<List<String>>> chunkgroups =
          Lamat.divideIntoChuncksGroup(chunkList, ContactsSearchCountBatchSize);

      for (var chunks in chunkgroups) {
        var futureGroup = FutureGroup();

        for (var chunk in chunks) {
          futureGroup.add(getUsersUsingChunks(chunk));
        }
        futureGroup.close();
        var p = await futureGroup.future;
        for (var batch in p) {
          if (batch != null) {
            for (QueryDocumentSnapshot<Map<String, dynamic>> registeredUser
                in batch) {
              if (registeredUser.data().containsKey(Dbkeys.joinedOn)) {
                if (alreadyJoinedSavedUsersPhoneNameAsInServer.indexWhere(
                            (element) =>
                                element.phone == registeredUser[Dbkeys.phone]) <
                        0 &&
                    registeredUser[Dbkeys.phone] != currentuserphone) {
                  for (var phone in registeredUser
                      .data()[Dbkeys.phonenumbervariants]
                      .toList()) {
                    previouslyFetchedKEYPhoneInSharedPrefs
                        .add(DeviceContactIdAndName(phone: phone ?? ''));
                  }

                  alreadyJoinedSavedUsersPhoneNameAsInServer.add(
                      DeviceContactIdAndName(
                          phone: registeredUser.data()[Dbkeys.phone] ?? '',
                          name: registeredUser.data()[Dbkeys.phone]));
                  // print('INSERTED $key IN LOCAL USER DATA LIST');
                  addORUpdateLocalUserDataMANUALLY(
                      prefs: existingPrefs,
                      localUserData: LocalUserData(
                          aboutUser:
                              registeredUser.data()[Dbkeys.aboutMe] ?? "",
                          id: registeredUser.data()[Dbkeys.phone],
                          idVariants:
                              registeredUser.data()[Dbkeys.phonenumbervariants],
                          userType: 0,
                          lastUpdated: DateTime.now().millisecondsSinceEpoch,
                          name: registeredUser.data()[Dbkeys.nickname],
                          photoURL:
                              registeredUser.data()[Dbkeys.photoUrl] ?? ""),
                      isNotifyListener: true);
                }
              } else {}
            }
          }
        }
      }
      int i = alreadyJoinedSavedUsersPhoneNameAsInServer
          .indexWhere((element) => element.phone == currentuserphone);
      if (i >= 0) {
        alreadyJoinedSavedUsersPhoneNameAsInServer.removeAt(i);
        previouslyFetchedKEYPhoneInSharedPrefs.removeAt(i);
      }
      finishLoadingTasks(context, existingPrefs, currentuserphone,
          "24. SEARCHING STOPPED as users search completed in database.");
    }
  }

  finishLoadingTasks(BuildContext context, SharedPreferences existingPrefs,
      String currentuserphone, String printStatement,
      {bool isrealyfinish = true}) async {
    if (isrealyfinish == true) {
      searchingcontactsindatabase = false;
    }

    final String encodedavailablePhoneString =
        DeviceContactIdAndName.encode(previouslyFetchedKEYPhoneInSharedPrefs);
    await existingPrefs.setString(
        'availablePhoneString', encodedavailablePhoneString);

    final String encodedalreadyJoinedSavedUsersPhoneNameAsInServer =
        DeviceContactIdAndName.encode(
            alreadyJoinedSavedUsersPhoneNameAsInServer);
    await existingPrefs.setString('availablePhoneAndNameString',
        encodedalreadyJoinedSavedUsersPhoneNameAsInServer);

    if (isrealyfinish == true) {
      await existingPrefs.setString('lastTimeCheckedContactBookSavedCopy',
          contactsBookContactList.toString());
    }
  }

  String getUserNameOrIdQuickly(String phoneNumber) {
    if (localUsersLIST.indexWhere((element) => element.id == phoneNumber) >=
        0) {
      return localUsersLIST[
              localUsersLIST.indexWhere((element) => element.id == phoneNumber)]
          .name;
    } else {
      return 'User';
    }
  }
}

class DeviceContactIdAndName {
  final String phone;
  final String? name;

  DeviceContactIdAndName({
    required this.phone,
    this.name,
  });

  factory DeviceContactIdAndName.fromJson(Map<String, dynamic> jsonData) {
    return DeviceContactIdAndName(
      phone: jsonData['id'],
      name: jsonData['name'],
    );
  }

  static Map<String, dynamic> toMap(DeviceContactIdAndName contact) => {
        'id': contact.phone,
        'name': contact.name,
      };

  static String encode(List<DeviceContactIdAndName> contacts) => json.encode(
        contacts
            .map<Map<String, dynamic>>(
                (contact) => DeviceContactIdAndName.toMap(contact))
            .toList(),
      );

  static List<DeviceContactIdAndName> decode(String contacts) =>
      (json.decode(contacts) as List<dynamic>)
          .map<DeviceContactIdAndName>(
              (item) => DeviceContactIdAndName.fromJson(item))
          .toList();
}
