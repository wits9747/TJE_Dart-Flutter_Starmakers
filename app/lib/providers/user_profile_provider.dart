import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:lamatdating/helpers/constants.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/providers/nude_detector.dart';
import 'package:shared_preferences/shared_preferences.dart';

// final userProfileFutureProvider =
//     FutureProvider<UserProfileModel?>((ref) async {
//   final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
//   final userCollection = FirebaseFirestore.instance
//       .collection(FirebaseConstants.userProfileCollection);

//   // DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
//   //     .collection(DbPaths.collectionusers)
//   //     .doc(phoneNumber)
//   //     .get();

//   final docRef = userCollection.doc(phoneNumber);
//   final snapshot = await docRef.get();

//   final userProf = UserProfileModel.fromMap(snapshot.data()!);

//   final box = Hive.box(HiveConstants.hiveBox);
//   box.put(HiveConstants.currentUserProf, userProf.toJson());

//   return userProf;
// });

final userProfileFutureProvider =
    FutureProvider<UserProfileModel?>((ref) async {
  final box = Hive.box(HiveConstants.hiveBox);

  // // Check if data is already stored and within 24 hours
  // final lastUpdated = box.get(HiveConstants.lastUserProfileUpdatedKey);
  // if (lastUpdated != null &&
  //     DateTime.now().difference(lastUpdated) < const Duration(days: 1)) {
  //   // Use data from Hive if it's recent
  //   return UserProfileModel.fromJson(box.get(HiveConstants.currentUserProf));
  // }

  // Fetch new data if not available or outdated in Hive
  final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
  final userCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.userProfileCollection);
  final docRef = userCollection.doc(phoneNumber);
  final snapshot = await docRef.get();

  if (!snapshot.exists) {
    return null; // Handle case where user profile doesn't exist
  }

  final userProf = UserProfileModel.fromMap(snapshot.data()!);

  // Save data to Hive
  await box.put(HiveConstants.currentUserProf, userProf.toJson());
  debugPrint("User Profile =======> SET: ${userProf.toJson()}");
  await box.put(HiveConstants.lastUserProfileUpdatedKey, DateTime.now());

  return userProf;
});

final userProfileNotifier = Provider<UserProfileNotifier>((ref) {
  return UserProfileNotifier();
});

class UserProfileNotifier {
  final _userCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.userProfileCollection);
  List<String> mediaURLs = [];
  String? imageUrl;

  Future<bool> createUserProfile(
      UserProfileModel userProfileModel, SharedPreferences prefs) async {
    try {
      UserProfileModel? newUserProfile;
      debugPrint('User Number: ${userProfileModel.phoneNumber}');

      if (userProfileModel.profilePicture != null) {
        if (Uri.parse(userProfileModel.profilePicture!).isAbsolute) {
          newUserProfile = userProfileModel;
        } else {
          await _uploadProfilePicture(
              userProfileModel.profilePicture!, userProfileModel.phoneNumber);
          newUserProfile = userProfileModel.copyWith(profilePicture: imageUrl);
        }
      } else {
        newUserProfile = userProfileModel;
      }

      // List<String> mediaURLs = [];
      for (var media in userProfileModel.mediaFiles) {
        if (Uri.parse(media).isAbsolute) {
          mediaURLs.add(media);
        } else if (media == "") {
          debugPrint("Media is empty");
        } else {
          await _uploadUserMediaFiles(media, userProfileModel.phoneNumber);
        }
      }

      final anotherNewUserProfile =
          newUserProfile.copyWith(mediaFiles: mediaURLs);
      if (anotherNewUserProfile.profilePicture != null &&
          anotherNewUserProfile.profilePicture != "") {
        await _userCollection
            .doc(anotherNewUserProfile.phoneNumber)
            .set(anotherNewUserProfile.toMap(), SetOptions(merge: true));
        return true;
      } else {
        EasyLoading.showError("Profile picture is required!");
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateUserProfile(UserProfileModel userProfileModel) async {
    try {
      UserProfileModel newUserProfile = userProfileModel;

      if (userProfileModel.profilePicture != null) {
        if (Uri.parse(userProfileModel.profilePicture!).isAbsolute) {
          newUserProfile = userProfileModel;
        } else {
          await _uploadProfilePicture(
              userProfileModel.profilePicture!, userProfileModel.phoneNumber);
          newUserProfile = userProfileModel.copyWith(profilePicture: imageUrl);
        }
      }

      for (var media in userProfileModel.mediaFiles) {
        if (Uri.parse(media).isAbsolute) {
          mediaURLs.add(media);
        } else if (media == "") {
          debugPrint("Media is empty");
        } else {
          await _uploadUserMediaFiles(media, userProfileModel.phoneNumber);
        }
      }

      final anotherNewUserProfile =
          newUserProfile.copyWith(mediaFiles: mediaURLs);
      debugPrint("User Profile =======> UPDATE: ${mediaURLs.length}");
      if (anotherNewUserProfile.profilePicture != null &&
          anotherNewUserProfile.profilePicture != "") {
        await _userCollection
            .doc(anotherNewUserProfile.phoneNumber)
            .update(anotherNewUserProfile.toMap());
        return true;
      } else {
        EasyLoading.showError("Profile picture is required!");
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<String?> _uploadProfilePicture(
      String imagePath, String phoneNumber) async {
    final storageRef = FirebaseStorage.instance.ref();

    final imageRef = storageRef.child("user_profile_pictures/$phoneNumber");

    final uploadTask = imageRef.putFile(File(imagePath));

    await detectNudity(imagePath).then((value) async {
      if (value == false) {
        await uploadTask.whenComplete(() async {
          imageUrl = await imageRef.getDownloadURL();
        });
        return imageUrl;
      } else {
        EasyLoading.showError("Nudity/Violence detected, try different image!");
        return null;
      }
    });
    return null;
  }

  Future<String?> _uploadUserMediaFiles(String path, String phoneNumber) async {
    final storageRef = FirebaseStorage.instance.ref();

    final imageRef = storageRef
        .child("user_media_files/$phoneNumber/${path.split("/").last}");
    final uploadTask = imageRef.putFile(File(path));

    // String? imageUrl;
    await detectNudity(path).then((value) async {
      if (value == false) {
        await uploadTask.whenComplete(() async {
          final imageUrl = await imageRef.getDownloadURL();
          mediaURLs.add(imageUrl);
          debugPrint("Media URL Uploaded: $imageUrl");
          return imageUrl;
        });
        // return imageUrl;
      } else {
        EasyLoading.showError("Nudity/Violence detected, try different image!");
        return null;
      }
    });
    return null;
  }

  //Update Online Status
  Future<void> updateOnlineStatus({
    required bool isOnline,
    required String phoneNumber,
  }) async {
    await _userCollection.doc(phoneNumber).update({"isOnline": isOnline});
  }

  Future<void> updateAgoraToken({
    required String? agoraToken,
    required String phoneNumber,
  }) async {
    await _userCollection.doc(phoneNumber).update({"agoraToken": agoraToken});
  }

  Future<void> saveFavouriteMusic({
    required String? soundId,
    required String phoneNumber,
  }) async {
    final doc = await _userCollection.doc(phoneNumber).get();
    final favSongs = List<String>.from(doc.data()?['favSongs'] ?? []);

    if (favSongs.contains(soundId)) {
      // If the soundId is already in favSongs, remove it
      await _userCollection.doc(phoneNumber).update({
        "favSongs": FieldValue.arrayRemove([soundId])
      });
    } else {
      // If the soundId is not in favSongs, add it
      await _userCollection.doc(phoneNumber).update({
        "favSongs": FieldValue.arrayUnion([soundId])
      });
    }
  }

  Future<void> saveFavouriteTeels({required String? id, ref}) async {
    final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
    final doc = await _userCollection.doc(phoneNumber).get();
    final favSongs = List<String>.from(doc.data()?['favTeels'] ?? []);

    if (favSongs.contains(id)) {
      // If the soundId is already in favSongs, remove it
      await _userCollection.doc(phoneNumber).update({
        "favTeels": FieldValue.arrayRemove([id])
      });
    } else {
      // If the soundId is not in favSongs, add it
      await _userCollection.doc(phoneNumber).update({
        "favTeels": FieldValue.arrayUnion([id])
      });
    }
  }

  // Stream<List<String>> getFollowers({required String? phoneNumber}) async* {
  //   await for (var snapshot in _userCollection.doc(phoneNumber).snapshots()) {
  //     yield List<String>.from(snapshot.data()?['followers'] ?? []);
  //   }
  // }

  Future<List<UserProfileModel>> myFollowing(WidgetRef ref) async {
    final box = Hive.box(HiveConstants.hiveBox);
    final userProfileRef = await box.get(HiveConstants.currentUserProf);
    final userProfile = UserProfileModel.fromJson(userProfileRef);
    final numbersList = userProfile.following;
    final myFollowersList = <UserProfileModel>[];
    if (numbersList != null) {
      for (var number in numbersList) {
        final docUser = await _userCollection.doc(number).get();
        final user = UserProfileModel.fromMap(docUser.data()!);
        myFollowersList.add(user);
      }
    }

    return myFollowersList;
  }

  Future<List<UserProfileModel>> myFollowers(WidgetRef ref) async {
    final box = Hive.box(HiveConstants.hiveBox);
    final userProfileRef = await box.get(HiveConstants.currentUserProf);
    final userProfile = UserProfileModel.fromJson(userProfileRef);
    final numbersList = userProfile.followers;
    final myFollowersList = <UserProfileModel>[];
    if (numbersList != null) {
      for (var number in numbersList) {
        final docUser = await _userCollection.doc(number).get();
        final user = UserProfileModel.fromMap(docUser.data()!);
        myFollowersList.add(user);
      }
    }

    return myFollowersList;
  }

  Future<void> followUnfollow({required String? followUser, ref}) async {
    final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
    final doc = await _userCollection.doc(phoneNumber).get();
    final docUser = await _userCollection.doc(followUser).get();
    final follow = List<String>.from(docUser.data()?['followers'] ?? []);
    final following = List<String>.from(doc.data()?['following'] ?? []);

    if (follow.contains(phoneNumber)) {
      await _userCollection.doc(followUser).update({
        "followers": FieldValue.arrayRemove([phoneNumber])
      });
    } else {
      await _userCollection.doc(followUser).update({
        "followers": FieldValue.arrayUnion([phoneNumber])
      });
    }
    if (following.contains(followUser)) {
      await _userCollection.doc(phoneNumber).update({
        "following": FieldValue.arrayRemove([followUser])
      });
    } else {
      await _userCollection.doc(phoneNumber).update({
        "following": FieldValue.arrayUnion([followUser])
      });
    }
  }

  Future<List<String>> getFavouriteMusic({
    required String phoneNumber,
  }) async {
    final userDoc = await _userCollection.doc(phoneNumber).get();
    final favSongsIds = List<String>.from(userDoc.data()?['favSongs'] ?? []);
    return favSongsIds;
  }
}

final isUserAddedProvider = FutureProvider<bool>((ref) async {
  final userCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.userProfileCollection);
  final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
  bool isUserAdded = false;
  await userCollection
      .where("phoneNumber", isEqualTo: phoneNumber)
      .get()
      .then((event) {
    if (event.docs.isNotEmpty) {
      final box = Hive.box(HiveConstants.hiveBox);
      box.put(HiveConstants.userSet, true);
      isUserAdded = true;
    }
  });
  return isUserAdded;
});
