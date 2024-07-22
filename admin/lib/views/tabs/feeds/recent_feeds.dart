// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:lamatadmin/core/constants/color_constants.dart';
import 'package:lamatadmin/helpers/config.dart';
import 'package:lamatadmin/models/feed_model.dart';
import 'package:lamatadmin/providers/feeds_provider.dart';
import 'package:lamatadmin/responsive.dart';
import 'package:lamatadmin/views/dashboard/components/header.dart';
import 'package:lamatadmin/views/home/components/side_menu.dart';
import 'package:lamatadmin/views/others/other_widgets.dart';
import 'package:lamatadmin/views/tabs/feeds/feed_detail.dart';

class FeedsPage extends ConsumerStatefulWidget {
  final Function? changeScreen;
  const FeedsPage({super.key, this.changeScreen});

  @override
  ConsumerState<FeedsPage> createState() => _FeedsPageState();
}

class _FeedsPageState extends ConsumerState<FeedsPage> {
  bool _sortAscending = true;
  final _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final feedsRef = ref.watch(getFeedsProvider);

    return Scaffold(
      drawer: SideMenu(changeScreen: widget.changeScreen!),
      body: feedsRef.when(
        data: (feeds) {
          if (_searchController.text.isNotEmpty) {
            feeds = feeds
                .where((teel) => teel.caption!
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase()))
                .toList();
          }

          if (_sortAscending) {
            feeds.sort((a, b) => a.caption!.compareTo(b.caption!));
          } else {
            feeds.sort((a, b) => b.caption!.compareTo(a.caption!));
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
                    feedsRef.when(
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
                              "Recent Feeds",
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
                                    label: const Text('Caption'),
                                    onSort: (i, b) {
                                      setState(() {
                                        _sortAscending = !_sortAscending;
                                      });
                                    },
                                  ),
                                  const DataColumn2(label: Text("Upload Date")),
                                  const DataColumn2(
                                      label: Text('Trending Status')),
                                  const DataColumn2(
                                      label: Text("View"), fixedWidth: 100)
                                ],
                                rows: List.generate(
                                  feeds.length,
                                  (index) {
                                    final feed = feeds[index];
                                    return userDataRow(index, feed, feeds);
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

  DataRow userDataRow(int index, FeedModel feed, List feeds) {
    bool isTrending = feed.likes.length > feeds.length / 3 ? true : false;
    return DataRow(
      cells: [
        DataCell(Text((index + 1).toString())),
        DataCell(
          Padding(
            padding: const EdgeInsets.all(4),
            child: feed.images.isEmpty
                ? const Icon(Icons.image_rounded, size: 20)
                : CachedNetworkImage(
                    imageUrl: feed.images[0],
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
        DataCell(Text(feed.caption ?? "")),
        DataCell(Text(
            "${feed.createdAt.day}/${feed.createdAt.month}/${feed.createdAt.year}")),
        DataCell(
          Text(
            isTrending ? 'Trending' : 'Not Trending',
            style: TextStyle(
              color: isTrending ? Colors.green : Colors.red,
            ),
          ),
        ),
        DataCell(
          FilledButton(
            child: const Text("View"),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return FeedDetailsPage(feed: feed);
              }));
            },
          ),
        ),
      ],
    );
  }
}
