import 'dart:convert';

class ActionsModel {
  String actionType;
  DateTime actionDate;
  String fullName;

  ActionsModel({
    required this.actionType,
    required this.actionDate,
    required this.fullName,
  });

  ActionsModel copyWith({
    String? actionType,
    DateTime? actionDate,
    String? fullName,
  }) {
    return ActionsModel(
      actionType: actionType ?? this.actionType,
      actionDate: actionDate ?? this.actionDate,
      fullName: fullName ?? this.fullName,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'actionType': actionType,
      'actionDate': actionDate.millisecondsSinceEpoch,
      'fullName': fullName,
    };
  }

  factory ActionsModel.fromMap(Map<String, dynamic> map) {
    return ActionsModel(
      actionType: map['actionType'] as String,
      actionDate: DateTime.fromMillisecondsSinceEpoch(map['actionDate'] as int),
      fullName: map['fullName'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ActionsModel.fromJson(String source) =>
      ActionsModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'ActionsModel( actionType: $actionType, actionDate: $actionDate, fullName: $fullName, )';

  @override
  bool operator ==(covariant ActionsModel other) {
    if (identical(this, other)) return true;

    return other.actionType == actionType &&
        other.actionDate == actionDate &&
        other.fullName == fullName;
  }

  @override
  int get hashCode =>
      actionType.hashCode ^ actionDate.hashCode ^ fullName.hashCode;
}
