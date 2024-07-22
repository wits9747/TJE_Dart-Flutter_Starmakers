// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:data_table_2/data_table_2.dart';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lamatadmin/helpers/config.dart';
import 'package:lamatadmin/models/user_profile_model.dart';
import 'package:lamatadmin/providers/fake_user_provider.dart';
// import 'package:lamatadmin/providers/search_text_provider.dart';
import 'package:lamatadmin/providers/user_profiles_provider.dart';
import 'package:lamatadmin/core/constants/color_constants.dart';
import 'package:lamatadmin/responsive.dart';
// import 'package:lamatadmin/responsive.dart';
import 'package:lamatadmin/views/dashboard/components/header.dart';
import 'package:lamatadmin/views/home/components/side_menu.dart';
import 'package:lamatadmin/views/others/other_widgets.dart';
import 'package:lamatadmin/views/tabs/users/user_details_page.dart';
import 'package:restart_app/restart_app.dart';

class UsersPage extends ConsumerStatefulWidget {
  final Function? changeScreen;
  const UsersPage({super.key, this.changeScreen});

  @override
  ConsumerState<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends ConsumerState<UsersPage> {
  bool _sortAscending = true;
  final _searchController = TextEditingController();
  final _fakesController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;
    final totalUsersRef = ref.watch(usersStreamProvider);
    // final controller = ref.watch(textControllerProvider);
    // final generateUsers = ref.read(generateFakeUsersProvider);

    return Scaffold(
      drawer: SideMenu(changeScreen: widget.changeScreen!),
      body: totalUsersRef.when(
        data: (totalUsers) {
          if (_searchController.text.isNotEmpty) {
            totalUsers = totalUsers
                .where((user) => (user.fullName ?? "")
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase()))
                .toList();
          }

          if (_sortAscending) {
            totalUsers.sort((a, b) => a.fullName!.compareTo(b.fullName ?? ""));
          } else {
            totalUsers.sort((a, b) => b.fullName!.compareTo(a.fullName ?? ""));
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
                          ? width * .7
                          : width * .3,
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
                    totalUsersRef.when(
                      data: (totalUsers) => Text('Total: ${totalUsers.length}'),
                      loading: () => const SizedBox(),
                      error: (error, stack) => const SizedBox(),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(
                      width: (Responsive.isMobile(context))
                          ? width * .7
                          : width * .3,
                      child: TextFormField(
                        controller: _fakesController,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.parse(value) > 50 ||
                              int.parse(value) < 1) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                        // onChanged: (value) {
                        //   if (value.isEmpty) {
                        //     setState(() {});
                        //   } else if (value.length >= 2) {
                        //     setState(() {});
                        //   }
                        // },
                        decoration: InputDecoration(
                          hintText: "Press Button to Generate 25-50 Fake Users",
                          fillColor: secondaryColor,
                          filled: true,
                          border: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          suffixIcon: InkWell(
                            onTap: () async {
                              EasyLoading.show(status: 'Generating Users');
                              await generateFakeUsersProvider();
                              EasyLoading.showSuccess('Users Generated');
                              await Restart.restartApp();
                            },
                            child: Container(
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
                                "assets/icons/menu_account.svg",
                                color: Colors.white,
                                width: 32,
                                height: 32,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Expanded(child: SizedBox()),
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
                                "All Users",
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
                                        label: Text(""), fixedWidth: 100),
                                    DataColumn2(
                                      label: const Text('Full Name'),
                                      onSort: (i, b) {
                                        setState(() {
                                          _sortAscending = !_sortAscending;
                                        });
                                      },
                                    ),
                                    const DataColumn2(label: Text("Gender")),
                                    const DataColumn2(
                                        label: Text('Verification Status')),
                                    const DataColumn2(
                                        label: Text("View"), fixedWidth: 100)
                                  ],
                                  rows: List.generate(
                                    totalUsers.length,
                                    (index) {
                                      final user = totalUsers[index];
                                      return userDataRow(index, user);
                                    },
                                  ),
                                ),
                              ),
                            ])))
              ],
            ),
          );
        },
        loading: () => const MyLoadingWidget(),
        error: (error, stack) => const MyErrorWidget(),
      ),
    );
  }

  DataRow userDataRow(int index, UserProfileModel user) {
    return DataRow(
      cells: [
        DataCell(Text((index + 1).toString())),
        DataCell(
          Padding(
            padding: const EdgeInsets.all(4),
            child: user.profilePicture == null
                ? const Icon(Icons.image_rounded, size: 20)
                : CachedNetworkImage(
                    imageUrl: user.profilePicture!,
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
        DataCell(Text(user.fullName ?? "")),
        DataCell(Text((user.gender ?? "").toUpperCase())),
        DataCell(
          Text(
            user.isVerified! ? 'Verified' : 'Not verified',
            style: TextStyle(
              color: user.isVerified! ? Colors.green : Colors.red,
            ),
          ),
        ),
        DataCell(
          FilledButton(
            child: const Text("View"),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return UserDetailsPage(userId: user.phoneNumber ?? "");
              }));
            },
          ),
        ),
      ],
    );
  }
}
//    drawer: SideMenu(changeScreen: widget.changeScreen!),

// appBar:
//        AppBar(
//           title: Header(),

//            Row(
//             children: [
//               // if (Responsive.isMobile(context))
//               //         AppBar(
//               //           automaticallyImplyLeading:
//               //               true, // This enables the default menu button
//               //         ),

//               if (!Responsive.isMobile(context))
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Hello, Deniz 👋",
//                       style: Theme.of(context).textTheme.headline6,
//                     ),
//                     SizedBox(
//                       height: 8,
//                     ),
//                     Text(
//                       "Wellcome to your dashboard",
//                       style: Theme.of(context).textTheme.subtitle2,
//                     ),
//                   ],
//                 ),
//               // if (!Responsive.isMobile(context)) Spacer(flex: 1),
//             ],
//           ),
//           automaticallyImplyLeading: (Responsive.isMobile(context)),
//           leading: const Icon(Icons.people),
//           actions: [
//             Align(
//               alignment: Alignment.centerRight,
//               child: Row(
//                 mainAxisSize: MainAxisSize.max,
//                 children: [
//                   SizedBox(
//                     width: 200,
//                     child: TextFormField(
//                       controller: _searchController,
//                       onChanged: (value) {
//                         if (value.isEmpty) {
//                           setState(() {});
//                         } else if (value.length > 2) {
//                           setState(() {});
//                         }
//                       },
//                       decoration: const InputDecoration(
//                         hintText: 'Search By Name',
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   totalUsersRef.when(
//                     data: (totalUsers) =>
//                         Text('Total ${totalUsers.length} users'),
//                     loading: () => const SizedBox(),
//                     error: (error, stack) => const SizedBox(),
//                   ),
//                   const SizedBox(width: 16),
//                 ],
//               ),
//             ),
//           ]
//           ),
