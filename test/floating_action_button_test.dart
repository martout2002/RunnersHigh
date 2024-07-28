import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runners_high/widgets/floating_action_button.dart';

// Create a mock RunTrackingPage to replace the real one in the test
class MockRunTrackingPage extends StatelessWidget {
  final VoidCallback onToggleTheme;

  const MockRunTrackingPage({Key? key, required this.onToggleTheme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mock Run Tracking Page')),
    );
  }
}

void main() {
  testWidgets('CustomFloatingActionButton navigates to MockRunTrackingPage on press', (WidgetTester tester) async {
    final onToggleTheme = () {};

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          floatingActionButton: CustomFloatingActionButton(
            onToggleTheme: onToggleTheme,
            pageBuilder: (context) => MockRunTrackingPage(onToggleTheme: onToggleTheme),
          ),
        ),
      ),
    );

    // Verify if FloatingActionButton is present
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Tap the FloatingActionButton
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Verify that MockRunTrackingPage is pushed
    expect(find.byType(MockRunTrackingPage), findsOneWidget);
  });
}