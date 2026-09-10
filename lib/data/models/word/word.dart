import 'dart:core';

import 'package:json_annotation/json_annotation.dart';

part 'word.g.dart';

@JsonSerializable()
class Word {
  String id;
  String categoryId;
  String text;
  String emoji;

  /// Set only for alphabet entries (e.g. "A") to show the big letter above the emoji.
  String? letter;

  Word({
    required this.id,
    required this.categoryId,
    required this.text,
    required this.emoji,
    this.letter,
  });

  factory Word.fromJson(Map<String, dynamic> json) => _$WordFromJson(json);
  Map<String, dynamic> toJson() => _$WordToJson(this);
}
