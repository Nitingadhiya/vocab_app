// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Word _$WordFromJson(Map<String, dynamic> json) => Word(
  id: json['id'] as String,
  categoryId: json['categoryId'] as String,
  text: json['text'] as String,
  emoji: json['emoji'] as String,
  letter: json['letter'] as String?,
  phonicsSound: json['phonicsSound'] as String?,
);

Map<String, dynamic> _$WordToJson(Word instance) => <String, dynamic>{
  'id': instance.id,
  'categoryId': instance.categoryId,
  'text': instance.text,
  'emoji': instance.emoji,
  'letter': instance.letter,
  'phonicsSound': instance.phonicsSound,
};
