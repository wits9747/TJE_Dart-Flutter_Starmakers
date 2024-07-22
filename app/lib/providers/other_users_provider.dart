import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:lamatdating/helpers/constants.dart';
import 'package:lamatdating/models/user_account_settings_model.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/providers/block_user_provider.dart';
import 'package:lamatdating/providers/subscriptions/is_subscribed_provider.dart';
import 'package:lamatdating/providers/user_profile_provider.dart';

final filteredOtherUsersProvider =
    FutureProvider<List<UserProfileModel>>((ref) async {
  List<UserProfileModel> usersList = [];
  final otherUsers = ref.watch(otherUsersProvider);
  final box = Hive.box(HiveConstants.hiveBox);
  // final lastUpdated = box.get(HiveConstants.lastUpdatedKey);
  // if (lastUpdated != null &&
  //     await box.get(HiveConstants.cachedProfiles) != null &&
  //     await box.get(HiveConstants.cachedProfiles) != [] &&
  //     DateTime.now().difference(lastUpdated) < const Duration(days: 1)) {
  //   usersList.addAll(
  //       await box.get(HiveConstants.cachedProfiles) as List<UserProfileModel>);
  // } else {
  otherUsers.whenData((value) {
    usersList.addAll(value);
  });
  // }

  final myProfileProvider = ref.watch(userProfileFutureProvider);
  final isPremiumUserRef = ref.watch(isPremiumUserProvider);

  List<UserProfileModel> filteredUserList = [];

  myProfileProvider.whenData((value) {
    if (value != null) {
      final UserAccountSettingsModel mySettings =
          value.userAccountSettingsModel;

      for (var user in usersList) {
        bool willBeShown = false;
        bool isBoth = false;

        final userAge = DateTime.now().difference(user.birthDay).inDays ~/ 365;
        final userLocation = user.userAccountSettingsModel.location;
        final userGender = user.gender;

        double distanceBetweenMeAndUser = Geolocator.distanceBetween(
                mySettings.location.latitude,
                mySettings.location.longitude,
                userLocation.latitude,
                userLocation.longitude) /
            1;

        if (mySettings.interestedIn == null) {
          isBoth = true;
        }

        bool isWorldWide = mySettings.distanceInKm == null;

        bool isDistanceOk = isWorldWide ||
            (mySettings.distanceInKm! >= (distanceBetweenMeAndUser / 1000));

        if (userAge >= mySettings.minimumAge &&
            userAge <= mySettings.maximumAge &&
            isDistanceOk) {
          if (isBoth) {
            willBeShown = true;
          } else {
            if (mySettings.interestedIn == userGender) {
              willBeShown = true;
            } else {
              willBeShown = false;
            }
          }
        }

        if (willBeShown) {
          filteredUserList.add(user);
        }
      }
    }
  });

  bool isPremiumUser = false;
  isPremiumUserRef.whenData((value) {
    isPremiumUser = value;
  });

  if (!isPremiumUser) {
    filteredUserList.removeWhere((element) {
      return element.userAccountSettingsModel.showOnlyToPremiumUsers ?? false;
    });
  }
  DateTime? ntpTime;
  Future<void> getNTPTime() async {
    ntpTime = DateTime.now().toUtc();
  }

  await getNTPTime();

  // final currentTime = ntpTime!;

  final userCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.userProfileCollection);

  for (int i = 0; i < filteredUserList.length; i++) {
    final user = filteredUserList[i];
    if (user.isBoosted == true) {
      final boostType = user.boostType;
      final boostedTime = DateTime.fromMillisecondsSinceEpoch(user.boostedOn!);
      Duration boostDuration = ntpTime!.difference(boostedTime);
      if ((boostType == AppRes.daily &&
              boostDuration > const Duration(hours: 24)) ||
          (boostType == AppRes.weekly &&
              boostDuration > const Duration(hours: 168)) ||
          (boostType == AppRes.monthly &&
              boostDuration > const Duration(hours: 720))) {
        final newUserProf = user.copyWith(isBoosted: false);
        filteredUserList[i] = newUserProf;
        await userCollection
            .doc(newUserProf.phoneNumber)
            .set(newUserProf.toMap(), SetOptions(merge: true));
        debugPrint("NewCachedOtherUsersProvider: Boost Expired");
      }
    }
    if (user.isPremium != null) {
      if (user.isPremium == true && user.premiumExpiryDate != null) {
        final premiumExpireTime =
            DateTime.fromMillisecondsSinceEpoch(user.premiumExpiryDate!);
        if (ntpTime!.isAfter(premiumExpireTime)) {
          final newUserProf = user.copyWith(isPremium: false);
          filteredUserList[i] = newUserProf;
          await userCollection
              .doc(newUserProf.phoneNumber)
              .set(newUserProf.toMap(), SetOptions(merge: true));
          debugPrint("NewCachedOtherUsersProvider: Premium Expired");
        }
      }
    }
  }

  filteredUserList.sort((a, b) {
    if (b.isBoosted && !a.isBoosted) return 1;
    if (!b.isBoosted && a.isBoosted) return -1;
    return 0;
  });

  // if (filteredUserList.isNotEmpty) {
  //   prefss!.setString('usersList', filteredUserList.toString());
  // }

  List cachedUsersList = [];
  for (final user in filteredUserList) {
    final doc = user.toJson();
    cachedUsersList.add(doc);
  }
  await box.put(HiveConstants.cachedProfiles, cachedUsersList).then((value) =>
      debugPrint("NewCachedOtherUsersProvider: ${cachedUsersList.length}"));
  await box.put(HiveConstants.lastUpdatedKey, ntpTime);

  return filteredUserList;
});

final allUsersProvider = FutureProvider<List<UserProfileModel>>((ref) async {
  List<UserProfileModel> usersList = [];

  final otherUsers = ref.watch(otherUsersProvider);

  otherUsers.whenData((value) {
    usersList.addAll(value);
  });

  final myProfileProvider = ref.watch(userProfileFutureProvider);
  final isPremiumUserRef = ref.watch(isPremiumUserProvider);

  List<UserProfileModel> filteredUserList = [];

  myProfileProvider.whenData((value) {
    if (value != null) {
      filteredUserList.add(value);
      final UserAccountSettingsModel mySettings =
          value.userAccountSettingsModel;

      for (var user in usersList) {
        bool willBeShown = false;
        bool isBoth = false;

        final userAge = DateTime.now().difference(user.birthDay).inDays ~/ 365;
        final userLocation = user.userAccountSettingsModel.location;
        final userGender = user.gender;

        double distanceBetweenMeAndUser = Geolocator.distanceBetween(
                mySettings.location.latitude,
                mySettings.location.longitude,
                userLocation.latitude,
                userLocation.longitude) /
            1;

        if (mySettings.interestedIn == null) {
          isBoth = true;
        }

        bool isWorldWide = mySettings.distanceInKm == null;

        bool isDistanceOk = isWorldWide ||
            (mySettings.distanceInKm! >= (distanceBetweenMeAndUser / 1000));

        if (userAge >= mySettings.minimumAge &&
            userAge <= mySettings.maximumAge &&
            isDistanceOk) {
          if (isBoth) {
            willBeShown = true;
          } else {
            if (mySettings.interestedIn == userGender) {
              willBeShown = true;
            } else {
              willBeShown = false;
            }
          }
        }

        if (willBeShown) {
          filteredUserList.add(user);
        }
      }
    }
  });

  bool isPremiumUser = false;
  isPremiumUserRef.whenData((value) {
    isPremiumUser = value;
  });

  if (!isPremiumUser) {
    filteredUserList.removeWhere((element) {
      return element.userAccountSettingsModel.showOnlyToPremiumUsers ?? false;
    });
  }

  filteredUserList.sort((a, b) {
    if (b.isBoosted && !a.isBoosted) return 1;
    if (!b.isBoosted && a.isBoosted) return -1;
    return 0;
  });

  return filteredUserList;
});

final otherUserProfileFutureProvider =
    FutureProvider.family<UserProfileModel?, String>((ref, phoneNumber) async {
  final userCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.userProfileCollection);

  // DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
  //     .collection(DbPaths.collectionusers)
  //     .doc(phoneNumber)
  //     .get();

  final docRef = userCollection.doc(phoneNumber);
  final snapshot = await docRef.get();

  return UserProfileModel.fromMap(snapshot.data()!);
});

final closestUsersProvider = Provider<List<ClosestUser>>((ref) {
  List<UserProfileModel> usersList = [];

  final otherUsers = ref.watch(otherUsersProvider);

  otherUsers.whenData((value) {
    usersList.addAll(value);
  });

  final myProfileProvider = ref.watch(userProfileFutureProvider);

  List<ClosestUser> closestUsers = [];

  myProfileProvider.whenData((value) {
    if (value != null) {
      final UserAccountSettingsModel mySettings =
          value.userAccountSettingsModel;

      for (var user in usersList) {
        final userLocation = user.userAccountSettingsModel.location;

        double distanceBetweenMeAndUser = Geolocator.distanceBetween(
                mySettings.location.latitude,
                mySettings.location.longitude,
                userLocation.latitude,
                userLocation.longitude) /
            1;

        closestUsers
            .add(ClosestUser(user: user, distance: distanceBetweenMeAndUser));
      }
    }
  });

  return closestUsers;
});

class ClosestUser {
  UserProfileModel user;
  double distance;
  ClosestUser({
    required this.user,
    required this.distance,
  });
}

class SimilarUser {
  UserProfileModel user;
  double similarity;
  SimilarUser({
    required this.user,
    required this.similarity,
  });
}

// final otherUsersProvider = FutureProvider<List<UserProfileModel>>((ref) async {
//   final allOtherUsers =
//       await getAllOtherUsers(ref.watch(currentUserStateProvider)!.phoneNumber!);

//   final List<String> blockedUsersIds = [];
//   final usersIblocked =
//       await getBlockUsers(ref.watch(currentUserStateProvider)!.phoneNumber!);
//   for (var user in usersIblocked) {
//     blockedUsersIds.add(user.blockedUserId);
//   }
//   final usersWhoBlockedMe = await getUsersWhoBlockedMe(
//       ref.watch(currentUserStateProvider)!.phoneNumber!);
//   for (var user in usersWhoBlockedMe) {
//     blockedUsersIds.add(user.blockedByUserId);
//   }

//   final filteredUsers = allOtherUsers.where((user) {
//     return !blockedUsersIds.contains(user.phoneNumber);
//   }).toList();

//   return filteredUsers;
// });

final otherUsersProvider = FutureProvider<List<UserProfileModel>>((ref) async {
  // final box = Hive.box(HiveConstants.hiveBox);

  // // Check if data is already stored and within 24 hours
  // final lastUpdated = box.get(HiveConstants.lastUpdatedKey);
  // if (lastUpdated != null &&
  //     DateTime.now().difference(lastUpdated) < const Duration(days: 1)) {
  //   // Use data from Hive if it's recent
  //   return box.get(HiveConstants.allOtherUsersKey) as List<UserProfileModel>;
  // } else {
  // Fetch new data if not available or outdated in Hive
  final allOtherUsers =
      await getAllOtherUsers(ref.watch(currentUserStateProvider)!.phoneNumber!);

  final List<String> blockedUsersIds = [];
  final usersIblocked =
      await getBlockUsers(ref.watch(currentUserStateProvider)!.phoneNumber!);
  for (var user in usersIblocked) {
    blockedUsersIds.add(user.blockedUserId);
  }
  final usersWhoBlockedMe = await getUsersWhoBlockedMe(
      ref.watch(currentUserStateProvider)!.phoneNumber!);
  for (var user in usersWhoBlockedMe) {
    blockedUsersIds.add(user.blockedByUserId);
  }

  final filteredUsers = allOtherUsers.where((user) {
    return !blockedUsersIds.contains(user.phoneNumber);
  }).toList();

  // Save the fetched data to Hive
  // await box.put(HiveConstants.allOtherUsersKey, filteredUsers);
  // await box.put(HiveConstants.lastUpdatedKey, DateTime.now());

  return filteredUsers;
}
// }
// keepAlive: true
    );

// final followersProvider = FutureProvider<List<UserProfileModel>>((ref) async {});

final otherUsersWithoutBlockedProvider =
    FutureProvider<List<UserProfileModel>>((ref) async {
  return await getAllOtherUsers(
      ref.watch(currentUserStateProvider)!.phoneNumber!);
});

Future<List<UserProfileModel>> getAllOtherUsers(String currentUserId) async {
  final userCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.userProfileCollection);

  final otherUsers = await userCollection
      .where("phoneNumber", isNotEqualTo: currentUserId)
      .get();

  final allOtherUsers = otherUsers.docs.map((doc) {
    return UserProfileModel.fromMap(doc.data());
  }).toList();

  // if (!AppConfig.userProfileShowWithoutImages) {
  //   debugPrint("Removing users without profile picture");
  //   allOtherUsers.removeWhere((element) {
  //     bool isNotProfilePicture =
  //         element.profilePicture == null || element.profilePicture!.isEmpty;
  //     bool isOtherPicturesEmpty = element.mediaFiles.isEmpty;

  //     // debugPrint("isNotProfilePicture: $isNotProfilePicture");
  //     // debugPrint("isOtherOicturesEmpty: $isOtherPicturesEmpty");

  //     return isNotProfilePicture || isOtherPicturesEmpty;
  //   });
  // }

  debugPrint("AllOtherUsers: ${allOtherUsers.length}");

  return allOtherUsers;
}
