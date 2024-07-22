import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/helpers/constants.dart';
import 'package:lamatdating/providers/firebase_provider.dart';
import 'dart:async';

import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';

class FirebaseGroupServices {
  getGroupsList(String? phone) {
    return FirebaseFirestore.instance
        .collection(DbPaths.collectiongroups)
        .where(Dbkeys.groupMEMBERSLIST, arrayContains: phone)
        .orderBy(Dbkeys.groupCREATEDON, descending: true)
        .snapshots()
        .map((snapShot) => snapShot.docs
            .map((document) => GroupModel.fromJson(document.data()))
            .toList());
  }

  getChannelsList(String? phone) {
    return FirebaseFirestore.instance
        .collection(DbPaths.collectionchannels)
        .where(Dbkeys.groupMEMBERSLIST, arrayContains: phone)
        .orderBy(Dbkeys.groupCREATEDON, descending: true)
        .snapshots()
        .map((snapShot) => snapShot.docs
            .map((document) => GroupModel.fromJson(document.data()))
            .toList());
  }

  getAllChannelsList(String? phone) {
    return FirebaseFirestore.instance
        .collection(DbPaths.collectionchannels)
        // .where(Dbkeys.groupMEMBERSLIST, arrayContains: phone)
        .orderBy(Dbkeys.groupCREATEDON, descending: true)
        .snapshots()
        .map((snapShot) => snapShot.docs
            .map((document) => GroupModel.fromJson(document.data()))
            .toList());
  }

  Future<bool> addUserToGroup(String? groupid, String? phone) async {
    try {
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionchannels)
          .doc(groupid)
          .update({
        Dbkeys.groupMEMBERSLIST: FieldValue.arrayUnion([phone])
      });
      return true;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
  }
}

class GroupModel {
  Map<String, dynamic> docmap = {};

  GroupModel.fromJson(Map<String, dynamic> parsedJSON) : docmap = parsedJSON;
}

final firestoreDataProviderMESSAGESforGROUPCHAT =
    ChangeNotifierProvider<FirestoreDataProviderMESSAGESforGROUPCHAT>(
        (ref) => FirestoreDataProviderMESSAGESforGROUPCHAT());

class FirestoreDataProviderMESSAGESforGROUPCHAT extends ChangeNotifier {
  List<DocumentSnapshot> datalistSnapshot = <DocumentSnapshot>[];
  String _errorMessage = '';
  bool _hasNext = true;
  bool _isFetchingData = false;
  String? parentid;
  String get errorMessage => _errorMessage;

  bool get hasNext => _hasNext;

  List get recievedDocs => datalistSnapshot.map((snap) {
        final recievedData = snap.data();

        return recievedData;
      }).toList();

  reset() {
    _hasNext = true;
    datalistSnapshot.clear();
    _isFetchingData = false;
    _errorMessage = '';
    recievedDocs.clear();
    notifyListeners();
  }

  Future fetchNextData(
      String? dataType, Query? refdataa, bool isAfterNewdocCreated) async {
    if (_isFetchingData) return;

    _errorMessage = '';
    _isFetchingData = true;

    try {
      final snap = isAfterNewdocCreated == true
          ? await FirebaseApi.getFirestoreCOLLECTIONData(
              maxChatMessageDocsLoadAtOnceForGroupChatAndBroadcastLazyLoading,
              // startAfter: null,
              refdata: refdataa)
          : await FirebaseApi.getFirestoreCOLLECTIONData(
              maxChatMessageDocsLoadAtOnceForGroupChatAndBroadcastLazyLoading,
              startAfter:
                  datalistSnapshot.isNotEmpty ? datalistSnapshot.last : null,
              refdata: refdataa);
      if (isAfterNewdocCreated == true) {
        datalistSnapshot.clear();
        datalistSnapshot.addAll(snap.docs);
      } else {
        datalistSnapshot.addAll(snap.docs);
      }
      // notifyListeners();
      if (snap.docs.length <
          maxChatMessageDocsLoadAtOnceForGroupChatAndBroadcastLazyLoading) {
        _hasNext = false;
      }
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }

    _isFetchingData = false;
  }

  addDoc(DocumentSnapshot newDoc) {
    int index = datalistSnapshot
        .indexWhere((doc) => doc[Dbkeys.timestamp] == newDoc[Dbkeys.timestamp]);
    if (index < 0) {
      // List<DocumentSnapshot> list = datalistSnapshot.reversed.toList();
      datalistSnapshot.insert(0, newDoc);
      // datalistSnapshot = list;
      notifyListeners();
    }
  }

  bool checkIfDocAlreadyExits(
      {required DocumentSnapshot newDoc, int? timestamp}) {
    return timestamp != null
        ? datalistSnapshot.indexWhere(
                (doc) => doc[Dbkeys.timestamp] == newDoc[Dbkeys.timestamp]) >=
            0
        : datalistSnapshot.contains(newDoc);
  }

  int totalDocsLoadedLength() {
    return datalistSnapshot.length;
  }

  updateparticulardocinProvider({
    required DocumentSnapshot updatedDoc,
  }) async {
    int index = datalistSnapshot.indexWhere(
        (doc) => doc[Dbkeys.timestamp] == updatedDoc[Dbkeys.timestamp]);

    datalistSnapshot.removeAt(index);
    datalistSnapshot.insert(index, updatedDoc);
    notifyListeners();
  }

  deleteparticulardocinProvider({required DocumentSnapshot deletedDoc}) async {
    int index = datalistSnapshot.indexWhere(
        (doc) => doc[Dbkeys.groupmsgTIME] == deletedDoc[Dbkeys.groupmsgTIME]);
    var d = datalistSnapshot[index];
    if (index >= 0) {
      datalistSnapshot.remove(d);
      notifyListeners();
    }
  }
}
