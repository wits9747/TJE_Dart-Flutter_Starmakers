import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TextController extends StateNotifier<TextEditingController> {
  TextController() : super(TextEditingController());

  void updateText(String newText) {
    state.text = newText;
  }
}

final textControllerProvider =
    StateNotifierProvider<TextController, TextEditingController>(
  (ref) => TextController(),
);

// final filteredUsersProvider = Provider((ref) {
//   final usersAsyncValue = ref.watch(usersShortStreamProvider);
//   final textController = ref.watch(textControllerProvider);

//   return usersAsyncValue.when(
//     data: (users) {
//       return users
//           .where((user) => user.fullName
//               .toLowerCase()
//               .contains(textController.text.toLowerCase()))
//           .toList();
//     },
//     loading: () => const [], // Return an empty list while loading
//     error: (error, stackTrace) => throw error, // Rethrow errors
//   );
// });
