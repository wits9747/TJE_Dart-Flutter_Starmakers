import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism/glassmorphism.dart';

import 'package:lamatadmin/core/constants/color_constants.dart';
import 'package:lamatadmin/helpers/config.dart';
import 'package:lamatadmin/models/songs_model.dart';
import 'package:lamatadmin/providers/songs_provider.dart';
import 'package:lamatadmin/views/tabs/sounds/category_details.dart';

class CategoryWidget extends StatefulWidget {
  const CategoryWidget({
    Key? key,
    required this.categoryData,
  }) : super(key: key);
  final SoundData categoryData;

  @override
  CategoryWidgetState createState() => CategoryWidgetState();
}

class CategoryWidgetState extends State<CategoryWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CategoryDetailsScreen(
                      soundsData: widget.categoryData,
                    )));
      },
      child: Container(
        padding: const EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(widget.categoryData.soundCategoryProfile!),
            fit: BoxFit.cover,
          ),
          color: AppConstants.primaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: defaultPadding,
                            vertical: defaultPadding / 1.8),
                        height: 40,
                        // width: 40,
                        decoration: BoxDecoration(
                          color: AppConstants
                              .wallpaperSolidColors[Random().nextInt(
                                  AppConstants.wallpaperSolidColors.length - 1)]
                              .withOpacity(0.1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Text(
                          "${widget.categoryData.soundList!.length} Songs",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ),
                ),
                const Expanded(child: SizedBox()),
                OptionsMenu(
                  categoryData: widget.categoryData,
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: defaultPadding,
                                vertical: defaultPadding / 1.8),
                            height: 40,
                            // width: 40,
                            decoration: BoxDecoration(
                              color: AppConstants
                                  .wallpaperSolidColors[Random().nextInt(
                                      AppConstants.wallpaperSolidColors.length -
                                          1)]
                                  .withOpacity(0.1),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                            ),
                            child: Text(
                              widget.categoryData.soundCategoryName!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            )))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OptionsMenu extends ConsumerWidget {
  final SoundData categoryData;
  const OptionsMenu({
    Key? key,
    required this.categoryData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    return PopupMenuButton(
        offset: const Offset(0, 60),
        onSelected: (value) {
          // your logic
        },
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16))),
        itemBuilder: (BuildContext bc) {
          return [
            PopupMenuItem(
              value: '/edit',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) =>
                      EditCategoryForm(categoryData: categoryData),
                );
              },
              child: const Text("Edit"),
            ),
            PopupMenuItem(
              value: '/delete',
              onTap: () async {
                EasyLoading.show(status: 'Deleting...');
                await deleteSoundDataProvider(categoryData.soundCategoryId!);
                EasyLoading.dismiss();
              },
              child: const Text("Delete"),
            )
          ];
        },
        child: Container(
          // margin: const EdgeInsets.only(left: defaultPadding),
          padding: const EdgeInsets.symmetric(
            horizontal: defaultPadding,
            vertical: defaultPadding / 2,
          ),
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            border: Border.all(color: Colors.white10),
          ),
          child: const Row(
            children: [
              Icon(Icons.keyboard_arrow_down),
            ],
          ),
        ));
  }
}

class EditCategoryForm extends ConsumerStatefulWidget {
  final SoundData categoryData;
  const EditCategoryForm({super.key, required this.categoryData}) : super();

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      EditCategoryFormState();
}

class EditCategoryFormState extends ConsumerState<EditCategoryForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _imageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    _nameController.text = widget.categoryData.soundCategoryName!;
    _imageController.text = widget.categoryData.soundCategoryProfile!;
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
            'Edit Sound Category',
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
                      await editSoundDataProvider(SoundData(
                        soundCategoryId: widget.categoryData.soundCategoryId,
                        soundCategoryName: _nameController.text,
                        soundCategoryProfile: _imageController.text,
                        soundList: widget.categoryData.soundList,
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
