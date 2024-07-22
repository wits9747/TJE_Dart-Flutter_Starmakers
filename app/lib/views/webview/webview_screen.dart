// import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/helpers/constants.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatelessWidget {
  final int type;

  const WebViewScreen(this.type, {super.key});

  @override
  Widget build(BuildContext context) {
    // if (Platform.isAndroid) WebViewWidget. = SurfaceAndroidWebView();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 55,
              child: Stack(
                children: [
                  Padding(
                      padding: const EdgeInsets.all(10),
                      child: InkWell(
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        overlayColor:
                            WidgetStateProperty.all(Colors.transparent),
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppConstants.secondaryColor,
                                AppConstants.primaryColor,
                              ],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      )),
                  Center(
                    child: Text(
                      getTitle(),
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 0.3,
              color: AppConstants.textColorLight,
            ),
            Expanded(
              child: WebViewWidget(
                  controller: WebViewController()
                    ..setJavaScriptMode(JavaScriptMode.unrestricted)
                    ..setBackgroundColor(const Color(0x00000000))
                    ..setNavigationDelegate(
                      NavigationDelegate(
                        onProgress: (int progress) {
                          // Update loading bar.
                        },
                        onPageStarted: (String url) {},
                        onPageFinished: (String url) {},
                        onWebResourceError: (WebResourceError error) {},
                      ),
                    )
                    ..loadRequest(Uri.parse(getWebUrl()))),
            ),
          ],
        ),
      ),
    );
  }

  String getTitle() {
    String title = '';
    if (type == 1) {
      title = LocaleKeys.help.tr();
    } else if (type == 2) {
      title = LocaleKeys.termsOfUse.tr();
    } else if (type == 3) {
      title = LocaleKeys.privacyPolicy.tr();
    }
    return title;
  }

  String getWebUrl() {
    String title = '';
    if (type == 1) {
      title = ConstRes.helpUrl;
    } else if (type == 2) {
      title = ConstRes.termOfUse;
    } else if (type == 3) {
      title = ConstRes.privacy;
    }
    return title;
  }
}
