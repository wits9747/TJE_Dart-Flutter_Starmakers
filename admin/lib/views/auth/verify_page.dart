import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:restart_app/restart_app.dart';

import 'package:lamatadmin/helpers/config.dart';
import 'package:lamatadmin/models/verify_model.dart';
import 'package:lamatadmin/providers/verify_provider.dart';

class VerifyPage extends ConsumerStatefulWidget {
  const VerifyPage({Key? key}) : super(key: key);

  @override
  VerifyPageState createState() => VerifyPageState();
}

class VerifyPageState extends ConsumerState<VerifyPage> {
  @override
  Widget build(BuildContext context) {
    final licenseType = ref.watch(licenseProvider);
    final licenseKeyController = TextEditingController();
    // String? licenseKey;
    LicenseType? licensetype;

    Future<void> setLicense(String key) async {
      EasyLoading.show();

      debugPrint(
          "Setting License!!!!!!!!!!!!!!!!!!!!!!!!!!!! \nLicenseKey: $licenseKey");

      setState(() {});
      final VerifyModel verifyModel = VerifyModel(
        id: 1,
        status: licensetype == LicenseType.extended
            ? 2
            : licensetype == LicenseType.regular
                ? 1
                : 0,
        purcahseCode: licenseKey,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      await addLicense(license: verifyModel).then((value) {
        if (value) {
          EasyLoading.showSuccess("License Added Successfully");
          Restart.restartApp();
        } else {
          EasyLoading.showError("Failed to add license");
        }
      });

      EasyLoading.dismiss();
    }

    Future<void> verifyLicense(String key) async {
      await ref
          .read(verifiedJsonProvider.notifier)
          .verifyLicense(key)
          .then((value) async {
        setState(() {
          licensetype = licenseType;
        });

        debugPrint(
            "Setting License!!!!!!!!!!!!!!!!!!!!!!!!!!!! \nLicenseKey: $licenseKey");
      });
    }

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Container(
            width: width,
            height: height,
            // color: AppConstants.primaryColor,
            decoration: const BoxDecoration(
                image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage(AppConstants.bgImage),
            )),
            child: Center(
                child: GlassmorphicContainer(
                    width: width * .8,
                    height: height * .85,
                    borderRadius: 20,
                    blur: 20,
                    alignment: Alignment.bottomCenter,
                    border: 2,
                    linearGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFffffff).withOpacity(0.1),
                          const Color(0xFFFFFFFF).withOpacity(0.05),
                        ],
                        stops: const [
                          0.1,
                          1,
                        ]),
                    borderGradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFffffff).withOpacity(0.5),
                        const Color((0xFFFFFFFF)).withOpacity(0.5),
                      ],
                    ), // Adjust blur strength
                    child: Container(
                      width: width * .8,
                      height: height * .85,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            AppConstants.defaultNumericValue * 2),
                        color: AppConstants.backgroundColor.withOpacity(0),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        // key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                                height: AppConstants.defaultNumericValue),

                            Image.asset(
                              'assets/logo/logo.png',
                              width: 120,
                              height: 120,
                              fit: BoxFit.fitHeight,
                            ),
                            SizedBox(height: height * 0.1),
                            Text(
                              'License Key Verification',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: licenseKeyController,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal:
                                        AppConstants.defaultNumericValue * 1.5),
                                filled: true,
                                fillColor:
                                    AppConstants.primaryColor.withOpacity(.05),
                                hintText: "Enter License Key",
                                hintStyle:
                                    const TextStyle(color: Colors.black87),
                                border: OutlineInputBorder(
                                  // Set outline border
                                  borderRadius: BorderRadius.circular(
                                      AppConstants.defaultNumericValue * 2),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter license key';
                                }
                                return null;
                              },
                            ),
                            // TextField(
                            //   controller: licenseKeyController,
                            //   decoration: const InputDecoration(
                            //     labelText: 'Enter License Key',
                            //   ),
                            // ),
                            const SizedBox(height: 20),
                            if (licenseType == LicenseType.unknown)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: AppConstants
                                      .primaryColor, // Set primary color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppConstants.defaultNumericValue * 2),
                                  ),
                                ),
                                onPressed: () async {
                                  licenseKey = licenseKeyController.text;
                                  // setState(() {});
                                  await verifyLicense(licenseKey);
                                  // setState(() {});
                                },
                                child: Text('Verify',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                              ),
                            const SizedBox(height: 20),
                            if (licenseType == LicenseType.unknown)
                              const Center(
                                  child: CircularProgressIndicator.adaptive()),
                            if (licenseType != LicenseType.unknown)
                              Center(
                                child: Text(
                                  'License Type: ${licenseType.name.toUpperCase()}',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                            const SizedBox(height: 20),
                            if (licenseType != LicenseType.unknown)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: AppConstants
                                      .primaryColor, // Set primary color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppConstants.defaultNumericValue * 2),
                                  ),
                                ),
                                onPressed: () async {
                                  debugPrint(licenseKey);
                                  await verifyLicense(licenseKey);
                                  // setState(() {});
                                  await setLicense(licenseKey);
                                  // await Restart.restartApp();
                                },
                                child: Text('Install',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                              ),
                          ],
                        ),
                      ),
                    )))));
  }
}
