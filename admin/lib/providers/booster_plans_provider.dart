import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatadmin/helpers/firebase_constants.dart';
import 'package:lamatadmin/models/boosters_model.dart';

final getBoostersProvider = FutureProvider<BoosterPlans>((ref) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  QuerySnapshot querySnapshot =
      await firestore.collection(FirebaseConstants.boostersCollection).get();

  if (querySnapshot.docs.isNotEmpty) {
    List<BoosterPlanData> boosterPlanDataList = querySnapshot.docs
        .map((doc) => BoosterPlanData.fromJson(doc.data()))
        .toList();
    return BoosterPlans(data: boosterPlanDataList);
  } else {
    throw Exception('No documents found in the database');
  }
});

Future<bool> addBooster({required BoosterPlanData plan}) async {
  final boostersCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.boostersCollection);
  try {
    await boostersCollection
        .doc(plan.boosterPlanId.toString())
        .set(plan.toJson(), SetOptions(merge: true));
    return true;
  } catch (e) {
    debugPrint(e.toString());
    return false;
  }
}

Future<bool> editBooster({required BoosterPlanData plan}) async {
  final boostersCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.boostersCollection);
  try {
    await boostersCollection
        .doc(plan.boosterPlanId.toString())
        .update(plan.toJson());
    return true;
  } catch (e) {
    debugPrint(e.toString());
    return false;
  }
}

Future<bool> deleteBooster({required String planId}) async {
  final boostersCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.boostersCollection);
  try {
    await boostersCollection.doc(planId).delete();
    return true;
  } catch (e) {
    debugPrint(e.toString());
    return false;
  }
}
