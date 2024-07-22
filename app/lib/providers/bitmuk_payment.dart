// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

Future<bool> bitmukPaymentRequest(Map<String, dynamic> parameters) async {
  final url = Uri.parse('http://bitmuk.com/payment/connection');
  const String apiKey =
      'IvHcUZARLSHOJrt2EA7W8NcQAKwcHfGrGWkDyr2HY2wOwP5HUGlV8Wj9lJUc'; // Replace with your actual API key

  final headers = {
    'Accept': 'application/json',
    'x-api-key': apiKey,
  };

  final response =
      await http.post(url, headers: headers, body: jsonEncode(parameters));

  if (response.statusCode == 200) {
    final responseMap = jsonDecode(response.body) as Map<String, dynamic>;
    if (responseMap['success'] == true) {
      final redirectUrl = responseMap['redirect_url'];
      if (redirectUrl != null && redirectUrl.isNotEmpty) {
        // Launch the redirection using a webview or in-app browser
        await launchUrl(Uri.parse(redirectUrl));
        return true;
      } else {
        // Handle case where redirect_url is missing
        debugPrint('Missing redirect URL in response');
        return false;
      }
    } else {
      // Handle unsuccessful payment or other errors
      debugPrint('Payment request failed: ${responseMap['message']}');
      return false;
    }
  } else {
    debugPrint('Failed to connect to payment API');
    return false;
  }
  // return false;
}
