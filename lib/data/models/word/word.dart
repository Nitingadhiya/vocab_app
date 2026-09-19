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

  /// Set only for phonics entries: a phonetic-spelling approximation of the
  /// letter's spoken sound (e.g. "kuh" for C), spoken via TTS instead of
  /// [text] so playback is the letter *sound*, not its name or a vocab word.
  String? phonicsSound;

  Word({
    required this.id,
    required this.categoryId,
    required this.text,
    required this.emoji,
    this.letter,
    this.phonicsSound,
  });

  factory Word.fromJson(Map<String, dynamic> json) => _$WordFromJson(json);
  Map<String, dynamic> toJson() => _$WordToJson(this);
}
