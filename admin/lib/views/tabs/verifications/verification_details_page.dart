import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lamatadmin/core/constants/color_constants.dart';
import 'package:lamatadmin/models/verification_form_model.dart';
import 'package:lamatadmin/providers/user_profiles_provider.dart';
import 'package:lamatadmin/providers/user_verification_forms_provider.dart';
import 'package:lamatadmin/views/tabs/users/user_short_card.dart';

class VerificationDetailsPage extends ConsumerStatefulWidget {
  final VerificationFormModel form;

  const VerificationDetailsPage({
    super.key,
    required this.form,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _VerificationDetailsPageState();
}

class _VerificationDetailsPageState
    extends ConsumerState<VerificationDetailsPage> {
  late VerificationFormModel form;
  final _statusMessageController = TextEditingController();

  @override
  void initState() {
    form = widget.form;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verification Action')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 300,
                child: Card(child: UserShortCard(userId: form.id)),
              ),
              const SizedBox(height: 24),
              const Text("ID Images"),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  CachedNetworkImage(
                    imageUrl: form.photoIdFrontViewUrl,
                    width: 300,
                    fit: BoxFit.fitWidth,
                  ),
                  CachedNetworkImage(
                    imageUrl: form.photoIdBackViewUrl,
                    width: 300,
                    fit: BoxFit.fitWidth,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text("Selfie Image"),
              const SizedBox(height: 8),
              CachedNetworkImage(
                imageUrl: form.selfieUrl,
                width: 300,
                fit: BoxFit.fitWidth,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 400,
                child: TextField(
                  controller: _statusMessageController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: "Status Message",
                    fillColor: secondaryColor,
                    filled: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  FilledButton(
                    child: const Text("Approve"),
                    onPressed: () {
                      final VerificationFormModel newForm = form.copyWith(
                        statusMessage:
                            _statusMessageController.text.trim().isEmpty
                                ? null
                                : _statusMessageController.text.trim(),
                        isApproved: true,
                        isPending: false,
                      );

                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Approve Verification"),
                            content: const Text(
                                "Are you sure you want to approve this verification?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  EasyLoading.show(status: 'Updating...');
                                  await VerificationProvider.updateForm(newForm)
                                      .then((value) async {
                                    if (value) {
                                      await UserProfileProvider.verifyUser(
                                              form.id)
                                          .then((value) {
                                        if (value) {
                                          EasyLoading.showSuccess('Updated!');
                                          ref.invalidate(
                                              userProfileProvider(newForm.id));
                                          Navigator.of(context).pop();
                                        }
                                      });
                                    } else {
                                      EasyLoading.showError(
                                          'Failed to update Form!');
                                    }
                                  });
                                },
                                child: const Text("Approve"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  FilledButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.red),
                    ),
                    child: const Text("Reject"),
                    onPressed: () {
                      final VerificationFormModel newForm = form.copyWith(
                        statusMessage:
                            _statusMessageController.text.trim().isEmpty
                                ? null
                                : _statusMessageController.text.trim(),
                        isApproved: false,
                        isPending: false,
                      );

                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Reject Verification"),
                            content: const Text(
                                "Are you sure you want to reject this verification?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  EasyLoading.show(status: 'Updating...');
                                  await VerificationProvider.updateForm(newForm)
                                      .then((value) {
                                    if (value) {
                                      EasyLoading.showSuccess('Updated!');
                                      ref.invalidate(
                                          userProfileProvider(newForm.id));
                                      Navigator.of(context).pop();
                                    } else {
                                      EasyLoading.showError(
                                          'Failed to update Form!');
                                    }
                                  });
                                },
                                child: const Text("Reject"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
