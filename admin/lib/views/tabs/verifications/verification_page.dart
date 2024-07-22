import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lamatadmin/models/verification_form_model.dart';
import 'package:lamatadmin/providers/user_verification_forms_provider.dart';
import 'package:lamatadmin/views/dashboard/components/header.dart';
import 'package:lamatadmin/views/home/components/side_menu.dart';
import 'package:lamatadmin/views/others/other_widgets.dart';
import 'package:lamatadmin/views/tabs/users/user_short_card.dart';
import 'package:lamatadmin/views/tabs/verifications/verification_details_page.dart';

class VerificationsPage extends ConsumerWidget {
  final Function changeScreen;
  const VerificationsPage({super.key, required this.changeScreen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verificationsref = ref.watch(pendingVerificationFormsStreamProvider);
    return Scaffold(
      drawer: SideMenu(changeScreen: changeScreen),
      body: verificationsref.when(
        data: (data) {
          if (data.isEmpty) {
            return Column(
              children: [
                const SizedBox(height: 16),
                Header(changeScreen: changeScreen),
                const SizedBox(height: 32),
                const Spacer(),
                const Center(
                  child: Text('No Pending Verifications'),
                ),
                const Spacer(),
              ],
            );
          } else {
            return Column(
              children: [
                const SizedBox(height: 16),
                Header(changeScreen: changeScreen),
                const SizedBox(height: 32),
                Expanded(child: VerificationFormsBody(pendingForms: data)),
              ],
            );
          }
        },
        error: (error, stackTrace) => const MyErrorWidget(),
        loading: () => const MyLoadingWidget(),
      ),
    );
  }
}

class VerificationFormsBody extends ConsumerWidget {
  final List<VerificationFormModel> pendingForms;
  const VerificationFormsBody({
    super.key,
    required this.pendingForms,
  });

  @override
  Widget build(BuildContext context, ref) {
    pendingForms.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: pendingForms.length,
      itemBuilder: (context, index) {
        final form = pendingForms[index];
        return Card(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: UserShortCard(userId: form.id),
              ),
              const Spacer(),
              const SizedBox(width: 16),
              const Text(
                'Pending Verification!',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              FilledButton(
                child: const Text("Take Action"),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return VerificationDetailsPage(form: form);
                    },
                  ));
                },
              ),
              const SizedBox(width: 16),
            ],
          ),
        );
      },
    );
  }
}
