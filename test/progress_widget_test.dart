// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:runners_high/widgets/progress_indicator.dart';

void main() {
  testWidgets('ProgressIndicatorWidget displays progress correctly', (WidgetTester tester) async {
    // Define a sample run recommendation
    final runRecommendation = {
      "Week 1": {
        "Run 1": {"details": "5 km at 6:00 min/km pace", "completed": true},
        "Run 2": {"details": "7 km at 6:15 min/km pace", "completed": false},
      },
      "Week 2": {
        "Run 1": {"details": "6 km at 6:00 min/km pace", "completed": true},
        "Run 2": {"details": "8 km at 6:10 min/km pace", "completed": false},
      },
    };

    // Define a test key
    const testKey = Key('progress-indicator-widget');

    // Build the widget tree
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProgressIndicatorWidget(key: testKey, runRecommendation: runRecommendation),
        ),
      ),
    );

    // Verify the CircularPercentIndicator displays the correct progress
    expect(find.byType(CircularPercentIndicator), findsOneWidget);
    expect(find.text("50.0%"), findsOneWidget);
  });

  testWidgets('ProgressIndicatorWidget handles null recommendation', (WidgetTester tester) async {
    // Define a test key
    const testKey = Key('progress-indicator-widget');

    // Build the widget tree with a null runRecommendation
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProgressIndicatorWidget(key: testKey, runRecommendation: null),
        ),
      ),
    );

    // Verify the CircularPercentIndicator displays 0% progress
    expect(find.byType(CircularPercentIndicator), findsOneWidget);
    expect(find.text("0.0%"), findsOneWidget);
  });

  testWidgets('ProgressIndicatorWidget adapts to dark theme', (WidgetTester tester) async {
    // Define a sample run recommendation
    final runRecommendation = {
      "Week 1": {
        "Run 1": {"details": "5 km at 6:00 min/km pace", "completed": true},
        "Run 2": {"details": "7 km at 6:15 min/km pace", "completed": false},
      },
    };

    // Define a test key
    const testKey = Key('progress-indicator-widget');

    // Build the widget tree with a dark theme
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: ProgressIndicatorWidget(key: testKey, runRecommendation: runRecommendation),
        ),
      ),
    );

    // Verify the text color is white in dark theme
    final text = tester.widget<Text>(find.text("50.0%"));
    expect(text.style?.color, Colors.white);
  });

  testWidgets('ProgressIndicatorWidget adapts to light theme', (WidgetTester tester) async {
    // Define a sample run recommendation
    final runRecommendation = {
      "Week 1": {
        "Run 1": {"details": "5 km at 6:00 min/km pace", "completed": true},
        "Run 2": {"details": "7 km at 6:15 min/km pace", "completed": false},
      },
    };

    // Define a test key
    const testKey = Key('progress-indicator-widget');

    // Build the widget tree with a light theme
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        home: Scaffold(
          body: ProgressIndicatorWidget(key: testKey, runRecommendation: runRecommendation),
        ),
      ),
    );

    // Verify the text color is black in light theme
    final text = tester.widget<Text>(find.text("50.0%"));
    expect(text.style?.color, Colors.black);
  });
}

