import 'dart:convert';

class GiftsModel {
  int? id;
  int? coinPrice;
  String? image;
  int? createdAt;
  int? updatedAt;
  GiftsModel({
    this.id,
    this.coinPrice,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  GiftsModel copyWith({
    int? id,
    int? coinPrice,
    String? image,
    int? createdAt,
    int? updatedAt,
  }) {
    return GiftsModel(
      id: id ?? this.id,
      coinPrice: coinPrice ?? this.coinPrice,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'coinPrice': coinPrice,
      'image': image,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory GiftsModel.fromMap(Map<String, dynamic> map) {
    return GiftsModel(
      id: map['id'] as int?,
      coinPrice: map['coinPrice'] as int?,
      image: map['image'] ?? '',
      createdAt: map['createdAt'] as int?,
      updatedAt: map['updatedAt'] as int?,
    );
  }

  String toJson() => json.encode(toMap());

  factory GiftsModel.fromJson(String source) =>
      GiftsModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'GiftsModel(id: $id, coinPrice: $coinPrice, image: $image, createdAt: $createdAt, updatedAt: $updatedAt)';

  @override
  bool operator ==(covariant GiftsModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.coinPrice == coinPrice &&
        other.image == image &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      coinPrice.hashCode ^
      image.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
}
