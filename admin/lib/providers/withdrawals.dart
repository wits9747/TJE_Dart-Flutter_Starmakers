import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatadmin/helpers/firebase_constants.dart';
import 'package:lamatadmin/models/withdrawal_model.dart';

final getWithdrawalsProvider =
    FutureProvider<List<WithrawalModel>>((ref) async {
  final feedsCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.withdrawalsCollection);

  final snapshot = await feedsCollection.get();

  final List<WithrawalModel> withdrawals = [];
  for (final doc in snapshot.docs) {
    withdrawals.add(WithrawalModel.fromMap(doc.data()));
  }

  withdrawals.sort((a, b) => b.createdAt.compareTo(a.createdAt));

  return withdrawals;
});

class WithdrawalsProvider {
  static Future<bool> updateStatus(WithrawalModel withdrawal) async {
    final collection = FirebaseFirestore.instance
        .collection(FirebaseConstants.withdrawalsCollection);

    try {
      await collection.doc(withdrawal.id).update(withdrawal.toMap());
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}

FirebaseStorage storage = FirebaseStorage.instance;
Reference rootReference = storage.ref();
