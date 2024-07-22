import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:lamatadmin/helpers/config.dart';
import 'package:lamatadmin/models/admin_model.dart';
import 'package:lamatadmin/providers/admin_provider.dart';

class ChangeNameDialog extends ConsumerStatefulWidget {
  final AdminModel admin;
  const ChangeNameDialog({
    super.key,
    required this.admin,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChangeNameDialogState();
}

class _ChangeNameDialogState extends ConsumerState<ChangeNameDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void initState() {
    _nameController.text = widget.admin.name;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return GlassmorphicContainer(
        width: width * .5,
        height: height * .5,
        borderRadius: 20,
        blur: 20,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFffffff).withOpacity(0.1),
              const Color(0xFFFFFFFF).withOpacity(0.05),
            ],
            stops: const [
              0.1,
              1,
            ]),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFffffff).withOpacity(0.5),
            const Color((0xFFFFFFFF)).withOpacity(0.5),
          ],
        ), // Adjust blur strength
        child: AlertDialog(
          title: const Text('Change Name'),
          content: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: TextFormField(
                controller: _nameController,
                // header: "Name",
                decoration: InputDecoration(
                  hintText: 'Enter your name', // Use labelText for placeholder
                  hintStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: AppConstants.primaryColor.withOpacity(.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        AppConstants.defaultNumericValue * 2),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final AdminModel newModel = widget.admin.copyWith(
                    name: _nameController.text.trim(),
                  );

                  EasyLoading.show(status: 'Saving...');
                  await AdminProvider.updateAdmin(admin: newModel)
                      .then((value) {
                    if (value) {
                      EasyLoading.dismiss();
                      ref.invalidate(currentAdminProvider);
                      Navigator.of(context).pop();
                    } else {
                      EasyLoading.showError('Failed to save');
                    }
                  });
                }
              },
              child:
                  const Text('Update', style: TextStyle(color: Colors.white)),
            ),
          ],
        ));
  }
}
