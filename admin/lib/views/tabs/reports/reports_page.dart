import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:lamatadmin/models/banned_user_model.dart';
import 'package:lamatadmin/providers/banned_users_provider.dart';
import 'package:lamatadmin/providers/user_reports_provider.dart';
import 'package:lamatadmin/views/dashboard/components/header.dart';
import 'package:lamatadmin/views/home/components/side_menu.dart';
import 'package:lamatadmin/views/others/other_widgets.dart';
import 'package:lamatadmin/views/tabs/users/user_short_card.dart';

class ReportsPage extends ConsumerWidget {
  final Function changeScreen;
  const ReportsPage({super.key, required this.changeScreen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allReportsRef = ref.watch(allReportsProvider);

    return Scaffold(
      drawer: SideMenu(changeScreen: changeScreen),
      body: allReportsRef.when(
        data: (data) {
          data.sort((a, b) => b.reportsCount.compareTo(a.reportsCount));

          if (data.isEmpty) {
            return Column(
              children: [
                const SizedBox(height: 16),
                Header(changeScreen: changeScreen),
                const SizedBox(height: 32),
                const Spacer(),
                const Center(
                  child: Text('No reports'),
                ),
                const Spacer(),
              ],
            );
          } else {
            return Column(
              children: [
                const SizedBox(height: 16),
                Header(changeScreen: changeScreen),
                Expanded(
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final userReports = data[index];
                      return Card(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: UserShortCard(userId: userReports.userId),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '${userReports.reportsCount} ${userReports.reportsCount == 1 ? 'report' : 'reports'}',
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),
                            FilledButton(
                              child: const Text('Ban User'),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return BanUserDialog(
                                        userId: userReports.userId);
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
                ),
              ],
            );
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

class BanUserDialog extends ConsumerStatefulWidget {
  final String userId;
  const BanUserDialog({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BanUserDialogState();
}

class _BanUserDialogState extends ConsumerState<BanUserDialog> {
  int? _banDays;
  bool _isLifetimeBan = false;

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
        title: const Text('Ban User'),
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Are you sure you want to ban this user?'),
              const SizedBox(height: 16),
              const Text('Ban for:'),
              Wrap(
                children: _banForDays
                    .map(
                      (days) => Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ChoiceChip(
                          selectedColor: Colors.blue,
                          label: Text('$days ${days == 1 ? 'day' : 'days'}'),
                          selected: _banDays == days,
                          onSelected: (selected) {
                            setState(() {
                              _banDays = selected ? days : null;
                            });
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Ban for life'),
                  Checkbox(
                      value: _isLifetimeBan,
                      onChanged: (value) {
                        setState(() {
                          _isLifetimeBan = value!;
                        });
                      }),
                ],
              )
            ],
          ),
        ),
        actions: [
          FilledButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          FilledButton(
            child: const Text('Ban'),
            onPressed: () async {
              if (_banDays == null) {
                EasyLoading.showInfo('Please select a ban duration');
              } else {
                final DateTime now = DateTime.now();
                final DateTime bannedUntil = now.add(Duration(days: _banDays!));

                final BannedUserModel model = BannedUserModel(
                  userId: widget.userId,
                  bannedAt: now,
                  bannedUntil: bannedUntil,
                  isLifetimeBan: _isLifetimeBan,
                );

                EasyLoading.show(status: 'Banning user...');
                await BanUserProvider.banUser(model).then((value) async {
                  if (value) {
                    ref.invalidate(bannedUsersProvider);
                    EasyLoading.show(status: 'Deleting reports...');
                    await UserReportsProvider.deleteReports(widget.userId)
                        .then((value) {
                      if (value) {
                        ref.invalidate(allReportsProvider);
                        EasyLoading.dismiss();
                        Navigator.of(context).pop();
                      } else {
                        EasyLoading.showError('Failed to delete reports');
                      }
                    });
                  } else {
                    EasyLoading.showError('Failed to ban user');
                  }
                });
              }
            },
          ),
        ],
      ),
    );
  }
}

List<int> _banForDays = [1, 3, 7, 14, 30, 60, 90, 180, 365];
