import 'package:flutter_riverpod/flutter_riverpod.dart';

// Create a StateProvider to hold the boolean value
final menuProvider = StateProvider<bool>((ref) => false);

// Function to toggle the boolean value
void toggleBool(WidgetRef ref) {
  ref.read(menuProvider.notifier).state = !ref.read(menuProvider);
}
