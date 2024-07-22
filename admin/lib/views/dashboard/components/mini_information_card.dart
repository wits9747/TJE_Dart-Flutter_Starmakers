// ignore_for_file: unused_local_variable, non_constant_identifier_names

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lamatadmin/core/constants/color_constants.dart';
import 'package:lamatadmin/helpers/config.dart';
import 'package:lamatadmin/models/daily_info_model.dart';
import 'package:lamatadmin/providers/banned_users_provider.dart';
import 'package:lamatadmin/providers/devices_provider.dart';
import 'package:lamatadmin/providers/feeds_provider.dart';
import 'package:lamatadmin/providers/interactions_provider.dart';
import 'package:lamatadmin/providers/matches_provider.dart';
import 'package:lamatadmin/providers/storage_provider.dart';
import 'package:lamatadmin/providers/teels_provider.dart';
import 'package:lamatadmin/providers/user_profiles_provider.dart';
import 'package:lamatadmin/responsive.dart';
import 'package:lamatadmin/views/dashboard/components/mini_information_widget.dart';
// import 'package:lamatadmin/views/forms/input_form.dart';

class MiniInformation extends ConsumerWidget {
  const MiniInformation({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     const SizedBox(
        //       width: 10,
        //     ),
        //     ElevatedButton.icon(
        //       style: TextButton.styleFrom(
        //         backgroundColor: AppConstants.primaryColorDark,
        //         padding: EdgeInsets.symmetric(
        //           horizontal: defaultPadding * 1.5,
        //           vertical:
        //               defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
        //         ),
        //       ),
        //       onPressed: () {
        //         Navigator.of(context).push(MaterialPageRoute<void>(
        //             builder: (BuildContext context) {
        //               return const FormMaterial();
        //             },
        //             fullscreenDialog: true));
        //       },
        //       icon:
        //           const Icon(Icons.add, color: AppConstants.primaryColorLight),
        //       label: const Text(
        //         "Add New",
        //         style: TextStyle(color: AppConstants.primaryColorLight),
        //       ),
        //     ),
        //   ],
        // ),
        const SizedBox(height: defaultPadding),
        Responsive(
          mobile: InformationCard(
            crossAxisCount: size.width < 650 ? 2 : 4,
            childAspectRatio: size.width < 650 ? 1.2 : 1,
          ),
          tablet: const InformationCard(),
          desktop: InformationCard(
            childAspectRatio: size.width < 1400 ? 1.2 : 1.4,
          ),
        ),
      ],
    );
  }
}

class InformationCard extends ConsumerWidget {
  const InformationCard({
    Key? key,
    this.crossAxisCount = 5,
    this.childAspectRatio = 1.0,
  }) : super(key: key);

  final int crossAxisCount;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context, ref) {
    final totalUsersRef = ref.watch(usersStreamProvider);
    final totalInteractionsRef = ref.watch(totalInteractionsProvider);
    final totalMatchesRef = ref.watch(totalMatchesProvider);
    final totalDevicesRef = ref.watch(totalDevicesProvider);
    final totalTeelsRef = ref.watch(getTeelsProvider);
    final totalFeedsRef = ref.watch(getFeedsProvider);
    final bannedUsersRef = ref.watch(bannedUsersProvider);
    final totalStorageSize = ref.watch(totalStorageSizeProvider);
    // final isLoading = ref.watch(totalStorageSizeProvider).isLoading;
    return totalUsersRef.when(
      data: (totalUsers) {
        final male =
            totalUsers.where((element) => element.gender == "male").toList();
        final female =
            totalUsers.where((element) => element.gender == "female").toList();
        return totalInteractionsRef.when(
          data: (totalInteractions) {
            final likes =
                totalInteractions.where((element) => element.isLike).toList();

            final dislikes = totalInteractions
                .where((element) => element.isDislike)
                .toList();

            final superLikes = totalInteractions
                .where((element) => element.isSuperLike)
                .toList();

            return totalMatchesRef.when(
              data: (totalMatches) {
                return totalDevicesRef.when(
                  data: (totalDevices) {
                    return bannedUsersRef.when(
                      data: (bannedUsers) {
                        return totalTeelsRef.when(
                          data: (totalTeels) {
                            return totalFeedsRef.when(
                              data: (totalFeeds) {
                                return totalStorageSize.when(
                                  data: (totalServerSize) {
                                    final TrendingTeels = totalTeels
                                        .where((element) =>
                                            element.likes.length >
                                            totalUsers.length / 3)
                                        .toList();

                                    final TrendingFeeds = totalFeeds
                                        .where((element) =>
                                            element.likes.length >
                                            totalUsers.length / 3)
                                        .toList();

                                    final verified = totalUsers
                                        .where((element) => element.isVerified!)
                                        .toList();

                                    final online = totalUsers
                                        .where((element) => element.isOnline!)
                                        .toList();

                                    var dailyData = totalUsers.isNotEmpty
                                        ? [
                                            {
                                              "title": "Male : Female",
                                              "volumeData": male.length,
                                              "icon":
                                                  FlutterIcons.user_alt_faw5s,
                                              "totalStorage":
                                                  female.length.toString(),
                                              "color":
                                                  AppConstants.primaryColor,
                                              "percentage": ((male.length /
                                                          totalUsers.length) *
                                                      100)
                                                  .round(),
                                              "colors": [
                                                const Color(0xff23b6e6),
                                                const Color(0xff02d39a),
                                              ],
                                              "spots": [
                                                const FlSpot(
                                                  1,
                                                  2,
                                                ),
                                                const FlSpot(
                                                  2,
                                                  1.0,
                                                ),
                                                const FlSpot(
                                                  3,
                                                  1.8,
                                                ),
                                                const FlSpot(
                                                  4,
                                                  1.5,
                                                ),
                                                const FlSpot(
                                                  5,
                                                  1.0,
                                                ),
                                                const FlSpot(
                                                  6,
                                                  2.2,
                                                ),
                                                const FlSpot(
                                                  7,
                                                  1.8,
                                                ),
                                                const FlSpot(
                                                  8,
                                                  1.5,
                                                )
                                              ]
                                            },
                                            {
                                              "title": "Live",
                                              "volumeData": 0,
                                              "icon":
                                                  FlutterIcons.video_camera_faw,
                                              "totalStorage":
                                                  "of ${totalUsers.length}",
                                              "color": const Color(0xFFFFA113),
                                              "percentage": 0,
                                              "colors": [
                                                const Color(0xfff12711),
                                                const Color(0xfff5af19)
                                              ],
                                              "spots": [
                                                const FlSpot(
                                                  1,
                                                  1.3,
                                                ),
                                                const FlSpot(
                                                  2,
                                                  1.0,
                                                ),
                                                const FlSpot(
                                                  3,
                                                  4,
                                                ),
                                                const FlSpot(
                                                  4,
                                                  1.5,
                                                ),
                                                const FlSpot(
                                                  5,
                                                  1.0,
                                                ),
                                                const FlSpot(
                                                  6,
                                                  3,
                                                ),
                                                const FlSpot(
                                                  7,
                                                  1.8,
                                                ),
                                                const FlSpot(
                                                  8,
                                                  1.5,
                                                )
                                              ]
                                            },
                                            {
                                              "title": "Teels",
                                              "volumeData": totalTeels.length,
                                              "icon":
                                                  FlutterIcons.play_video_fou,
                                              "totalStorage":
                                                  " ${((TrendingTeels.length / totalTeels.length) * 100).round()}% Trending",
                                              "color": const Color(0xFFA4CDFF),
                                              "percentage": ((TrendingTeels
                                                              .length /
                                                          totalTeels.length) *
                                                      100)
                                                  .round(),
                                              "colors": [
                                                const Color(0xff2980B9),
                                                const Color(0xff6DD5FA)
                                              ],
                                              "spots": [
                                                const FlSpot(
                                                  1,
                                                  1.3,
                                                ),
                                                const FlSpot(
                                                  2,
                                                  5,
                                                ),
                                                const FlSpot(
                                                  3,
                                                  1.8,
                                                ),
                                                const FlSpot(
                                                  4,
                                                  6,
                                                ),
                                                const FlSpot(
                                                  5,
                                                  1.0,
                                                ),
                                                const FlSpot(
                                                  6,
                                                  2.2,
                                                ),
                                                const FlSpot(
                                                  7,
                                                  1.8,
                                                ),
                                                const FlSpot(
                                                  8,
                                                  1,
                                                )
                                              ]
                                            },
                                            {
                                              "title": "Feeds",
                                              "volumeData": totalFeeds.length,
                                              "icon":
                                                  FlutterIcons.image_album_mco,
                                              "totalStorage":
                                                  "${((TrendingFeeds.length / totalFeeds.length) * 100).round()}% Trending",
                                              "color": const Color(0xFFd50000),
                                              "percentage": ((TrendingFeeds
                                                              .length /
                                                          totalFeeds.length) *
                                                      100)
                                                  .round(),
                                              "colors": [
                                                const Color(0xff93291E),
                                                const Color(0xffED213A)
                                              ],
                                              "spots": [
                                                const FlSpot(
                                                  1,
                                                  3,
                                                ),
                                                const FlSpot(
                                                  2,
                                                  4,
                                                ),
                                                const FlSpot(
                                                  3,
                                                  1.8,
                                                ),
                                                const FlSpot(
                                                  4,
                                                  1.5,
                                                ),
                                                const FlSpot(
                                                  5,
                                                  1.0,
                                                ),
                                                const FlSpot(
                                                  6,
                                                  2.2,
                                                ),
                                                const FlSpot(
                                                  7,
                                                  1.8,
                                                ),
                                                const FlSpot(
                                                  8,
                                                  1.5,
                                                )
                                              ]
                                            },
                                            {
                                              "title": "Storage",
                                              "volumeData": totalServerSize,
                                              "icon":
                                                  FlutterIcons.sd_storage_mdi,
                                              "totalStorage": "∞",
                                              "color": const Color(0xFF00F260),
                                              "percentage": 78,
                                              "colors": [
                                                const Color(0xff0575E6),
                                                const Color(0xff00F260)
                                              ],
                                              "spots": [
                                                const FlSpot(
                                                  1,
                                                  1.3,
                                                ),
                                                const FlSpot(
                                                  2,
                                                  1.0,
                                                ),
                                                const FlSpot(
                                                  3,
                                                  1.8,
                                                ),
                                                const FlSpot(
                                                  4,
                                                  1.5,
                                                ),
                                                const FlSpot(
                                                  5,
                                                  1.0,
                                                ),
                                                const FlSpot(
                                                  6,
                                                  2.2,
                                                ),
                                                const FlSpot(
                                                  7,
                                                  1.8,
                                                ),
                                                const FlSpot(
                                                  8,
                                                  1.5,
                                                ),
                                                const FlSpot(
                                                  9,
                                                  3.5,
                                                )
                                              ]
                                            },
                                            {
                                              "title": "Verified",
                                              "volumeData": verified.length,
                                              "icon": FlutterIcons.verified_oct,
                                              "totalStorage":
                                                  "${((verified.length / totalUsers.length) * 100).round()}% of ${totalUsers.length}",
                                              "color": const Color(0xFFd50000),
                                              "percentage": ((verified.length /
                                                          totalUsers.length) *
                                                      100)
                                                  .round(),
                                              "colors": [
                                                const Color(0xff93291E),
                                                const Color(0xffED213A)
                                              ],
                                              "spots": [
                                                const FlSpot(
                                                  1,
                                                  3,
                                                ),
                                                const FlSpot(
                                                  2,
                                                  4,
                                                ),
                                                const FlSpot(
                                                  3,
                                                  1.8,
                                                ),
                                                const FlSpot(
                                                  4,
                                                  1.5,
                                                ),
                                                const FlSpot(
                                                  5,
                                                  1.0,
                                                ),
                                                const FlSpot(
                                                  6,
                                                  2.2,
                                                ),
                                                const FlSpot(
                                                  7,
                                                  1.8,
                                                ),
                                                const FlSpot(
                                                  8,
                                                  1.5,
                                                )
                                              ]
                                            },
                                            {
                                              "title": "Banned",
                                              "volumeData": bannedUsers.length,
                                              "icon": FlutterIcons.block_ent,
                                              "totalStorage":
                                                  "${((bannedUsers.length / totalUsers.length) * 100).round()}% of ${totalUsers.length}",
                                              "color": const Color(0xFF00F260),
                                              "percentage": ((bannedUsers
                                                              .length /
                                                          totalUsers.length) *
                                                      100)
                                                  .round(),
                                              "colors": [
                                                const Color(0xff0575E6),
                                                const Color(0xff00F260)
                                              ],
                                              "spots": [
                                                const FlSpot(
                                                  1,
                                                  1.3,
                                                ),
                                                const FlSpot(
                                                  2,
                                                  1.0,
                                                ),
                                                const FlSpot(
                                                  3,
                                                  1.8,
                                                ),
                                                const FlSpot(
                                                  4,
                                                  1.5,
                                                ),
                                                const FlSpot(
                                                  5,
                                                  1.0,
                                                ),
                                                const FlSpot(
                                                  6,
                                                  2.2,
                                                ),
                                                const FlSpot(
                                                  7,
                                                  1.8,
                                                ),
                                                const FlSpot(
                                                  8,
                                                  1.5,
                                                ),
                                                const FlSpot(
                                                  9,
                                                  3.5,
                                                )
                                              ]
                                            },
                                            {
                                              "title": "Online",
                                              "volumeData": online.length,
                                              "icon": FlutterIcons.circle_faw5s,
                                              "totalStorage":
                                                  "${((online.length / totalUsers.length) * 100).round()}% of ${totalUsers.length}",
                                              "color": const Color(0xFFFFA113),
                                              "percentage": ((online.length /
                                                          totalUsers.length) *
                                                      100)
                                                  .round(),
                                              "colors": [
                                                const Color(0xfff12711),
                                                const Color(0xfff5af19)
                                              ],
                                              "spots": [
                                                const FlSpot(
                                                  1,
                                                  1.3,
                                                ),
                                                const FlSpot(
                                                  2,
                                                  1.0,
                                                ),
                                                const FlSpot(
                                                  3,
                                                  4,
                                                ),
                                                const FlSpot(
                                                  4,
                                                  1.5,
                                                ),
                                                const FlSpot(
                                                  5,
                                                  1.0,
                                                ),
                                                const FlSpot(
                                                  6,
                                                  3,
                                                ),
                                                const FlSpot(
                                                  7,
                                                  1.8,
                                                ),
                                                const FlSpot(
                                                  8,
                                                  1.5,
                                                )
                                              ]
                                            },
                                          ]
                                        : [
                                            {
                                              "title": "Male : Female",
                                              "volumeData": 0,
                                              "icon":
                                                  FlutterIcons.user_alt_faw5s,
                                              "totalStorage": "0",
                                              "color":
                                                  AppConstants.primaryColor,
                                              "percentage": 0,
                                              "colors": [
                                                const Color(0xff23b6e6),
                                                const Color(0xff02d39a),
                                              ],
                                              "spots": [
                                                const FlSpot(
                                                  1,
                                                  2,
                                                ),
                                                const FlSpot(
                                                  2,
                                                  1.0,
                                                ),
                                                const FlSpot(
                                                  3,
                                                  1.8,
                                                ),
                                                const FlSpot(
                                                  4,
                                                  1.5,
                                                ),
                                                const FlSpot(
                                                  5,
                                                  1.0,
                                                ),
                                                const FlSpot(
                                                  6,
                                                  2.2,
                                                ),
                                                const FlSpot(
                                                  7,
                                                  1.8,
                                                ),
                                                const FlSpot(
                                                  8,
                                                  1.5,
                                                )
                                              ]
                                            },
                                            {
                                              "title": "Live",
                                              "volumeData": 0,
                                              "icon":
                                                  FlutterIcons.video_camera_faw,
                                              "totalStorage": "of 0",
                                              "color": const Color(0xFFFFA113),
                                              "percentage": 0,
                                              "colors": [
                                                const Color(0xfff12711),
                                                const Color(0xfff5af19)
                                              ],
                                              "spots": [
                                                const FlSpot(
                                                  1,
                                                  1.3,
                                                ),
                                                const FlSpot(
                                                  2,
                                                  1.0,
                                                ),
                                                const FlSpot(
                                                  3,
                                                  4,
                                                ),
                                                const FlSpot(
                                                  4,
                                                  1.5,
                                                ),
                                                const FlSpot(
                                                  5,
                                                  1.0,
                                                ),
                                                const FlSpot(
                                                  6,
                                                  3,
                                                ),
                                                const FlSpot(
                                                  7,
                                                  1.8,
                                                ),
                                                const FlSpot(
                                                  8,
                                                  1.5,
                                                )
                                              ]
                                            },
                                            {
                                              "title": "Teels",
                                              "volumeData": 0,
                                              "icon":
                                                  FlutterIcons.play_video_fou,
                                              "totalStorage": "0% Trending",
                                              "color": const Color(0xFFA4CDFF),
                                              "percentage": 0,
                                              "colors": [
                                                const Color(0xff2980B9),
                                                const Color(0xff6DD5FA)
                                              ],
                                              "spots": [
                                                const FlSpot(
                                                  1,
                                                  1.3,
                                                ),
                                                const FlSpot(
                                                  2,
                                                  5,
                                                ),
                                                const FlSpot(
                                                  3,
                                                  1.8,
                                                ),
                                                const FlSpot(
                                                  4,
                                                  6,
                                                ),
                                                const FlSpot(
                                                  5,
                                                  1.0,
                                                ),
                                                const FlSpot(
                                                  6,
                                                  2.2,
                                                ),
                                                const FlSpot(
                                                  7,
                                                  1.8,
                                                ),
                                                const FlSpot(
                                                  8,
                                                  1,
                                                )
                                              ]
                                            },
                                            {
                                              "title": "Feeds",
                                              "volumeData": 0,
                                              "icon":
                                                  FlutterIcons.image_album_mco,
                                              "totalStorage": "0% Trending",
                                              "color": const Color(0xFFd50000),
                                              "percentage": 0,
                                              "colors": [
                                                const Color(0xff93291E),
                                                const Color(0xffED213A)
                                              ],
                                              "spots": [
                                                const FlSpot(
                                                  1,
                                                  3,
                                                ),
                                                const FlSpot(
                                                  2,
                                                  4,
                                                ),
                                                const FlSpot(
                                                  3,
                                                  1.8,
                                                ),
                                                const FlSpot(
                                                  4,
                                                  1.5,
                                                ),
                                                const FlSpot(
                                                  5,
                                                  1.0,
                                                ),
                                                const FlSpot(
                                                  6,
                                                  2.2,
                                                ),
                                                const FlSpot(
                                                  7,
                                                  1.8,
                                                ),
                                                const FlSpot(
                                                  8,
                                                  1.5,
                                                )
                                              ]
                                            },
                                            {
                                              "title": "Storage",
                                              "volumeData": 0,
                                              "icon":
                                                  FlutterIcons.sd_storage_mdi,
                                              "totalStorage": "∞",
                                              "color": const Color(0xFF00F260),
                                              "percentage": 0,
                                              "colors": [
                                                const Color(0xff0575E6),
                                                const Color(0xff00F260)
                                              ],
                                              "spots": [
                                                const FlSpot(
                                                  1,
                                                  1.3,
                                                ),
                                                const FlSpot(
                                                  2,
                                                  1.0,
                                                ),
                                                const FlSpot(
                                                  3,
                                                  1.8,
                                                ),
                                                const FlSpot(
                                                  4,
                                                  1.5,
                                                ),
                                                const FlSpot(
                                                  5,
                                                  1.0,
                                                ),
                                                const FlSpot(
                                                  6,
                                                  2.2,
                                                ),
                                                const FlSpot(
                                                  7,
                                                  1.8,
                                                ),
                                                const FlSpot(
                                                  8,
                                                  1.5,
                                                ),
                                                const FlSpot(
                                                  9,
                                                  3.5,
                                                )
                                              ]
                                            },
                                            {
                                              "title": "Verified",
                                              "volumeData": 0,
                                              "icon": FlutterIcons.verified_oct,
                                              "totalStorage":
                                                  "0% of ${totalUsers.length}",
                                              "color": const Color(0xFFd50000),
                                              "percentage": 0,
                                              "colors": [
                                                const Color(0xff93291E),
                                                const Color(0xffED213A)
                                              ],
                                              "spots": [
                                                const FlSpot(
                                                  1,
                                                  3,
                                                ),
                                                const FlSpot(
                                                  2,
                                                  4,
                                                ),
                                                const FlSpot(
                                                  3,
                                                  1.8,
                                                ),
                                                const FlSpot(
                                                  4,
                                                  1.5,
                                                ),
                                                const FlSpot(
                                                  5,
                                                  1.0,
                                                ),
                                                const FlSpot(
                                                  6,
                                                  2.2,
                                                ),
                                                const FlSpot(
                                                  7,
                                                  1.8,
                                                ),
                                                const FlSpot(
                                                  8,
                                                  1.5,
                                                )
                                              ]
                                            },
                                            {
                                              "title": "Banned",
                                              "volumeData": 0,
                                              "icon": FlutterIcons.block_ent,
                                              "totalStorage": "0% of 0",
                                              "color": const Color(0xFF00F260),
                                              "percentage": 0,
                                              "colors": [
                                                const Color(0xff0575E6),
                                                const Color(0xff00F260)
                                              ],
                                              "spots": [
                                                const FlSpot(
                                                  1,
                                                  1.3,
                                                ),
                                                const FlSpot(
                                                  2,
                                                  1.0,
                                                ),
                                                const FlSpot(
                                                  3,
                                                  1.8,
                                                ),
                                                const FlSpot(
                                                  4,
                                                  1.5,
                                                ),
                                                const FlSpot(
                                                  5,
                                                  1.0,
                                                ),
                                                const FlSpot(
                                                  6,
                                                  2.2,
                                                ),
                                                const FlSpot(
                                                  7,
                                                  1.8,
                                                ),
                                                const FlSpot(
                                                  8,
                                                  1.5,
                                                ),
                                                const FlSpot(
                                                  9,
                                                  3.5,
                                                )
                                              ]
                                            },
                                            {
                                              "title": "Online",
                                              "volumeData": 0,
                                              "icon": FlutterIcons.circle_faw5s,
                                              "totalStorage": "0% of 0",
                                              "color": const Color(0xFFFFA113),
                                              "percentage": 0,
                                              "colors": [
                                                const Color(0xfff12711),
                                                const Color(0xfff5af19)
                                              ],
                                              "spots": [
                                                const FlSpot(
                                                  1,
                                                  1.3,
                                                ),
                                                const FlSpot(
                                                  2,
                                                  1.0,
                                                ),
                                                const FlSpot(
                                                  3,
                                                  4,
                                                ),
                                                const FlSpot(
                                                  4,
                                                  1.5,
                                                ),
                                                const FlSpot(
                                                  5,
                                                  1.0,
                                                ),
                                                const FlSpot(
                                                  6,
                                                  3,
                                                ),
                                                const FlSpot(
                                                  7,
                                                  1.8,
                                                ),
                                                const FlSpot(
                                                  8,
                                                  1.5,
                                                )
                                              ]
                                            },
                                          ];

                                    List<DailyInfoModel> dailyDatas = dailyData
                                        .map((item) =>
                                            DailyInfoModel.fromJson(item))
                                        .toList();
                                    return GridView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: dailyDatas.length,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        crossAxisSpacing: defaultPadding,
                                        mainAxisSpacing: defaultPadding,
                                        childAspectRatio: childAspectRatio,
                                      ),
                                      itemBuilder: (context, index) =>
                                          MiniInformationWidget(
                                              dailyData: dailyDatas[index]),
                                    );
                                  },
                                  loading: () =>
                                      const CircularProgressIndicator(),
                                  error: (error, stack) =>
                                      const CircularProgressIndicator(),
                                );
                              },
                              loading: () => const CircularProgressIndicator(),
                              error: (error, stack) =>
                                  const CircularProgressIndicator(),
                            );
                          },
                          loading: () => const CircularProgressIndicator(),
                          error: (error, stack) =>
                              const CircularProgressIndicator(),
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) =>
                          const CircularProgressIndicator(),
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => const CircularProgressIndicator(),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => const CircularProgressIndicator(),
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => const CircularProgressIndicator(),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => const CircularProgressIndicator(),
    );
  }
}
