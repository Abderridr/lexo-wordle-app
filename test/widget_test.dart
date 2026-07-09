import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lexo_puzzle/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LexoApp());
    expect(find.byType(MaterialApp), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 1));
  });
}
