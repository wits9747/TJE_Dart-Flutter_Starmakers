import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatadmin/helpers/firebase_constants.dart';
import 'package:lamatadmin/models/coin_plans.dart';

final getPlansProvider = FutureProvider<CoinPlans>((ref) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  QuerySnapshot querySnapshot =
      await firestore.collection(FirebaseConstants.plansCollection).get();

  if (querySnapshot.docs.isNotEmpty) {
    List<CoinPlanData> coinPlanDataList = querySnapshot.docs
        .map((doc) => CoinPlanData.fromJson(doc.data()))
        .toList();
    return CoinPlans(data: coinPlanDataList);
  } else {
    throw Exception('No documents found in the database');
  }
});

Future<bool> addPlan({required CoinPlanData plan}) async {
  final plansCollection =
      FirebaseFirestore.instance.collection(FirebaseConstants.plansCollection);
  try {
    await plansCollection
        .doc(plan.coinPlanId.toString())
        .set(plan.toJson(), SetOptions(merge: true));
    return true;
  } catch (e) {
    debugPrint(e.toString());
    return false;
  }
}

Future<bool> editPlan({required CoinPlanData plan}) async {
  final plansCollection =
      FirebaseFirestore.instance.collection(FirebaseConstants.plansCollection);
  try {
    await plansCollection.doc(plan.coinPlanId.toString()).update(plan.toJson());
    return true;
  } catch (e) {
    debugPrint(e.toString());
    return false;
  }
}

Future<bool> deletePlan({required String planId}) async {
  final plansCollection =
      FirebaseFirestore.instance.collection(FirebaseConstants.plansCollection);
  try {
    await plansCollection.doc(planId).delete();
    return true;
  } catch (e) {
    debugPrint(e.toString());
    return false;
  }
}
