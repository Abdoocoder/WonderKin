// This is a basic Flutter widget test.
//
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kids_adventure_app/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const KidsAdventureApp());

    // Verify the app loads
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}