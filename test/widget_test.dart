// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/cupertino.dart';

import 'package:stably_app/main.dart';

void main() {
  testWidgets('renders shell navigation and home content',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: StablyBootstrap()),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CustomScrollView), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.home), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.compass_fill), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.chart_bar_alt_fill), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.money_dollar_circle_fill), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.bell_fill), findsOneWidget);
  });
}
