// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/helpers/constants.dart';
import 'package:lamatdating/helpers/admob.dart';
import 'package:lamatdating/providers/observer.dart';

import 'package:lamatdating/views/calling/pickup_layout.dart';
import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditGroupDetails extends ConsumerStatefulWidget {
  final String? groupName;
  final String? groupDesc;
  final String? groupType;
  final String? groupID;
  final String currentUserNo;
  final bool isadmin;
  final SharedPreferences prefs;
  const EditGroupDetails(
      {super.key,
      this.groupName,
      this.groupDesc,
      required this.isadmin,
      required this.prefs,
      this.groupID,
      this.groupType,
      required this.currentUserNo});
  @override
  ConsumerState createState() => EditGroupDetailsState();
}

class EditGroupDetailsState extends ConsumerState<EditGroupDetails> {
  TextEditingController? controllerName = TextEditingController();
  TextEditingController? controllerDesc = TextEditingController();

  bool isLoading = false;

  final FocusNode focusNodeName = FocusNode();
  final FocusNode focusNodeDesc = FocusNode();

  String? groupTitle;
  String? groupDesc;
  String? groupType;
  BannerAd? myBanner;
  AdWidget? adWidget;
  @override
  void initState() {
    if (!kIsWeb) {
      myBanner = BannerAd(
        adUnitId: getBannerAdUnitId()!,
        size: AdSize.mediumRectangle,
        request: const AdRequest(),
        listener: const BannerAdListener(),
      );
    }
    super.initState();
    Lamat.internetLookUp();
    groupDesc = widget.groupDesc;
    groupTitle = widget.groupName;
    groupType = widget.groupType;
    controllerName!.text = groupTitle!;
    controllerDesc!.text = groupDesc!;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final observer = ref.watch(observerProvider);
      if (IsBannerAdShow == true && observer.isadmobshow == true && !kIsWeb) {
        myBanner!.load();
        adWidget = AdWidget(ad: myBanner!);
        setState(() {});
      }
    });
  }

  void handleUpdateData() {
    focusNodeName.unfocus();
    focusNodeDesc.unfocus();

    setState(() {
      isLoading = true;
    });
    groupTitle =
        controllerName!.text.isEmpty ? groupTitle : controllerName!.text;
    groupDesc = controllerDesc!.text.isEmpty ? groupDesc : controllerDesc!.text;
    setState(() {});
    FirebaseFirestore.instance
        .collection(DbPaths.collectiongroups)
        .doc(widget.groupID)
        .update({
      Dbkeys.groupNAME: groupTitle,
      Dbkeys.groupDESCRIPTION: groupDesc,
      Dbkeys.groupTYPE: groupType,
    }).then((value) async {
      DateTime time = DateTime.now();
      await FirebaseFirestore.instance
          .collection(DbPaths.collectiongroups)
          .doc(widget.groupID)
          .collection(DbPaths.collectiongroupChats)
          .doc('${time.millisecondsSinceEpoch}--${widget.currentUserNo}')
          .set({
        Dbkeys.groupmsgCONTENT: widget.isadmin
            ? LocaleKeys.grpdetailsupdatebyadmin.tr()
            : '${widget.currentUserNo} ${LocaleKeys.hasupdatedgrpdetails.tr()}',
        Dbkeys.groupmsgLISToptional: [],
        Dbkeys.groupmsgTIME: time.millisecondsSinceEpoch,
        Dbkeys.groupmsgSENDBY: widget.currentUserNo,
        Dbkeys.groupmsgISDELETED: false,
        Dbkeys.groupmsgTYPE: Dbkeys.groupmsgTYPEnotificationUpdatedGroupDetails,
      });
      Navigator.of(context).pop();
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });

      Lamat.toast(err.toString());
    });
  }

  void _handleTypeChange(String value) {
    setState(() {
      groupType = value;
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (IsBannerAdShow == true && !kIsWeb) {
      myBanner!.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final observer = ref.watch(observerProvider);
    return PickupLayout(
        prefs: widget.prefs,
        scaffold: Lamat.getNTPWrappedWidget(Scaffold(
            backgroundColor: Teme.isDarktheme(widget.prefs)
                ? lamatCONTAINERboxColorDarkMode
                : lamatCONTAINERboxColorLightMode,
            appBar: AppBar(
              elevation: 0.4,
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.arrow_back,
                  size: 24,
                  color: pickTextColorBasedOnBgColorAdvanced(
                      Teme.isDarktheme(widget.prefs)
                          ? lamatAPPBARcolorDarkMode
                          : lamatAPPBARcolorLightMode),
                ),
              ),
              titleSpacing: 0,
              backgroundColor: Teme.isDarktheme(widget.prefs)
                  ? lamatAPPBARcolorDarkMode
                  : lamatAPPBARcolorLightMode,
              title: Text(
                LocaleKeys.editgroup.tr(),
                style: TextStyle(
                  fontSize: 20.0,
                  color: pickTextColorBasedOnBgColorAdvanced(
                      Teme.isDarktheme(widget.prefs)
                          ? lamatAPPBARcolorDarkMode
                          : lamatAPPBARcolorLightMode),
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: handleUpdateData,
                  child: Text(
                    LocaleKeys.save.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      color: Teme.isDarktheme(widget.prefs)
                          ? lamatPRIMARYcolor
                          : pickTextColorBasedOnBgColorAdvanced(
                              lamatAPPBARcolorLightMode),
                    ),
                  ),
                )
              ],
            ),
            body: Stack(
              children: <Widget>[
                SingleChildScrollView(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(
                        height: 25,
                      ),
                      ListTile(
                          title: TextFormField(
                        style: TextStyle(
                          color: pickTextColorBasedOnBgColorAdvanced(
                              Teme.isDarktheme(widget.prefs)
                                  ? lamatCONTAINERboxColorDarkMode
                                  : lamatCONTAINERboxColorLightMode),
                        ),
                        autovalidateMode: AutovalidateMode.always,
                        controller: controllerName,
                        validator: (v) {
                          return v!.isEmpty ? "Enter valid details" : null;
                        },
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(6),
                          labelStyle: const TextStyle(
                            height: 0.8,
                            color: lamatPRIMARYcolor,
                          ),
                          labelText: LocaleKeys.groupname.tr(),
                        ),
                      )),
                      const SizedBox(
                        height: 30,
                      ),
                      ListTile(
                          title: TextFormField(
                        minLines: 1,
                        maxLines: 10,
                        style: TextStyle(
                          color: pickTextColorBasedOnBgColorAdvanced(
                              Teme.isDarktheme(widget.prefs)
                                  ? lamatCONTAINERboxColorDarkMode
                                  : lamatCONTAINERboxColorLightMode),
                        ),
                        controller: controllerDesc,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(6),
                          labelStyle: const TextStyle(
                              height: 0.8, color: lamatPRIMARYcolor),
                          labelText: LocaleKeys.groupdesc.tr(),
                        ),
                      )),
                      const SizedBox(
                        height: 15,
                      ),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(5, 20, 12, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 20, 12, 10),
                                child: Text(
                                  LocaleKeys.grouptype.tr(),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: pickTextColorBasedOnBgColorAdvanced(
                                          Teme.isDarktheme(widget.prefs)
                                              ? lamatCONTAINERboxColorDarkMode
                                              : lamatCONTAINERboxColorLightMode),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16),
                                ),
                              ),
                              Row(
                                children: [
                                  Radio<String>(
                                    value: 'userAdmin',
                                    groupValue: groupType,
                                    onChanged: (v) {
                                      _handleTypeChange(v!);
                                    },
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 1.5,
                                    child: Text(
                                      LocaleKeys.bothuseradmin.tr(),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 7,
                              ),
                              Row(
                                children: [
                                  Radio<String>(
                                    value: 'onlyAdmin',
                                    groupValue: groupType,
                                    onChanged: (v) {
                                      _handleTypeChange(v!);
                                    },
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 1.5,
                                    child: const Text(
                                      "Only Admin Messages Allowed",
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )),
                      IsBannerAdShow == true &&
                              observer.isadmobshow == true &&
                              adWidget != null &&
                              !kIsWeb
                          ? Container(
                              height: MediaQuery.of(context).size.width - 30,
                              width: MediaQuery.of(context).size.width,
                              margin: const EdgeInsets.only(
                                bottom: 5.0,
                                top: 2,
                              ),
                              child: adWidget!)
                          : const SizedBox(
                              height: 0,
                            ),
                    ],
                  ),
                ),
                // Loading
                Positioned(
                  child: isLoading
                      ? Container(
                          color: pickTextColorBasedOnBgColorAdvanced(
                                  !Teme.isDarktheme(widget.prefs)
                                      ? lamatCONTAINERboxColorDarkMode
                                      : lamatCONTAINERboxColorLightMode)
                              .withOpacity(0.6),
                          child: const Center(
                            child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    lamatSECONDARYolor)),
                          ))
                      : Container(),
                ),
              ],
            ))));
  }
}
