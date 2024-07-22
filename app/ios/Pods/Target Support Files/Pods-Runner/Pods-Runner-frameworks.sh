#!/bin/sh
set -e
set -u
set -o pipefail

function on_error {
  echo "$(realpath -mq "${0}"):$1: error: Unexpected failure"
}
trap 'on_error $LINENO' ERR

if [ -z ${FRAMEWORKS_FOLDER_PATH+x} ]; then
  # If FRAMEWORKS_FOLDER_PATH is not set, then there's nowhere for us to copy
  # frameworks to, so exit 0 (signalling the script phase was successful).
  exit 0
fi

echo "mkdir -p ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
mkdir -p "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"

COCOAPODS_PARALLEL_CODE_SIGN="${COCOAPODS_PARALLEL_CODE_SIGN:-false}"
SWIFT_STDLIB_PATH="${TOOLCHAIN_DIR}/usr/lib/swift/${PLATFORM_NAME}"
BCSYMBOLMAP_DIR="BCSymbolMaps"


# This protects against multiple targets copying the same framework dependency at the same time. The solution
# was originally proposed here: https://lists.samba.org/archive/rsync/2008-February/020158.html
RSYNC_PROTECT_TMP_FILES=(--filter "P .*.??????")

# Copies and strips a vendored framework
install_framework()
{
  if [ -r "${BUILT_PRODUCTS_DIR}/$1" ]; then
    local source="${BUILT_PRODUCTS_DIR}/$1"
  elif [ -r "${BUILT_PRODUCTS_DIR}/$(basename "$1")" ]; then
    local source="${BUILT_PRODUCTS_DIR}/$(basename "$1")"
  elif [ -r "$1" ]; then
    local source="$1"
  fi

  local destination="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"

  if [ -L "${source}" ]; then
    echo "Symlinked..."
    source="$(readlink -f "${source}")"
  fi

  if [ -d "${source}/${BCSYMBOLMAP_DIR}" ]; then
    # Locate and install any .bcsymbolmaps if present, and remove them from the .framework before the framework is copied
    find "${source}/${BCSYMBOLMAP_DIR}" -name "*.bcsymbolmap"|while read f; do
      echo "Installing $f"
      install_bcsymbolmap "$f" "$destination"
      rm "$f"
    done
    rmdir "${source}/${BCSYMBOLMAP_DIR}"
  fi

  # Use filter instead of exclude so missing patterns don't throw errors.
  echo "rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --links --filter \"- CVS/\" --filter \"- .svn/\" --filter \"- .git/\" --filter \"- .hg/\" --filter \"- Headers\" --filter \"- PrivateHeaders\" --filter \"- Modules\" \"${source}\" \"${destination}\""
  rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --links --filter "- CVS/" --filter "- .svn/" --filter "- .git/" --filter "- .hg/" --filter "- Headers" --filter "- PrivateHeaders" --filter "- Modules" "${source}" "${destination}"

  local basename
  basename="$(basename -s .framework "$1")"
  binary="${destination}/${basename}.framework/${basename}"

  if ! [ -r "$binary" ]; then
    binary="${destination}/${basename}"
  elif [ -L "${binary}" ]; then
    echo "Destination binary is symlinked..."
    dirname="$(dirname "${binary}")"
    binary="${dirname}/$(readlink "${binary}")"
  fi

  # Strip invalid architectures so "fat" simulator / device frameworks work on device
  if [[ "$(file "$binary")" == *"dynamically linked shared library"* ]]; then
    strip_invalid_archs "$binary"
  fi

  # Resign the code if required by the build settings to avoid unstable apps
  code_sign_if_enabled "${destination}/$(basename "$1")"

  # Embed linked Swift runtime libraries. No longer necessary as of Xcode 7.
  if [ "${XCODE_VERSION_MAJOR}" -lt 7 ]; then
    local swift_runtime_libs
    swift_runtime_libs=$(xcrun otool -LX "$binary" | grep --color=never @rpath/libswift | sed -E s/@rpath\\/\(.+dylib\).*/\\1/g | uniq -u)
    for lib in $swift_runtime_libs; do
      echo "rsync -auv \"${SWIFT_STDLIB_PATH}/${lib}\" \"${destination}\""
      rsync -auv "${SWIFT_STDLIB_PATH}/${lib}" "${destination}"
      code_sign_if_enabled "${destination}/${lib}"
    done
  fi
}
# Copies and strips a vendored dSYM
install_dsym() {
  local source="$1"
  warn_missing_arch=${2:-true}
  if [ -r "$source" ]; then
    # Copy the dSYM into the targets temp dir.
    echo "rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --filter \"- CVS/\" --filter \"- .svn/\" --filter \"- .git/\" --filter \"- .hg/\" --filter \"- Headers\" --filter \"- PrivateHeaders\" --filter \"- Modules\" \"${source}\" \"${DERIVED_FILES_DIR}\""
    rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --filter "- CVS/" --filter "- .svn/" --filter "- .git/" --filter "- .hg/" --filter "- Headers" --filter "- PrivateHeaders" --filter "- Modules" "${source}" "${DERIVED_FILES_DIR}"

    local basename
    basename="$(basename -s .dSYM "$source")"
    binary_name="$(ls "$source/Contents/Resources/DWARF")"
    binary="${DERIVED_FILES_DIR}/${basename}.dSYM/Contents/Resources/DWARF/${binary_name}"

    # Strip invalid architectures from the dSYM.
    if [[ "$(file "$binary")" == *"Mach-O "*"dSYM companion"* ]]; then
      strip_invalid_archs "$binary" "$warn_missing_arch"
    fi
    if [[ $STRIP_BINARY_RETVAL == 0 ]]; then
      # Move the stripped file into its final destination.
      echo "rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --links --filter \"- CVS/\" --filter \"- .svn/\" --filter \"- .git/\" --filter \"- .hg/\" --filter \"- Headers\" --filter \"- PrivateHeaders\" --filter \"- Modules\" \"${DERIVED_FILES_DIR}/${basename}.framework.dSYM\" \"${DWARF_DSYM_FOLDER_PATH}\""
      rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --links --filter "- CVS/" --filter "- .svn/" --filter "- .git/" --filter "- .hg/" --filter "- Headers" --filter "- PrivateHeaders" --filter "- Modules" "${DERIVED_FILES_DIR}/${basename}.dSYM" "${DWARF_DSYM_FOLDER_PATH}"
    else
      # The dSYM was not stripped at all, in this case touch a fake folder so the input/output paths from Xcode do not reexecute this script because the file is missing.
      mkdir -p "${DWARF_DSYM_FOLDER_PATH}"
      touch "${DWARF_DSYM_FOLDER_PATH}/${basename}.dSYM"
    fi
  fi
}

# Used as a return value for each invocation of `strip_invalid_archs` function.
STRIP_BINARY_RETVAL=0

# Strip invalid architectures
strip_invalid_archs() {
  binary="$1"
  warn_missing_arch=${2:-true}
  # Get architectures for current target binary
  binary_archs="$(lipo -info "$binary" | rev | cut -d ':' -f1 | awk '{$1=$1;print}' | rev)"
  # Intersect them with the architectures we are building for
  intersected_archs="$(echo ${ARCHS[@]} ${binary_archs[@]} | tr ' ' '\n' | sort | uniq -d)"
  # If there are no archs supported by this binary then warn the user
  if [[ -z "$intersected_archs" ]]; then
    if [[ "$warn_missing_arch" == "true" ]]; then
      echo "warning: [CP] Vendored binary '$binary' contains architectures ($binary_archs) none of which match the current build architectures ($ARCHS)."
    fi
    STRIP_BINARY_RETVAL=1
    return
  fi
  stripped=""
  for arch in $binary_archs; do
    if ! [[ "${ARCHS}" == *"$arch"* ]]; then
      # Strip non-valid architectures in-place
      lipo -remove "$arch" -output "$binary" "$binary"
      stripped="$stripped $arch"
    fi
  done
  if [[ "$stripped" ]]; then
    echo "Stripped $binary of architectures:$stripped"
  fi
  STRIP_BINARY_RETVAL=0
}

# Copies the bcsymbolmap files of a vendored framework
install_bcsymbolmap() {
    local bcsymbolmap_path="$1"
    local destination="${BUILT_PRODUCTS_DIR}"
    echo "rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --filter "- CVS/" --filter "- .svn/" --filter "- .git/" --filter "- .hg/" --filter "- Headers" --filter "- PrivateHeaders" --filter "- Modules" "${bcsymbolmap_path}" "${destination}""
    rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --filter "- CVS/" --filter "- .svn/" --filter "- .git/" --filter "- .hg/" --filter "- Headers" --filter "- PrivateHeaders" --filter "- Modules" "${bcsymbolmap_path}" "${destination}"
}

# Signs a framework with the provided identity
code_sign_if_enabled() {
  if [ -n "${EXPANDED_CODE_SIGN_IDENTITY:-}" -a "${CODE_SIGNING_REQUIRED:-}" != "NO" -a "${CODE_SIGNING_ALLOWED}" != "NO" ]; then
    # Use the current code_sign_identity
    echo "Code Signing $1 with Identity ${EXPANDED_CODE_SIGN_IDENTITY_NAME}"
    local code_sign_cmd="/usr/bin/codesign --force --sign ${EXPANDED_CODE_SIGN_IDENTITY} ${OTHER_CODE_SIGN_FLAGS:-} --preserve-metadata=identifier,entitlements '$1'"

    if [ "${COCOAPODS_PARALLEL_CODE_SIGN}" == "true" ]; then
      code_sign_cmd="$code_sign_cmd &"
    fi
    echo "$code_sign_cmd"
    eval "$code_sign_cmd"
  fi
}

if [[ "$CONFIGURATION" == "Debug" ]]; then
  install_framework "${BUILT_PRODUCTS_DIR}/AppAuth/AppAuth.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/AppCheckCore/AppCheckCore.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/BoringSSL-GRPC/openssl_grpc.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/BranchSDK/BranchSDK.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/DKImagePickerController/DKImagePickerController.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/DKPhotoGallery/DKPhotoGallery.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseAppCheck/FirebaseAppCheck.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseAppCheckInterop/FirebaseAppCheckInterop.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseAuth/FirebaseAuth.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseAuthInterop/FirebaseAuthInterop.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseCore/FirebaseCore.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseCoreExtension/FirebaseCoreExtension.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseCoreInternal/FirebaseCoreInternal.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseFirestore/FirebaseFirestore.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseFirestoreInternal/FirebaseFirestoreInternal.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseFunctions/FirebaseFunctions.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseInstallations/FirebaseInstallations.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseMessaging/FirebaseMessaging.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseMessagingInterop/FirebaseMessagingInterop.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseSharedSwift/FirebaseSharedSwift.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseStorage/FirebaseStorage.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GTMAppAuth/GTMAppAuth.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GTMSessionFetcher/GTMSessionFetcher.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GoogleDataTransport/GoogleDataTransport.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GoogleSignIn/GoogleSignIn.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GoogleUtilities/GoogleUtilities.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/MTBBarcodeScanner/MTBBarcodeScanner.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Mantle/Mantle.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/PromisesObjC/FBLPromises.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/PurchasesHybridCommon/PurchasesHybridCommon.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/RecaptchaInterop/RecaptchaInterop.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/RevenueCat/RevenueCat.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SDWebImage/SDWebImage.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SDWebImageWebPCoder/SDWebImageWebPCoder.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Stripe/Stripe.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/StripeApplePay/StripeApplePay.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/StripeCore/StripeCore.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/StripeFinancialConnections/StripeFinancialConnections.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/StripePaymentSheet/StripePaymentSheet.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/StripePayments/StripePayments.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/StripePaymentsUI/StripePaymentsUI.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/StripeUICore/StripeUICore.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SwiftyGif/SwiftyGif.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Toast/Toast.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/abseil/absl.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/agora_rtc_engine/agora_rtc_engine.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/audio_session/audio_session.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/audioplayers_darwin/audioplayers_darwin.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/better_open_file/better_open_file.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/camera_avfoundation/camera_avfoundation.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/contacts_service/contacts_service.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/device_info_plus/device_info_plus.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/devicelocale/devicelocale.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/emoji_picker_flutter/emoji_picker_flutter.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/file_picker/file_picker.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/file_saver/file_saver.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/flutter_branch_sdk/flutter_branch_sdk.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/flutter_downloader/flutter_downloader.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/flutter_image_compress_common/flutter_image_compress_common.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/flutter_local_notifications/flutter_local_notifications.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/flutter_native_splash/flutter_native_splash.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/flutter_paystack/flutter_paystack.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/flutter_pdfview/flutter_pdfview.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/flutter_secure_storage/flutter_secure_storage.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/flutter_sound_core/flutter_sound_core.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/flutter_video_info/flutter_video_info.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/fluttertoast/fluttertoast.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/gRPC-C++/grpcpp.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/gRPC-Core/grpc.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/gallery_saver/gallery_saver.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/geolocator_apple/geolocator_apple.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/image_editor_common/image_editor_common.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/image_picker_ios/image_picker_ios.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/in_app_purchase_storekit/in_app_purchase_storekit.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/iris_method_channel/iris_method_channel.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/just_audio/just_audio.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/leveldb-library/leveldb.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/libwebp/libwebp.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/local_auth_darwin/local_auth_darwin.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/location/location.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/media_info/media_info.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/nanopb/nanopb.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/package_info_plus/package_info_plus.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/path_provider_foundation/path_provider_foundation.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/photo_manager/photo_manager.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/purchases_flutter/purchases_flutter.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/qr_code_scanner/qr_code_scanner.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/receive_sharing_intent/receive_sharing_intent.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/record/record.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/restart_app/restart_app.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/share/share.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/share_plus/share_plus.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/shared_preferences_foundation/shared_preferences_foundation.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/sms_autofill/sms_autofill.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/sqflite/sqflite.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/stripe_ios/stripe_ios.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/the_apple_sign_in/the_apple_sign_in.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/url_launcher_ios/url_launcher_ios.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/video_compress/video_compress.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/video_player_avfoundation/video_player_avfoundation.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/video_thumbnail/video_thumbnail.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/wakelock/wakelock.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/webview_flutter_wkwebview/webview_flutter_wkwebview.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraIrisRTC_iOS/AgoraRtcWrapper.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/AIAEC/AgoraAiEchoCancellationExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/AINS/AgoraAiNoiseSuppressionExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/AudioBeauty/AgoraAudioBeautyExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/ClearVision/AgoraClearVisionExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/ContentInspect/AgoraContentInspectExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/FaceCapture/AgoraFaceCaptureExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/FaceDetection/AgoraFaceDetectionExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/LipSync/AgoraLipSyncExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/ReplayKit/AgoraReplayKitExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/RtcBasic/AgoraRtcKit.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/RtcBasic/aosl.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/RtcBasic/Agorafdkaac.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/RtcBasic/Agoraffmpeg.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/RtcBasic/AgoraSoundTouch.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/SpatialAudio/AgoraSpatialAudioExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/VQA/AgoraVideoQualityAnalyzerExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/VideoAv1CodecDec/AgoraVideoAv1DecoderExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/VideoAv1CodecEnc/AgoraVideoAv1EncoderExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/VideoCodecDec/AgoraVideoDecoderExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/VideoCodecDec/video_dec.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/VideoCodecEnc/AgoraVideoEncoderExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/VideoCodecEnc/video_enc.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/VirtualBackground/AgoraVideoSegmentationExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/ffmpeg-kit-ios-min-gpl/ffmpegkit.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/ffmpeg-kit-ios-min-gpl/libavcodec.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/ffmpeg-kit-ios-min-gpl/libavdevice.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/ffmpeg-kit-ios-min-gpl/libavfilter.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/ffmpeg-kit-ios-min-gpl/libavformat.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/ffmpeg-kit-ios-min-gpl/libavutil.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/ffmpeg-kit-ios-min-gpl/libswresample.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/ffmpeg-kit-ios-min-gpl/libswscale.framework"
fi
if [[ "$CONFIGURATION" == "Profile" ]]; then
  install_framework "${BUILT_PRODUCTS_DIR}/AppAuth/AppAuth.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/AppCheckCore/AppCheckCore.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/BoringSSL-GRPC/openssl_grpc.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/BranchSDK/BranchSDK.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/DKImagePickerController/DKImagePickerController.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/DKPhotoGallery/DKPhotoGallery.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseAppCheck/FirebaseAppCheck.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseAppCheckInterop/FirebaseAppCheckInterop.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseAuth/FirebaseAuth.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseAuthInterop/FirebaseAuthInterop.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseCore/FirebaseCore.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseCoreExtension/FirebaseCoreExtension.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseCoreInternal/FirebaseCoreInternal.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseFirestore/FirebaseFirestore.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseFirestoreInternal/FirebaseFirestoreInternal.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseFunctions/FirebaseFunctions.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseInstallations/FirebaseInstallations.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseMessaging/FirebaseMessaging.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseMessagingInterop/FirebaseMessagingInterop.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseSharedSwift/FirebaseSharedSwift.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseStorage/FirebaseStorage.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GTMAppAuth/GTMAppAuth.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GTMSessionFetcher/GTMSessionFetcher.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GoogleDataTransport/GoogleDataTransport.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GoogleSignIn/GoogleSignIn.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GoogleUtilities/GoogleUtilities.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/MTBBarcodeScanner/MTBBarcodeScanner.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Mantle/Mantle.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/PromisesObjC/FBLPromises.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/PurchasesHybridCommon/PurchasesHybridCommon.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/RecaptchaInterop/RecaptchaInterop.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/RevenueCat/RevenueCat.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SDWebImage/SDWebImage.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SDWebImageWebPCoder/SDWebImageWebPCoder.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Stripe/Stripe.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/StripeApplePay/StripeApplePay.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/StripeCore/StripeCore.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/StripeFinancialConnections/StripeFinancialConnections.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/StripePaymentSheet/StripePaymentSheet.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/StripePayments/StripePayments.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/StripePaymentsUI/StripePaymentsUI.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/StripeUICore/StripeUICore.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SwiftyGif/SwiftyGif.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Toast/Toast.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/abseil/absl.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/agora_rtc_engine/agora_rtc_engine.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/audio_session/audio_session.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/audioplayers_darwin/audioplayers_darwin.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/better_open_file/better_open_file.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/camera_avfoundation/camera_avfoundation.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/contacts_service/contacts_service.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/device_info_plus/device_info_plus.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/devicelocale/devicelocale.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/emoji_picker_flutter/emoji_picker_flutter.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/file_picker/file_picker.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/file_saver/file_saver.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/flutter_branch_sdk/flutter_branch_sdk.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/flutter_downloader/flutter_downloader.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/flutter_image_compress_common/flutter_image_compress_common.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/flutter_local_notifications/flutter_local_notifications.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/flutter_native_splash/flutter_native_splash.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/flutter_paystack/flutter_paystack.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/flutter_pdfview/flutter_pdfview.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/flutter_secure_storage/flutter_secure_storage.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/flutter_sound_core/flutter_sound_core.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/flutter_video_info/flutter_video_info.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/fluttertoast/fluttertoast.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/gRPC-C++/grpcpp.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/gRPC-Core/grpc.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/gallery_saver/gallery_saver.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/geolocator_apple/geolocator_apple.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/image_editor_common/image_editor_common.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/image_picker_ios/image_picker_ios.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/in_app_purchase_storekit/in_app_purchase_storekit.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/iris_method_channel/iris_method_channel.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/just_audio/just_audio.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/leveldb-library/leveldb.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/libwebp/libwebp.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/local_auth_darwin/local_auth_darwin.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/location/location.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/media_info/media_info.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/nanopb/nanopb.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/package_info_plus/package_info_plus.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/path_provider_foundation/path_provider_foundation.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/photo_manager/photo_manager.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/purchases_flutter/purchases_flutter.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/qr_code_scanner/qr_code_scanner.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/receive_sharing_intent/receive_sharing_intent.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/record/record.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/restart_app/restart_app.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/share/share.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/share_plus/share_plus.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/shared_preferences_foundation/shared_preferences_foundation.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/sms_autofill/sms_autofill.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/sqflite/sqflite.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/stripe_ios/stripe_ios.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/the_apple_sign_in/the_apple_sign_in.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/url_launcher_ios/url_launcher_ios.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/video_compress/video_compress.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/video_player_avfoundation/video_player_avfoundation.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/video_thumbnail/video_thumbnail.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/wakelock/wakelock.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/webview_flutter_wkwebview/webview_flutter_wkwebview.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraIrisRTC_iOS/AgoraRtcWrapper.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/AIAEC/AgoraAiEchoCancellationExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/AINS/AgoraAiNoiseSuppressionExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/AudioBeauty/AgoraAudioBeautyExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/ClearVision/AgoraClearVisionExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/ContentInspect/AgoraContentInspectExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/FaceCapture/AgoraFaceCaptureExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/FaceDetection/AgoraFaceDetectionExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/LipSync/AgoraLipSyncExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/ReplayKit/AgoraReplayKitExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/RtcBasic/AgoraRtcKit.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/RtcBasic/aosl.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/RtcBasic/Agorafdkaac.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/RtcBasic/Agoraffmpeg.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/RtcBasic/AgoraSoundTouch.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/SpatialAudio/AgoraSpatialAudioExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/VQA/AgoraVideoQualityAnalyzerExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/VideoAv1CodecDec/AgoraVideoAv1DecoderExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/VideoAv1CodecEnc/AgoraVideoAv1EncoderExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/VideoCodecDec/AgoraVideoDecoderExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/VideoCodecDec/video_dec.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/VideoCodecEnc/AgoraVideoEncoderExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/VideoCodecEnc/video_enc.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/VirtualBackground/AgoraVideoSegmentationExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/ffmpeg-kit-ios-min-gpl/ffmpegkit.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/ffmpeg-kit-ios-min-gpl/libavcodec.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/ffmpeg-kit-ios-min-gpl/libavdevice.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/ffmpeg-kit-ios-min-gpl/libavfilter.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/ffmpeg-kit-ios-min-gpl/libavformat.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/ffmpeg-kit-ios-min-gpl/libavutil.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/ffmpeg-kit-ios-min-gpl/libswresample.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/ffmpeg-kit-ios-min-gpl/libswscale.framework"
fi
if [[ "$CONFIGURATION" == "Release" ]]; then
  install_framework "${BUILT_PRODUCTS_DIR}/AppAuth/AppAuth.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/AppCheckCore/AppCheckCore.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/BoringSSL-GRPC/openssl_grpc.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/BranchSDK/BranchSDK.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/DKImagePickerController/DKImagePickerController.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/DKPhotoGallery/DKPhotoGallery.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseAppCheck/FirebaseAppCheck.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseAppCheckInterop/FirebaseAppCheckInterop.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseAuth/FirebaseAuth.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseAuthInterop/FirebaseAuthInterop.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseCore/FirebaseCore.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseCoreExtension/FirebaseCoreExtension.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseCoreInternal/FirebaseCoreInternal.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseFirestore/FirebaseFirestore.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseFirestoreInternal/FirebaseFirestoreInternal.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseFunctions/FirebaseFunctions.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseInstallations/FirebaseInstallations.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseMessaging/FirebaseMessaging.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseMessagingInterop/FirebaseMessagingInterop.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseSharedSwift/FirebaseSharedSwift.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FirebaseStorage/FirebaseStorage.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GTMAppAuth/GTMAppAuth.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GTMSessionFetcher/GTMSessionFetcher.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GoogleDataTransport/GoogleDataTransport.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GoogleSignIn/GoogleSignIn.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GoogleUtilities/GoogleUtilities.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/MTBBarcodeScanner/MTBBarcodeScanner.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Mantle/Mantle.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/PromisesObjC/FBLPromises.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/PurchasesHybridCommon/PurchasesHybridCommon.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/RecaptchaInterop/RecaptchaInterop.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/RevenueCat/RevenueCat.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SDWebImage/SDWebImage.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SDWebImageWebPCoder/SDWebImageWebPCoder.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Stripe/Stripe.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/StripeApplePay/StripeApplePay.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/StripeCore/StripeCore.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/StripeFinancialConnections/StripeFinancialConnections.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/StripePaymentSheet/StripePaymentSheet.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/StripePayments/StripePayments.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/StripePaymentsUI/StripePaymentsUI.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/StripeUICore/StripeUICore.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SwiftyGif/SwiftyGif.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Toast/Toast.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/abseil/absl.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/agora_rtc_engine/agora_rtc_engine.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/audio_session/audio_session.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/audioplayers_darwin/audioplayers_darwin.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/better_open_file/better_open_file.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/camera_avfoundation/camera_avfoundation.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/contacts_service/contacts_service.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/device_info_plus/device_info_plus.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/devicelocale/devicelocale.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/emoji_picker_flutter/emoji_picker_flutter.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/file_picker/file_picker.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/file_saver/file_saver.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/flutter_branch_sdk/flutter_branch_sdk.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/flutter_downloader/flutter_downloader.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/flutter_image_compress_common/flutter_image_compress_common.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/flutter_local_notifications/flutter_local_notifications.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/flutter_native_splash/flutter_native_splash.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/flutter_paystack/flutter_paystack.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/flutter_pdfview/flutter_pdfview.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/flutter_secure_storage/flutter_secure_storage.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/flutter_sound_core/flutter_sound_core.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/flutter_video_info/flutter_video_info.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/fluttertoast/fluttertoast.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/gRPC-C++/grpcpp.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/gRPC-Core/grpc.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/gallery_saver/gallery_saver.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/geolocator_apple/geolocator_apple.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/image_editor_common/image_editor_common.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/image_picker_ios/image_picker_ios.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/in_app_purchase_storekit/in_app_purchase_storekit.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/iris_method_channel/iris_method_channel.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/just_audio/just_audio.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/leveldb-library/leveldb.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/libwebp/libwebp.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/local_auth_darwin/local_auth_darwin.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/location/location.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/media_info/media_info.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/nanopb/nanopb.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/package_info_plus/package_info_plus.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/path_provider_foundation/path_provider_foundation.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/photo_manager/photo_manager.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/purchases_flutter/purchases_flutter.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/qr_code_scanner/qr_code_scanner.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/receive_sharing_intent/receive_sharing_intent.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/record/record.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/restart_app/restart_app.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/share/share.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/share_plus/share_plus.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/shared_preferences_foundation/shared_preferences_foundation.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/sms_autofill/sms_autofill.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/sqflite/sqflite.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/stripe_ios/stripe_ios.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/the_apple_sign_in/the_apple_sign_in.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/url_launcher_ios/url_launcher_ios.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/video_compress/video_compress.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/video_player_avfoundation/video_player_avfoundation.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/video_thumbnail/video_thumbnail.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/wakelock/wakelock.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/webview_flutter_wkwebview/webview_flutter_wkwebview.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraIrisRTC_iOS/AgoraRtcWrapper.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/AIAEC/AgoraAiEchoCancellationExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/AINS/AgoraAiNoiseSuppressionExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/AudioBeauty/AgoraAudioBeautyExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/ClearVision/AgoraClearVisionExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/ContentInspect/AgoraContentInspectExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/FaceCapture/AgoraFaceCaptureExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/FaceDetection/AgoraFaceDetectionExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/LipSync/AgoraLipSyncExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/ReplayKit/AgoraReplayKitExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/RtcBasic/AgoraRtcKit.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/RtcBasic/aosl.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/RtcBasic/Agorafdkaac.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/RtcBasic/Agoraffmpeg.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/RtcBasic/AgoraSoundTouch.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/SpatialAudio/AgoraSpatialAudioExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/VQA/AgoraVideoQualityAnalyzerExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/VideoAv1CodecDec/AgoraVideoAv1DecoderExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/VideoAv1CodecEnc/AgoraVideoAv1EncoderExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/VideoCodecDec/AgoraVideoDecoderExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/VideoCodecDec/video_dec.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/VideoCodecEnc/AgoraVideoEncoderExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/VideoCodecEnc/video_enc.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/AgoraRtcEngine_iOS/VirtualBackground/AgoraVideoSegmentationExtension.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/ffmpeg-kit-ios-min-gpl/ffmpegkit.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/ffmpeg-kit-ios-min-gpl/libavcodec.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/ffmpeg-kit-ios-min-gpl/libavdevice.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/ffmpeg-kit-ios-min-gpl/libavfilter.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/ffmpeg-kit-ios-min-gpl/libavformat.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/ffmpeg-kit-ios-min-gpl/libavutil.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/ffmpeg-kit-ios-min-gpl/libswresample.framework"
  install_framework "${PODS_XCFRAMEWORKS_BUILD_DIR}/ffmpeg-kit-ios-min-gpl/libswscale.framework"
fi
if [ "${COCOAPODS_PARALLEL_CODE_SIGN}" == "true" ]; then
  wait
fi
