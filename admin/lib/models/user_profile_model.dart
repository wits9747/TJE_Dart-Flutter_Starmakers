import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:lamatadmin/models/user_account_settings_model.dart';

class UserProfileModel {
  String? id;
  String? userId;
  String? fullName;
  String? userName;
  String? nickname;
  String? email;
  String? profilePicture;
  String? phoneNumber;
  String? gender;
  String? about;
  DateTime? birthDay;
  DateTime? joinedOn;
  List<String>? mediaFiles;
  List<String>? interests;
  List<String>? followers;
  List<String>? following;
  List<String>? favSongs;
  List<String>? favTeels;
  UserAccountSettingsModel? userAccountSettingsModel;
  bool? isVerified;
  bool? isOnline;
  bool? isBoosted;
  int? boostBalance;
  int? superLikesCount;
  String? deviceToken;
  String? fbUrl;
  String? instaUrl;
  String? youtubeUrl;
  String? agoraToken;
  int? followersCount;
  int? followingCount;
  int? myPostLikes;
  String? profileCategoryName;

  UserProfileModel({
    this.isBoosted,
    this.boostBalance,
    this.superLikesCount,
    this.fbUrl,
    this.deviceToken,
    this.instaUrl,
    this.youtubeUrl,
    this.agoraToken,
    this.followersCount,
    this.followingCount,
    this.myPostLikes,
    this.followers,
    this.following,
    this.favSongs,
    this.favTeels,
    this.profileCategoryName,
    this.id,
    this.phoneNumber,
    this.fullName,
    this.userName,
    this.nickname,
    this.email,
    this.profilePicture,
    this.userId,
    this.gender,
    this.about,
    this.birthDay,
    this.joinedOn,
    this.mediaFiles,
    this.interests,
    this.userAccountSettingsModel,
    this.isVerified,
    this.isOnline = true,
  });

  UserProfileModel copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? userName,
    String? nickname,
    double? walletBalance,
    String? email,
    String? profilePicture,
    String? phoneNumber,
    String? gender,
    String? about,
    bool? isBoosted,
    int? boostBalance,
    int? superLikesCount,
    DateTime? birthDay,
    DateTime? joinedOn,
    List<String>? mediaFiles,
    List<String>? interests,
    List<String>? followers,
    List<String>? following,
    List<String>? favSongs,
    List<String>? favTeels,
    UserAccountSettingsModel? userAccountSettingsModel,
    bool? isVerified,
    bool? isOnline,
    String? deviceToken,
    String? fbUrl,
    String? instaUrl,
    String? youtubeUrl,
    String? agoraToken,
    int? followersCount,
    int? followingCount,
    int? myPostLikes,
    String? profileCategoryName,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      userName: userName ?? this.userName,
      nickname: nickname ?? this.nickname,
      email: email ?? this.email,
      isBoosted: isBoosted ?? this.isBoosted,
      boostBalance: boostBalance ?? this.boostBalance,
      superLikesCount: superLikesCount ?? this.superLikesCount,
      profilePicture: profilePicture ?? this.profilePicture,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      about: about ?? this.about,
      birthDay: birthDay ?? this.birthDay,
      joinedOn: joinedOn ?? this.joinedOn,
      mediaFiles: mediaFiles ?? this.mediaFiles,
      interests: interests ?? this.interests,
      userAccountSettingsModel:
          userAccountSettingsModel ?? this.userAccountSettingsModel,
      isVerified: isVerified ?? this.isVerified,
      isOnline: isOnline ?? this.isOnline,
      favSongs: favSongs ?? this.favSongs,
      favTeels: favTeels ?? this.favTeels,
      // from v2
      deviceToken: deviceToken ?? this.deviceToken,
      instaUrl: instaUrl ?? this.instaUrl,
      fbUrl: fbUrl ?? this.fbUrl,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      agoraToken: agoraToken ?? this.agoraToken,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      myPostLikes: myPostLikes ?? this.myPostLikes,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      profileCategoryName: profileCategoryName ?? this.profileCategoryName,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    // from v1
    result.addAll({'id': id});
    result.addAll({'userId': userId});
    result.addAll({'fullName': fullName});
    result.addAll({'userName': userName});
    result.addAll({'nickname': nickname});
    if (email != null) {
      result.addAll({'email': email});
    }
    if (profilePicture != null) {
      result.addAll({'profilePicture': profilePicture});
    }

    result.addAll({'phoneNumber': phoneNumber});

    result.addAll({'gender': gender});
    if (about != null) {
      result.addAll({'about': about});
    }
    result.addAll({'birthDay': birthDay!.millisecondsSinceEpoch});
    result.addAll({'joinedOn': joinedOn!.millisecondsSinceEpoch});
    result.addAll({'mediaFiles': mediaFiles});
    result.addAll({'interests': interests});
    result.addAll({'isBoosted': isBoosted});
    result.addAll({'boostBalance': boostBalance});
    result.addAll({'superLikesCount': superLikesCount});
    result.addAll(
        {'userAccountSettingsModel': userAccountSettingsModel!.toMap()});
    result.addAll({'isVerified': isVerified});
    result.addAll({'isOnline': isOnline});
    result.addAll({'favSongs': favSongs});
    result.addAll({'favTeels': favTeels});
    // from v2
    result.addAll({'deviceToken': deviceToken});
    result.addAll({'instaUrl': instaUrl});
    result.addAll({'youtubeUrl': youtubeUrl});
    result.addAll({'agoraToken': agoraToken});
    result.addAll({'followersCount': followersCount});
    result.addAll({'followingCount': followingCount});
    result.addAll({'myPostLikes': myPostLikes});
    result.addAll({'followers': followers});
    result.addAll({'following': following});
    result.addAll({'profileCategoryName': profileCategoryName});
    result.addAll({'fbUrl': fbUrl});

    return result;
  }

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      // from v1
      id: map['id'] ?? '',
      userId: map['userId'],
      fullName: map['fullName'] ?? '',
      userName: map['userName'] ?? '',
      nickname: map['nickname'] ?? '',
      email: map['email'],
      profilePicture: map['profilePicture'],
      phoneNumber: map['phoneNumber'],
      gender: map['gender'] ?? '',
      about: map['about'],
      birthDay: DateTime.fromMillisecondsSinceEpoch(map['birthDay']),
      joinedOn: DateTime.fromMillisecondsSinceEpoch(map['joinedOn']),
      mediaFiles: List<String>.from(map['mediaFiles']),
      interests: List<String>.from(map['interests']),
      userAccountSettingsModel:
          UserAccountSettingsModel.fromMap(map['userAccountSettingsModel']),
      isVerified: map['isVerified'] ?? false,
      isBoosted: map['isBoosted'] ?? false,
      boostBalance: map['boostBalance'] ?? 0,
      superLikesCount: map['superLikesCount'] ?? 0,
      favSongs: List<String>.from(map['favSongs']),
      favTeels: List<String>.from(map['favTeels']),
      isOnline: map['isOnline'] ?? false,
      // from v2
      deviceToken: map['deviceToken'] ?? '',
      instaUrl: map['instaUrl'] ?? '',
      youtubeUrl: map['youtubeUrl'] ?? '',
      fbUrl: map['fbUrl'] ?? '',
      agoraToken: map['agoraToken'] ?? '',
      followersCount: map['followersCount'] ?? 0,
      followingCount: map['followingCount'] ?? 0,
      myPostLikes: map['myPostLikes'] ?? 0,
      followers: List<String>.from(map['followers']),
      following: List<String>.from(map['following']),
      profileCategoryName: map['profileCategoryName'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfileModel.fromJson(String source) =>
      UserProfileModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserProfileModel(profileCategoryName: $profileCategoryName, following: $following, favTeels: $favTeels, favSongs: $favSongs, superLikesCount: $superLikesCount, isBoosted: $isBoosted, boostBalance: $boostBalance, agoraToken: $agoraToken, followers: $followers, followersCount: $followersCount, followingCount: $followingCount, myPostLikes: $myPostLikes, deviceToken: $deviceToken, instaUrl: $instaUrl, youtubeUrl: $youtubeUrl, fbUrl: $fbUrl, id: $id, userId: $userId, phoneNumber: $phoneNumber, fullName: $fullName, userName: $userName, nickname: $nickname, email: $email, profilePicture: $profilePicture, phoneNumber: $phoneNumber, gender: $gender, about: $about, birthDay: $birthDay, joinedOn: $joinedOn, mediaFiles: $mediaFiles, interests: $interests, userAccountSettingsModel: $userAccountSettingsModel, isVerified: $isVerified, isOnline: $isOnline)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is UserProfileModel &&
        other.id == id &&
        other.userId == userId &&
        other.fullName == fullName &&
        other.userName == userName &&
        other.nickname == nickname &&
        other.email == email &&
        other.profilePicture == profilePicture &&
        other.phoneNumber == phoneNumber &&
        other.gender == gender &&
        other.isBoosted == isBoosted &&
        other.boostBalance == boostBalance &&
        other.superLikesCount == superLikesCount &&
        other.about == about &&
        other.birthDay == birthDay &&
        other.joinedOn == joinedOn &&
        listEquals(other.mediaFiles, mediaFiles) &&
        listEquals(other.interests, interests) &&
        other.userAccountSettingsModel == userAccountSettingsModel &&
        other.isVerified == isVerified &&
        other.isOnline == isOnline &&
        other.favSongs == favSongs &&
        other.favTeels == favTeels &&
        // from v2
        other.deviceToken == deviceToken &&
        other.fbUrl == fbUrl &&
        other.instaUrl == instaUrl &&
        other.youtubeUrl == youtubeUrl &&
        other.agoraToken == agoraToken &&
        other.followersCount == followersCount &&
        other.followingCount == followingCount &&
        other.myPostLikes == myPostLikes &&
        other.followers == followers &&
        other.following == following &&
        other.profileCategoryName == profileCategoryName;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        fullName.hashCode ^
        userName.hashCode ^
        nickname.hashCode ^
        email.hashCode ^
        profilePicture.hashCode ^
        phoneNumber.hashCode ^
        gender.hashCode ^
        isBoosted.hashCode ^
        boostBalance.hashCode ^
        about.hashCode ^
        birthDay.hashCode ^
        joinedOn.hashCode ^
        mediaFiles.hashCode ^
        interests.hashCode ^
        userAccountSettingsModel.hashCode ^
        isVerified.hashCode ^
        isOnline.hashCode ^
        favSongs.hashCode ^
        favTeels.hashCode ^
        // from v2
        deviceToken.hashCode ^
        fbUrl.hashCode ^
        instaUrl.hashCode ^
        youtubeUrl.hashCode ^
        agoraToken.hashCode ^
        followersCount.hashCode ^
        followingCount.hashCode ^
        myPostLikes.hashCode ^
        followers.hashCode ^
        following.hashCode ^
        profileCategoryName.hashCode;
  }
}

class UserProfileShortModel {
  String? id;
  String? userId;
  String? fullName;
  String? profilePicture;
  String? gender;
  DateTime? joinedOn;
  bool? isVerified;
  UserProfileShortModel({
    this.id,
    this.userId,
    this.fullName,
    this.profilePicture,
    this.gender,
    this.joinedOn,
    this.isVerified,
  });

  UserProfileShortModel copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? profilePicture,
    String? gender,
    DateTime? joinedOn,
    bool? isVerified,
  }) {
    return UserProfileShortModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      profilePicture: profilePicture ?? this.profilePicture,
      gender: gender ?? this.gender,
      joinedOn: joinedOn ?? this.joinedOn,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'userId': userId});
    result.addAll({'fullName': fullName});
    if (profilePicture != null) {
      result.addAll({'profilePicture': profilePicture});
    }
    result.addAll({'gender': gender});
    result.addAll({'joinedOn': joinedOn!.millisecondsSinceEpoch});
    result.addAll({'isVerified': isVerified});

    return result;
  }

  factory UserProfileShortModel.fromMap(Map<String, dynamic> map) {
    return UserProfileShortModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      fullName: map['fullName'] ?? '',
      profilePicture: map['profilePicture'],
      gender: map['gender'] ?? '',
      joinedOn: DateTime.fromMillisecondsSinceEpoch(map['joinedOn']),
      isVerified: map['isVerified'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfileShortModel.fromJson(String source) =>
      UserProfileShortModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserProfileShortModel(id: $id, userId: $userId, fullName: $fullName, profilePicture: $profilePicture, gender: $gender, joinedOn: $joinedOn, isVerified: $isVerified)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserProfileShortModel &&
        other.id == id &&
        other.userId == userId &&
        other.fullName == fullName &&
        other.profilePicture == profilePicture &&
        other.gender == gender &&
        other.joinedOn == joinedOn &&
        other.isVerified == isVerified;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        fullName.hashCode ^
        profilePicture.hashCode ^
        gender.hashCode ^
        joinedOn.hashCode ^
        isVerified.hashCode;
  }
}
