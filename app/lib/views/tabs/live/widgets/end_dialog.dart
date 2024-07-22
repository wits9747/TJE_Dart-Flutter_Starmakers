import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';

import 'package:lamatdating/helpers/constants.dart';
import 'package:lamatdating/providers/shared_pref_provider.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/custom/custom_button.dart';

class EndDialog extends ConsumerWidget {
  final VoidCallback onYesBtnClick;

  const EndDialog({Key? key, required this.onYesBtnClick}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final prefs = ref.watch(sharedPreferences).value;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 70),
      backgroundColor: Teme.isDarktheme(prefs!)
          ? AppConstants.backgroundColorDark
          : AppConstants.backgroundColor,
      shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.defaultNumericValue)),
      child: AspectRatio(
        aspectRatio: 1 / 0.7,
        child: Container(
          padding: const EdgeInsets.all(AppConstants.defaultNumericValue),
          child: Column(
            children: [
              Text(
                LocaleKeys.areYouSure.tr(),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                LocaleKeys.endlivevideo.tr(),
                style: const TextStyle(fontWeight: FontWeight.normal),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                      child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Center(child: Text(LocaleKeys.cancel.tr())))),
                  Expanded(
                      child: CustomButton(
                    onPressed: onYesBtnClick,
                    text: LocaleKeys.yes.tr(),
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
