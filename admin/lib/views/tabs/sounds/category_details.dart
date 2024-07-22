import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism/glassmorphism.dart';

import 'package:lamatadmin/core/constants/color_constants.dart';
import 'package:lamatadmin/helpers/config.dart';
import 'package:lamatadmin/models/songs_model.dart';
import 'package:lamatadmin/providers/admin_provider.dart';
import 'package:lamatadmin/providers/songs_provider.dart';
import 'package:lamatadmin/responsive.dart';
import 'package:lamatadmin/views/tabs/sounds/components/song_widget.dart';

class CategoryDetailsScreen extends ConsumerStatefulWidget {
  final SoundData soundsData;
  final Function? changeScreen;
  const CategoryDetailsScreen({
    super.key,
    this.changeScreen,
    required this.soundsData,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      CategoryDetailsScreenState();
}

class CategoryDetailsScreenState extends ConsumerState<CategoryDetailsScreen> {
  // Widget currentScreen =
  //     const DashboardScreen(); // Initially set to DashboardScreen

  // void changeScreen(Widget screen) {
  //   setState(() {
  //     currentScreen = screen;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        //padding: EdgeInsets.all(defaultPadding),
        child: Container(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            children: [
              // Header(changeScreen: widget.changeScreen),
              const SizedBox(height: defaultPadding),
              SongsGrid(soundsData: widget.soundsData),
              const SizedBox(height: defaultPadding),
            ],
          ),
        ),
      ),
    );
  }
}

class SongsGrid extends ConsumerWidget {
  final SoundData soundsData;
  const SongsGrid({
    Key? key,
    required this.soundsData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(
              width: 10,
            ),
            ElevatedButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: AppConstants.primaryColorDark,
                padding: EdgeInsets.symmetric(
                  horizontal: defaultPadding * 1.5,
                  vertical:
                      defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
                ),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => NewSongForm(soundsData: soundsData),
                );
              },
              icon:
                  const Icon(Icons.add, color: AppConstants.primaryColorLight),
              label: const Text(
                "Add New",
                style: TextStyle(color: AppConstants.primaryColorLight),
              ),
            ),
          ],
        ),
        const SizedBox(height: defaultPadding),
        Responsive(
          mobile: CategoryCard(
            crossAxisCount: size.width < 650 ? 2 : 4,
            childAspectRatio: size.width < 650 ? 1.2 : 1,
            soundsData: soundsData,
          ),
          tablet: CategoryCard(
            soundsData: soundsData,
          ),
          desktop: CategoryCard(
            childAspectRatio: size.width < 1400 ? 1.2 : 1.4,
            soundsData: soundsData,
          ),
        ),
      ],
    );
  }
}

class CategoryCard extends ConsumerWidget {
  final SoundData soundsData;
  const CategoryCard({
    Key? key,
    this.crossAxisCount = 5,
    this.childAspectRatio = 1.0,
    required this.soundsData,
  }) : super(key: key);

  final int crossAxisCount;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context, ref) {
    final soundDataStream = ref.watch(soundDataProvider);
    // final isLoading = ref.watch(totalStorageSizeProvider).isLoading;
    return soundDataStream.when(
      data: (categories) {
        if (categories.isEmpty) {
          return const Center(
            child: Text("No Songs"),
          );
        } else {
          final catData = categories.firstWhere((element) =>
              element.soundCategoryId == soundsData.soundCategoryId);
          final songsList = catData.soundList;

          List<SoundList> songsListMap =
              songsList!.map((item) => SoundList.fromJson(item)).toList();
          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: songsListMap.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: defaultPadding,
              mainAxisSpacing: defaultPadding,
              childAspectRatio: childAspectRatio,
            ),
            itemBuilder: (context, index) =>
                SongWidget(songData: songsListMap[index]),
          );
        }
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => const CircularProgressIndicator(),
    );
  }
}

class NewSongForm extends ConsumerStatefulWidget {
  final SoundData soundsData;
  const NewSongForm({super.key, required this.soundsData});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => NewSongFormState();
}

class NewSongFormState extends ConsumerState<NewSongForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _imageController = TextEditingController();
  final _singerController = TextEditingController();
  final _soundController = TextEditingController();
  final _durationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final currentUser = ref.watch(currentAdminProvider).value;
    return GlassmorphicContainer(
        width: width * .5,
        height: height * .5,
        borderRadius: 20,
        blur: 20,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFffffff).withOpacity(0.1),
              const Color(0xFFFFFFFF).withOpacity(0.05),
            ],
            stops: const [
              0.3,
              1,
            ]),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFffffff).withOpacity(0),
            const Color((0xFFFFFFFF)).withOpacity(0),
          ],
        ), // Adjust blur strength
        child: AlertDialog(
          title: const Center(
              child: Text(
            'Add New Sound',
            style: TextStyle(color: Colors.white),
          )),
          backgroundColor: Colors.transparent,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText:
                                'Enter song title', // Use labelText for placeholder
                            hintStyle: const TextStyle(color: Colors.white),
                            filled: true,
                            fillColor:
                                AppConstants.primaryColor.withOpacity(.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  AppConstants.defaultNumericValue * 2),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          cursorColor: Colors.white,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter category name';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: TextFormField(
                          controller: _singerController,
                          decoration: InputDecoration(
                            hintText:
                                'Enter singer name', // Use labelText for placeholder
                            hintStyle: const TextStyle(color: Colors.white),
                            filled: true,
                            fillColor:
                                AppConstants.primaryColor.withOpacity(.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  AppConstants.defaultNumericValue * 2),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          cursorColor: Colors.white,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter singer name';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: TextFormField(
                          controller: _soundController,
                          decoration: InputDecoration(
                            hintText:
                                'Enter Sound Link', // Use labelText for placeholder
                            hintStyle: const TextStyle(color: Colors.white),
                            filled: true,
                            fillColor:
                                AppConstants.primaryColor.withOpacity(.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  AppConstants.defaultNumericValue * 2),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          cursorColor: Colors.white,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter sound name';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: TextFormField(
                          controller: _imageController,
                          decoration: InputDecoration(
                            hintText:
                                'Enter Link to image', // Use labelText for placeholder
                            hintStyle: const TextStyle(color: Colors.white),
                            filled: true,
                            fillColor:
                                AppConstants.primaryColor.withOpacity(.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  AppConstants.defaultNumericValue * 2),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          cursorColor: Colors.white,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter Link to an image';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: TextFormField(
                          controller: _durationController,
                          decoration: InputDecoration(
                            hintText:
                                'Enter song duration (Min:Sec)', // Use labelText for placeholder
                            hintStyle: const TextStyle(color: Colors.white),
                            filled: true,
                            fillColor:
                                AppConstants.primaryColor.withOpacity(.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  AppConstants.defaultNumericValue * 2),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          cursorColor: Colors.white,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter song duration';
                            } else if (!value.contains(":")) {
                              return 'Please enter song duration in Min:Sec format';
                            } else if (int.parse(value.split(":")[0]) > 10) {
                              return 'Please enter valid song duration less than 10 Min';
                            } else if (value.contains(RegExp(r'[a-zA-Z]'))) {
                              return 'Please enter valid song duration in Min:Sec format';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      EasyLoading.show(status: 'Adding Song...');
                      await addSongToCategory(
                              SoundList(
                                soundId: (Random().nextInt(1000000000) + 1)
                                    .toString(),
                                soundCategoryId:
                                    widget.soundsData.soundCategoryId,
                                soundTitle: _nameController.text,
                                sound: _soundController.text,
                                duration: _durationController.text,
                                singer: _singerController.text,
                                soundImage: _imageController.text,
                                addedBy: currentUser!.name,
                                createdAt: DateTime.now(),
                                updatedAt: DateTime.now(),
                              ),
                              widget.soundsData.soundCategoryId.toString())
                          .then((value) {
                        EasyLoading.showSuccess("Added Successfully");
                        // Restart.restartApp();
                        Navigator.of(context).pop();
                        setState(() {});
                      });
                    }
                  },
                  child:
                      const Text('Add', style: TextStyle(color: Colors.white)),
                ),
              ]),
            ],
          ),
        ));
  }
}
