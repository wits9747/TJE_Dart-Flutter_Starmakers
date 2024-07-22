import 'package:colorize_text_avatar/colorize_text_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lamatadmin/core/constants/color_constants.dart';
import 'package:lamatadmin/core/utils/colorful_tag.dart';
import 'package:lamatadmin/helpers/demo_constants.dart';
import 'package:lamatadmin/models/user_profile_model.dart';
import 'package:lamatadmin/providers/user_profiles_provider.dart';
import 'package:lamatadmin/views/others/other_widgets.dart';
import 'package:lamatadmin/views/tabs/users/user_details_page.dart';

class RecentUsers extends ConsumerWidget {
  const RecentUsers({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final totalUsersRef = ref.watch(recentUsersStreamProvider);
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: const BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recent Users",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          totalUsersRef.when(
            data: (totalUsers) {
              return SingleChildScrollView(
                //scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: double.infinity,
                  child: DataTable(
                    horizontalMargin: 0,
                    columnSpacing: defaultPadding,
                    columns: const [
                      DataColumn(
                        label: Text("Full Name"),
                      ),
                      DataColumn(
                        label: Text("Category"),
                      ),
                      DataColumn(
                        label: Text("Number"),
                      ),
                      DataColumn(
                        label: Text("Reg Date"),
                      ),
                      DataColumn(
                        label: Text("Status"),
                      ),
                      DataColumn(
                        label: Text("Actions"),
                      ),
                    ],
                    rows: List.generate(
                      totalUsers.length,
                      (index) => recentUserDataRow(
                          totalUsers[index], context, totalUsers),
                    ),
                  ),
                ),
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => const MyErrorWidget(),
          )
        ],
      ),
    );
  }
}

DataRow recentUserDataRow(
    UserProfileModel userInfo, BuildContext context, List totalUsers) {
  return DataRow(
    cells: [
      DataCell(
        Row(
          children: [
            TextAvatar(
              size: 35,
              backgroundColor: Colors.white,
              textColor: Colors.white,
              fontSize: 14,
              upperCase: true,
              numberLetters: 1,
              shape: Shape.Rectangle,
              text: hasNonEnglishCharacters(userInfo.fullName!.trim())
                  ? userInfo.fullName
                  : "User",
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Text(
                userInfo.fullName ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      DataCell(Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: getRoleColor(userInfo.profileCategoryName).withOpacity(.2),
            border:
                Border.all(color: getRoleColor(userInfo.profileCategoryName)),
            borderRadius: const BorderRadius.all(Radius.circular(5.0) //
                ),
          ),
          child: Text(userInfo.profileCategoryName!))),
      DataCell(Text(
          DemoConstants.isDemo ? "**********" : userInfo.phoneNumber ?? "")),
      DataCell(Text(
          "${userInfo.joinedOn!.day}/${userInfo.joinedOn!.month}/${userInfo.joinedOn!.year}")),
      DataCell(Text(userInfo.gender ?? "")),
      DataCell(
        Row(
          children: [
            TextButton(
              child: const Text('View', style: TextStyle(color: greenColor)),
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return UserDetailsPage(userId: userInfo.phoneNumber ?? "");
                }));
              },
            ),
            const SizedBox(
              width: 6,
            ),
            TextButton(
              child: const Text("Delete",
                  style: TextStyle(color: Colors.redAccent)),
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
                                Text(
                                    "Are you sure want to delete '${userInfo.fullName}'?"),
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
                                          UserProfileProvider.deleteUser(
                                              userInfo.phoneNumber ?? "");
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
              // Delete
            ),
          ],
        ),
      ),
    ],
  );
}
