import 'dart:core';

import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable()
class Category {
  String id;
  String name;
  String emoji;
  String colorHex;
  String description;

  Category({
    required this.id,
    required this.name,
    required this.emoji,
    required this.colorHex,
    required this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}
