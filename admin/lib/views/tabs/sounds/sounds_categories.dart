import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism/glassmorphism.dart';

import 'package:lamatadmin/core/constants/color_constants.dart';
import 'package:lamatadmin/helpers/config.dart';
import 'package:lamatadmin/models/songs_model.dart';
import 'package:lamatadmin/providers/songs_provider.dart';
import 'package:lamatadmin/responsive.dart';
import 'package:lamatadmin/views/dashboard/components/header.dart';
import 'package:lamatadmin/views/dashboard/dashboard_screen.dart';
import 'package:lamatadmin/views/tabs/sounds/components/category_widget.dart';

class SoundsScreen extends ConsumerStatefulWidget {
  final Function changeScreen;
  const SoundsScreen({
    super.key,
    required this.changeScreen,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => SoundsScreenState();
}

class SoundsScreenState extends ConsumerState<SoundsScreen> {
  Widget currentScreen =
      const DashboardScreen(); // Initially set to DashboardScreen

  void changeScreen(Widget screen) {
    setState(() {
      currentScreen = screen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        //padding: EdgeInsets.all(defaultPadding),
        child: Container(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            children: [
              Header(changeScreen: widget.changeScreen),
              const SizedBox(height: defaultPadding),
              const CategoryGrid(),
              const SizedBox(height: defaultPadding),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryGrid extends ConsumerWidget {
  const CategoryGrid({
    Key? key,
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
                  builder: (context) => const NewCategoryForm(),
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
          ),
          tablet: const CategoryCard(),
          desktop: CategoryCard(
            childAspectRatio: size.width < 1400 ? 1.2 : 1.4,
          ),
        ),
      ],
    );
  }
}

class CategoryCard extends ConsumerWidget {
  const CategoryCard({
    Key? key,
    this.crossAxisCount = 5,
    this.childAspectRatio = 1.0,
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
            child: Text("No Categories"),
          );
        } else {
          List<Map<String, dynamic>> categoryData = [];
          for (final soundData in categories) {
            categoryData.add({
              "sound_category_id": soundData.soundCategoryId,
              "sound_category_name": soundData.soundCategoryName,
              "sound_category_profile": soundData.soundCategoryProfile,
              "sound_list": soundData.soundList,
            });
          }

          List<SoundData> categoryDataList =
              categoryData.map((item) => SoundData.fromJson(item)).toList();
          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: categoryDataList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: defaultPadding,
              mainAxisSpacing: defaultPadding,
              childAspectRatio: childAspectRatio,
            ),
            itemBuilder: (context, index) =>
                CategoryWidget(categoryData: categoryDataList[index]),
          );
        }
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => const CircularProgressIndicator(),
    );
  }
}

class NewCategoryForm extends ConsumerStatefulWidget {
  const NewCategoryForm({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => NewCategoryFormState();
}

class NewCategoryFormState extends ConsumerState<NewCategoryForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _imageController = TextEditingController();

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
            'Add Sound Category',
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
                                'Enter category name', // Use labelText for placeholder
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
                      EasyLoading.show(status: 'Adding Category...');
                      await addSoundDataProvider(SoundData(
                        soundCategoryId: Random().nextInt(1000000000) + 1,
                        soundCategoryName: _nameController.text,
                        soundCategoryProfile: _imageController.text,
                        soundList: [],
                      )).then((value) {
                        EasyLoading.showSuccess("Added Successfully");
                        // Restart.restartApp();
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
