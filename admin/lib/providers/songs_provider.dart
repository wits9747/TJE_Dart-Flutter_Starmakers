import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatadmin/helpers/firebase_constants.dart';
import 'package:lamatadmin/models/songs_model.dart';

final soundDataProvider = StreamProvider.autoDispose<List<SoundData>>((ref) {
  return FirebaseFirestore.instance
      .collection(FirebaseConstants.soundList)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return SoundData.fromJson(doc.data());
    }).toList();
  });
});

Future<bool> addSoundDataProvider(SoundData soundData) async {
  final firestore = FirebaseFirestore.instance;
  // Validate sound data (optional)
  // ...

  try {
    final docRef = firestore
        .collection(FirebaseConstants.soundList)
        .doc(soundData.soundCategoryId.toString());
    await docRef.set(soundData.toJson());
    return true;
  } catch (error) {
    // Handle errors gracefully, e.g., display user-friendly messages
    debugPrint('Error adding sound Category: $error');
    rethrow;
    // Rethrow to allow UI-level error handling
  }
}

// Future<void> addSongToCategory(SoundList songModel, String categoryId) async {
//   try {
//     final firestore = FirebaseFirestore.instance;
//     final docRef =
//         firestore.collection(FirebaseConstants.soundList).doc(categoryId);

//     await firestore.runTransaction((transaction) async {
//       // Retrieve the existing document
//       DocumentSnapshot snapshot = await transaction.get(docRef);

//       List<SoundList> songLists = (snapshot.data()
//               as Map<String, dynamic>)['sound_list'] as List<SoundList>? ??
//           [];

//       List<SoundList> newSongLists = [...songLists, songModel];
//       transaction.update(docRef, {'sound_list': newSongLists});
//       // songLists.add(songModel);

//       // Update the document with the new songList
//       // transaction.update(docRef, {'sound_list': songLists});
//     });
//   } catch (error) {
//     // Handle errors gracefully, e.g., display user-friendly messages
//     debugPrint('Error adding song: $error');
//     // Optionally rethrow the error for UI-level handling
//   }
// }

Future<void> addSongToCategory(SoundList songModel, String categoryId) async {
  try {
    final firestore = FirebaseFirestore.instance;
    final docRef =
        firestore.collection(FirebaseConstants.soundList).doc(categoryId);

    // Instead of creating a new map, use songModel.toJson()
    Map<String, dynamic> updatedSongList = songModel.toJson();

    // Update the document
    await docRef.update({
      'sound_list': FieldValue.arrayUnion([updatedSongList])
    });
  } catch (error) {
    debugPrint('Error adding song: $error');
    // Handle errors gracefully
  }
}

Future<bool> editSoundDataProvider(SoundData soundData) async {
  final firestore = FirebaseFirestore.instance;
  // Validate sound data (optional)
  // ...

  try {
    final docRef = firestore.collection(FirebaseConstants.soundList).doc();
    await docRef.update(soundData.toJson());
    return true;
  } catch (error) {
    // Handle errors gracefully, e.g., display user-friendly messages
    debugPrint('Error adding sound Category: $error');
    rethrow;
    // Rethrow to allow UI-level error handling
  }
}

Future<bool> deleteSoundDataProvider(int id) async {
  try {
    final firestore = FirebaseFirestore.instance;
    final docRef =
        firestore.collection(FirebaseConstants.soundList).doc(id.toString());
    await docRef.delete();
    return true;
  } catch (error) {
    // Handle errors gracefully, e.g., display user-friendly messages
    debugPrint('Error deleting sound Category: $error');
    rethrow;
    // Rethrow to allow UI-level error handling
  }
}
