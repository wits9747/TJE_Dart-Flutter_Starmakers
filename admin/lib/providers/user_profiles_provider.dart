// ignore_for_file: unused_local_variable

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatadmin/helpers/firebase_constants.dart';
import 'package:lamatadmin/models/user_profile_model.dart';

final userProfileProvider =
    FutureProvider.family<UserProfileModel, String>((ref, userId) async {
  final userProfileCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.userProfileCollection);
  final userProfileDoc = await userProfileCollection.doc(userId).get();
  final userProfileData = userProfileDoc.data();
  if (userProfileData != null) {
    return UserProfileModel.fromMap(userProfileData);
  } else {
    throw Exception('User profile not found!');
  }
});

final usersShortStreamProvider =
    StreamProvider<List<UserProfileShortModel>>((ref) {
  final usersCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.userProfileCollection);

  return usersCollection.snapshots().map((snapshot) => snapshot.docs
      .map((doc) => UserProfileShortModel.fromMap(doc.data()))
      .toList());
});

final usersStreamProvider = StreamProvider<List<UserProfileModel>>((ref) {
  final usersCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.userProfileCollection);

  return usersCollection.snapshots().map((snapshot) => snapshot.docs
      .map((doc) => UserProfileModel.fromMap(doc.data()))
      .toList());
});

bool hasNonEnglishCharacters(String text) {
  const englishPattern = r"[a-zA-Z0-9\s]";
  return RegExp(r"[^\s$englishPattern]").hasMatch(text);
}

Future<void> cleanDatabase() async {
  final usersCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.userProfileCollection);
  try {
    EasyLoading.show(status: "Cleaning Database...");
    final querySnapshot =
        await usersCollection.get(); // Retrieve all documents in the collection

    for (final doc in querySnapshot.docs) {
      if (!doc.data().containsKey('about')) {
        await doc.reference
            .delete(); // Delete the document if "about" field is missing
        if (kDebugMode) {
          print('Document without "about" field deleted: ${doc.id}');
        } // Log for confirmation
      }
      if (!doc.data().containsKey('aboutMe')) {
        await doc.reference
            .delete(); // Delete the document if "about" field is missing
        if (kDebugMode) {
          print('Document without "aboutMe" field deleted: ${doc.id}');
        } // Log for confirmation
      }
    }
    EasyLoading.showSuccess("Database Cleaned Successfully!");
  } on FirebaseException catch (e) {
    if (kDebugMode) {
      print('Error deleting documents: $e');
    }
    // Handle any errors that occur during the deletion process
  }
}

final recentUsersStreamProvider = StreamProvider<List<UserProfileModel>>((ref) {
  final usersCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.userProfileCollection);

  // Use a StreamController to create a Stream of UserProfileModel lists
  final streamController = StreamController<List<UserProfileModel>>();

  // Fetch all documents once
  usersCollection.get().then((snapshot) {
    // Convert to UserProfileModel objects
    var userProfiles = snapshot.docs
        .map((doc) => UserProfileModel.fromMap(doc.data()))
        .toList();

    // Sort UserProfileModel objects by joinedOn in ascending order
    userProfiles.sort((a, b) => b.joinedOn!.compareTo(a.joinedOn!));

    // Add sorted userProfiles to the stream
    streamController.add(userProfiles.take(6).toList());
  });

  // Return the Stream from the StreamController
  return streamController.stream;
});

class UserProfileProvider {
  static Future<bool> verifyUser(String userId) async {
    final userProfileCollection = FirebaseFirestore.instance
        .collection(FirebaseConstants.userProfileCollection);

    try {
      await userProfileCollection.doc(userId).update({'isVerified': true});
      return true;
    } on Exception catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  // Add user profile
  static Future<bool> addUser(UserProfileModel userProfile) async {
    final userProfileCollection = FirebaseFirestore.instance
        .collection(FirebaseConstants.userProfileCollection);

    try {
      await userProfileCollection
          .doc(userProfile.userId)
          .set(userProfile.toMap());
      return true;
    } on Exception catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  //delete user profile
  static Future<bool> deleteUser(String userId) async {
    final userProfileCollection = FirebaseFirestore.instance
        .collection(FirebaseConstants.userProfileCollection);

    try {
      await userProfileCollection.doc(userId).delete();

      final userProfilePicture = FirebaseStorage.instance
          .ref()
          .child("user_profile_pictures")
          .child(userId);
      await userProfilePicture.listAll().then((value) async {
        for (var item in value.items) {
          await item.delete();
        }
      });

      final userMediaFiles = FirebaseStorage.instance
          .ref()
          .child("user_media_files")
          .child(userId);
      await userMediaFiles.listAll().then((value) async {
        for (var item in value.items) {
          await item.delete();
        }
      });

      return true;
    } on Exception catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}

final _userCollection = FirebaseFirestore.instance
    .collection(FirebaseConstants.userProfileCollection);

final getFollowers =
    StreamProvider.family<List<String>, String>((ref, phoneNumber) async* {
  try {
    final userDoc = _userCollection.doc(phoneNumber).snapshots();
    await for (var snapshot in userDoc) {
      final userData = snapshot.data();
      if (userData != null) {
        final user = UserProfileModel.fromMap(userData);
        final followers = user.followers;
        yield followers!;
      }
    }
  } catch (e) {
    yield [];
  }
});
