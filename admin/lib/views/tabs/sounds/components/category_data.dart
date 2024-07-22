import 'package:lamatadmin/models/songs_model.dart';

class SoundCategoryModel {
  int? soundCategoryId;
  String? soundCategoryName;
  String? soundCategoryProfile;
  List<SoundList>? soundList;

  SoundCategoryModel({
    this.soundCategoryId,
    this.soundCategoryName,
    this.soundCategoryProfile,
    this.soundList,
  });

  SoundCategoryModel.fromJson(Map<String, dynamic> json) {
    soundCategoryId = json['soundCategoryId'];
    soundCategoryName = json['soundCategoryName'];
    soundCategoryProfile = json['soundCategoryProfile'];
    soundList = json['soundList'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['soundCategoryId'] = soundCategoryId;
    data['soundCategoryName'] = soundCategoryName;
    data['soundCategoryProfile'] = soundCategoryProfile;
    data['soundList'] = soundList;
    return data;
  }
}
