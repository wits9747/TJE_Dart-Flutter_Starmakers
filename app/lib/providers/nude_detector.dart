// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lamatdating/helpers/constants.dart';

Future<bool> detectNudity(String imagePath) async {
  // Replace with the base URL for detect explicit content
  // if (isDemo) {
  //   return false;
  // }
  const String visionApiUrl =
      'https://vision.googleapis.com/images:annotate?key=$locationApiKey';

  debugPrint("Vision API URL: $visionApiUrl");

  // Read the image bytes
  final imageBytes = await File(imagePath).readAsBytes();

  // Base64 encode the image bytes
  final imageBase64 = base64Encode(imageBytes);

  // Prepare the request body
  final body = {
    'requests': [
      {
        'image': {'content': imageBase64},
        'features': [
          {'type': 'SAFE_SEARCH_DETECTION'}
        ],
      }
    ]
  };

  // Make the POST request
  debugPrint("Checking Nudity!!!!!!!!!!!");
  final response =
      await http.post(Uri.parse(visionApiUrl), body: jsonEncode(body));

  if (isDemo) {
    return false;
  }

  if (response.statusCode == 200) {
    // Parse the JSON response
    final responseJson = jsonDecode(response.body);

    // Check for 'adult' or 'violence' in response labels
    final labels = responseJson['responses'][0]['labelAnnotations'];
    for (var label in labels) {
      if (label['description'].toLowerCase() == 'adult' ||
          label['description'].toLowerCase() == 'violence') {
        debugPrint("Image is Nude!!!!!!!!!!!");
        return true;
      }
    }
    debugPrint("Image is not Nude!!!!!!!!!!!");
    return false;
  } else {
    // Handle API errors
    throw Exception('Failed to detect nudity. Code: ${response.statusCode}');
  }
}
