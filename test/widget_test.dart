// Basic smoke test for the IED Reader app.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ied_reader/main.dart';

void main() {
  testWidgets('App starts and shows home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const IedReaderApp());
    await tester.pump();

    // The bottom navigation bar should be present.
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}
