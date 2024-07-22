import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:lamatadmin/helpers/firebase_constants.dart';
import 'dart:convert';

import 'package:lamatadmin/models/verify_model.dart';
// import 'package:restart_app/restart_app.dart';

final getLicenseProvider = FutureProvider<VerifyModel?>((ref) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final licenseSnapshot = await firestore
      .collection(FirebaseConstants.verifyCollection)
      .doc('license')
      .get();

  if (licenseSnapshot.exists) {
    final license = VerifyModel.fromMap(licenseSnapshot.data()!);

    return license;
  } else {
    return null;
  }
});

Future<bool> addLicense({required VerifyModel license}) async {
  final licenseCollection =
      FirebaseFirestore.instance.collection(FirebaseConstants.verifyCollection);
  try {
    await licenseCollection
        .doc("license")
        .set(license.toMap(), SetOptions(merge: true));
    // Restart.restartApp();
    return true;
  } catch (e) {
    debugPrint(e.toString());
    return false;
  }
}

final verifiedJsonProvider =
    StateNotifierProvider<VerifiedJsonStateNotifier, Map<String, dynamic>?>(
  (ref) => VerifiedJsonStateNotifier(),
);

class VerifiedJsonStateNotifier extends StateNotifier<Map<String, dynamic>> {
  VerifiedJsonStateNotifier() : super({});

  final _verificationUrl =
      'https://weabbble.c1.is/v2/index.php/?purchaseCode='; // Replace with your verification URL

  Future<void> verifyLicense(String licenseKey) async {
    try {
      final response = await http.get(Uri.parse(_verificationUrl + licenseKey));

      if (response.statusCode == 200) {
        final decodedJson = jsonDecode(response.body) as Map<String, dynamic>;
        state = decodedJson;
      } else {
        // Handle verification error
        throw Exception(
            'Verification failed with status code: ${response.statusCode}');
      }
    } catch (error) {
      // Handle request errors
      throw Exception('Error fetching verification data: $error');
    }
  }
}

final licenseProvider = Provider<LicenseType>((ref) {
  final json = ref.watch(verifiedJsonProvider);

  // if (json == null) return LicenseType.unknown;

  // final license = json['license'] as String?;
  Map<String, dynamic>? data;
  String? license;

  if (json != null || json!.isNotEmpty) {
    data = json['data'] as Map<String, dynamic>?;
    if (data != null) {
      license = data['license'] as String?;
    }
  }

  if (license == null) return LicenseType.unknown;

  switch (license) {
    case 'Regular License':
      return LicenseType.regular;
    case 'Extended License':
      return LicenseType.extended;
    default:
      return LicenseType.unknown;
  }
});

enum LicenseType {
  regular,
  extended,
  unknown,
}
