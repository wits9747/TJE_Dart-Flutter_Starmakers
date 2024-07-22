import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';

import 'package:lamatdating/helpers/constants.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/auth_providers.dart';

final userProfileFutureProvider =
    FutureProvider<UserProfileModel?>((ref) async {
  final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
  final userCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.userProfileCollection);

  // DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
  //     .collection(DbPaths.collectionusers)
  //     .doc(phoneNumber)
  //     .get();

  final docRef = userCollection.doc(phoneNumber);
  final snapshot = await docRef.get();

  final userProf = UserProfileModel.fromMap(snapshot.data()!);

  final box = Hive.box(HiveConstants.hiveBox);
  await box.put(HiveConstants.currentUserProf, userProf.toJson());
  debugPrint("User Profile =======> SET: ${userProf.toJson()}");

  return userProf;
});

final userProfileNotifier = Provider<UserProfileNotifier>((ref) {
  return UserProfileNotifier();
});

class UserProfileNotifier {
  final _userCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.userProfileCollection);

  Future<bool> createUserProfile(UserProfileModel userProfileModel) async {
    try {
      UserProfileModel? newUserProfile;

      // if (userProfileModel.profilePicture != null) {
      //   if (Uri.parse(userProfileModel.profilePicture!).isAbsolute) {
      //     newUserProfile = userProfileModel;
      //   }
      //   // else {
      //   //   final profileURL = await _uploadProfilePicture(
      //   //       userProfileModel.profilePicture!, userProfileModel.phoneNumber);
      //   //   newUserProfile =
      //   //       userProfileModel.copyWith(profilePicture: profileURL);
      //   // }
      // } else {
      newUserProfile = userProfileModel;
      // }

      // List<String> mediaURLs = [];
      // for (var media in userProfileModel.mediaFiles) {
      //   if (Uri.parse(media).isAbsolute) {
      //     mediaURLs.add(media);
      //   } else if (media == "") {
      //     debugPrint("Media is empty");
      //   } else {
      //     final mediaURL =
      //         await _uploadUserMediaFiles(media, userProfileModel.phoneNumber);
      //     if (mediaURL != null) {
      //       mediaURLs.add(mediaURL);
      //     }
      //   }
      // }

      // final anotherNewUserProfile =
      //     newUserProfile!.copyWith(mediaFiles: mediaURLs);

      await _userCollection
          .doc(newUserProfile.phoneNumber)
          .set(newUserProfile.toMap(), SetOptions(merge: true));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateUserProfile(UserProfileModel userProfileModel) async {
    try {
      UserProfileModel newUserProfile = userProfileModel;

      // if (userProfileModel.profilePicture != null) {
      //   if (Uri.parse(userProfileModel.profilePicture!).isAbsolute) {
      //     newUserProfile = userProfileModel;
      //   } else if (userProfileModel.profilePicture == "") {
      //     newUserProfile = userProfileModel.copyWith(profilePicture: "");
      //   } else {
      //     final profileURL = await _uploadProfilePicture(
      //         userProfileModel.profilePicture!, userProfileModel.phoneNumber);
      //     newUserProfile =
      //         userProfileModel.copyWith(profilePicture: profileURL);
      //   }
      // }

      // List<String> mediaURLs = [];
      // for (var media in userProfileModel.mediaFiles) {
      //   if (Uri.parse(media).isAbsolute) {
      //     mediaURLs.add(media);
      //   } else if (media == "") {
      //     debugPrint("Media is empty");
      //   } else {
      //     final mediaURL =
      //         await _uploadUserMediaFiles(media, userProfileModel.phoneNumber);
      //     if (mediaURL != null) {
      //       mediaURLs.add(mediaURL);
      //     }
      //   }
      // }

      // final anotherNewUserProfile =
      //     newUserProfile.copyWith(mediaFiles: mediaURLs);

      await _userCollection
          .doc(newUserProfile.phoneNumber)
          .update(newUserProfile.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  // Future<String?> _uploadProfilePicture(
  //     String imagePath, String phoneNumber) async {
  //   final storageRef = FirebaseStorage.instance.ref();

  //   final imageRef = storageRef.child("user_profile_pictures/$phoneNumber");
  //   final uploadTask = imageRef.putFile(File(imagePath));

  //   String? imageUrl;
  //   await uploadTask.whenComplete(() async {
  //     imageUrl = await imageRef.getDownloadURL();
  //   });
  //   return imageUrl;
  // }

  // Future<String?> _uploadUserMediaFiles(String path, String phoneNumber) async {
  //   final storageRef = FirebaseStorage.instance.ref();

  //   final imageRef = storageRef
  //       .child("user_media_files/$phoneNumber/${path.split("/").last}");
  //   final uploadTask = imageRef.putFile(File(path));

  //   String? imageUrl;
  //   await uploadTask.whenComplete(() async {
  //     imageUrl = await imageRef.getDownloadURL();
  //   });
  //   return imageUrl;
  // }

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
      isUserAdded = true;
    }
  });
  return isUserAdded;
});
