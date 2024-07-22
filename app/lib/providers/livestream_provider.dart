// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:lamatdating/models/agora/agora.dart';
import 'package:lamatdating/models/agora/agora_token.dart';
import 'package:http/http.dart' as http;
import 'package:lamatdating/utils/call_utilities.dart';

class LiveStream {
  var client = http.Client();

  Future<AgoraToken> generateAgoraToken(String channelName, String uid) async {
    Map<String, dynamic>? res = await FunctionCall().makeCloudCall();
    // final response = await client.get(Uri.parse(
    //     "https://XXXXXXXX.onrender.com/rtc/$channelName/publisher/userAccount/$uid/?expiry=3600"));
    // if (kDebugMode) {
    //   print(response.body);
    // }
    return AgoraToken.fromJson(res);
  }

  Future<AgoraTokenDemo> generateAgoraTokenDemo(
      String channelName, String uid) async {
    final response = await client.get(Uri.parse(
        "https://XXXXXXXXXXXXXXXXXXXXXXXXXXX.onrender.com/rtc/$channelName/publisher/userAccount/$uid/?expiry=3600"));
    if (kDebugMode) {
      print(response.body);
    }
    return AgoraTokenDemo.fromJson(jsonDecode(response.body));
  }

  Future<Agora> agoraListStreamingCheck(
      String channelName, String authToken, String agoraAppId) async {
    if (kDebugMode) {
      print(channelName);
    }
    if (kDebugMode) {
      print(authToken);
    }
    http.Response response = await http.get(
        Uri.parse(
            'https://api.agora.io/dev/channel/user/$agoraAppId/$channelName'),
        headers: {'Authorization': 'Basic $authToken'});
    return Agora.fromJson(jsonDecode(response.body));
  }
}
