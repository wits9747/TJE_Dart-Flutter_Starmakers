class HashTagVideo {
  int? _status;
  String? _message;
  int? _totalVideos;
  List<HashTagData>? _data;

  int? get status => _status;

  String? get message => _message;

  int? get totalVideos => _totalVideos;

  List<HashTagData>? get data => _data;

  HashTagVideo(
      {int? status,
      String? message,
      int? totalVideos,
      List<HashTagData>? data}) {
    _status = status;
    _message = message;
    _totalVideos = totalVideos;
    _data = data;
  }

  HashTagVideo.fromJson(dynamic json) {
    _status = json["status"];
    _message = json["message"];
    _totalVideos = json["total_videos"];
    if (json["data"] != null) {
      _data = [];
      json["data"].forEach((v) {
        _data!.add(HashTagData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["status"] = _status;
    map["message"] = _message;
    map["total_videos"] = _totalVideos;
    if (_data != null) {
      map["data"] = _data!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class HashTagData {
  int? _postId;
  int? _userId;
  String? _fullName;
  String? _userName;
  String? _userProfile;
  int? _isVerify;
  int? _isTrending;
  String? _postDescription;
  String? _postHashTag;
  String? _postVideo;
  String? _postImage;
  String? _profileCategoryId;
  String? _profileCategoryName;
  int? _soundId;
  String? _soundTitle;
  String? _duration;
  String? _singer;
  String? _soundImage;
  String? _sound;
  int? _postLikesCount;
  int? _postCommentsCount;
  int? _postViewCount;
  String? _createdDate;
  int? _videoLikesOrNot;
  int? _followOrNot;
  int? _isBookmark;
  int? _canComment;
  int? _canDuet;
  int? _canSave;

  int? get postId => _postId;

  int? get phoneNumber => _userId;

  String? get fullName => _fullName;

  String? get userName => _userName;

  String? get userProfile => _userProfile;

  int? get isVerify => _isVerify;

  int? get isTrending => _isTrending;

  String? get postDescription => _postDescription;

  String? get postHashTag => _postHashTag;

  String? get postVideo => _postVideo;

  String? get postImage => _postImage;

  String? get profileCategoryId => _profileCategoryId;

  String? get profileCategoryName => _profileCategoryName;

  int? get soundId => _soundId;

  String? get soundTitle => _soundTitle;

  String? get duration => _duration;

  String? get singer => _singer;

  String? get soundImage => _soundImage;

  String? get sound => _sound;

  int? get postLikesCount => _postLikesCount;

  int? get postCommentsCount => _postCommentsCount;

  int? get postViewCount => _postViewCount;

  String? get createdDate => _createdDate;

  int? get videoLikesOrNot => _videoLikesOrNot;

  int? get followOrNot => _followOrNot;

  int? get isBookmark => _isBookmark;

  int? get canComment => _canComment;

  int? get canDuet => _canDuet;

  int? get canSave => _canSave;

  HashTagData(
      {int? postId,
      int? phoneNumber,
      String? fullName,
      String? userName,
      String? userProfile,
      int? isVerify,
      int? isTrending,
      String? postDescription,
      String? postHashTag,
      String? postVideo,
      String? postImage,
      String? profileCategoryId,
      String? profileCategoryName,
      int? soundId,
      String? soundTitle,
      String? duration,
      String? singer,
      String? soundImage,
      String? sound,
      int? postLikesCount,
      int? postCommentsCount,
      int? postViewCount,
      String? createdDate,
      int? videoLikesOrNot,
      int? followOrNot,
      int? isBookmark,
      int? canComment,
      int? canDuet,
      int? canSave}) {
    _postId = postId;
    _userId = phoneNumber;
    _fullName = fullName;
    _userName = userName;
    _userProfile = userProfile;
    _isVerify = isVerify;
    _isTrending = isTrending;
    _postDescription = postDescription;
    _postHashTag = postHashTag;
    _postVideo = postVideo;
    _postImage = postImage;
    _profileCategoryId = profileCategoryId;
    _profileCategoryName = profileCategoryName;
    _soundId = soundId;
    _soundTitle = soundTitle;
    _duration = duration;
    _singer = singer;
    _soundImage = soundImage;
    _sound = sound;
    _postLikesCount = postLikesCount;
    _postCommentsCount = postCommentsCount;
    _postViewCount = postViewCount;
    _createdDate = createdDate;
    _videoLikesOrNot = videoLikesOrNot;
    _followOrNot = followOrNot;
    _isBookmark = isBookmark;
    _canComment = canComment;
    _canDuet = canDuet;
    _canSave = canSave;
  }

  HashTagData.fromJson(dynamic json) {
    _postId = json["post_id"];
    _userId = json["user_id"];
    _fullName = json["full_name"];
    _userName = json["user_name"];
    _userProfile = json["user_profile"];
    _isVerify = json["is_verify"];
    _isTrending = json["is_trending"];
    _postDescription = json["post_description"];
    _postHashTag = json["post_hash_tag"];
    _postVideo = json["post_video"];
    _postImage = json["post_image"];
    _profileCategoryId = json["profile_category_id"];
    _profileCategoryName = json["profile_category_name"];
    _soundId = json["sound_id"];
    _soundTitle = json["sound_title"];
    _duration = json["duration"];
    _singer = json["singer"];
    _soundImage = json["sound_image"];
    _sound = json["sound"];
    _postLikesCount = json["post_likes_count"];
    _postCommentsCount = json["post_comments_count"];
    _postViewCount = json["post_view_count"];
    _createdDate = json["created_date"];
    _videoLikesOrNot = json["video_likes_or_not"];
    _followOrNot = json["follow_or_not"];
    _isBookmark = json["is_bookmark"];
    _canComment = json["can_comment"];
    _canDuet = json["can_duet"];
    _canSave = json["can_save"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["post_id"] = _postId;
    map["user_id"] = _userId;
    map["full_name"] = _fullName;
    map["user_name"] = _userName;
    map["user_profile"] = _userProfile;
    map["is_verify"] = _isVerify;
    map["is_trending"] = _isTrending;
    map["post_description"] = _postDescription;
    map["post_hash_tag"] = _postHashTag;
    map["post_video"] = _postVideo;
    map["post_image"] = _postImage;
    map["profile_category_id"] = _profileCategoryId;
    map["profile_category_name"] = _profileCategoryName;
    map["sound_id"] = _soundId;
    map["sound_title"] = _soundTitle;
    map["duration"] = _duration;
    map["singer"] = _singer;
    map["sound_image"] = _soundImage;
    map["sound"] = _sound;
    map["post_likes_count"] = _postLikesCount;
    map["post_comments_count"] = _postCommentsCount;
    map["post_view_count"] = _postViewCount;
    map["created_date"] = _createdDate;
    map["video_likes_or_not"] = _videoLikesOrNot;
    map["follow_or_not"] = _followOrNot;
    map["is_bookmark"] = _isBookmark;
    map["can_comment"] = _canComment;
    map["can_duet"] = _canDuet;
    map["can_save"] = _canSave;
    return map;
  }
}
