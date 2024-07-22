class BoosterPlans {
  List<BoosterPlanData>? _data;

  List<BoosterPlanData>? get data => _data;

  BoosterPlans({List<BoosterPlanData>? data}) {
    _data = data;
  }

  BoosterPlans.fromJson(dynamic json) {
    if (json["data"] != null) {
      _data = [];
      json["data"].forEach((v) {
        _data!.add(BoosterPlanData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    if (_data != null) {
      map["data"] = _data!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class BoosterPlanData {
  int? _boosterPlanId;
  String? _boosterPlanName;
  String? _boosterPlanDescription;
  double? _boosterPlanPrice;
  int? _boosterAmount;
  int? _createdAt;
  int? _updatedAt;

  int? get boosterPlanId => _boosterPlanId;

  String? get boosterPlanName => _boosterPlanName;

  String? get boosterPlanDescription => _boosterPlanDescription;

  double? get boosterPlanPrice => _boosterPlanPrice;

  int? get boosterAmount => _boosterAmount;

  int? get createdAt => _createdAt;

  int? get updatedAt => _updatedAt;

  BoosterPlanData(
      {int? boosterPlanId,
      String? boosterPlanName,
      String? boosterPlanDescription,
      double? boosterPlanPrice,
      int? boosterAmount,
      int? createdAt,
      int? updatedAt}) {
    _boosterPlanId = boosterPlanId;
    _boosterPlanName = boosterPlanName;
    _boosterPlanDescription = boosterPlanDescription;
    _boosterPlanPrice = boosterPlanPrice;
    _boosterAmount = boosterAmount;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  BoosterPlanData.fromJson(dynamic json) {
    _boosterPlanId = json["booster_plan_id"];
    _boosterPlanName = json["booster_plan_name"];
    _boosterPlanDescription = json["booster_plan_description"];
    _boosterPlanPrice = json["booster_plan_price"];
    _boosterAmount = json["booster_amount"];
    _createdAt = json["created_at"];
    _updatedAt = json["updated_at"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["booster_plan_id"] = _boosterPlanId;
    map["booster_plan_name"] = _boosterPlanName;
    map["booster_plan_description"] = _boosterPlanDescription;
    map["booster_plan_price"] = _boosterPlanPrice;
    map["booster_amount"] = _boosterAmount;
    map["created_at"] = _createdAt;
    map["updated_at"] = _updatedAt;
    return map;
  }
}
