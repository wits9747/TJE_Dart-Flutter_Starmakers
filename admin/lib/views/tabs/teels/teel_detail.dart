import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lamatadmin/helpers/date_formater.dart';
import 'package:lamatadmin/models/admin_model.dart';
import 'package:lamatadmin/models/teels_model.dart';
import 'package:lamatadmin/models/user_profile_model.dart';
import 'package:lamatadmin/providers/admin_provider.dart';
import 'package:lamatadmin/providers/user_profiles_provider.dart';
import 'package:lamatadmin/providers/user_reports_provider.dart';
import 'package:lamatadmin/responsive.dart';
import 'package:lamatadmin/views/others/other_widgets.dart';
import 'package:lamatadmin/views/tabs/reports/reports_page.dart';
import 'package:lamatadmin/views/tabs/users/user_short_card.dart';

class TeelDetailsPage extends ConsumerStatefulWidget {
  final TeelsModel teel;
  const TeelDetailsPage({
    super.key,
    required this.teel,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TeelDetailsPageState();
}

class _TeelDetailsPageState extends ConsumerState<TeelDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final userProfileRef =
        ref.watch(userProfileProvider(widget.teel.phoneNumber));
    final currentAdminRef = ref.watch(currentAdminProvider);

    return userProfileRef.when(
      data: (profile) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Text("@${widget.teel.userName}"),
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
                    teel: widget.teel,
                  ),
                  UserDetailsAccountSettingsCard(
                      profile: profile, teel: widget.teel),
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

class UserDetailsAccountSettingsCard extends StatelessWidget {
  final UserProfileModel profile;
  final TeelsModel teel;
  const UserDetailsAccountSettingsCard({
    Key? key,
    required this.profile,
    required this.teel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;
    return SizedBox(
      width: (Responsive.isMobile(context)) ? width : width * .31,
      child: Card(
        // padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Text(
              "Teel Options",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            // const TextBox(
            //   readOnly: true,
            //   // header: 'Location',
            //   maxLines: null,
            //   // initialValue:
            //   // profile.userAccountSettingsModel.location.addressText,

            // ),
            ListTile(
              title: const Text("Likes Showed"),
              subtitle: Text(
                teel.videoShowLikes.toString(),
              ),
              selected: true,
            ),
            ListTile(
              title: const Text("Comments Allowed"),
              subtitle: Text(
                teel.canComment.toString(),
              ),
              selected: true,
            ),
            const SizedBox(height: 8),
            // const TextBox(
            //   readOnly: true,
            //   // header: "Interested In",
            //   // initialValue:
            //   // profile.userAccountSettingsModel.interestedIn ?? "All",
            // ),
            ListTile(
              title: const Text("Downloads Allowed"),
              subtitle: Text(
                teel.canDownload.toString(),
              ),
              selected: true,
            ),
            const SizedBox(height: 8),
            // const TextBox(
            //   readOnly: true,
            //   // header: "Age Range",
            //   // initialValue:
            //   // "${profile.userAccountSettingsModel.minimumAge} - ${profile.userAccountSettingsModel.maximumAge}",
            // ),
            ListTile(
              title: const Text("Duet Allowed"),
              subtitle: Text(
                teel.canDuet.toString(),
              ),
              selected: true,
            ),
            const SizedBox(height: 8),
            // Distance Range
            // const TextBox(
            //   readOnly: true,
            //   // header: "Distance Radius",
            //   // initialValue:
            //   // "${profile.userAccountSettingsModel.distanceInKm ?? "Unknown"} km",
            // ),
            ListTile(
              title: const Text("Saving Allowed"),
              subtitle: Text(
                teel.canSave.toString(),
              ),
              selected: true,
            ),
          ],
        ),
      ),
    );
  }
}

class UserDetailsProfileCard extends StatefulWidget {
  final UserProfileModel profile;
  final TeelsModel teel;
  const UserDetailsProfileCard({
    Key? key,
    required this.profile,
    required this.teel,
  }) : super(key: key);

  @override
  State<UserDetailsProfileCard> createState() => _UserDetailsProfileCardState();
}

class _UserDetailsProfileCardState extends State<UserDetailsProfileCard> {
  // late VideoPlayerController _controller;

  // @override
  // void initState() {
  //   super.initState();
  //   _controller = VideoPlayerController.network(
  //       '${widget.teel.postVideo}') // Use network constructor
  //     ..initialize().then((_) {
  //       setState(() {});
  //     });
  //   _controller.setLooping(true);
  // }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;
    return SizedBox(
      width: (Responsive.isMobile(context)) ? width : width * .31,
      child: Card(
        // padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Text(
              "Teel Details",
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
            widget.teel.caption != null || widget.teel.caption != ""
                ? ListTile(
                    title: const Text("Caption"),
                    subtitle: Text(widget.teel.caption ?? ""),
                    selected: true,
                  )
                : const SizedBox(),
            const SizedBox(height: 8),
            // const TextBox(
            //   readOnly: true,
            //   // header: 'Email',
            //   // initialValue: profile.email,
            // ),
            widget.teel.postHashTag != null || widget.teel.postHashTag != ""
                ? ListTile(
                    title: const Text("Hashtags"),
                    subtitle: Text(
                      widget.teel.postHashTag ?? "",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    selected: true,
                  )
                : const SizedBox(),
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
                      Text(widget.teel.likes.length.toString(),
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
                      Text(widget.teel.saves.length.toString(),
                          style: Theme.of(context).textTheme.titleMedium),
                      Text("Saves",
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
                      Text(widget.teel.views.length.toString(),
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
            // const TextBox(
            //   readOnly: true,
            //   maxLines: null,
            //   // header: 'About',
            //   // initialValue: profile.about,
            // ),
            // ListTile(
            //   title: const Text("About"),
            //   subtitle: Text(profile.about ?? "Unknown"),
            //   selected: true,
            // ),
            // const SizedBox(height: 8),
            // // const TextBox(
            // //   readOnly: true,
            // //   // initialValue: profile.interests.join(', '),
            // //   // header: 'Interests',
            // // ),
            // ListTile(
            //   title: const Text("Interests"),
            //   subtitle: Text(profile.interests.join(', ')),
            //   selected: true,
            // ),
            const SizedBox(height: 8),
            const Text("video"),
            const SizedBox(height: 8),
            // Center(
            //   child: _controller.value.isInitialized
            //       ? AspectRatio(
            //           aspectRatio: _controller.value.aspectRatio,
            //           child: VideoPlayer(
            //             _controller,
            //           ),
            //         )
            //       : CircularProgressIndicator(),
            // ),
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
    // double height = MediaQuery.of(context).size.height;
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
