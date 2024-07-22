// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:restart_app/restart_app.dart';

import 'package:lamatadmin/core/constants/color_constants.dart';
import 'package:lamatadmin/models/gifts_model.dart';
import 'package:lamatadmin/providers/gifts_provider.dart';
import 'package:lamatadmin/views/dashboard/components/header.dart';
import 'package:lamatadmin/views/home/components/side_menu.dart';
import 'package:lamatadmin/views/others/other_widgets.dart';

class GiftsPage extends ConsumerStatefulWidget {
  final Function? changeScreen;
  const GiftsPage({super.key, this.changeScreen});

  @override
  ConsumerState<GiftsPage> createState() => GiftsPageState();
}

class GiftsPageState extends ConsumerState<GiftsPage> {
  bool _sortAscending = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _reload();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      initState();
    });
  }

  @override
  Widget build(BuildContext context) {
    final giftsRef = ref.watch(getGiftsProvider);

    return Scaffold(
      drawer: SideMenu(changeScreen: widget.changeScreen!),
      body: giftsRef.when(
        data: (gifts) {
          if (_searchController.text.isNotEmpty) {
            gifts = gifts
                .where((gift) => gift.id!
                    .toString()
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase()))
                .toList();
          }

          if (_sortAscending) {
            gifts.sort((a, b) => a.id!.compareTo(b.id!));
          } else {
            gifts.sort((a, b) => b.id!.compareTo(a.id!));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Header(changeScreen: widget.changeScreen!),
                const SizedBox(height: 16),
                Row(children: [
                  const SizedBox(width: 16),
                  const Text('Create New'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      showDialog(
                          barrierColor: Colors.transparent,
                          context: context,
                          builder: (context) => const CreateNewGiftPopup());
                    },
                  ),
                  Expanded(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                          onPressed: () async {
                            await Restart.restartApp();
                          },
                          icon: const Icon(Icons.replay_rounded)),
                      const SizedBox(width: 16),
                    ],
                  )),
                ]),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                      padding: const EdgeInsets.all(defaultPadding),
                      decoration: const BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Gifts",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Expanded(
                              child: DataTable2(
                                columnSpacing: 16,
                                horizontalMargin: 8,
                                minWidth: 600,
                                sortAscending: _sortAscending,
                                sortColumnIndex: 1,
                                columns: [
                                  const DataColumn2(
                                      label: Text("Order"), fixedWidth: 60),
                                  const DataColumn2(
                                      label: Text("Image"), fixedWidth: 100),
                                  DataColumn2(
                                    label: const Text('ID'),
                                    onSort: (i, b) {
                                      setState(() {
                                        _sortAscending = !_sortAscending;
                                      });
                                    },
                                  ),
                                  const DataColumn2(label: Text("Upload Date")),
                                  const DataColumn2(label: Text('Cost')),
                                  const DataColumn2(
                                      label: Text("Action"), fixedWidth: 100)
                                ],
                                rows: List.generate(
                                  gifts.length,
                                  (index) {
                                    final gift = gifts[index];
                                    return userDataRow(index, gift, gifts);
                                  },
                                ),
                              ),
                            ),
                          ])),
                )
              ],
            ),
          );
        },
        loading: () => const MyLoadingWidget(),
        error: (error, stack) => const MyErrorWidget(),
      ),
    );
  }

  DataRow userDataRow(int index, GiftsModel gift, List gifts) {
    // bool isTrending = plan.likes.length > plans.length / 3 ? true : false;
    return DataRow(
      cells: [
        DataCell(Text((index + 1).toString())),
        const DataCell(
          Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.monetization_on_rounded, size: 20)),
        ),
        DataCell(Text(gift.id.toString())),
        DataCell(Text(
            "${DateTime.fromMillisecondsSinceEpoch(gift.createdAt!).day}/${DateTime.fromMillisecondsSinceEpoch(gift.createdAt!).month}/${DateTime.fromMillisecondsSinceEpoch(gift.createdAt!).year}")),
        DataCell(
          Text(
            gift.coinPrice.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DataCell(
          FilledButton(
            child: const Text("Edit"),
            onPressed: () async {
              showDialog(
                  barrierColor: Colors.transparent,
                  context: context,
                  builder: (context) => EditGiftPopup(gift: gift));
            },
          ),
        ),
      ],
    );
  }
}

class CreateNewGiftPopup extends ConsumerStatefulWidget {
  const CreateNewGiftPopup({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      CreateNewGiftPopupState();
}

class CreateNewGiftPopupState extends ConsumerState<CreateNewGiftPopup> {
  final _formKey = GlobalKey<FormState>();
  final _imageController = TextEditingController();
  final _priceController = TextEditingController();

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
          title: const Text('Create New Gift'),
          content: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _imageController,
                  // header: "Name",
                  decoration: const InputDecoration(
                    hintText: 'Link to image',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a gift image link';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  // header: "Email",
                  // placeholder: 'Enter email',
                  decoration: const InputDecoration(
                    hintText: 'Enter price',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a price';
                    } else if (value.contains('.') || value.contains(',')) {
                      return 'Please enter a price without decimal';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
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
                  EasyLoading.show(status: "Creating Gift...");
                  Random random = Random();
                  final GiftsModel newGift = GiftsModel(
                    id: random.nextInt(999999) + 1000,
                    image: _imageController.text,
                    coinPrice: int.parse(_priceController.text),
                    createdAt: DateTime.now().millisecondsSinceEpoch,
                    updatedAt: DateTime.now().millisecondsSinceEpoch,
                  );

                  await addGift(gift: newGift).then((value) {
                    EasyLoading.dismiss();
                    EasyLoading.showSuccess("Created");
                    Navigator.of(context).pop();
                  });
                }
              },
              child: const Text('Create'),
            ),
          ],
        ));
  }
}

class EditGiftPopup extends ConsumerStatefulWidget {
  final GiftsModel gift;
  const EditGiftPopup({super.key, required this.gift});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => EditGiftPopupState();
}

class EditGiftPopupState extends ConsumerState<EditGiftPopup> {
  final _formKey = GlobalKey<FormState>();
  final _imageController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    _imageController.text = widget.gift.image!;
    _priceController.text = widget.gift.coinPrice.toString();

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
          title: const Text('Edit Gift'),
          content: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _imageController,
                  decoration: const InputDecoration(
                    hintText: 'Enter image link',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a link to image';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Enter price',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a price';
                    } else if (value.contains('.') || value.contains(',')) {
                      return 'Please enter a price without decimal';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          actions: [
            Row(
              children: [
                TextButton(
                  onPressed: () async {
                    EasyLoading.show(status: "Deleting Gift...");
                    await deleteGift(giftId: widget.gift.id.toString());
                    EasyLoading.dismiss();
                    Navigator.of(context).pop();
                  },
                  child:
                      const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      EasyLoading.show(status: "Saving Gift...");

                      final GiftsModel newGift = GiftsModel(
                        id: widget.gift.id,
                        image: _imageController.text.trim(),
                        coinPrice: int.parse(_priceController.text.trim()),
                        createdAt: DateTime.now().millisecondsSinceEpoch,
                        updatedAt: DateTime.now().millisecondsSinceEpoch,
                      );

                      await editGift(gift: newGift).then((value) {
                        EasyLoading.dismiss();
                        EasyLoading.showSuccess("Saved");
                        Navigator.of(context).pop();
                      });
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ));
  }
}
