import 'dart:convert';

class VerifyModel {
  int? id;
  int? status;
  String? purcahseCode;
  int? createdAt;
  int? updatedAt;
  VerifyModel({
    this.id,
    this.status,
    this.purcahseCode,
    this.createdAt,
    this.updatedAt,
  });

  VerifyModel copyWith({
    int? id,
    int? status,
    String? purcahseCode,
    int? createdAt,
    int? updatedAt,
  }) {
    return VerifyModel(
      id: id ?? this.id,
      status: status ?? this.status,
      purcahseCode: purcahseCode ?? this.purcahseCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'status': status,
      'purcahseCode': purcahseCode,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory VerifyModel.fromMap(Map<String, dynamic> map) {
    return VerifyModel(
      id: map['id'] as int?,
      status: map['status'] as int?,
      purcahseCode: map['purcahseCode'] ?? '',
      createdAt: map['createdAt'] as int?,
      updatedAt: map['updatedAt'] as int?,
    );
  }

  String toJson() => json.encode(toMap());

  factory VerifyModel.fromJson(String source) =>
      VerifyModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'VerifyModel(id: $id, status: $status, purcahseCode: $purcahseCode, createdAt: $createdAt, updatedAt: $updatedAt)';

  @override
  bool operator ==(covariant VerifyModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.status == status &&
        other.purcahseCode == purcahseCode &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      status.hashCode ^
      purcahseCode.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
}
