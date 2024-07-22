import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatadmin/helpers/firebase_constants.dart';
import 'package:lamatadmin/models/gifts_model.dart';

final getGiftsProvider = FutureProvider<List<GiftsModel>>((ref) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final giftsSnapshot = await firestore
      .collection(FirebaseConstants.appSettingsCollection)
      .doc('settings')
      .collection('gifts')
      .get();

  if (giftsSnapshot.docs.isEmpty) {
    return [];
  } else {
    List<GiftsModel> gifts =
        giftsSnapshot.docs.map((e) => GiftsModel.fromMap(e.data())).toList();

    gifts.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

    return gifts;
  }
});

Future<bool> addGift({required GiftsModel gift}) async {
  final giftsCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.appSettingsCollection)
      .doc('settings')
      .collection('gifts');
  try {
    await giftsCollection
        .doc(gift.id.toString())
        .set(gift.toMap(), SetOptions(merge: true));
    return true;
  } catch (e) {
    debugPrint(e.toString());
    return false;
  }
}

Future<bool> editGift({required GiftsModel gift}) async {
  final giftsCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.appSettingsCollection)
      .doc('settings')
      .collection('gifts');
  try {
    await giftsCollection.doc(gift.id.toString()).update(gift.toMap());
    return true;
  } catch (e) {
    debugPrint(e.toString());
    return false;
  }
}

Future<bool> deleteGift({required String giftId}) async {
  final giftsCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.appSettingsCollection)
      .doc('settings')
      .collection('gifts');
  try {
    await giftsCollection.doc(giftId).delete();
    return true;
  } catch (e) {
    debugPrint(e.toString());
    return false;
  }
}
