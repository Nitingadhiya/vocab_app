import 'package:flutter/material.dart';
import 'package:vocab_app/bootstrap.dart';
import 'package:vocab_app/presentation/app/view/app_view.dart';

void main() async {
  final router = await bootstrap();
  runApp(AppView(router: router));
}
