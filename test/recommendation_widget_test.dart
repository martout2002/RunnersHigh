import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mockito/mockito.dart';
import 'package:runners_high/widgets/recommendation_widget.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockFirebaseDatabase extends Mock implements FirebaseDatabase {}
class MockDatabaseReference extends Mock implements DatabaseReference {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockAuth = MockFirebaseAuth();
  final mockUser = MockUser();
  final mockDatabase = MockFirebaseDatabase();
  final mockReference = MockDatabaseReference();

  setUp(() {
    when(mockAuth.currentUser).thenReturn(mockUser);
    when(mockDatabase.ref()).thenReturn(mockReference);
    when(mockReference.child('')).thenReturn(mockReference.child(''));
    when(mockReference.set('')).thenAnswer((_) async => Future.value());
  });

  testWidgets('RecommendationWidget displays recommendations correctly', (WidgetTester tester) async {
    final recommendation = {
      "Week 1": {
        "Run 1": {"details": "5 km at 6:00 min/km pace", "completed": true},
        "Run 2": {"details": "7 km at 6:15 min/km pace", "completed": false},
      },
      "Week 2": {
        "Run 1": {"details": "6 km at 6:00 min/km pace", "completed": false},
        "Run 2": {"details": "8 km at 6:10 min/km pace", "completed": false},
      },
    };

    final pastRuns = [
      {"date": "2023-07-01", "distance": 5, "pace": "6:00"},
      {"date": "2023-07-03", "distance": 8, "pace": "6:30"},
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecommendationWidget(
            recommendation: recommendation,
            pastRuns: pastRuns,
            onRecommendationUpdated: (updatedRecommendation) {},
          ),
        ),
      ),
    );

    expect(find.text("Week 1"), findsOneWidget);
    expect(find.text("Run 1"), findsOneWidget);
    expect(find.text("5 km at 6:00 min/km pace"), findsOneWidget);
    expect(find.text("Run 2"), findsOneWidget);
    expect(find.text("7 km at 6:15 min/km pace"), findsOneWidget);

    expect(find.text("Week 2"), findsOneWidget);
    expect(find.text("Run 1"), findsOneWidget);
    expect(find.text("6 km at 6:00 min/km pace"), findsOneWidget);
    expect(find.text("Run 2"), findsOneWidget);
    expect(find.text("8 km at 6:10 min/km pace"), findsOneWidget);
  });

  testWidgets('RecommendationWidget toggles run completion status', (WidgetTester tester) async {
    final recommendation = {
      "Week 1": {
        "Run 1": {"details": "5 km at 6:00 min/km pace", "completed": true},
        "Run 2": {"details": "7 km at 6:15 min/km pace", "completed": false},
      },
    };

    final pastRuns = [
      {"date": "2023-07-01", "distance": 5, "pace": "6:00"},
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecommendationWidget(
            recommendation: recommendation,
            pastRuns: pastRuns,
            onRecommendationUpdated: (updatedRecommendation) {
              recommendation.update("Week 1", (value) => updatedRecommendation["Week 1"]);
            },
          ),
        ),
      ),
    );

    // Initial state
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);

    // Toggle completion
    await tester.tap(find.byIcon(Icons.check_circle_outline));
    await tester.pumpAndSettle();

    // Verify the state after toggling
    expect(find.byIcon(Icons.check_circle), findsNWidgets(2));
    expect(find.byIcon(Icons.check_circle_outline), findsNothing);
  });
}
