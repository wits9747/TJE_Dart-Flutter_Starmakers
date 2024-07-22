import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatadmin/helpers/config.dart';

import 'package:lamatadmin/helpers/date_formater.dart';
import 'package:lamatadmin/models/admin_model.dart';
import 'package:lamatadmin/models/user_profile_model.dart';
import 'package:lamatadmin/models/withdrawal_model.dart';
import 'package:lamatadmin/providers/admin_provider.dart';
import 'package:lamatadmin/providers/user_profiles_provider.dart';
import 'package:lamatadmin/providers/user_reports_provider.dart';
import 'package:lamatadmin/providers/withdrawals.dart';
import 'package:lamatadmin/responsive.dart';
import 'package:lamatadmin/views/others/other_widgets.dart';
import 'package:lamatadmin/views/tabs/reports/reports_page.dart';
import 'package:lamatadmin/views/tabs/users/user_short_card.dart';

class WithdrawalDetailsPage extends ConsumerStatefulWidget {
  final WithrawalModel withdrawal;
  const WithdrawalDetailsPage({
    super.key,
    required this.withdrawal,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      WithdrawalDetailsPageState();
}

class WithdrawalDetailsPageState extends ConsumerState<WithdrawalDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final userProfileRef =
        ref.watch(userProfileProvider(widget.withdrawal.phoneNumber));
    final currentAdminRef = ref.watch(currentAdminProvider);

    return userProfileRef.when(
      data: (profile) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Text("@${profile.userName}"),
              ],
            ),
          ),
          body: Align(
            alignment: Alignment.topLeft,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  UserDetailsProfileCard(
                    profile: profile,
                    withdrawal: widget.withdrawal,
                  ),
                  // UserDetailsAccountSettingsCard(
                  //   profile: profile,
                  //   feed: widget.feed,
                  // ),
                  currentAdminRef.when(
                    data: (data) {
                      if (data != null &&
                          data.permissions.contains(reportPermission)) {
                        return UserDetailsReportsSection(
                            userId: profile.userId ?? "");
                      } else {
                        return const SizedBox();
                      }
                    },
                    error: (error, stackTrace) => const SizedBox(),
                    loading: () => const SizedBox(),
                  )
                ],
              ),
            ),
          ),
        );
      },
      error: (error, stackTrace) => const MyErrorWidget(),
      loading: () => const MyLoadingWidget(),
    );
  }
}

class UserDetailsProfileCard extends StatefulWidget {
  final UserProfileModel profile;
  final WithrawalModel withdrawal;
  const UserDetailsProfileCard({
    Key? key,
    required this.profile,
    required this.withdrawal,
  }) : super(key: key);

  @override
  State<UserDetailsProfileCard> createState() => _UserDetailsProfileCardState();
}

class _UserDetailsProfileCardState extends State<UserDetailsProfileCard> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: (Responsive.isMobile(context)) ? width : width * .31,
      child: Card(
        // padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Text(
              "Withdrawal Details",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (widget.profile.profilePicture != null)
              Center(
                child: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                    widget.profile.profilePicture!,
                  ),
                  radius: 70,
                ),
              ),
            if (widget.profile.profilePicture == null)
              Center(
                child: CircleAvatar(
                  radius: 50,
                  child: Text(
                    widget.profile.fullName![0],
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
              ),
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.profile.isVerified! ? Icons.verified : Icons.clear,
                      color: widget.profile.isVerified!
                          ? Colors.green
                          : Colors.red,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      widget.profile.isVerified! ? "Verified" : "Not Verified",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text("Withdraw Amount"),
              subtitle: Text(
                widget.withdrawal.amount.toStringAsFixed(2),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              selected: true,
            ),
            const SizedBox(height: 8),
            ListTile(
              title: const Text("Date: "),
              subtitle: Text(
                "${widget.withdrawal.createdAt.day}/${widget.withdrawal.createdAt.month}/${widget.withdrawal.createdAt.year}",
                style: const TextStyle(fontWeight: FontWeight.normal),
              ),
              selected: true,
            ),
            const SizedBox(height: 8),
            ListTile(
              title: const Text("STATUS:"),
              subtitle: Text(
                widget.withdrawal.status.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              selected: true,
            ),
            const SizedBox(height: 20),
            ListTile(
              title: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Card Details",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              subtitle: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      width: width / 4,
                      height: 1,
                      color: Colors.grey,
                    ),
                  ),
                  Row(
                    children: [
                      Text("Account Number: ",
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(widget.withdrawal.accountNumber.toString(),
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      width: width / 4,
                      height: 1,
                      color: Colors.grey,
                    ),
                  ),
                  Row(
                    children: [
                      Text("Bank: ",
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(widget.withdrawal.bankName!,
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      width: width / 4,
                      height: 1,
                      color: Colors.grey,
                    ),
                  ),
                  Row(
                    children: [
                      Text("Address: ",
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(widget.withdrawal.address!,
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      width: width / 4,
                      height: 1,
                      color: Colors.grey,
                    ),
                  ),
                  Row(
                    children: [
                      Text("City: ",
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(widget.withdrawal.city!,
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      width: width / 4,
                      height: 1,
                      color: Colors.grey,
                    ),
                  ),
                  Row(
                    children: [
                      Text("State: ",
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(widget.withdrawal.state!,
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      width: width / 4,
                      height: 1,
                      color: Colors.grey,
                    ),
                  ),
                  Row(
                    children: [
                      Text("ZipCode: ",
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(widget.withdrawal.zipCode!,
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      width: width / 4,
                      height: 1,
                      color: Colors.grey,
                    ),
                  ),
                  Row(
                    children: [
                      Text("Country: ",
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(widget.withdrawal.country!,
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      width: width / 4,
                      height: 1,
                      color: Colors.grey,
                    ),
                  ),
                  Row(
                    children: [
                      Text("PayPal: ",
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(widget.withdrawal.paypalEmail!,
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      width: width / 4,
                      height: 1,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              selected: true,
            ),
            const SizedBox(height: 20),
            if (widget.withdrawal.status == "pending")
              ListTile(
                title: const Text("ACTION"),
                subtitle: Text(
                  widget.withdrawal.status.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                selected: false,
              ),
            const SizedBox(height: 8),
            if (widget.withdrawal.status == "pending")
              ListTile(
                title: const Text("APPROVE"),
                subtitle: Text(
                  widget.withdrawal.status.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                selectedColor: AppConstants.primaryColor,
                hoverColor: AppConstants.primaryColor,
                onTap: () {
                  final withdrawal = WithrawalModel(
                    id: widget.withdrawal.id,
                    phoneNumber: widget.withdrawal.phoneNumber,
                    status: "approved",
                    createdAt: widget.withdrawal.createdAt,
                    amount: widget.withdrawal.amount,
                  );
                  WithdrawalsProvider.updateStatus(withdrawal);
                },
              ),
            if (widget.withdrawal.status == "pending")
              const SizedBox(height: 16),
            if (widget.withdrawal.status == "pending")
              ListTile(
                title: const Text("REJECT"),
                subtitle: Text(
                  widget.withdrawal.status.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                selectedColor: AppConstants.secondaryColor,
                hoverColor: AppConstants.secondaryColor,
                onTap: () {
                  final withdrawal = WithrawalModel(
                    id: widget.withdrawal.id,
                    phoneNumber: widget.withdrawal.phoneNumber,
                    status: "rejected",
                    createdAt: widget.withdrawal.createdAt,
                    amount: widget.withdrawal.amount,
                  );
                  WithdrawalsProvider.updateStatus(withdrawal);
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class UserDetailsReportsSection extends ConsumerWidget {
  final String userId;
  const UserDetailsReportsSection({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userReportsRef = ref.watch(userReportsProvider(userId));
    double width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: (Responsive.isMobile(context)) ? width : width * .31,
      height: MediaQuery.of(context).size.height * 0.8,
      child: Card(
        // padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    "User Reports",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                userReportsRef.when(
                  data: (data) {
                    return Row(
                      children: [
                        Text(
                          "Total: ${data.length}",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 8),
                        if (data.isNotEmpty)
                          FilledButton(
                            child: const Text('Ban User'),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return BanUserDialog(userId: userId);
                                },
                              );
                            },
                          ),
                      ],
                    );
                  },
                  error: (error, stackTrace) {
                    return const SizedBox();
                  },
                  loading: () => const SizedBox(),
                )
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: userReportsRef.when(
                data: (data) {
                  if (data.isEmpty) {
                    return const Center(
                      child: Text(
                        "No reports found!",
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final report = data[index];

                        return Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "${index + 1}.",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Expanded(
                                      child: UserShortCard(
                                          userId: report.reportedByUserId)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(report.reason),
                              ),
                              if (report.images.isNotEmpty)
                                Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: report.images
                                      .map(
                                        (e) => CachedNetworkImage(
                                          imageUrl: e,
                                          width: 120,
                                          height: 180,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                      .toList(),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  "Reported at: ${DateFormatter.toWholeDateTime(report.createdAt)}",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
                error: (error, stackTrace) {
                  return const SizedBox();
                },
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
            )
          ],
        ),
      ),
    );
  }
}
