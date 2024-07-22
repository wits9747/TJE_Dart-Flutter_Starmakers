import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/helpers/constants.dart';
import 'package:lamatdating/models/meeting_model.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/providers/meeting_provider.dart';
import 'package:lamatdating/providers/shared_pref_provider.dart';
import 'package:lamatdating/responsive.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/custom/custom_app_bar.dart';
import 'package:lamatdating/views/custom/custom_headline.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';
import 'package:lamatdating/views/loading_error/error_page.dart';
import 'package:lamatdating/views/loading_error/loading_page.dart';

class MeetingsPage extends ConsumerStatefulWidget {
  const MeetingsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<MeetingsPage> createState() => _MeetingsPageState();
}

class _MeetingsPageState extends ConsumerState<MeetingsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Access the list of meetings from the provider
    final meetings = ref.watch(getMeetingsProvider);
    final prefs = ref.watch(sharedPreferences).value;

    return Scaffold(
      backgroundColor: Teme.isDarktheme(prefs!)
          ? AppConstants.backgroundColorDark
          : AppConstants.backgroundColor,
      body: meetings.when(
        data: (data) {
          final meetings = data;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppConstants.defaultNumericValue),
              Padding(
                padding: EdgeInsets.only(
                  left: AppConstants.defaultNumericValue,
                  right: AppConstants.defaultNumericValue,
                  top: MediaQuery.of(context).padding.top,
                ),
                child: CustomAppBar(
                  leading: Row(children: [
                    CustomIconButton(
                        padding: const EdgeInsets.all(
                            AppConstants.defaultNumericValue / 1.8),
                        onPressed: () {
                          (!Responsive.isDesktop(context))
                              ? Navigator.pop(context)
                              : ref.invalidate(arrangementProviderExtend);
                        },
                        color: AppConstants.primaryColor,
                        icon: leftArrowSvg),
                  ]),
                  title: Center(
                      child: CustomHeadLine(
                    text: LocaleKeys.meetups.tr(),
                  )),
                  trailing: CustomIconButton(
                    icon: ellipsisIcon,
                    onPressed: () {},
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: meetings.length,
                itemBuilder: (context, index) {
                  final meeting = meetings[index];
                  return MeetingItem(meeting: meeting);
                },
              ),
            ],
          );
        },
        error: (_, __) => const ErrorPage(),
        loading: () => const LoadingPage(),
      ),
    );
  }
}

class MeetingItem extends StatelessWidget {
  final MeetingModel meeting;

  const MeetingItem({Key? key, required this.meeting}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      width: width,
      height: height * .1,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: ListTile(
        title: Text(meeting.meetingVenue),
        subtitle: Text(
          '${meeting.meetingDate.toString()} - ${meeting.meetingStartTime} - ${meeting.meetingEndTime}',
        ),
        // Add more details as needed, e.g., venue, status, etc.
      ),
    );
  }
}
