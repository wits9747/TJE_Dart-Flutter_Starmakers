import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatadmin/helpers/firebase_constants.dart';
import 'package:lamatadmin/models/feed_model.dart';

class FeedsProvider {
  static Future<bool> deleteFeeds(String userId) async {
    final collection = FirebaseFirestore.instance
        .collection(FirebaseConstants.feedsCollection);

    try {
      await collection.where('userId', isEqualTo: userId).get().then((value) {
        for (var element in value.docs) {
          element.reference.delete();
        }
      });

      final feedsImages =
          FirebaseStorage.instance.ref().child("feeds").child(userId);

      await feedsImages.listAll().then((value) {
        for (var element in value.items) {
          element.delete();
        }
      });

      return true;
    } catch (e) {
      return false;
    }
  }
}

final getFeedsProvider = FutureProvider<List<FeedModel>>((ref) async {
  final feedsCollection =
      FirebaseFirestore.instance.collection(FirebaseConstants.feedsCollection);

  final snapshot = await feedsCollection.get();

  final List<FeedModel> feeds = [];
  for (final doc in snapshot.docs) {
    feeds.add(FeedModel.fromMap(doc.data()));
  }

  feeds.sort((a, b) => b.createdAt.compareTo(a.createdAt));

  return feeds;
});

FirebaseStorage storage = FirebaseStorage.instance;
Reference rootReference = storage.ref();
