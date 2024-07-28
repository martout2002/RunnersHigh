import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runners_high/widgets/profileRunWidget.dart'; // Adjust the import path as necessary

void main() {
  testWidgets('ProfileRunWidget displays the correct data', (WidgetTester tester) async {
    // Define the test data
    final int testDisplay = 42;
    final String testBot = 'Test Bot';

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileRunWidget(testDisplay, testBot),
        ),
      ),
    );

    // Verify if the Card is present
    expect(find.byType(Card), findsOneWidget);

    // Verify if the display text is present and correct
    expect(find.text('$testDisplay'), findsOneWidget);

    // Verify if the bot text is present and correct
    expect(find.text(testBot), findsOneWidget);
  });
}
