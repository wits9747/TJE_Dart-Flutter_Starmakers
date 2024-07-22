// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:lamatadmin/helpers/config.dart';
import 'package:lamatadmin/helpers/email_verifier.dart';
import 'package:lamatadmin/models/admin_model.dart';
import 'package:lamatadmin/providers/admin_provider.dart';
import 'package:lamatadmin/providers/auth_provider.dart';
import 'package:lamatadmin/views/dashboard/components/header.dart';
import 'package:lamatadmin/views/home/components/side_menu.dart';
import 'package:lamatadmin/views/others/other_widgets.dart';

class AdminsPage extends ConsumerWidget {
  final Function changeScreen;
  const AdminsPage({super.key, required this.changeScreen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminsRef = ref.watch(allAdminsProviderProvider);

    return Scaffold(
      drawer: SideMenu(changeScreen: changeScreen),
      body: adminsRef.when(
        data: (data) {
          if (data.isEmpty) {
            return Column(
              children: [
                const SizedBox(height: 16),
                Header(changeScreen: changeScreen),
                const SizedBox(height: 32),
                Row(
                  children: [
                    const SizedBox(width: 16),
                    const Text('Create New'),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () async {
                        showDialog(
                            barrierColor: Colors.transparent,
                            context: context,
                            builder: (context) => const CreateNewAdminPopup());
                      },
                    ),
                  ],
                ),
                const Spacer(),
                const Text('No admins found'),
                const Spacer(),
              ],
            );
          } else {
            return Column(
              children: [
                const SizedBox(height: 16),
                Header(changeScreen: changeScreen),
                const SizedBox(height: 32),
                Row(
                  children: [
                    const SizedBox(width: 16),
                    const Text('Create New'),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () async {
                        showDialog(
                            barrierColor: Colors.transparent,
                            context: context,
                            builder: (context) => const CreateNewAdminPopup());
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: ListView.separated(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final admin = data[index];
                      return Card(
                        child: ListTile(
                          title: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(admin.name,
                                    style:
                                        const TextStyle(color: Colors.white)),
                                const SizedBox(width: 8),
                                Text(
                                  "[${admin.permissions.isEmpty ? "Only Insights" : admin.permissions.join(', ')}]",
                                  style: Theme.of(context).textTheme.bodySmall,
                                )
                              ],
                            ),
                          ),
                          subtitle: Text(admin.email,
                              style: const TextStyle(color: Colors.white)),
                          trailing: const Icon(Icons.chevron_right,
                              color: Colors.white),
                          onTap: () async {
                            showDialog(
                                context: context,
                                builder: (context) =>
                                    EditAdminPermission(admin: admin));
                          },
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(),
                  ),
                ),
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

class CreateNewAdminPopup extends ConsumerStatefulWidget {
  const CreateNewAdminPopup({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateNewAdminPopupState();
}

class _CreateNewAdminPopupState extends ConsumerState<CreateNewAdminPopup> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final List<String> _adminPermissions = [];
  html.File? _cloudFileProfile;
  Uint8List? _fileBytesProfile;
  Image? _imageWidgetProfile;

  Future<void> getProfileImage() async {
    html.File? mediaData = await ImagePickerWeb.getImageAsFile();
    // String? mimeType = mime(Path.basename(mediaData!.name));
    html.File? mediaFile = mediaData;
    final reader = html.FileReader();
    reader.readAsArrayBuffer(mediaData!);
    await reader.onLoad.first;
    final image = reader.result as Uint8List;

    // html.File(mediaData.data!, mediaData.fileName!, {'type': mimeType});

    if (mediaFile != null) {
      setState(() {
        _cloudFileProfile = mediaFile;
        _fileBytesProfile = image;
        _imageWidgetProfile = Image.memory(image);
      });
    }
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
        border: 0,
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
          backgroundColor: Theme.of(context).cardColor,
          title: const Text('Create New Admin'),
          content: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      // padding: const EdgeInsets.all(
                      //     defaultPadding * 0.75),
                      height: 100,
                      width: 100,
                      decoration: _cloudFileProfile == null
                          ? BoxDecoration(
                              color: AppConstants.primaryColor.withOpacity(0.1),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20)),
                            )
                          : const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                      child: _cloudFileProfile != null
                          ? _imageWidgetProfile
                          : const SizedBox.shrink(),
                    ),
                    //Edit Icon
                    if (_cloudFileProfile == null)
                      TextButton(
                        onPressed: () async {
                          // Pick image from gallery
                          await getProfileImage();
                        },
                        child: const Text(
                          "PROFILE\nPIC",
                          style: TextStyle(
                              color: AppConstants.backgroundColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    if (_cloudFileProfile != null)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: AppConstants.backgroundColor,
                          child: IconButton(
                            onPressed: () async {
                              // Pick image from gallery
                              await getProfileImage();
                            },
                            icon: const Icon(Icons.mode_edit_outline_outlined),
                            color: AppConstants.primaryColor,
                          ),
                        ),
                      )
                  ],
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  // header: "Name",
                  decoration: const InputDecoration(
                    hintText: 'Enter name',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  // header: "Email",
                  // placeholder: 'Enter email',
                  decoration: const InputDecoration(
                    hintText: 'Enter email',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter an email';
                    } else if (emailVerifier().hasMatch(value) == false) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  // header: "Password",
                  obscureText: true,
                  // placeholder: 'Enter password',
                  decoration: const InputDecoration(
                    hintText: 'Enter password',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a password';
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  // header: "Confirm Password",
                  obscureText: true,
                  // placeholder: 'Confirm password',
                  decoration: const InputDecoration(
                    hintText: 'Confirm password',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please confirm your password';
                    } else if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  "Permissions",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    children: permissions.map(
                      (e) {
                        return CheckboxListTile(
                          value: _adminPermissions.contains(e),
                          title: Text(e),
                          onChanged: (value) {
                            setState(() {
                              if (value!) {
                                _adminPermissions.add(e);
                              } else {
                                _adminPermissions.remove(e);
                              }
                            });
                          },
                        );
                      },
                    ).toList(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await AuthProvider.registerNewAdmin(
                          email: _emailController.text.trim(),
                          password: _passwordController.text.trim())
                      .then((value) async {
                    if (value != null) {
                      String? uploadedProfilePic;
                      EasyLoading.show(status: "Saving Admin...");
                      final storage = FirebaseStorage.instance;
                      final SettableMetadata metadataProfile = SettableMetadata(
                        contentType: _cloudFileProfile!.name.contains('.png')
                            ? 'image/png'
                            : 'image/jpeg',
                      );
                      final reffProfile = storage
                          .ref()
                          .child("admin_profile/${_cloudFileProfile!.name}");
                      final uploadTaskProfile = reffProfile.putData(
                          _fileBytesProfile!, metadataProfile);
                      await uploadTaskProfile.whenComplete(() async {
                        // uploadedLogo download Url
                        uploadedProfilePic = await reffProfile.getDownloadURL();
                      });
                      final AdminModel newAdmin = AdminModel(
                        id: value.uid,
                        name: _nameController.text.trim(),
                        email: _emailController.text.trim(),
                        profilePic: uploadedProfilePic!,
                        permissions: _adminPermissions,
                        isSuperAdmin: false,
                        createdAt: DateTime.now(),
                      );

                      await AdminProvider.addAdmin(admin: newAdmin)
                          .then((value) {
                        EasyLoading.dismiss();
                        ref.invalidate(allAdminsProviderProvider);
                        Navigator.of(context).pop();
                      });
                    }
                  });
                }
              },
              child: const Text('Create'),
            ),
          ],
        ));
  }
}

class EditAdminPermission extends ConsumerStatefulWidget {
  final AdminModel admin;
  const EditAdminPermission({
    super.key,
    required this.admin,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditAdminPermissionState();
}

class _EditAdminPermissionState extends ConsumerState<EditAdminPermission> {
  final List<String> _adminPermissions = [];

  @override
  void initState() {
    _adminPermissions.addAll(widget.admin.permissions);
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
        border: 0,
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
        borderGradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.white,
          ],
        ), // Adjust blur strength
        child: AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Edit Admin Permissions',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.red),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Delete Admin'),
                        content: const Text(
                            'Are you sure you want to delete this admin?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              EasyLoading.show(status: "Deleting Admin...");
                              await AdminProvider.deleteAdmin(
                                      adminId: widget.admin.id)
                                  .then((value) {
                                EasyLoading.dismiss();
                                ref.invalidate(allAdminsProviderProvider);
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              });
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );
                },
              )
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Name: ${widget.admin.name}",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Permissions",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Wrap(
                    spacing: 8,
                    children: permissions.map(
                      (e) {
                        return CheckboxListTile(
                          value: _adminPermissions.contains(e),
                          title: Text(e),
                          onChanged: (value) {
                            setState(() {
                              if (value!) {
                                _adminPermissions.add(e);
                              } else {
                                _adminPermissions.remove(e);
                              }
                            });
                          },
                        );
                      },
                    ).toList(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                EasyLoading.show(status: "Saving Admin...");

                final AdminModel newAdmin =
                    widget.admin.copyWith(permissions: _adminPermissions);

                await AdminProvider.updateAdmin(admin: newAdmin).then((value) {
                  EasyLoading.dismiss();
                  ref.invalidate(allAdminsProviderProvider);
                  Navigator.of(context).pop();
                });
              },
              child: const Text('Save'),
            ),
          ],
        ));
  }
}
