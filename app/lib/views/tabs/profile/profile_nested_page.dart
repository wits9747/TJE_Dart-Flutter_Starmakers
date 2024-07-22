// ignore_for_file: deprecated_member_use, use_build_context_synchronously, unused_result, unused_local_variable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gif_view/gif_view.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/responsive.dart';
import 'package:lamatdating/views/settings/account_settings.dart';
import 'package:lamatdating/views/tabs/home/explore_page.dart';
import 'package:lamatdating/views/wallet/dialog_coins_plan.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'package:lamatdating/main.dart';
import 'package:lamatdating/views/others/photo_view_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/helpers/constants.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/models/wallets_model.dart';
import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/providers/feed_provider.dart';
import 'package:lamatdating/providers/shared_pref_provider.dart';
import 'package:lamatdating/providers/teels_provider.dart';
import 'package:lamatdating/providers/user_profile_provider.dart';
import 'package:lamatdating/providers/wallets_provider.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/company/contact_us.dart';
import 'package:lamatdating/views/company/faq_page.dart';
import 'package:lamatdating/views/company/privacy_policy.dart';
import 'package:lamatdating/views/custom/lottie/no_item_found_widget.dart';
import 'package:lamatdating/views/tabs/live/screen/live_stream_screen.dart';
import 'package:lamatdating/views/plan_date/my_meetings.dart';
import 'package:lamatdating/views/security/security_and_privacy_page.dart';
// import 'package:lamatdating/views/settings/account_settings.dart';
import 'package:lamatdating/views/tabs/feeds/feeds_home_page.dart';
// import 'package:lamatdating/views/tabs/home/explore_page.dart';
import 'package:lamatdating/views/tabs/interactions/interactions_page.dart';
import 'package:lamatdating/views/tabs/matches/matches_page.dart';
import 'package:lamatdating/views/tabs/profile/profile_view.dart';
import 'package:lamatdating/views/video/video_list_screen.dart';
import 'package:lamatdating/views/wallet/wallet_page.dart';

class ProfileNested extends ConsumerStatefulWidget {
  final bool? isHome;
  const ProfileNested({
    Key? key,
    this.isHome,
  }) : super(key: key);
  @override
  ConsumerState<ProfileNested> createState() => _ProfileNestedState();
}

class _ProfileNestedState extends ConsumerState<ProfileNested>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final ScrollController _controller = ScrollController();
  late double maxExtent;
  double currentExtent = 500;
  SharedPreferences? prefs;
  bool biometricEnabled = false;
  DataModel? _cachedModel;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      maxExtent = 500;
      currentExtent = maxExtent;
      prefs = ref.watch(sharedPreferences).value;
      getModel();
      // setStatusBarColor(prefs!);

      _controller.addListener(() {
        setState(() {
          currentExtent = maxExtent - _controller.offset;
          if (currentExtent < 100) currentExtent = 0.0;
          if (currentExtent > maxExtent) currentExtent = maxExtent;
        });
      });
    });
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuilds the TabBar when the tab selection changes
    });
  }

  DataModel? getModel() {
    _cachedModel ??= DataModel(prefs!.getString(Dbkeys.phone));
    return _cachedModel;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _isSelected(int index) {
    return _tabController.index == index;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final preffs = ref.watch(sharedPreferences).value;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarBrightness:
          Teme.isDarktheme(preffs!) ? Brightness.light : Brightness.dark,
      statusBarIconBrightness:
          Teme.isDarktheme(preffs) ? Brightness.light : Brightness.dark,
    ));

    final userProfileRef = ref.watch(userProfileFutureProvider);
    final walletAsyncValue = ref.watch(walletsStreamProvider);
    final feedList = ref.watch(getFeedsProvider);
    final teelsListAsyncValue = ref.watch(getTeelsProvider);
    final phone = ref.watch(currentUserStateProvider)!.phoneNumber!;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Teme.isDarktheme(preffs)
              ? AppConstants.primaryColorDark
              : AppConstants.primaryColor,
          elevation: 0,
          toolbarHeight: 10,
          automaticallyImplyLeading: false,
          // systemOverlayStyle: const SystemUiOverlayStyle(
          //   statusBarBrightness: Brightness.light,
          //   statusBarIconBrightness: Brightness.light,
          // )
        ),
        body: walletAsyncValue.when(
          data: (snapshot) {
            if (snapshot.docs.isEmpty) {
              ref.read(createNewWalletProvider);
              ref.refresh(walletsStreamProvider);
              return const Center(child: CircularProgressIndicator());
            } else {
              final wallet = WalletsModel.fromMap(
                  snapshot.docs.first.data() as Map<String, dynamic>);
              return userProfileRef.when(
                data: (data) {
                  // final phone = data!.phoneNumber;
                  final user = data!;
                  return DefaultTabController(
                    length: 3,
                    child: NestedScrollView(
                      controller: _controller,
                      physics: const BouncingScrollPhysics(),
                      headerSliverBuilder: (context, bool innerBoxIsScrolled) {
                        return <Widget>[
                          SliverAppBar(
                            // toolbarHeight: 45,
                            backgroundColor: Teme.isDarktheme(prefs!)
                                ? AppConstants.primaryColorDark
                                : AppConstants.primaryColor,
                            title: Row(
                              children: [
                                Expanded(
                                    child: Container(
                                  color: Teme.isDarktheme(prefs!)
                                      ? AppConstants.primaryColorDark
                                      : AppConstants.primaryColor,
                                  // width: width / 3,
                                  height: 50,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      if (widget.isHome != null)
                                        GestureDetector(
                                          onTap: () {
                                            if (!Responsive.isDesktop(
                                                context)) {
                                              Navigator.of(context).pop();
                                            } else {
                                              ref.invalidate(
                                                  arrangementProvider);
                                            }
                                          },
                                          child: WebsafeSvg.asset(
                                            height: 22,
                                            width: 22,
                                            fit: BoxFit.fitHeight,
                                            leftArrowSvg,
                                            color: Colors.white,
                                          ),
                                        ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        "@${data.userName}",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize:
                                              AppConstants.defaultNumericValue *
                                                  1.2,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      data.isVerified
                                          ? GestureDetector(
                                              onTap: () {
                                                EasyLoading.showToast(LocaleKeys
                                                    .verifiedUser
                                                    .tr());
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: AppConstants
                                                            .defaultNumericValue *
                                                        .5),
                                                child: Image(
                                                  image:
                                                      AssetImage(verifiedIcon),
                                                  width: 20,
                                                ),
                                              ),
                                            )
                                          : Container(),
                                      const Expanded(
                                        child: SizedBox(),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          showModalBottomSheet(
                                            context: context,
                                            backgroundColor: Colors.transparent,
                                            builder: (context) {
                                              return const DialogCoinsPlan();
                                            },
                                          );
                                        },
                                        child: Container(
                                            padding: const EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Colors.red,
                                                  Colors.purple,
                                                  Colors.orange,
                                                  Colors.pink,
                                                ], // Change colors as desired
                                                begin: Alignment
                                                    .topLeft, // Adjust gradient direction if needed
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius: BorderRadius
                                                  .circular(AppConstants
                                                          .defaultNumericValue *
                                                      2), // Adjust corner radius
                                            ),
                                            // Other container properties (width, height, padding, etc.)
                                            child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5),
                                                decoration: BoxDecoration(
                                                  color:
                                                      Teme.isDarktheme(prefs!)
                                                          ? AppConstants
                                                              .primaryColorDark
                                                          : AppConstants
                                                              .primaryColor,
                                                  borderRadius: BorderRadius
                                                      .circular(AppConstants
                                                              .defaultNumericValue *
                                                          2), // Adjust corner radius
                                                ),
                                                child: walletAsyncValue.when(
                                                  data: (snapshot) {
                                                    if (snapshot.docs.isEmpty) {
                                                      ref.read(
                                                          createNewWalletProvider);
                                                      ref.refresh(
                                                          walletsStreamProvider);
                                                      return const Center(
                                                          child:
                                                              CircularProgressIndicator());
                                                    } else {
                                                      final wallet =
                                                          WalletsModel.fromMap(
                                                              snapshot.docs.first
                                                                      .data()
                                                                  as Map<String,
                                                                      dynamic>);
                                                      return Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          GifView.asset(
                                                            coinsIcon,
                                                            height: 24,
                                                            width: 24,
                                                            frameRate:
                                                                60, // default is 15 FPS
                                                          ),
                                                          const SizedBox(
                                                            width: AppConstants
                                                                    .defaultNumericValue /
                                                                4,
                                                          ),
                                                          Text(
                                                              wallet.balance
                                                                  .toStringAsFixed(
                                                                      2),
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .titleSmall!
                                                                  .copyWith(
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w900)),
                                                        ],
                                                      );
                                                    }
                                                  },
                                                  loading: () => const Center(
                                                      child:
                                                          CircularProgressIndicator()),
                                                  error: (_, __) =>
                                                      const Center(
                                                          child: Text('0')),
                                                ))),
                                      ),
                                      const SizedBox(
                                          width:
                                              AppConstants.defaultNumericValue /
                                                  2),
                                      IconButton(
                                          onPressed: () {
                                            profileMore(context, ref, prefs!,
                                                data.phoneNumber, data);
                                          },
                                          icon: const Icon(
                                              Icons.more_vert_rounded,
                                              color: Colors.white)),
                                      const SizedBox(
                                          width:
                                              AppConstants.defaultNumericValue /
                                                  2)
                                    ],
                                  ),
                                )),
                              ],
                            ),
                            // backgroundColor: AppConstants.secondaryColor,
                            flexibleSpace: FlexibleSpaceBar.createSettings(
                                currentExtent: currentExtent,
                                minExtent: 0,
                                maxExtent: maxExtent,
                                child: const FlexibleSpaceBar(
                                  background: ProfileView(),
                                )),
                            expandedHeight: maxExtent,
                            automaticallyImplyLeading: false,
                            floating: false,
                            pinned: true,
                            primary: true,
                            snap: false,
                          ),
                          SliverPersistentHeader(
                            delegate: MyDelegate(
                                TabBar(
                                  dividerColor: Colors.transparent,
                                  controller: _tabController,
                                  tabs: [
                                    Tab(
                                      icon: WebsafeSvg.asset(
                                        height: 36,
                                        width: 36,
                                        fit: BoxFit.fitHeight,
                                        gridIcon,
                                        color: _isSelected(0)
                                            ? AppConstants.primaryColor
                                            : Colors.grey,
                                      ),
                                    ),
                                    Tab(
                                      icon: WebsafeSvg.asset(
                                        height: 36,
                                        width: 36,
                                        fit: BoxFit.fitHeight,
                                        reelsIcon,
                                        color: _isSelected(1)
                                            ? AppConstants.primaryColor
                                            : Colors.grey,
                                      ),
                                    ),
                                    Tab(
                                      icon: WebsafeSvg.asset(
                                        height: 36,
                                        width: 36,
                                        fit: BoxFit.fitHeight,
                                        feedsIcon,
                                        color: _isSelected(2)
                                            ? AppConstants.primaryColor
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                  indicatorColor: AppConstants.primaryColor,
                                  unselectedLabelColor: Colors.grey,
                                  labelColor: AppConstants.primaryColor,
                                ),
                                prefs!),
                            pinned: true,
                          )
                        ];
                      },
                      body: TabBarView(controller: _tabController, children: [
                        // Tab 1

                        CustomScrollView(
                          physics: const BouncingScrollPhysics(),
                          slivers: <Widget>[
                            SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 1,
                                crossAxisSpacing: 2,
                                mainAxisSpacing: 2,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SinglePhotoViewPage(
                                                  images: data.mediaFiles,
                                                  index: index,
                                                  title:
                                                      LocaleKeys.images.tr()),
                                        ),
                                      );
                                    },
                                    child: CachedNetworkImage(
                                      imageUrl: data.mediaFiles[index],
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const Center(
                                        child: CircularProgressIndicator
                                            .adaptive(),
                                      ),
                                      errorWidget: (context, url, error) {
                                        return const Center(
                                          child:
                                              Icon(Icons.image_not_supported),
                                        );
                                      },
                                    ),
                                  );
                                },
                                childCount: data.mediaFiles.length,
                              ),
                            ),
                          ],
                        ),

                        // Tab 2

                        teelsListAsyncValue.when(
                          data: (teelsList) {
                            final myTeels = teelsList
                                .where((element) =>
                                    element.phoneNumber == data.phoneNumber)
                                .toList();

                            if (myTeels.isEmpty) {
                              return SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                child: Center(
                                    child: NoItemFoundWidget(
                                        text: LocaleKeys.noFeedFound.tr())),
                              );
                            } else {
                              return CustomScrollView(
                                slivers: <Widget>[
                                  SliverGrid(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3, // number of columns
                                      childAspectRatio: 0.6, // aspect ratio
                                      crossAxisSpacing: 2, // horizontal spacing
                                      mainAxisSpacing: 2, // vertical spacing
                                    ),
                                    delegate: SliverChildBuilderDelegate(
                                      (BuildContext context, int index) {
                                        return InkWell(
                                          onTap: () {
                                            !(Responsive.isDesktop(context))
                                                ? Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          VideoListScreen(
                                                        list: myTeels,
                                                        index: myTeels.indexOf(
                                                            myTeels[index]),
                                                        type: "video",
                                                        phoneNumber:
                                                            data.phoneNumber,
                                                        soundId: myTeels[index]
                                                            .soundId,
                                                      ),
                                                    ),
                                                  )
                                                : ref
                                                    .read(arrangementProvider
                                                        .notifier)
                                                    .setArrangement(
                                                        VideoListScreen(
                                                      list: myTeels,
                                                      index: myTeels.indexOf(
                                                          myTeels[index]),
                                                      type: "video",
                                                      phoneNumber:
                                                          data.phoneNumber,
                                                      soundId: myTeels[index]
                                                          .soundId,
                                                    ));
                                          },
                                          onLongPress: () async {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                // return dialog content
                                                return AlertDialog(
                                                  title: Text(
                                                      LocaleKeys.confirm.tr()),
                                                  content: Text(
                                                      "${LocaleKeys.deleteFeed.tr()}?"),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () {
                                                        deleteTeel(
                                                            myTeels[index].id);
                                                        myTeels.removeAt(index);
                                                        ref.invalidate(
                                                            getTeelsProvider);
                                                        // ref.invalidate(provider)
                                                        Navigator.pop(context,
                                                            true); // User pressed Yes
                                                      },
                                                      child: Text(
                                                          LocaleKeys.yes.tr()),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context,
                                                            false); // User pressed No
                                                      },
                                                      child: Text(
                                                          LocaleKeys.no.tr()),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                            // await  deleteTeel(myTeels[index].id);
                                          },
                                          child: GridTile(
                                            footer: GridTileBar(
                                              backgroundColor: Colors.black54,
                                              title: Text(
                                                myTeels[index]
                                                        .views
                                                        .length
                                                        .toString() +
                                                    LocaleKeys.views.tr(),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  myTeels[index].thumbnail!,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  const Center(
                                                child: CircularProgressIndicator
                                                    .adaptive(),
                                              ),
                                              errorWidget:
                                                  (context, url, error) {
                                                return const Center(
                                                  child: Icon(Icons
                                                      .image_not_supported),
                                                );
                                              },
                                            ),

                                            //  Image.network(
                                            //   teelsList[index].thumbnail!,
                                            //   fit: BoxFit.cover,
                                            // ),
                                          ),
                                        );
                                      },
                                      childCount: myTeels.length,
                                    ),
                                  ),
                                ],
                              );
                            }
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (error, stack) =>
                              Center(child: Text(LocaleKeys.error.tr())),
                        ),

                        // Tab 3

                        Column(
                          children: [
                            feedList.when(
                              data: (feed) {
                                final myFeeds = feed
                                    .where((element) =>
                                        element.phoneNumber == data.phoneNumber)
                                    .toList();

                                if (myFeeds.isEmpty) {
                                  return SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.5,
                                    child: Center(
                                        child: NoItemFoundWidget(
                                            text: LocaleKeys.noFeedFound.tr())),
                                  );
                                } else {
                                  return ListView.builder(
                                      shrinkWrap: true,
                                      physics: const ScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        final feeds = myFeeds[index];

                                        return SingleFeedPost(
                                          feed: feeds,
                                          user: data,
                                          currentUser: data,
                                        );
                                      },
                                      itemCount: myFeeds.length);
                                }
                              },
                              error: (_, __) => SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                              ),
                              loading: () => SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                              ),
                            ),
                          ],
                        )
                      ]
                          // .map((tab) => GridView.count(
                          //       physics: const BouncingScrollPhysics(),
                          //       crossAxisCount: 3,
                          //       shrinkWrap: true,
                          //       mainAxisSpacing: 2.0,
                          //       crossAxisSpacing: 2.0,
                          //       children: posts
                          //           .map((e) => Container(
                          //                 decoration: BoxDecoration(
                          //                     image: DecorationImage(
                          //                         image: AssetImage(e),
                          //                         fit: BoxFit.fill)),
                          //               ))
                          //           .toList(),
                          //     ))
                          // .toList(),
                          ),
                    ),
                  );
                },
                error: (_, e) =>
                    Center(child: Text(LocaleKeys.somethingWentWrong.tr())),
                loading: () => const Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
              );
            }
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(child: Text(LocaleKeys.error.tr())),
        ));
  }
}

class MyDelegate extends SliverPersistentHeaderDelegate {
  MyDelegate(this.tabBar, this.prefs);
  final TabBar tabBar;
  final SharedPreferences prefs;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Teme.isDarktheme(prefs)
          ? AppConstants.backgroundColorDark
          : AppConstants.backgroundColor,
      child: Center(
        child: tabBar,
      ),
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

void profileMore(BuildContext context, ref, SharedPreferences prefs,
    String phone, UserProfileModel user) {
  // final width = MediaQuery.of(context).size.width;
  final height = MediaQuery.of(context).size.height;
  // final phone = ref.read(currentUserStateProvider)!.phoneNumber;
  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
    ),
    constraints: BoxConstraints(
      maxHeight: height * 0.7,
      minHeight: height * 0.6,
    ),
    backgroundColor: Teme.isDarktheme(prefs)
        ? AppConstants.backgroundColorDark
        : AppConstants.backgroundColor,
    builder: (BuildContext context) {
      // List of your list text
      List<String> listText = [
        LocaleKeys.settings.tr(),
        LocaleKeys.goLive.tr(),
        LocaleKeys.wallet.tr(),
        LocaleKeys.meetups.tr(),
        LocaleKeys.likes.tr(),
        LocaleKeys.matches.tr(),
        "Find New Friends",
        LocaleKeys.security.tr(),
        LocaleKeys.privacyPolicy.tr(),
        LocaleKeys.faq.tr(),
        LocaleKeys.help.tr(),
        LocaleKeys.logout.tr(),
      ];
      List<Widget> pages = [
        AccountSettingsLandingWidget(
          currentUserNo: phone,
          userProfile: user,
        ),
        const LiveStreamScreen(),
        const WalletPage(),
        const MeetingsPage(),
        const InteractionsPage(),
        const MatchesConsumerPage(),
        const ExplorePage(),
        const SecurityAndPrivacyLandingPage(),
        const PrivacyPolicy(),
        const FaqPage(),
        const ContactUs(),
        const LandingWidget(),
      ];
      return SizedBox(
        width: Responsive.isMobile(context)
            ? MediaQuery.of(context).size.width
            : MediaQuery.of(context).size.width * .45,
        child: Column(
          children: [
            const SizedBox(
              height: AppConstants.defaultNumericValue,
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: AppConstants.defaultNumericValue,
                  ),
                  InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: WebsafeSvg.asset(
                        closeIcon,
                        color: AppConstants.secondaryColor,
                        height: 32,
                        width: 32,
                        fit: BoxFit.contain,
                      )),
                  const Spacer(),
                  Container(
                      width: AppConstants.defaultNumericValue * 3,
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: AppConstants.hintColor,
                      )),
                  const Spacer(),
                ]),
            const SizedBox(
              width: AppConstants.defaultNumericValue,
            ),
            Expanded(
              child: Padding(
                  padding:
                      const EdgeInsets.all(AppConstants.defaultNumericValue),
                  child: ListView.builder(
                    itemCount: pages.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        leading: WebsafeSvg.asset(
                            height: 36,
                            width: 36,
                            fit: BoxFit.fitHeight,
                            color: Teme.isDarktheme(prefs)
                                ? AppConstants.backgroundColor
                                : AppConstants.backgroundColorDark,
                            svgIcons[index]),
                        title: Text(listText[index]),
                        onTap: index != 11
                            ? () {
                                Navigator.pop(context);
                                !Responsive.isDesktop(context)
                                    ? Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => pages[index]),
                                      )
                                    : {
                                        // updateCurrentIndex(ref, 10),
                                        ref
                                            .read(arrangementProviderExtend
                                                .notifier)
                                            .setArrangement(pages[index])
                                      };
                              }
                            : () async {
                                EasyLoading.show(
                                    status: LocaleKeys.loggingout.tr());
                                final currentUserId = ref
                                    .read(currentUserStateProvider)!
                                    .phoneNumber;

                                if (currentUserId != null) {
                                  await ref
                                      .read(userProfileNotifier)
                                      .updateOnlineStatus(
                                          isOnline: false,
                                          phoneNumber: currentUserId);
                                }
                                await ref.read(authProvider).signOut();
                                EasyLoading.dismiss();
                                Navigator.pop(context);
                              },
                      );
                    },
                  )),
            ),
          ],
        ),
      );
    },
  );
}

// List of your pages

// List of your SVG icons
List<String> svgIcons = [
  settingsLinearIcon,
  liveIcon,
  walletIcon,
  meetupIcon,
  likeIcon,
  likeIcon,
  profileIcon,
  boltIcon,
  boltIcon,
  boltIcon,
  boltIcon,
  logoutIcon
  // walletIcon,

  // Add all your SVG icons here
];
