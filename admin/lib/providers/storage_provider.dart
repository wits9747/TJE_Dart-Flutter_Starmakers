// providers.dart

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseStorageProvider = Provider((ref) => FirebaseStorage.instance);

final totalStorageSizeProvider = FutureProvider<int>((ref) async {
  final storage = ref.read(firebaseStorageProvider);
  final rootReference = storage.ref();

  try {
    final totalSize = await calculateTotalSize(rootReference);
    return totalSize;
  } catch (error) {
    // Handle errors appropriately
    rethrow;
  }
});

Future<int> calculateTotalSize(Reference reference) async {
  int totalSize = 0;

  final listResult = await reference.listAll();

  for (final item in listResult.items) {
    // If it's a folder, recursively calculate its size
    totalSize += await calculateTotalSize(item);
  }

  return totalSize;
}
