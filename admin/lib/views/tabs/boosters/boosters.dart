// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism/glassmorphism.dart';

import 'package:lamatadmin/core/constants/color_constants.dart';
import 'package:lamatadmin/models/boosters_model.dart';
import 'package:lamatadmin/providers/booster_plans_provider.dart';
import 'package:lamatadmin/views/dashboard/components/header.dart';
import 'package:lamatadmin/views/home/components/side_menu.dart';
import 'package:lamatadmin/views/others/other_widgets.dart';
import 'package:restart_app/restart_app.dart';

class BoostersPage extends ConsumerStatefulWidget {
  final Function? changeScreen;
  const BoostersPage({super.key, this.changeScreen});

  @override
  ConsumerState<BoostersPage> createState() => BoostersPageState();
}

class BoostersPageState extends ConsumerState<BoostersPage> {
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
    final plansRef = ref.watch(getBoostersProvider);

    return Scaffold(
      drawer: SideMenu(changeScreen: widget.changeScreen!),
      body: plansRef.when(
        data: (plans) {
          List<BoosterPlanData>? boostersList = plans.data;

          if (_searchController.text.isNotEmpty) {
            boostersList = boostersList!
                .where((plan) => plan.boosterPlanName!
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase()))
                .toList();
          }

          if (_sortAscending) {
            boostersList!.sort(
                (a, b) => a.boosterPlanName!.compareTo(b.boosterPlanName!));
          } else {
            boostersList!.sort(
                (a, b) => b.boosterPlanName!.compareTo(a.boosterPlanName!));
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
                          builder: (context) => const CreateNewPlanPopup());
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
                              "Boosters",
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
                                    label: const Text('Name'),
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
                                  boostersList.length,
                                  (index) {
                                    final plan = boostersList![index];
                                    return userDataRow(
                                        index, plan, boostersList);
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
        error: (error, stack) => Padding(
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
                        builder: (context) => const CreateNewPlanPopup());
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
                    // padding: const EdgeInsets.all(defaultPadding),
                    // decoration: const BoxDecoration(
                    //   color: secondaryColor,
                    //   borderRadius: BorderRadius.all(Radius.circular(10)),
                    // ),
                    // child: const MyErrorWidget()
                    ),
              )
            ],
          ),
        ),
      ),
    );
  }

  DataRow userDataRow(int index, BoosterPlanData plan, List plans) {
    // bool isTrending = plan.likes.length > plans.length / 3 ? true : false;
    return DataRow(
      cells: [
        DataCell(Text((index + 1).toString())),
        const DataCell(
          Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.monetization_on_rounded, size: 20)),
        ),
        DataCell(Text(plan.boosterPlanName ?? "")),
        DataCell(Text(
            "${DateTime.fromMillisecondsSinceEpoch(plan.createdAt!).day}/${DateTime.fromMillisecondsSinceEpoch(plan.createdAt!).month}/${DateTime.fromMillisecondsSinceEpoch(plan.createdAt!).year}")),
        DataCell(
          Text(
            plan.boosterPlanPrice.toString(),
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
                  builder: (context) => EditPlanPopup(plan: plan));
            },
          ),
        ),
      ],
    );
  }
}

class CreateNewPlanPopup extends ConsumerStatefulWidget {
  const CreateNewPlanPopup({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      CreateNewPlanPopupState();
}

class CreateNewPlanPopupState extends ConsumerState<CreateNewPlanPopup> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _amountController = TextEditingController();

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
          title: const Text('Create New Booster'),
          content: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  // header: "Name",
                  decoration: const InputDecoration(
                    hintText: 'Enter name',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a booster name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  // header: "Email",
                  // placeholder: 'Enter email',
                  decoration: const InputDecoration(
                    hintText: 'Enter description',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Enter booster price(coins)',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Amount of Boosts',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter amount of boosts';
                    } else if (value.contains('.') || value.contains(',')) {
                      return 'Please enter number of boosts without decimal';
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
                  EasyLoading.show(status: "Creating Plan...");
                  Random random = Random();
                  final BoosterPlanData newPlan = BoosterPlanData(
                    boosterPlanId: random.nextInt(999999) + 1000,
                    boosterPlanName: _nameController.text.trim(),
                    boosterPlanDescription: _descController.text.trim(),
                    boosterPlanPrice:
                        double.parse(_priceController.text.trim()),
                    boosterAmount: int.parse(_amountController.text.trim()),
                    createdAt: DateTime.now().millisecondsSinceEpoch,
                    updatedAt: DateTime.now().millisecondsSinceEpoch,
                  );

                  await addBooster(plan: newPlan).then((value) {
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

class EditPlanPopup extends ConsumerStatefulWidget {
  final BoosterPlanData plan;
  const EditPlanPopup({super.key, required this.plan});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => EditPlanPopupState();
}

class EditPlanPopupState extends ConsumerState<EditPlanPopup> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    _nameController.text = widget.plan.boosterPlanName!;
    _descController.text = widget.plan.boosterPlanDescription!;
    _priceController.text = widget.plan.boosterPlanPrice.toString();
    _amountController.text = widget.plan.boosterAmount.toString();

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
          title: const Text('Create New Booster'),
          content: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter name',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a booster name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    hintText: 'Enter description',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Enter booster coins cost',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter price in coins';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Amount of Boosts',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter amount of boosts';
                    } else if (value.contains('.') || value.contains(',')) {
                      return 'Please enter an amount without decimal';
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
                    EasyLoading.show(status: "Deleting Booster...");
                    await deleteBooster(
                        planId: widget.plan.boosterPlanId.toString());
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
                      EasyLoading.show(status: "Saving Booster...");

                      final BoosterPlanData newPlan = BoosterPlanData(
                        boosterPlanId: widget.plan.boosterPlanId,
                        boosterPlanName: _nameController.text.trim(),
                        boosterPlanDescription: _descController.text.trim(),
                        boosterPlanPrice:
                            double.parse(_priceController.text.trim()),
                        boosterAmount: int.parse(_amountController.text.trim()),
                        createdAt: widget.plan.createdAt,
                        updatedAt: DateTime.now().millisecondsSinceEpoch,
                      );

                      await editBooster(plan: newPlan).then((value) {
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
