import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lamatadmin/helpers/firebase_constants.dart';
import 'package:lamatadmin/models/comment_model.dart';
import 'package:lamatadmin/models/teels_model.dart';
// import 'package:lamatadmin/models/user_profile_model.dart';
// import 'package:lamatdating/v1/helpers/constants.dart';
// import 'package:lamatdating/v1/models/comment_model.dart';
// import 'package:lamatdating/v1/models/teels_model.dart';
// import 'package:lamatdating/v1/models/user_profile_model.dart';
// import 'package:lamatdating/v1/providers/auth_providers.dart';
// import 'package:lamatdating/v1/providers/match_provider.dart';
// import 'package:lamatdating/v1/providers/other_users_provider.dart';

final getTeelsProvider = FutureProvider<List<TeelsModel>>((ref) async {
  final teelsCollection =
      FirebaseFirestore.instance.collection(FirebaseConstants.teelsCollection);

  final snapshot = await teelsCollection.get();

  final List<TeelsModel> teels = [];
  for (final doc in snapshot.docs) {
    teels.add(TeelsModel.fromMap(doc.data()));
  }

  teels.sort((a, b) => b.createdAt.compareTo(a.createdAt));

  return teels;
});

final _teelsCollection =
    FirebaseFirestore.instance.collection(FirebaseConstants.teelsCollection);

final commentsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, teelId) {
  return FirebaseFirestore.instance
      .collection(FirebaseConstants.teelsCollection)
      .doc(teelId)
      .snapshots()
      .map((snapshot) =>
          List<Map<String, dynamic>>.from(snapshot.data()?['comments'] ?? []));
});

String userIdDateTime(String phoneNumber) {
  var now = DateTime.now();
  var formatter = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
  String formattedDate = formatter.format(now);
  return phoneNumber + formattedDate;
}

final getTotalLikes = StreamProvider.family<int, String>((ref, teelId) async* {
  try {
    final teelDoc = _teelsCollection.doc(teelId).snapshots();
    await for (var snapshot in teelDoc) {
      final teelData = snapshot.data();
      if (teelData != null) {
        final teel = TeelsModel.fromMap(teelData);
        final likes = teel.likes;
        yield likes.length;
      }
    }
  } catch (e) {
    yield 0;
  }
});

final getTeelLikes =
    StreamProvider.family<List<String>, String>((ref, teelId) async* {
  try {
    final teelDoc = _teelsCollection.doc(teelId).snapshots();
    await for (var snapshot in teelDoc) {
      final teelData = snapshot.data();
      if (teelData != null) {
        final teel = TeelsModel.fromMap(teelData);
        final likes = teel.likes;
        yield likes;
      }
    }
  } catch (e) {
    yield [];
  }
});

final getTeelSaves =
    StreamProvider.family<List<String>, String>((ref, teelId) async* {
  try {
    final teelDoc = _teelsCollection.doc(teelId).snapshots();
    await for (var snapshot in teelDoc) {
      final teelData = snapshot.data();
      if (teelData != null) {
        final teel = TeelsModel.fromMap(teelData);
        final likes = teel.saves;
        yield likes;
      }
    }
  } catch (e) {
    yield [];
  }
});

final getTotalSaves = StreamProvider.family<int, String>((ref, teelId) async* {
  try {
    final teelDoc = _teelsCollection.doc(teelId).snapshots();
    await for (var snapshot in teelDoc) {
      final teelData = snapshot.data();
      if (teelData != null) {
        final teel = TeelsModel.fromMap(teelData);
        final saves = teel.saves;
        yield saves.length;
      }
    }
  } catch (e) {
    yield 0;
  }
});

final totalCommentLikesProvider =
    StreamProvider.family<int, String>((ref, parameters) async* {
  String commentId = parameters.split(',')[0];
  String teelId = parameters.split(',')[1];

  try {
    final teelDoc = await _teelsCollection.doc(teelId).get();
    final teelData = teelDoc.data();
    if (teelData != null) {
      final teel = TeelsModel.fromMap(teelData);
      final comments =
          teel.comments.map((c) => CommentModel.fromMap(c)).toList();
      for (var comment in comments) {
        if (comment.id == commentId) {
          yield comment.likes!.length;
        }
      }
    }
  } catch (e) {
    yield 0;
  }
});

Future<bool> deleteTeel(String id) async {
  try {
    await _teelsCollection.doc(id).delete();
    return true;
  } catch (e) {
    return false;
  }
}

// Future<String> uploadTeelSound(
//     {required File uploadSound, required String phoneNumber}) async {
//   try {
//     String fileurl = "";

//     final currentTime = DateTime.now();
//     final ref = FirebaseStorage.instance
//         .ref()
//         .child(FirebaseConstants.teelsCollection)
//         .child(phoneNumber)
//         .child(currentTime.millisecondsSinceEpoch.toString() +
//             phoneNumber +
//             uploadSound.path.split('/').last);

//     final uploadTask = ref.putFile(uploadSound);
//     String? url;
//     await uploadTask.whenComplete(() async {
//       url = await ref.getDownloadURL();
//     });

//     if (url != null) {
//       fileurl = url!;
//     }

//     return fileurl;
//   } catch (e) {
//     return "";
//   }
// }

// Future<String> uploadTeelThumbnail(
//     {required File uploadThumbnail, required String phoneNumber}) async {
//   try {
//     String fileurl = "";

//     final currentTime = DateTime.now();
//     final ref = FirebaseStorage.instance
//         .ref()
//         .child(FirebaseConstants.teelsCollection)
//         .child(phoneNumber)
//         .child(currentTime.millisecondsSinceEpoch.toString() +
//             phoneNumber +
//             uploadThumbnail.path.split('/').last);

//     final uploadTask = ref.putFile(uploadThumbnail);
//     String? url;
//     await uploadTask.whenComplete(() async {
//       url = await ref.getDownloadURL();
//     });

//     if (url != null) {
//       fileurl = url!;
//     }

//     return fileurl;
//   } catch (e) {
//     return "";
//   }
// }

Future<String> uploadTeelSoundImage(
    {required File uploadTeelSoundImage, required String phoneNumber}) async {
  try {
    String fileurl = "";

    final currentTime = DateTime.now();
    final ref = FirebaseStorage.instance
        .ref()
        .child(FirebaseConstants.teelsCollection)
        .child(phoneNumber)
        .child(currentTime.millisecondsSinceEpoch.toString() +
            phoneNumber +
            uploadTeelSoundImage.path.split('/').last);

    final uploadTask = ref.putFile(uploadTeelSoundImage);
    String? url;
    await uploadTask.whenComplete(() async {
      url = await ref.getDownloadURL();
    });

    if (url != null) {
      fileurl = url!;
    }

    return fileurl;
  } catch (e) {
    return "";
  }
}

final getHashtagsProvider = FutureProvider<List<DocumentSnapshot>>((ref) async {
  final snapshot = await FirebaseFirestore.instance
      .collection(FirebaseConstants.hashtagsCollection)
      .get();
  return snapshot.docs;
});
