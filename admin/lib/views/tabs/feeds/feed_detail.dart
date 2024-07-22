import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:lamatadmin/helpers/date_formater.dart';
import 'package:lamatadmin/models/admin_model.dart';
import 'package:lamatadmin/models/feed_model.dart';
import 'package:lamatadmin/models/user_profile_model.dart';
import 'package:lamatadmin/providers/admin_provider.dart';
import 'package:lamatadmin/providers/user_profiles_provider.dart';
import 'package:lamatadmin/providers/user_reports_provider.dart';
import 'package:lamatadmin/responsive.dart';
import 'package:lamatadmin/views/others/other_widgets.dart';
import 'package:lamatadmin/views/tabs/reports/reports_page.dart';
import 'package:lamatadmin/views/tabs/users/user_short_card.dart';

class FeedDetailsPage extends ConsumerStatefulWidget {
  final FeedModel feed;
  const FeedDetailsPage({
    super.key,
    required this.feed,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FeedDetailsPageState();
}

class _FeedDetailsPageState extends ConsumerState<FeedDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final userProfileRef =
        ref.watch(userProfileProvider(widget.feed.phoneNumber));
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
                    feed: widget.feed,
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

class UserDetailsAccountSettingsCard extends ConsumerStatefulWidget {
  final UserProfileModel profile;
  final FeedModel feed;
  const UserDetailsAccountSettingsCard({
    Key? key,
    required this.profile,
    required this.feed,
  }) : super(key: key);

  @override
  ConsumerState<UserDetailsAccountSettingsCard> createState() =>
      _UserDetailsAccountSettingsCardState();
}

class _UserDetailsAccountSettingsCardState
    extends ConsumerState<UserDetailsAccountSettingsCard> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool sortAscending = true;
    return SizedBox(
      width: (Responsive.isMobile(context)) ? width : width * .31,
      child: Card(
        // padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Text(
              "Feed Comments",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: DataTable2(
                columnSpacing: 16,
                horizontalMargin: 8,
                minWidth: 600,
                sortAscending: sortAscending,
                sortColumnIndex: 2,
                columns: [
                  const DataColumn2(label: Text("Order"), fixedWidth: 60),
                  const DataColumn2(
                      label: Text("Profile Pic"), fixedWidth: 100),
                  DataColumn2(
                    label: const Text('Comment'),
                    onSort: (i, b) {
                      setState(() {
                        sortAscending = !sortAscending;
                      });
                    },
                  ),
                  const DataColumn2(label: Text('@username')),
                  const DataColumn2(label: Text("Date")),
                  const DataColumn2(label: Text('Action')),
                ],
                rows: List.generate(
                  widget.feed.comments.length,
                  (index) {
                    final comment = widget.feed.comments[index];
                    return commentsDataRow(index, comment, ref);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow commentsDataRow(int index, Map comment, WidgetRef ref) {
    //  bool isTrending = feed.likes.length > feeds.length / 3 ? true : false;
    final userProfileRef =
        ref.watch(userProfileProvider(comment['phoneNumber']));

    return userProfileRef.when(
      data: (profile) {
        return DataRow(
          cells: [
            DataCell(Text((index + 1).toString())),
            DataCell(
              Padding(
                padding: const EdgeInsets.all(4),
                child: profile.profilePicture != null ||
                        profile.profilePicture!.isEmpty
                    ? const Icon(Icons.image_rounded, size: 20)
                    : CachedNetworkImage(
                        imageUrl: profile.profilePicture!,
                        imageBuilder: (context, imageProvider) => Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
              ),
            ),
            DataCell(Text(comment['text'] as String)),
            DataCell(
              Text("@${profile.userName}"),
            ),
            DataCell(Text(DateFormat("yyyy-MM-dd HH:mm").format(
                DateTime.fromMillisecondsSinceEpoch(comment['createdAt'])))),
            DataCell(
              FilledButton(
                child: const Text("Delete"),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                            title: const Center(
                              child: Column(
                                children: [
                                  Icon(Icons.warning_outlined,
                                      size: 36, color: Colors.red),
                                  SizedBox(height: 20),
                                  Text("Confirm Deletion"),
                                ],
                              ),
                            ),
                            content: SizedBox(
                              height: 70,
                              child: Column(
                                children: [
                                  const Text(
                                      "Are you sure want to delete this comment'?"),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton.icon(
                                          icon: const Icon(
                                            Icons.close,
                                            size: 14,
                                          ),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.grey),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          label: const Text("Cancel")),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      ElevatedButton.icon(
                                          icon: const Icon(
                                            Icons.delete,
                                            size: 14,
                                          ),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          label: const Text("Delete"))
                                    ],
                                  )
                                ],
                              ),
                            ));
                      });
                },
              ),
            ),
          ],
        );
      },
      error: (error, stackTrace) => const DataRow(cells: []),
      loading: () => const DataRow(cells: []),
    );
  }
}

class UserDetailsProfileCard extends StatefulWidget {
  final UserProfileModel profile;
  final FeedModel feed;
  const UserDetailsProfileCard({
    Key? key,
    required this.profile,
    required this.feed,
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
              "Feed Details",
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
            const SizedBox(height: 8),
            CarouselSlider(
              options: CarouselOptions(
                aspectRatio: 2 / 2.5, // Adjust aspect ratio as needed
                autoPlay: true,
                enlargeCenterPage: true,
                enlargeStrategy: CenterPageEnlargeStrategy.height,
              ),
              items: widget.feed.images
                  .map(
                    (e) => CachedNetworkImage(
                      imageUrl: e,
                      width: 200,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
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
            // const TextBox(
            //   readOnly: true,
            //   // header: 'Full Name',
            //   // initialValue: profile.fullName,
            // ),
            widget.feed.caption != null || widget.feed.caption != ""
                ? ListTile(
                    title: const Text("Caption"),
                    subtitle: Text(widget.feed.caption ?? ""),
                    selected: true,
                  )
                : const SizedBox(),
            const SizedBox(height: 8),
            // const TextBox(
            //   readOnly: true,
            //   // header: 'Email',
            //   // initialValue: profile.email,
            // ),

            ListTile(
              title: const Text("Created:"),
              subtitle: Text(
                "${widget.feed.createdAt.day}/${widget.feed.createdAt.month}/${widget.feed.createdAt.year}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              selected: true,
            ),
            const SizedBox(height: 8),
            // const TextBox(
            //   readOnly: true,
            //   // header: 'Phone Number',
            //   // initialValue: profile.phoneNumber,
            // ),
            ListTile(
              title: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Engagements"),
                ],
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(widget.feed.likes.length.toString(),
                          style: Theme.of(context).textTheme.titleMedium),
                      Text("Likes",
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      width: 2,
                      height: 15,
                      color: Colors.grey,
                    ),
                  ),
                  Column(
                    children: [
                      Text(widget.feed.comments.length.toString(),
                          style: Theme.of(context).textTheme.titleMedium),
                      Text("Comments",
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      width: 2,
                      height: 15,
                      color: Colors.grey,
                    ),
                  ),
                  Column(
                    children: [
                      Text(widget.feed.likes.length.toString(),
                          style: Theme.of(context).textTheme.titleMedium),
                      Text("Views",
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ],
              ),
              selected: true,
            ),
            const SizedBox(height: 8),
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
