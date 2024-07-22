// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism/glassmorphism.dart';

import 'package:lamatadmin/core/constants/color_constants.dart';
import 'package:lamatadmin/models/coin_plans.dart';
import 'package:lamatadmin/providers/coin_plans_provider.dart';
import 'package:lamatadmin/views/dashboard/components/header.dart';
import 'package:lamatadmin/views/home/components/side_menu.dart';
import 'package:lamatadmin/views/others/other_widgets.dart';
import 'package:restart_app/restart_app.dart';

class PlansPage extends ConsumerStatefulWidget {
  final Function? changeScreen;
  const PlansPage({super.key, this.changeScreen});

  @override
  ConsumerState<PlansPage> createState() => PlansPageState();
}

class PlansPageState extends ConsumerState<PlansPage> {
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
    final plansRef = ref.watch(getPlansProvider);

    return Scaffold(
      drawer: SideMenu(changeScreen: widget.changeScreen!),
      body: plansRef.when(
        data: (plans) {
          List<CoinPlanData>? plansList = plans.data;

          if (_searchController.text.isNotEmpty) {
            plansList = plansList!
                .where((plan) => plan.coinPlanName!
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase()))
                .toList();
          }

          if (_sortAscending) {
            plansList!
                .sort((a, b) => a.coinPlanName!.compareTo(b.coinPlanName!));
          } else {
            plansList!
                .sort((a, b) => b.coinPlanName!.compareTo(a.coinPlanName!));
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
                              "Coin Plans",
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
                                  plansList.length,
                                  (index) {
                                    final plan = plansList![index];
                                    return userDataRow(index, plan, plansList);
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

  DataRow userDataRow(int index, CoinPlanData plan, List plans) {
    // bool isTrending = plan.likes.length > plans.length / 3 ? true : false;
    return DataRow(
      cells: [
        DataCell(Text((index + 1).toString())),
        const DataCell(
          Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.monetization_on_rounded, size: 20)),
        ),
        DataCell(Text(plan.coinPlanName ?? "")),
        DataCell(Text(
            "${DateTime.fromMillisecondsSinceEpoch(plan.createdAt!).day}/${DateTime.fromMillisecondsSinceEpoch(plan.createdAt!).month}/${DateTime.fromMillisecondsSinceEpoch(plan.createdAt!).year}")),
        DataCell(
          Text(
            plan.coinPlanPrice.toString(),
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
  final _playstoreIdController = TextEditingController();
  final _appstoreIdController = TextEditingController();

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
          title: const Text('Create New Coin Plan'),
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
                      return 'Please enter a plan name';
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
                    hintText: 'Enter plan price',
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
                    hintText: 'Amount of Coins',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter amount of coinns';
                    } else if (value.contains('.') || value.contains(',')) {
                      return 'Please enter an amount without decimal';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _playstoreIdController,
                  decoration: const InputDecoration(
                    hintText: 'playstore_product_id',
                  ),
                  validator: (value) {
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _appstoreIdController,
                  decoration: const InputDecoration(
                    hintText: 'appstore_product_id',
                  ),
                  validator: (value) {
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
                  final CoinPlanData newPlan = CoinPlanData(
                    coinPlanId: random.nextInt(999999) + 1000,
                    coinPlanName: _nameController.text.trim(),
                    coinPlanDescription: _descController.text.trim(),
                    coinPlanPrice: double.parse(_priceController.text.trim()),
                    coinAmount: int.parse(_amountController.text.trim()),
                    playstoreProductId: _playstoreIdController.text.trim(),
                    appstoreProductId: _appstoreIdController.text.trim(),
                    createdAt: DateTime.now().millisecondsSinceEpoch,
                    updatedAt: DateTime.now().millisecondsSinceEpoch,
                  );

                  await addPlan(plan: newPlan).then((value) {
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
  final CoinPlanData plan;
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
  final _playstoreIdController = TextEditingController();
  final _appstoreIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    _nameController.text = widget.plan.coinPlanName!;
    _descController.text = widget.plan.coinPlanDescription!;
    _priceController.text = widget.plan.coinPlanPrice.toString();
    _amountController.text = widget.plan.coinAmount.toString();
    _playstoreIdController.text = widget.plan.playstoreProductId!;
    _appstoreIdController.text = widget.plan.appstoreProductId!;

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
          title: const Text('Create New Coin Plan'),
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
                      return 'Please enter a plan name';
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
                    hintText: 'Enter plan price',
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
                    hintText: 'Amount of Coins',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter amount of coinns';
                    } else if (value.contains('.') || value.contains(',')) {
                      return 'Please enter an amount without decimal';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _playstoreIdController,
                  decoration: const InputDecoration(
                    hintText: 'playstore_product_id',
                  ),
                  validator: (value) {
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _appstoreIdController,
                  decoration: const InputDecoration(
                    hintText: 'appstore_product_id',
                  ),
                  validator: (value) {
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
                    EasyLoading.show(status: "Deleting Plan...");
                    await deletePlan(planId: widget.plan.coinPlanId.toString());
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
                      EasyLoading.show(status: "Saving Plan...");

                      final CoinPlanData newPlan = CoinPlanData(
                        coinPlanId: widget.plan.coinPlanId,
                        coinPlanName: _nameController.text.trim(),
                        coinPlanDescription: _descController.text.trim(),
                        coinPlanPrice:
                            double.parse(_priceController.text.trim()),
                        coinAmount: int.parse(_amountController.text.trim()),
                        playstoreProductId: _playstoreIdController.text.trim(),
                        appstoreProductId: _appstoreIdController.text.trim(),
                        createdAt: widget.plan.createdAt,
                        updatedAt: DateTime.now().millisecondsSinceEpoch,
                      );

                      await editPlan(plan: newPlan).then((value) {
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
