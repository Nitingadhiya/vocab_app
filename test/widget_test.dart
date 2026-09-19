// Basic smoke test: the app boots and shows the onboarding screen.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vocab_app/bootstrap.dart';
import 'package:vocab_app/presentation/app/view/app_view.dart';

void main() {
  testWidgets('App boots to onboarding and can get started', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    final router = await bootstrap();
    await tester.pumpWidget(AppView(router: router));
    await tester.pumpAndSettle();

    expect(find.text('Word Stars'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('Get Started'), findsNothing);
  });
}
