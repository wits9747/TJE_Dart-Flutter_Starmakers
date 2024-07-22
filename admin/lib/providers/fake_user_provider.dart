import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faker/faker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatadmin/helpers/config.dart';
import 'package:lamatadmin/helpers/firebase_constants.dart';
import 'package:lamatadmin/models/user_account_settings_model.dart';
import 'package:lamatadmin/models/user_profile_model.dart';

Future<bool> generateFakeUsersProvider() async {
  // Ensure Firebase is initialized
  await Firebase.initializeApp();

  // Use a Faker instance for consistency and localization
  final faker = Faker();

  // Generate a user count between 10 and 50 (adjustable)
  final userCount = Random().nextInt(2) + 1;

  // Set up a batch for efficient writes
  final batch = FirebaseFirestore.instance.batch();

  // Generate and add users to the batch
  for (int i = 0; i < userCount; i++) {
    // final random = Random();
    final interests = AppConstants.interests.toList();
    interests.shuffle(Random());
    final selectedInterests = interests.sublist(0, 8);
    final phone = generateRandomPhoneNumber();
    final fname = faker.person.firstName();
    final lname = faker.person.lastName();
    final email = faker.internet.email();
    final category = AppConstants.profileCategory[
        Random().nextInt(AppConstants.profileCategory.length - 1)];

    final user = UserProfileModel(
      id: UniqueKey().toString(),
      userId: phone,
      fullName: faker.person.name(),
      userName: fname.toLowerCase() + lname.toLowerCase(),
      nickname: faker.person.firstName() + faker.person.lastName(),
      email: email,
      profilePicture: faker.image.image(),
      phoneNumber: phone,
      gender: faker.randomGenerator.boolean() ? 'Male' : 'Female',
      about: faker.lorem.sentence(),
      birthDay: faker.date
          .dateTime()
          .subtract(Duration(days: 365 * Random().nextInt(23) + 18)),
      joinedOn: DateTime.now(),
      mediaFiles: [
        faker.image.image(),
        faker.image.image(),
        faker.image.image()
      ],
      interests: selectedInterests,
      followers: [],
      following: [],
      favSongs: [],
      favTeels: [],
      userAccountSettingsModel: UserAccountSettingsModel(
        location: UserLocation(
            addressText: "${faker.address.city()}, ${faker.address.country()}",
            latitude: 48.8566,
            longitude: 2.3522),
        distanceInKm: 9999,
        interestedIn: "everyone",
        minimumAge: 18,
        maximumAge: 99,
        showAge: true,
        showLocation: true,
        showOnlineStatus: true,
      ),
      isVerified: false,
      isOnline: true,
      isBoosted: false,
      boostBalance: 0,
      superLikesCount: 0,
      deviceToken: faker.guid.guid(),
      fbUrl: fname.toLowerCase() + lname.toLowerCase(),
      instaUrl: fname.toLowerCase() + lname.toLowerCase(),
      youtubeUrl: fname.toLowerCase() + lname.toLowerCase(),
      agoraToken: "",
      followersCount: 0,
      followingCount: 0,
      myPostLikes: 0,
      profileCategoryName: category,
    );

    Map<String, dynamic> user2 = {
      Dbkeys.publicKey: UniqueKey().toString(),
      Dbkeys.privateKey: UniqueKey().toString(),
      Dbkeys.countryCode: "+1",
      // Dbkeys.nickname: widget.nickname.trim(),

      Dbkeys.aboutMe: "Hey there, I wanna XOXO!",
      Dbkeys.photoUrl: user.profilePicture,
      Dbkeys.id: user.id,
      Dbkeys.phone: user.phoneNumber,
      Dbkeys.phoneRaw: user.phoneNumber,
      Dbkeys.authenticationType: 0,

      //---Additional fields added for Admin app compatible----
      Dbkeys.accountstatus: Dbkeys.sTATUSallowed,
      Dbkeys.actionmessage: "Account Approved",
      Dbkeys.lastLogin: DateTime.now().millisecondsSinceEpoch,
      Dbkeys.joinedOn: DateTime.now().millisecondsSinceEpoch,

      Dbkeys.videoCallMade: 0,
      Dbkeys.videoCallRecieved: 0,
      Dbkeys.audioCallMade: 0,
      Dbkeys.groupsCreated: 0,
      Dbkeys.blockeduserslist: [],
      Dbkeys.audioCallRecieved: 0,
      Dbkeys.mssgSent: 0,
      Dbkeys.deviceDetails: {},
      Dbkeys.currentDeviceID: faker.guid.guid().toString(),
      Dbkeys.phonenumbervariants: []
    };

    batch.set(
        FirebaseFirestore.instance
            .collection(FirebaseConstants.userProfileCollection)
            .doc(user.phoneNumber),
        user.toMap(),
        SetOptions(merge: true));

    batch.set(
        FirebaseFirestore.instance
            .collection(FirebaseConstants.userProfileCollection)
            .doc(user.phoneNumber),
        user2,
        SetOptions(merge: true));
  }

  // Commit the batch for efficient and reliable insertion
  await batch.commit();
  return true;
}

String generateRandomPhoneNumber() {
  // Adjust country code and format as needed
  const countryCode = '+1';
  final areaCode = Random().nextInt(999) + 100; // 3-digit area code
  final localNumber =
      Random().nextInt(9000000) + 1000000; // 7-digit local number

  return '$countryCode$areaCode$localNumber';
}
