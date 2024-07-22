import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatadmin/helpers/config.dart';
import 'package:lamatadmin/helpers/date_formater.dart';
import 'package:lamatadmin/providers/account_delete_request_provider.dart';
import 'package:lamatadmin/views/dashboard/components/header.dart';
import 'package:lamatadmin/views/home/components/side_menu.dart';
import 'package:lamatadmin/views/others/other_widgets.dart';
import 'package:lamatadmin/views/tabs/users/user_short_card.dart';

class AccountDeleteRequestsPage extends ConsumerWidget {
  final Function changeScreen;
  const AccountDeleteRequestsPage({super.key, required this.changeScreen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAccountDeleteRequests = ref.watch(accountDeleteRequestsProvider);

    return Scaffold(
      drawer: SideMenu(changeScreen: changeScreen),
      body: allAccountDeleteRequests.when(
        data: (data) {
          data.sort((a, b) {
            final aDaysRemaining =
                a.deleteDate.difference(DateTime.now()).inDays;
            final bDaysRemaining =
                b.deleteDate.difference(DateTime.now()).inDays;

            return bDaysRemaining.compareTo(aDaysRemaining);
          });

          if (data.isEmpty) {
            return Column(children: [
              const SizedBox(height: 16),
              Header(changeScreen: changeScreen),
              const Spacer(),
              const Center(
                child: Text('No account delete requests'),
              ),
              const Spacer(),
            ]);
          } else {
            return Column(children: [
              const SizedBox(height: 16),
              Header(changeScreen: changeScreen),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final userReports = data[index];

                    final daysRemaining = userReports.deleteDate
                        .difference(DateTime.now())
                        .inDays;

                    return Card(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child:
                                UserShortCard(userId: userReports.phoneNumber),
                          ),
                          const SizedBox(width: 16),
                          Text(
                              "Requested at: \n${DateFormatter.toYearMonthDay(userReports.requestDate)}"),
                          const SizedBox(width: 16),
                          Text(
                              "Delete at: \n${DateFormatter.toYearMonthDay(userReports.deleteDate)}"),
                          const SizedBox(width: 16),
                          Text(
                            '$daysRemaining ${daysRemaining == 1 ? 'day' : 'days'} remaining',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 16),
                          if (daysRemaining <= 0)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppConstants
                                    .primaryColor, // Set primary color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppConstants.defaultNumericValue * 2),
                                ),
                              ),
                              child: const Text("Delete"),
                              onPressed: () async {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Delete user'),
                                      content: const Text(
                                          'Are you sure you want to delete this user?'),
                                      actions: [
                                        TextButton(
                                          child: const Text('Cancel'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: const Text('Delete'),
                                          onPressed: () async {
                                            await AccountDeleteRequestProvider
                                                    .deleteUser(
                                                        userReports.phoneNumber)
                                                .then((value) async {
                                              if (value) {
                                                EasyLoading.show(
                                                    status:
                                                        'Deleting account delete request...');
                                                await AccountDeleteRequestProvider
                                                        .deleteRequest(
                                                            userReports
                                                                .phoneNumber)
                                                    .then((value) {
                                                  EasyLoading.dismiss();
                                                  ref.invalidate(
                                                      accountDeleteRequestsProvider);
                                                  Navigator.of(context).pop();
                                                });
                                              }
                                            });
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          const SizedBox(width: 16),
                        ],
                      ),
                    );
                  },
                ),
              )
            ]);
          }
        },
        error: (error, stackTrace) {
          debugPrintStack(stackTrace: stackTrace);
          debugPrint(error.toString());
          return const MyErrorWidget();
        },
        loading: () => const MyLoadingWidget(),
      ),
    );
  }
}
