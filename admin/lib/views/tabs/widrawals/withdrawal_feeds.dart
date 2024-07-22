// ignore_for_file: deprecated_member_use

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:lamatadmin/core/constants/color_constants.dart';
import 'package:lamatadmin/helpers/config.dart';
import 'package:lamatadmin/models/withdrawal_model.dart';
import 'package:lamatadmin/providers/withdrawals.dart';
import 'package:lamatadmin/responsive.dart';
import 'package:lamatadmin/views/dashboard/components/header.dart';
import 'package:lamatadmin/views/home/components/side_menu.dart';
import 'package:lamatadmin/views/others/other_widgets.dart';
import 'package:lamatadmin/views/tabs/widrawals/withdrawal_detail.dart';

class WithdrawalsPage extends ConsumerStatefulWidget {
  final Function? changeScreen;
  const WithdrawalsPage({super.key, this.changeScreen});

  @override
  ConsumerState<WithdrawalsPage> createState() => _WithdrawalsPageState();
}

class _WithdrawalsPageState extends ConsumerState<WithdrawalsPage> {
  bool _sortAscending = true;
  final _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final wdRef = ref.watch(getWithdrawalsProvider);

    return Scaffold(
      drawer: SideMenu(changeScreen: widget.changeScreen!),
      body: wdRef.when(
        data: (withdrawals) {
          if (_searchController.text.isNotEmpty) {
            withdrawals = withdrawals
                .where((withdrawal) => withdrawal.accountName!
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase()))
                .toList();
          }

          if (_sortAscending) {
            withdrawals
                .sort((a, b) => a.accountName!.compareTo(b.accountName!));
          } else {
            withdrawals
                .sort((a, b) => b.accountName!.compareTo(a.accountName!));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Header(changeScreen: widget.changeScreen!),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(
                      width: (Responsive.isMobile(context))
                          ? width * .5
                          : width * .2,
                      child: TextFormField(
                        controller: _searchController,
                        onChanged: (value) {
                          if (value.isEmpty) {
                            setState(() {});
                          } else if (value.length >= 2) {
                            setState(() {});
                          }
                        },
                        decoration: InputDecoration(
                          hintText: "Search",
                          fillColor: secondaryColor,
                          filled: true,
                          border: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          suffixIcon: Container(
                            padding:
                                const EdgeInsets.all(defaultPadding * 0.75),
                            margin: const EdgeInsets.symmetric(
                                horizontal: defaultPadding / 2),
                            decoration: BoxDecoration(
                              color:
                                  AppConstants.secondaryColor.withOpacity(.1),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                            ),
                            child: SvgPicture.asset(
                              "assets/icons/Search.svg",
                              color: AppConstants.secondaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                    wdRef.when(
                      data: (totalTeels) => Text('Total: ${totalTeels.length}'),
                      loading: () => const SizedBox(),
                      error: (error, stack) => const SizedBox(),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
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
                              "Recent Withdrawals",
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
                                      label: Text("Status"), fixedWidth: 100),
                                  DataColumn2(
                                    label: const Text('User'),
                                    onSort: (i, b) {
                                      setState(() {
                                        _sortAscending = !_sortAscending;
                                      });
                                    },
                                  ),
                                  const DataColumn2(label: Text("Date")),
                                  const DataColumn2(label: Text('Amount')),
                                  const DataColumn2(
                                      label: Text("View"), fixedWidth: 100)
                                ],
                                rows: List.generate(
                                  withdrawals.length,
                                  (index) {
                                    final withdrawal = withdrawals[index];
                                    return userDataRow(
                                        index, withdrawal, withdrawals);
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

  DataRow userDataRow(int index, WithrawalModel withdrawal, List withdrawals) {
    return DataRow(
      cells: [
        DataCell(Text((index + 1).toString())),
        DataCell(
          Padding(
              padding: const EdgeInsets.all(4),
              child: Text(withdrawal.status.toUpperCase())),
        ),
        DataCell(Text(withdrawal.accountName ?? "")),
        DataCell(Text(
            "${withdrawal.createdAt.day}/${withdrawal.createdAt.month}/${withdrawal.createdAt.year}")),
        DataCell(
          Text(
            withdrawal.amount.toStringAsFixed(2),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataCell(
          FilledButton(
            child: const Text("View"),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return WithdrawalDetailsPage(withdrawal: withdrawal);
              }));
            },
          ),
        ),
      ],
    );
  }
}
