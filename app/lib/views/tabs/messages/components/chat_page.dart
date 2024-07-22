// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers, unused_field, unused_local_variable

// import 'dart:io';
// import 'dart:ui';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as e;
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:websafe_svg/websafe_svg.dart';
// import 'package:lamatdating/generated/locale_keys.g.dart';
// import 'package:lamatdating/main.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:social_media_recorder/audio_encoder_type.dart';
// import 'package:social_media_recorder/screen/social_media_recorder.dart';
// import 'package:voice_message_package/voice_message_package.dart' as v;

import 'package:lamatdating/helpers/constants.dart';
// import 'package:lamatdating/helpers/date_formater.dart';
// import 'package:lamatdating/helpers/encrypt_helper.dart';
// import 'package:lamatdating/helpers/media_picker_helper.dart';
// import 'package:lamatdating/models/chat_item_model.dart';
// import 'package:lamatdating/models/user_profile_model.dart';
// import 'package:lamatdating/providers/auth_providers.dart';
// import 'package:lamatdating/providers/block_user_provider.dart';
// import 'package:lamatdating/providers/chat_provider.dart';
// import 'package:lamatdating/providers/other_users_provider.dart';
// import 'package:lamatdating/providers/wallets_provider.dart';
// import 'package:lamatdating/views/custom/custom_icon_button.dart';
// import 'package:lamatdating/views/live/widgets/gift_sheet.dart';
// import 'package:lamatdating/views/live/widgets/user_circle_widg.dart';
// import 'package:lamatdating/views/others/photo_view_page.dart';
// import 'package:lamatdating/views/report/report_page.dart';
// import 'package:lamatdating/views/otherProfile/user_details_page.dart';
// import 'package:lamatdating/views/others/video_player_page.dart';
// import 'package:lamatdating/views/tabs/messages/components/chat_media_gallery_page.dart';
// import 'package:lamatdating/views/tabs/messages/components/chat_page_background.dart';
// import 'package:lamatdating/views/wallet/dialog_coins_plan.dart';

// class ChatPage extends ConsumerStatefulWidget {
//   final String otherUserId;
//   final String matchId;
//   const ChatPage({
//     Key? key,
//     required this.otherUserId,
//     required this.matchId,
//   }) : super(key: key);

//   @override
//   ConsumerState<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends ConsumerState<ChatPage> {
//   final _chatController = TextEditingController();
//   bool emojiShowing = false;
//   String? _imagePath;
//   String? _videoPath;
//   String? _audioPath;
//   String? _filePath;

//   String? _searchQuery;

//   void _onSendMessage() async {
//     final chatData = ref.read(chatProvider);

//     if (_chatController.text.isNotEmpty ||
//         _imagePath != null ||
//         _videoPath != null ||
//         _audioPath != null ||
//         _filePath != null) {
//       final currentTime = DateTime.now();

//       String? imageUrl;
//       String? videoUrl;
//       String? audioUrl;
//       String? fileUrl;

//       if (_imagePath != null) {
//         EasyLoading.show(status: LocaleKeys.uploading.tr());
//         imageUrl = await chatData.uploadFile(
//             file: File(_imagePath!), matchId: widget.matchId);
//         EasyLoading.dismiss();
//       }

//       if (_videoPath != null) {
//         EasyLoading.show(status: LocaleKeys.uploading.tr());
//         videoUrl = await chatData.uploadFile(
//             file: File(_videoPath!), matchId: widget.matchId);
//         EasyLoading.dismiss();
//       }

//       if (_audioPath != null) {
//         EasyLoading.show(status: LocaleKeys.uploading.tr());
//         audioUrl = await chatData.uploadFile(
//             file: File(_audioPath!), matchId: widget.matchId);
//         EasyLoading.dismiss();
//       }

//       if (_filePath != null) {
//         EasyLoading.show(status: LocaleKeys.uploading.tr());
//         fileUrl = await chatData.uploadFile(
//             file: File(_filePath!), matchId: widget.matchId);
//         EasyLoading.dismiss();
//       }

//       final String? message = _chatController.text.isEmpty
//           ? null
//           : encryptText(_chatController.text);

//       ChatItemModel chatItem = ChatItemModel(
//         message: message,
//         createdAt: currentTime,
//         id: currentTime.millisecondsSinceEpoch.toString(),
//         phoneNumber: ref.watch(currentUserStateProvider)!.phoneNumber,
//         matchId: widget.matchId,
//         isRead: false,
//         image: imageUrl,
//         video: videoUrl,
//         audio: audioUrl,
//         file: fileUrl,
//       );

//       chatData.createChatItem(widget.matchId, chatItem);
//       _chatController.clear();
//       setState(() {
//         _imagePath = null;
//         _videoPath = null;
//         _audioPath = null;
//         _filePath = null;
//       });
//     }
//   }

//   _onEmojiSelected(e.Emoji emoji) {
//     setState(() {
//       _chatController
//         ..text += emoji.emoji
//         ..selection = TextSelection.fromPosition(
//             TextPosition(offset: _chatController.text.length));
//     });
//   }

//   _onBackspacePressed() {
//     setState(() {
//       _chatController
//         ..text = _chatController.text.characters.skipLast(1).toString()
//         ..selection = TextSelection.fromPosition(
//             TextPosition(offset: _chatController.text.length));
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final otherUsers = ref.watch(otherUsersProvider);
//     final prefs = ref.watch(sharedPreferencesProvider).value;
//     UserProfileModel? otherUser;
//     otherUsers.whenData((value) {
//       otherUser = value
//           .where((element) {
//             return element.phoneNumber == widget.otherUserId;
//           })
//           .toList()
//           .first;
//     });

//     return GestureDetector(
//       onTap: () {
//         FocusScope.of(context).requestFocus(FocusNode());
//         setState(() {
//           emojiShowing = false;
//         });
//       },
//       child: ChatPageBackground(
//         child: Scaffold(
//           backgroundColor: Colors.transparent,
//           // appBar: AppBar(
//           //   toolbarHeight: 0,
//           //   backgroundColor: Colors.transparent,
//           //   elevation: 0,
//           //   systemOverlayStyle: SystemUiOverlayStyle.dark,
//           // ),
//           body: SafeArea(
//               top: false,
//               child: Stack(
//                 alignment: Alignment.topCenter,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       Expanded(
//                         child: ChatBody(
//                           matchId: widget.matchId,
//                           searchQuery: _searchQuery,
//                           onSearchClear: () {
//                             setState(() {
//                               _searchQuery = null;
//                             });
//                           },
//                         ),
//                       ),
//                       const SizedBox(
//                           height: AppConstants.defaultNumericValue / 2),
//                       ChatTextFieldAndOthers(
//                         otherUser: otherUser,
//                         chatController: _chatController,
//                         onChangeText: () {
//                           setState(() {});
//                         },
//                         onTapEmoji: () {
//                           setState(() {
//                             emojiShowing = !emojiShowing;
//                           });
//                           FocusScope.of(context).requestFocus(FocusNode());
//                         },
//                         onTapVoice: () {
//                           showModalBottomSheet(
//                             context: context,
//                             isDismissible: false,
//                             enableDrag: false,
//                             backgroundColor: Colors.transparent,
//                             builder: (_) =>
//                                 VoiceRecorder(matchId: widget.matchId),
//                           );
//                         },
//                         onTapTextField: () {
//                           setState(() {
//                             emojiShowing = false;
//                           });
//                         },
//                         imageUrl: _imagePath,
//                         videoUrl: _videoPath,
//                         audioUrl: _audioPath,
//                         fileUrl: _filePath,
//                         onImageSelected: (String? path) {
//                           setState(() {
//                             _imagePath = path;
//                           });
//                         },
//                         onVideoSelected: (String? path) {
//                           setState(() {
//                             _videoPath = path;
//                           });
//                         },
//                         onAudioSelected: (String? path) {
//                           setState(() {
//                             _audioPath = path;
//                           });
//                         },
//                         onFileSelected: (String? path) {
//                           setState(() {
//                             _filePath = path;
//                           });
//                         },
//                         onTapSend: _onSendMessage,
//                       ),
//                       const SizedBox(
//                           height: AppConstants.defaultNumericValue / 2),
//                       Offstage(
//                         offstage: !emojiShowing,
//                         child: SizedBox(
//                           height: 250,
//                           child: e.EmojiPicker(
//                             onEmojiSelected:
//                                 (e.Category? category, e.Emoji emoji) {
//                               _onEmojiSelected(emoji);
//                             },
//                             onBackspacePressed: _onBackspacePressed,
//                             config: _emojiPickerConfig,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   if (otherUser != null)
//                     ChatTopBar(
//                       prefs: prefs!,
//                       otherUser: otherUser!,
//                       myUserId:
//                           ref.watch(currentUserStateProvider)!.phoneNumber!,
//                       matchId: widget.matchId,
//                       onSearch: (query) {
//                         setState(() {
//                           _searchQuery = query;
//                         });
//                       },
//                     ),
//                 ],
//               )),
//         ),
//       ),
//     );
//   }
// }

// class ChatBody extends ConsumerStatefulWidget {
//   final String matchId;
//   final String? searchQuery;
//   final VoidCallback onSearchClear;
//   const ChatBody({
//     Key? key,
//     required this.matchId,
//     required this.searchQuery,
//     required this.onSearchClear,
//   }) : super(key: key);

//   @override
//   ConsumerState<ChatBody> createState() => _ChatBodyState();
// }

// class _ChatBodyState extends ConsumerState<ChatBody> {
//   final _scrollController = ScrollController();

//   @override
//   Widget build(BuildContext context) {
//     final chatStreams = ref.watch(chatStreamProviderProvider(widget.matchId));

//     return chatStreams.when(
//         data: (data) {
//           return Column(
//             children: [
//               if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty)
//                 ListTile(
//                   title: Text(
//                     LocaleKeys.search.tr(),
//                     style: Theme.of(context).textTheme.bodySmall,
//                   ),
//                   leading: const Icon(Icons.search),
//                   minLeadingWidth: 0,
//                   subtitle: Text(
//                     widget.searchQuery!,
//                     style: Theme.of(context).textTheme.bodyLarge,
//                   ),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.clear),
//                         onPressed: widget.onSearchClear,
//                       ),
//                       IconButton(
//                           onPressed: () {
//                             //Move to a specific chat item
//                             _scrollController.animateTo(
//                               _scrollController.position.minScrollExtent,
//                               duration: const Duration(milliseconds: 1000),
//                               curve: Curves.easeInOut,
//                             );
//                           },
//                           icon: const Icon(Icons.arrow_downward)),
//                       IconButton(
//                           onPressed: () {
//                             _scrollController.animateTo(
//                               _scrollController.position.maxScrollExtent,
//                               duration: const Duration(milliseconds: 1000),
//                               curve: Curves.easeInOut,
//                             );
//                           },
//                           icon: const Icon(Icons.arrow_upward)),
//                     ],
//                   ),
//                 ),
//               if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty)
//                 const Divider(height: 0),
//               Expanded(
//                 child: ListView.builder(
//                   controller: _scrollController,
//                   reverse: true,
//                   itemCount: data.length,
//                   itemBuilder: (context, index) {
//                     final item = data[index];
//                     final bool isSearching = widget.searchQuery != null &&
//                         widget.searchQuery!.isNotEmpty &&
//                         item.message != null &&
//                         decryptText(item.message!)
//                             .toLowerCase()
//                             .contains(widget.searchQuery!.toLowerCase());

//                     return MessageSingleTile(
//                       key: ValueKey(item.id),
//                       chat: item,
//                       matchId: widget.matchId,
//                       isSearching: isSearching,
//                     );
//                   },
//                 ),
//               ),
//             ],
//           );
//         },
//         error: (_, __) => const SizedBox(),
//         loading: () => const SizedBox());
//   }
// }

// class ChatTopBar extends ConsumerStatefulWidget {
//   final SharedPreferences prefs;
//   final UserProfileModel otherUser;
//   final String myUserId;
//   final Function(String?) onSearch;

//   final String matchId;
//   const ChatTopBar({
//     Key? key,
//     required this.otherUser,
//     required this.myUserId,
//     required this.onSearch,
//     required this.matchId,
//     required this.prefs,
//   }) : super(key: key);

//   @override
//   ConsumerState<ChatTopBar> createState() => _ChatTopBarState();
// }

// class _ChatTopBarState extends ConsumerState<ChatTopBar> {
//   final CustomPopupMenuController _moreMenuController =
//       CustomPopupMenuController();

//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//     double height = MediaQuery.of(context).size.height;
//     return ClipRRect(
//         child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
//             child: Container(
//                 color:
//                     Theme.of(context).scaffoldBackgroundColor.withOpacity(0.2),
//                 width: MediaQuery.of(context).size.width,
//                 padding:
//                     EdgeInsets.only(top: MediaQuery.of(context).padding.top),
//                 child: ListTile(
//                   minVerticalPadding: 0,
//                   dense: true,
//                   visualDensity: VisualDensity.compact,
//                   onTap: () {
//                     showModalBottomSheet(
//                       context: context,
//                       isScrollControlled: true,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(
//                             AppConstants.defaultNumericValue / 2),
//                       ),
//                       builder: (context) {
//                         return AnimatedBuilder(
//                           animation: CurvedAnimation(
//                             parent: ModalRoute.of(context)!.animation!,
//                             curve: Curves.elasticOut,
//                           ),
//                           builder: (context, child) {
//                             return Column(
//                               children: [
//                                 Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal:
//                                             AppConstants.defaultNumericValue,
//                                         vertical:
//                                             AppConstants.defaultNumericValue),
//                                     child: Row(
//                                       children: [
//                                         CustomIconButton(
//                                             padding: const EdgeInsets.all(
//                                                 AppConstants
//                                                         .defaultNumericValue /
//                                                     1.8),
//                                             onPressed: () =>
//                                                 Navigator.pop(context),
//                                             color: AppConstants.primaryColor,
//                                             icon: closeIcon),
//                                       ],
//                                     )),
//                                 Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal:
//                                           AppConstants.defaultNumericValue,
//                                     ),
//                                     child: Stack(
//                                       children: [
//                                         UserCirlePicture(
//                                             imageUrl:
//                                                 widget.otherUser.profilePicture,
//                                             size: AppConstants
//                                                     .defaultNumericValue *
//                                                 5),
//                                         if (widget.otherUser.isOnline)
//                                           Container(
//                                             decoration: BoxDecoration(
//                                               shape: BoxShape.circle,
//                                               border: Border.all(
//                                                 color: AppConstants
//                                                     .primaryColor, // Set border color
//                                                 width: 2.0, // Set border width
//                                               ),
//                                             ),
//                                             child: const CircleAvatar(
//                                               backgroundColor:
//                                                   AppConstants.onlineStatus,
//                                               radius: 8,
//                                             ),
//                                           )
//                                       ],
//                                     )),
//                                 Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal:
//                                             AppConstants.defaultNumericValue *
//                                                 1.2,
//                                         vertical:
//                                             AppConstants.defaultNumericValue /
//                                                 2),
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         Text(
//                                           widget.otherUser.fullName,
//                                           style: Theme.of(context)
//                                               .textTheme
//                                               .headlineSmall!
//                                               .copyWith(
//                                                   fontWeight: FontWeight.bold),
//                                         ),
//                                         widget.otherUser.isVerified
//                                             ? GestureDetector(
//                                                 onTap: () {
//                                                   EasyLoading.showToast(
//                                                       LocaleKeys.verifiedUser
//                                                           .tr());
//                                                 },
//                                                 child: const Padding(
//                                                     padding: EdgeInsets.only(
//                                                         top: 5,
//                                                         left: AppConstants
//                                                                 .defaultNumericValue /
//                                                             2),
//                                                     child: Image(
//                                                       image: AssetImage(
//                                                           verifiedIcon),
//                                                       height: 24,
//                                                       width: 24,
//                                                     )),
//                                               )
//                                             : const SizedBox(),
//                                         widget.otherUser.isBoosted
//                                             ? Padding(
//                                                 padding: const EdgeInsets.only(
//                                                     top: 5,
//                                                     left: AppConstants
//                                                             .defaultNumericValue /
//                                                         2),
//                                                 child: WebsafeSvg.asset(
//                                                   boostedIcon,
//                                                   color: const Color.fromARGB(
//                                                       255, 255, 133, 67),
//                                                   width: 26,
//                                                   height: 26,
//                                                 ),
//                                               )
//                                             : const SizedBox(),
//                                       ],
//                                     )),
//                                 Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal:
//                                             AppConstants.defaultNumericValue *
//                                                 1.2,
//                                         vertical:
//                                             AppConstants.defaultNumericValue /
//                                                 2),
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         CustomIconButton(
//                                             color: AppConstants.primaryColor,
//                                             padding: const EdgeInsets.all(
//                                                 AppConstants
//                                                         .defaultNumericValue /
//                                                     1.8),
//                                             onPressed: () {
//                                               Navigator.of(context).push(
//                                                 CupertinoPageRoute(
//                                                   builder: (context) =>
//                                                       UserDetailsPage(
//                                                     user: widget.otherUser,
//                                                     matchId: widget.matchId,
//                                                   ),
//                                                 ),
//                                               );
//                                             },
//                                             icon: logoIcon)
//                                       ],
//                                     )),
//                                 Expanded(
//                                     child: Column(children: [
//                                   Container(
//                                       decoration: BoxDecoration(
//                                         color: AppConstants.primaryColor
//                                             .withOpacity(.1),
//                                         borderRadius: BorderRadius.circular(
//                                             20), // Adjust the radius as needed
//                                         // Adjust the border color and width as needed
//                                       ),
//                                       margin: const EdgeInsets.symmetric(
//                                         horizontal:
//                                             AppConstants.defaultNumericValue,
//                                       ),
//                                       padding: const EdgeInsets.symmetric(
//                                         vertical:
//                                             AppConstants.defaultNumericValue /
//                                                 3,
//                                       ),
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.stretch,
//                                         children: [
//                                           MoreMenuTitle(
//                                             icon: imgIcon,
//                                             title: LocaleKeys.gallery.tr(),
//                                             onTap: () {
//                                               Navigator.of(context).push(
//                                                 CupertinoPageRoute(
//                                                   builder: (context) =>
//                                                       ChatMediaGalleryConsumerPage(
//                                                           matchId:
//                                                               widget.matchId),
//                                                 ),
//                                               );
//                                             },
//                                           ),
//                                           const Divider(
//                                             indent: AppConstants
//                                                     .defaultNumericValue *
//                                                 3.3,
//                                           ),
//                                           MoreMenuTitle(
//                                             icon: searchIcon,
//                                             title: LocaleKeys.search,
//                                             onTap: () async {
//                                               final String? query =
//                                                   await showDialog(
//                                                       context: context,
//                                                       builder: (context) {
//                                                         final searchController =
//                                                             TextEditingController();
//                                                         return AlertDialog(
//                                                           title: Text(LocaleKeys
//                                                               .search
//                                                               .tr()),
//                                                           content: TextField(
//                                                             controller:
//                                                                 searchController,
//                                                             autofocus: true,
//                                                             onChanged: (_) {
//                                                               setState(() {});
//                                                             },
//                                                             decoration: InputDecoration(
//                                                                 hintText: LocaleKeys
//                                                                     .typeSomething
//                                                                     .tr()),
//                                                           ),
//                                                           actions: [
//                                                             OutlinedButton(
//                                                               child: Text(
//                                                                   LocaleKeys
//                                                                       .cancel
//                                                                       .tr()),
//                                                               onPressed: () {
//                                                                 Navigator.of(
//                                                                         context)
//                                                                     .pop();
//                                                               },
//                                                             ),
//                                                             ElevatedButton(
//                                                               onPressed: () {
//                                                                 Navigator.of(
//                                                                         context)
//                                                                     .pop(searchController
//                                                                             .text
//                                                                             .isEmpty
//                                                                         ? null
//                                                                         : searchController
//                                                                             .text);
//                                                               },
//                                                               child: Text(
//                                                                   LocaleKeys
//                                                                       .search
//                                                                       .tr()),
//                                                             )
//                                                           ],
//                                                         );
//                                                       });

//                                               widget.onSearch(query);
//                                             },
//                                           ),
//                                           const Divider(
//                                             indent: AppConstants
//                                                     .defaultNumericValue *
//                                                 3.3,
//                                           ),
//                                           MoreMenuTitle(
//                                             icon: lamatStarIcon,
//                                             title: LocaleKeys.background.tr(),
//                                             onTap: () {
//                                               Navigator.push(
//                                                 context,
//                                                 MaterialPageRoute(
//                                                     builder: (context) =>
//                                                         const ChatWallpaperPage()),
//                                               );
//                                             },
//                                           ),
//                                           const Divider(
//                                             indent: AppConstants
//                                                     .defaultNumericValue *
//                                                 3.3,
//                                           ),
//                                           MoreMenuTitle(
//                                             icon: closeIcon,
//                                             title: LocaleKeys.clearChat.tr(),
//                                             onTap: () async {
//                                               await ref
//                                                   .read(chatProvider)
//                                                   .clearChat(widget.matchId)
//                                                   .then((value) {
//                                                 if (value) {
//                                                   Navigator.of(context).pop();
//                                                 }
//                                               });
//                                             },
//                                           ),
//                                           const Divider(
//                                             indent: AppConstants
//                                                     .defaultNumericValue *
//                                                 3.3,
//                                           ),
//                                           MoreMenuTitle(
//                                             icon: lamatStarIcon,
//                                             title: LocaleKeys.report.tr(),
//                                             onTap: () {
//                                               Navigator.push(
//                                                 context,
//                                                 MaterialPageRoute(
//                                                   builder: (context) =>
//                                                       ReportPage(
//                                                           userProfileModel:
//                                                               widget.otherUser),
//                                                 ),
//                                               );
//                                             },
//                                           ),
//                                           const Divider(
//                                             indent: AppConstants
//                                                     .defaultNumericValue *
//                                                 3.3,
//                                           ),
//                                           MoreMenuTitle(
//                                             icon: lamatStarIcon,
//                                             title: LocaleKeys.block.tr(),
//                                             onTap: () {
//                                               showDialog(
//                                                   context: context,
//                                                   builder: (context) {
//                                                     return AlertDialog(
//                                                       title: Text(LocaleKeys
//                                                           .block
//                                                           .tr()),
//                                                       content: Text(LocaleKeys
//                                                           .areyousureyouwanttoblockthisuser
//                                                           .tr()),
//                                                       actions: [
//                                                         TextButton(
//                                                           child: Text(LocaleKeys
//                                                               .cancel
//                                                               .tr()),
//                                                           onPressed: () {
//                                                             Navigator.of(
//                                                                     context)
//                                                                 .pop();
//                                                           },
//                                                         ),
//                                                         Consumer(builder:
//                                                             (context, ref,
//                                                                 child) {
//                                                           return TextButton(
//                                                             child: Text(
//                                                                 LocaleKeys.block
//                                                                     .tr()),
//                                                             onPressed:
//                                                                 () async {
//                                                               EasyLoading.show(
//                                                                   status: LocaleKeys
//                                                                       .blocking
//                                                                       .tr());

//                                                               await blockUser(
//                                                                       widget
//                                                                           .otherUser
//                                                                           .phoneNumber,
//                                                                       widget
//                                                                           .myUserId)
//                                                                   .then(
//                                                                       (value) {
//                                                                 ref.invalidate(
//                                                                     otherUsersProvider);
//                                                                 ref.invalidate(
//                                                                     blockedUsersFutureProvider);
//                                                                 EasyLoading
//                                                                     .dismiss();
//                                                                 Navigator.of(
//                                                                         context)
//                                                                     .pop();
//                                                                 Navigator.of(
//                                                                         context)
//                                                                     .pop();
//                                                               });
//                                                             },
//                                                           );
//                                                         }),
//                                                       ],
//                                                     );
//                                                   });
//                                             },
//                                           ),
//                                         ],
//                                       ))
//                                 ])),
//                               ],
//                             );
//                           },
//                         );
//                       },
//                     );

//                     // Navigator.of(context).push(
//                     //   CupertinoPageRoute(
//                     //     builder: (context) => UserDetailsPage(
//                     //       user: widget.otherUser,
//                     //       matchId: widget.matchId,
//                     //     ),
//                     //   ),
//                     // );
//                   },
//                   contentPadding: const EdgeInsets.only(bottom: 0),
//                   title: Row(
//                     children: [
//                       Text(
//                         widget.otherUser.fullName,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style:
//                             Theme.of(context).textTheme.titleMedium!.copyWith(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                       ),
//                     ],
//                   ),
//                   subtitle: Text((widget.otherUser.isOnline)
//                       ? LocaleKeys.active.tr()
//                       : LocaleKeys.recentlyactive.tr()),
//                   leading: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       CustomIconButton(
//                           padding: const EdgeInsets.all(
//                               AppConstants.defaultNumericValue / 1.8),
//                           onPressed: () => Navigator.pop(context),
//                           color: AppConstants.backgroundColor,
//                           icon: leftArrowSvg),
//                       Stack(
//                         children: [
//                           UserCirlePicture(
//                               imageUrl: widget.otherUser.profilePicture,
//                               size: AppConstants.defaultNumericValue * 2),
//                           // if (widget.otherUser.isOnline)
//                           //   Container(
//                           //     decoration: BoxDecoration(
//                           //       shape: BoxShape.circle,
//                           //       border: Border.all(
//                           //         color: AppConstants
//                           //             .primaryColor, // Set border color
//                           //         width: 2.0, // Set border width
//                           //       ),
//                           //     ),
//                           //     child: const CircleAvatar(
//                           //       backgroundColor: AppConstants.onlineStatus,
//                           //       radius: 5,
//                           //     ),
//                           //   )
//                         ],
//                       )
//                     ],
//                   ),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       CupertinoButton(
//                         padding: EdgeInsets.zero,
//                         child: WebsafeSvg.asset(
//                           phoneLogoSvg,
//                           color: AppConstants.primaryColor,
//                         ),
//                         onPressed: () {},
//                       ),
//                       CupertinoButton(
//                         padding: EdgeInsets.zero,
//                         child: WebsafeSvg.asset(
//                           videoIcon,
//                           color: AppConstants.primaryColor,
//                         ),
//                         onPressed: () {},
//                       ),
//                       if (widget.otherUser.isOnline)
//                         const CircleAvatar(
//                           backgroundColor: AppConstants.onlineStatus,
//                           radius: 4,
//                         ),
//                       const SizedBox(
//                         width: AppConstants.defaultNumericValue / 2,
//                       )
//                     ],
//                   ),
//                 ))));
//   }
// }

// class ChatTextFieldAndOthers extends StatefulWidget {
//   final TextEditingController chatController;
//   final VoidCallback onTapEmoji;
//   final VoidCallback onTapVoice;
//   final VoidCallback onTapSend;
//   final VoidCallback onChangeText;
//   final VoidCallback onTapTextField;
//   final UserProfileModel? otherUser;
//   final String? imageUrl;
//   final String? videoUrl;
//   final String? audioUrl;
//   final String? fileUrl;
//   final Function(String?) onImageSelected;
//   final Function(String?) onVideoSelected;
//   final Function(String?) onAudioSelected;
//   final Function(String?) onFileSelected;

//   const ChatTextFieldAndOthers({
//     Key? key,
//     required this.chatController,
//     required this.onTapEmoji,
//     required this.onTapVoice,
//     required this.onTapSend,
//     required this.onChangeText,
//     required this.onTapTextField,
//     required this.otherUser,
//     this.imageUrl,
//     this.videoUrl,
//     this.audioUrl,
//     this.fileUrl,
//     required this.onImageSelected,
//     required this.onVideoSelected,
//     required this.onAudioSelected,
//     required this.onFileSelected,
//   }) : super(key: key);

//   @override
//   State<ChatTextFieldAndOthers> createState() => _ChatTextFieldAndOthersState();
// }

// class _ChatTextFieldAndOthersState extends State<ChatTextFieldAndOthers> {
//   final CustomPopupMenuController _addMenuController =
//       CustomPopupMenuController();
//   bool isPurchaseDialogOpen = false;

//   void onAddDymondsTap(BuildContext context) {
//     isPurchaseDialogOpen = true;
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return const DialogCoinsPlan();
//       },
//     ).then((value) {
//       isPurchaseDialogOpen = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//         child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
//             child: Container(
//                 color:
//                     Theme.of(context).scaffoldBackgroundColor.withOpacity(0.2),
//                 width: MediaQuery.of(context).size.width,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     if (widget.imageUrl != null)
//                       Stack(
//                         children: [
//                           CachedNetworkImage(
//                             imageUrl: widget.imageUrl!,
//                             placeholder: (context, url) => const Center(
//                                 child: CircularProgressIndicator.adaptive()),
//                             errorWidget: (context, url, error) =>
//                                 const Center(child: Icon(CupertinoIcons.photo)),
//                             fit: BoxFit.cover,
//                             height: 300.0,
//                           ),
//                           Positioned(
//                             right: 0,
//                             top: 0,
//                             child: IconButton(
//                               icon: const Icon(Icons.close),
//                               color: AppConstants.primaryColor,
//                               onPressed: () {
//                                 widget.onImageSelected(null);
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                     if (widget.videoUrl != null)
//                       Stack(
//                         children: [
//                           VideoPlayerThumbNail(onTap: () {
//                             Navigator.of(context).push(MaterialPageRoute(
//                               builder: (context) => VideoPlayerPage(
//                                   isNetwork: false, videoUrl: widget.videoUrl!),
//                             ));
//                           }),
//                           Positioned(
//                             right: 0,
//                             top: 0,
//                             child: IconButton(
//                               icon: const Icon(Icons.close),
//                               color: AppConstants.primaryColor,
//                               onPressed: () {
//                                 widget.onVideoSelected(null);
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         CustomPopupMenu(
//                           menuBuilder: () => ClipRRect(
//                             borderRadius: const BorderRadius.only(
//                               topLeft: Radius.circular(
//                                   AppConstants.defaultNumericValue / 2),
//                               topRight: Radius.circular(
//                                   AppConstants.defaultNumericValue / 2),
//                               bottomRight: Radius.circular(
//                                   AppConstants.defaultNumericValue / 2),
//                               bottomLeft: Radius.circular(
//                                   AppConstants.defaultNumericValue / 2),
//                             ),
//                             child: Container(
//                               decoration: const BoxDecoration(
//                                   color: AppConstants.primaryColor),
//                               child: IntrinsicWidth(
//                                 child: Column(
//                                   crossAxisAlignment:
//                                       CrossAxisAlignment.stretch,
//                                   children: [
//                                     ChatAddMenuItem(
//                                       icon: CupertinoIcons.music_note,
//                                       title: 'Sound',
//                                       onTap: () {
//                                         _addMenuController.hideMenu();
//                                         widget.onAudioSelected(null);
//                                       },
//                                     ),
//                                     ChatAddMenuItem(
//                                       icon: CupertinoIcons.video_camera_solid,
//                                       title: LocaleKeys.video.tr(),
//                                       onTap: () {
//                                         _addMenuController.hideMenu();
//                                         pickMedia(isVideo: true).then((value) {
//                                           widget.onVideoSelected(value);
//                                         });
//                                       },
//                                     ),
//                                     ChatAddMenuItem(
//                                       icon: CupertinoIcons.paperclip,
//                                       title: 'File',
//                                       onTap: () {
//                                         _addMenuController.hideMenu();
//                                         widget.onFileSelected(null);
//                                       },
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                           pressType: PressType.singleClick,
//                           verticalMargin: -10,
//                           controller: _addMenuController,
//                           arrowColor: Colors.transparent,
//                           barrierColor:
//                               AppConstants.primaryColor.withOpacity(0.1),
//                           child: InkWell(
//                             onTap: null,
//                             child: Padding(
//                                 padding: const EdgeInsets.all(5),
//                                 child: WebsafeSvg.asset(
//                                   addIcon,
//                                   color: AppConstants.primaryColor,
//                                 )),
//                           ),
//                         ),
//                         widget.chatController.text.isEmpty &&
//                                 widget.imageUrl == null &&
//                                 widget.videoUrl == null &&
//                                 widget.audioUrl == null &&
//                                 widget.fileUrl == null
//                             ? InkWell(
//                                 onTap: () async {
//                                   pickMedia(isCamera: true).then((value) {
//                                     widget.onImageSelected(value);
//                                   });
//                                 },
//                                 child: Padding(
//                                     padding: const EdgeInsets.all(5),
//                                     child: WebsafeSvg.asset(
//                                       cameraIcon,
//                                       color: AppConstants.primaryColor,
//                                     )),
//                               )
//                             : Container(),
//                         widget.chatController.text.isEmpty &&
//                                 widget.imageUrl == null &&
//                                 widget.videoUrl == null &&
//                                 widget.audioUrl == null &&
//                                 widget.fileUrl == null
//                             ? InkWell(
//                                 onTap: () {
//                                   pickMedia(isCamera: false).then((value) {
//                                     widget.onImageSelected(value);
//                                   });
//                                 },
//                                 child: Padding(
//                                     padding: const EdgeInsets.all(5),
//                                     child: WebsafeSvg.asset(
//                                       galleryIcon,
//                                       color: AppConstants.primaryColor,
//                                     )),
//                               )
//                             : Container(),
//                         widget.chatController.text.isEmpty &&
//                                 widget.imageUrl == null &&
//                                 widget.videoUrl == null &&
//                                 widget.audioUrl == null &&
//                                 widget.fileUrl == null
//                             ? InkWell(
//                                 onTap: widget.onTapVoice,
//                                 child: Padding(
//                                     padding: const EdgeInsets.all(5),
//                                     child: WebsafeSvg.asset(
//                                       microphoneIcon,
//                                       color: AppConstants.primaryColor,
//                                     )),
//                               )
//                             : Container(),
//                         Expanded(
//                           child: Container(
//                             padding: const EdgeInsets.only(
//                                 left: AppConstants.defaultNumericValue),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(
//                                   AppConstants.defaultNumericValue * 2),
//                               color: AppConstants.chatTextFieldAndOtherText,
//                             ),
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   child: TextField(
//                                     controller: widget.chatController,
//                                     keyboardType: TextInputType.text,
//                                     minLines: null,
//                                     onTap: widget.onTapTextField,
//                                     onSubmitted: (value) {
//                                       widget.onTapSend();
//                                     },
//                                     onChanged: (_) {
//                                       widget.onChangeText();
//                                     },
//                                     decoration: InputDecoration(
//                                       hintText: LocaleKeys.typeSomething.tr(),
//                                       border: InputBorder.none,
//                                       contentPadding: EdgeInsets.zero,
//                                       isDense: true,
//                                     ),
//                                   ),
//                                 ),
//                                 //Emoji
//                                 InkWell(
//                                   onTap: widget.onTapEmoji,
//                                   child: Padding(
//                                       padding: const EdgeInsets.all(5),
//                                       child: WebsafeSvg.asset(
//                                         emojiIcon,
//                                         color: AppConstants.primaryColor,
//                                       )),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         widget.chatController.text.isEmpty &&
//                                 widget.imageUrl == null &&
//                                 widget.videoUrl == null &&
//                                 widget.audioUrl == null &&
//                                 widget.fileUrl == null
//                             ? InkWell(
//                                 onTap: () {
//                                   showModalBottomSheet(
//                                     backgroundColor: Colors.transparent,
//                                     context: context,
//                                     builder: (context) {
//                                       return GiftSheet(
//                                         onAddDymondsTap: onAddDymondsTap,
//                                         onGiftSend: (gift) {
//                                           EasyLoading.show(
//                                               status:
//                                                   LocaleKeys.sendinggift.tr());

//                                           int value = gift!.coinPrice!;

//                                           sendGiftProvider(
//                                               giftCost: value,
//                                               recipientId: widget
//                                                   .otherUser!.phoneNumber);
//                                           if (kDebugMode) {
//                                             print("${gift.coinPrice}");
//                                           }

//                                           // onCommentSend(
//                                           //     commentType: FirebaseConst.image, msg: gift.image ?? '');
//                                           Future.delayed(
//                                               const Duration(seconds: 3), () {
//                                             EasyLoading.dismiss();
//                                           });
//                                           Navigator.pop(context);
//                                         },
//                                       );
//                                     },
//                                   );
//                                 },
//                                 child: Padding(
//                                     padding: const EdgeInsets.all(5),
//                                     child: WebsafeSvg.asset(
//                                       giftFilledIcon,
//                                       color: AppConstants.primaryColor,
//                                     )),
//                               )
//                             // ? const CupertinoButton(
//                             //     padding: EdgeInsets.zero,
//                             //     onPressed: null,
//                             //     child: Icon(CupertinoIcons.paperplane_fill),
//                             //   )
//                             : InkWell(
//                                 onTap: widget.onTapSend,
//                                 child: Padding(
//                                   padding:
//                                       const EdgeInsets.symmetric(horizontal: 5),
//                                   child: ClipOval(
//                                       child: Container(
//                                     padding: const EdgeInsets.only(
//                                         top: 8, bottom: 5, left: 7, right: 8),
//                                     height: 30,
//                                     width: 30,
//                                     decoration: BoxDecoration(
//                                         gradient: AppConstants.defaultGradient),
//                                     child: WebsafeSvg.asset(
//                                       paperplaneIcon,
//                                       color: Colors.white,
//                                       height: 24,
//                                       fit: BoxFit.contain,
//                                     ),
//                                   )),
//                                 ),
//                               ),
//                       ],
//                     ),
//                   ],
//                 ))));
//   }
// }

class MoreMenuTitle extends StatelessWidget {
  final VoidCallback onTap;

  final String title;
  final String? icon;
  const MoreMenuTitle({
    Key? key,
    required this.onTap,
    required this.title,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: Row(
          children: [
            const SizedBox(
              width: AppConstants.defaultNumericValue / 2,
            ),
            WebsafeSvg.asset(
              icon ?? homeIcon,
              height: 28,
              width: 28,
              fit: BoxFit.scaleDown,
              color: AppConstants.primaryColor,
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultNumericValue,
                  vertical: AppConstants.defaultNumericValue / 2),
              child: Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(color: Colors.black87)),
            ),
          ],
        ));
  }
}

class ChatAddMenuItem extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String title;
  const ChatAddMenuItem({
    Key? key,
    required this.onTap,
    required this.icon,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultNumericValue,
            vertical: AppConstants.defaultNumericValue / 1.2),
        child: Row(
          children: [
            Icon(
              icon,
              size: Theme.of(context).textTheme.titleSmall!.fontSize,
              color: Colors.white,
            ),
            const SizedBox(width: AppConstants.defaultNumericValue),
            Expanded(
              child: Text(title,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// final _emojiPickerConfig = e.Config(
//   columns: 7,
//   emojiSizeMax: 32 *
//       (!kIsWeb
//           ? Platform.isIOS
//               ? 1.30
//               : 1.0
//           : 1.3),
//   verticalSpacing: 0,
//   horizontalSpacing: 0,
//   initCategory: e.Category.RECENT,
//   bgColor: Colors.black.withOpacity(0.05),
//   indicatorColor: AppConstants.primaryColor,
//   iconColor: Colors.grey,
//   iconColorSelected: AppConstants.primaryColor,
//   backspaceColor: AppConstants.primaryColor,
//   skinToneDialogBgColor: Colors.white,
//   skinToneIndicatorColor: Colors.grey,
//   enableSkinTones: true,
//   // showRecentsTab: true,
//   recentsLimit: 40,
//   categoryIcons: const e.CategoryIcons(),
//   buttonMode: e.ButtonMode.CUPERTINO,
// );

// class MessageSingleTile extends ConsumerWidget {
//   final ChatItemModel chat;
//   final String matchId;
//   final bool isSearching;
//   const MessageSingleTile({
//     Key? key,
//     required this.chat,
//     required this.matchId,
//     required this.isSearching,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final bool? isNotMe = chat.phoneNumber == null
//         ? null
//         : chat.phoneNumber != ref.watch(currentUserStateProvider)?.phoneNumber;

//     if (isNotMe == null) {
//       return Padding(
//         padding: const EdgeInsets.all(5.0),
//         child: Center(
//             child: Container(
//           padding: const EdgeInsets.symmetric(
//             horizontal: AppConstants.defaultNumericValue,
//             vertical: AppConstants.defaultNumericValue / 2,
//           ),
//           decoration: BoxDecoration(
//             color: Colors.black.withOpacity(0.2),
//             borderRadius: BorderRadius.circular(
//               AppConstants.defaultNumericValue,
//             ),
//           ),
//           child: Text(decryptText(chat.message ?? "")),
//         )),
//       );
//     } else {
//       if (!chat.isRead) {
//         if (isNotMe) {
//           ref
//               .read(chatProvider)
//               .updateChatItem(matchId, chat.copyWith(isRead: true));
//         }
//       }
//       return Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           Align(
//             alignment: isNotMe ? Alignment.centerLeft : Alignment.centerRight,
//             child: Container(
//               margin:
//                   const EdgeInsets.all(AppConstants.defaultNumericValue / 4),
//               constraints: BoxConstraints(
//                 maxWidth: MediaQuery.of(context).size.width * 0.8,
//               ),
//               decoration: BoxDecoration(
//                 color: isNotMe ? Colors.black12 : AppConstants.primaryColor,
//                 borderRadius: BorderRadius.only(
//                   topLeft:
//                       const Radius.circular(AppConstants.defaultNumericValue),
//                   topRight:
//                       const Radius.circular(AppConstants.defaultNumericValue),
//                   bottomLeft: isNotMe
//                       ? const Radius.circular(AppConstants.defaultNumericValue)
//                       : const Radius.circular(AppConstants.defaultNumericValue),
//                   bottomRight: isNotMe
//                       ? const Radius.circular(AppConstants.defaultNumericValue)
//                       : const Radius.circular(AppConstants.defaultNumericValue),
//                 ),
//               ),
//               child: Padding(
//                 padding:
//                     const EdgeInsets.all(AppConstants.defaultNumericValue / 2),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: isNotMe
//                       ? CrossAxisAlignment.start
//                       : CrossAxisAlignment.end,
//                   children: [
//                     if (chat.image != null)
//                       SizedBox(
//                         height: MediaQuery.of(context).size.height * 0.3,
//                         child: GestureDetector(
//                           onTap: () {
//                             Navigator.of(context).push(MaterialPageRoute(
//                               builder: (context) => PhotoViewPage(
//                                 images: [chat.image!],
//                                 title: chat.message,
//                               ),
//                             ));
//                           },
//                           child: CachedNetworkImage(
//                             imageUrl: chat.image!,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ),
//                     if (chat.image != null && chat.message != null)
//                       const SizedBox(height: 8),
//                     if (chat.video != null)
//                       VideoPlayerThumbNail(onTap: () {
//                         Navigator.of(context).push(MaterialPageRoute(
//                           builder: (context) => VideoPlayerPage(
//                               isNetwork: true, videoUrl: chat.video!),
//                         ));
//                       }),
//                     if (chat.video != null && chat.message != null)
//                       const SizedBox(height: 8),
//                     if (chat.audio != null)
//                       v.VoiceMessage(
//                         audioSrc: chat.audio!,
//                         me: !isNotMe,
//                         contactBgColor: Colors.white,
//                         meBgColor: AppConstants.primaryColor,
//                         contactFgColor: AppConstants.primaryColor,
//                         contactPlayIconColor: Colors.white,
//                         mePlayIconColor: AppConstants.primaryColor,
//                       ),
//                     if (chat.audio != null && chat.message != null)
//                       const SizedBox(height: 8),
//                     if (chat.message != null)
//                       Text(
//                         decryptText(chat.message!),
//                         style: TextStyle(
//                           fontSize: 16,
//                           backgroundColor: isSearching ? Colors.white : null,
//                           color: isSearching ? Colors.black : Colors.white,
//                         ),
//                       ),
//                     const SizedBox(height: 8),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           DateFormatter.toWholeDateTime(chat.createdAt),
//                           style: Theme.of(context)
//                               .textTheme
//                               .bodySmall!
//                               .copyWith(color: Colors.white54, fontSize: 10),
//                         ),
//                         if (!isNotMe) const SizedBox(width: 8),
//                         if (!isNotMe)
//                           Icon(
//                             chat.isRead ? Icons.done_all : Icons.done,
//                             size: 12,
//                             color: chat.isRead
//                                 ? AppConstants.secondaryColor
//                                 : Colors.white54,
//                           ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           isNotMe
//               ? const SizedBox(height: AppConstants.defaultNumericValue / 8)
//               : const SizedBox()
//         ],
//       );
//     }
//   }
// }

// class VoiceRecorder extends ConsumerWidget {
//   final String matchId;
//   const VoiceRecorder({Key? key, required this.matchId}) : super(key: key);

//   @override
//   Widget build(BuildContext context, ref) {
//     return Container(
//       margin: const EdgeInsets.all(AppConstants.defaultNumericValue),
//       // height: MediaQuery.of(context).size.height * 0.2,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(AppConstants.defaultNumericValue),
//       ),
//       padding: const EdgeInsets.all(AppConstants.defaultNumericValue),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           ListTile(
//             contentPadding: EdgeInsets.zero,
//             title: Text(LocaleKeys.record.tr()),
//             trailing: IconButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 icon: const Icon(Icons.close)),
//             subtitle: Text(LocaleKeys.pressandholdthebuttontorecord.tr()),
//           ),
//           const Divider(height: 0),
//           const SizedBox(height: AppConstants.defaultNumericValue),
//           Align(
//             alignment: Alignment.centerRight,
//             child: SocialMediaRecorder(
//               recordIconWhenLockBackGroundColor: AppConstants.primaryColor,
//               recordIconBackGroundColor: AppConstants.primaryColor,
//               recordIcon: const Icon(
//                 CupertinoIcons.mic_circle_fill,
//                 color: Colors.white,
//                 size: 30,
//               ),
//               backGroundColor: AppConstants.primaryColor,
//               radius: BorderRadius.circular(8),
//               sendRequestFunction: (soundFile, _time) async {
//                 final chatData = ref.read(chatProvider);
//                 final currentTime = DateTime.now();

//                 EasyLoading.show(status: LocaleKeys.sending.tr());

//                 await chatData
//                     .uploadFile(file: soundFile, matchId: matchId)
//                     .then((audioUrl) {
//                   EasyLoading.dismiss();

//                   if (audioUrl == null) {
//                     EasyLoading.showError(LocaleKeys.failedsending.tr());
//                   } else {
//                     ChatItemModel chatItem = ChatItemModel(
//                       createdAt: currentTime,
//                       id: currentTime.millisecondsSinceEpoch.toString(),
//                       phoneNumber:
//                           ref.watch(currentUserStateProvider)!.phoneNumber,
//                       matchId: matchId,
//                       isRead: false,
//                       audio: audioUrl,
//                     );

//                     chatData.createChatItem(matchId, chatItem);
//                   }
//                   Navigator.of(context).pop();
//                 });
//               },
//               encode: AudioEncoderType.AAC_LD,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
