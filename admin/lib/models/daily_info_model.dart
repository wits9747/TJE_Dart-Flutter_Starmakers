import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'package:lamatadmin/helpers/config.dart';

class DailyInfoModel {
  IconData? icon;
  String? title;
  String? totalStorage;
  int? volumeData;
  int? percentage;
  Color? color;
  List<Color>? colors;
  List<FlSpot>? spots;

  DailyInfoModel({
    this.icon,
    this.title,
    this.totalStorage,
    this.volumeData,
    this.percentage,
    this.color,
    this.colors,
    this.spots,
  });

  DailyInfoModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    volumeData = json['volumeData'];
    icon = json['icon'];
    totalStorage = json['totalStorage'];
    color = json['color'];
    percentage = json['percentage'];
    colors = json['colors'];
    spots = json['spots'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['volumeData'] = volumeData;
    data['icon'] = icon;
    data['totalStorage'] = totalStorage;
    data['color'] = color;
    data['percentage'] = percentage;
    data['colors'] = colors;
    data['spots'] = spots;
    return data;
  }
}

List<DailyInfoModel> dailyDatas =
    dailyData.map((item) => DailyInfoModel.fromJson(item)).toList();

//List<FlSpot> spots = yValues.asMap().entries.map((e) {
//  return FlSpot(e.key.toDouble(), e.value);
//}).toList();

var dailyData = [
  {
    "title": "Users",
    "volumeData": 1328,
    "icon": FlutterIcons.user_alt_faw5s,
    "totalStorage": "+ %20",
    "color": AppConstants.primaryColor,
    "percentage": 35,
    "colors": [
      const Color(0xff23b6e6),
      const Color(0xff02d39a),
    ],
    "spots": [
      const FlSpot(
        1,
        2,
      ),
      const FlSpot(
        2,
        1.0,
      ),
      const FlSpot(
        3,
        1.8,
      ),
      const FlSpot(
        4,
        1.5,
      ),
      const FlSpot(
        5,
        1.0,
      ),
      const FlSpot(
        6,
        2.2,
      ),
      const FlSpot(
        7,
        1.8,
      ),
      const FlSpot(
        8,
        1.5,
      )
    ]
  },
  {
    "title": "Live Users",
    "volumeData": 1328,
    "icon": FlutterIcons.video_camera_faw,
    "totalStorage": "+ %5",
    "color": const Color(0xFFFFA113),
    "percentage": 35,
    "colors": [const Color(0xfff12711), const Color(0xfff5af19)],
    "spots": [
      const FlSpot(
        1,
        1.3,
      ),
      const FlSpot(
        2,
        1.0,
      ),
      const FlSpot(
        3,
        4,
      ),
      const FlSpot(
        4,
        1.5,
      ),
      const FlSpot(
        5,
        1.0,
      ),
      const FlSpot(
        6,
        3,
      ),
      const FlSpot(
        7,
        1.8,
      ),
      const FlSpot(
        8,
        1.5,
      )
    ]
  },
  {
    "title": "Teels",
    "volumeData": 1328,
    "icon": FlutterIcons.play_video_fou,
    "totalStorage": "+ %8",
    "color": const Color(0xFFA4CDFF),
    "percentage": 10,
    "colors": [const Color(0xff2980B9), const Color(0xff6DD5FA)],
    "spots": [
      const FlSpot(
        1,
        1.3,
      ),
      const FlSpot(
        2,
        5,
      ),
      const FlSpot(
        3,
        1.8,
      ),
      const FlSpot(
        4,
        6,
      ),
      const FlSpot(
        5,
        1.0,
      ),
      const FlSpot(
        6,
        2.2,
      ),
      const FlSpot(
        7,
        1.8,
      ),
      const FlSpot(
        8,
        1,
      )
    ]
  },
  {
    "title": "Posts",
    "volumeData": 1328,
    "icon": FlutterIcons.image_album_mco,
    "totalStorage": "+ %8",
    "color": const Color(0xFFd50000),
    "percentage": 10,
    "colors": [const Color(0xff93291E), const Color(0xffED213A)],
    "spots": [
      const FlSpot(
        1,
        3,
      ),
      const FlSpot(
        2,
        4,
      ),
      const FlSpot(
        3,
        1.8,
      ),
      const FlSpot(
        4,
        1.5,
      ),
      const FlSpot(
        5,
        1.0,
      ),
      const FlSpot(
        6,
        2.2,
      ),
      const FlSpot(
        7,
        1.8,
      ),
      const FlSpot(
        8,
        1.5,
      )
    ]
  },
  {
    "title": "Server Storage",
    "volumeData": 5328,
    "icon": FlutterIcons.sd_storage_mdi,
    "totalStorage": "- %5",
    "color": const Color(0xFF00F260),
    "percentage": 78,
    "colors": [const Color(0xff0575E6), const Color(0xff00F260)],
    "spots": [
      const FlSpot(
        1,
        1.3,
      ),
      const FlSpot(
        2,
        1.0,
      ),
      const FlSpot(
        3,
        1.8,
      ),
      const FlSpot(
        4,
        1.5,
      ),
      const FlSpot(
        5,
        1.0,
      ),
      const FlSpot(
        6,
        2.2,
      ),
      const FlSpot(
        7,
        1.8,
      ),
      const FlSpot(
        8,
        1.5,
      ),
      const FlSpot(
        9,
        3.5,
      )
    ]
  }
];

//final List<double> yValues = [
//  2.3,
//  1.8,
//  1.9,
//  1.5,
//  1.0,
//  2.2,
//  1.8,
//  1.5,
//];
