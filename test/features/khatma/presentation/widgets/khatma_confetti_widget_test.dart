import 'package:ayaat_quran_majeed/features/khatma/presentation/widgets/khatma_confetti_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('KhatmaConfettiWidget Tests (Reference 26)', () {
    testWidgets('starts dismissed and does not render particles before play',
        (tester) async {
      final key = GlobalKey<KhatmaConfettiWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KhatmaConfettiWidget(
              key: key,
              duration: const Duration(milliseconds: 500),
            ),
          ),
        ),
      );

      // Initially dismissed: SizedBox.shrink is rendered inside KhatmaConfettiWidget
      final confettiFinder = find.descendant(
        of: find.byType(KhatmaConfettiWidget),
        matching: find.byType(RepaintBoundary),
      );
      expect(confettiFinder, findsNothing);
    });

    testWidgets('play triggers animation and renders CustomPaint particles',
        (tester) async {
      final key = GlobalKey<KhatmaConfettiWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KhatmaConfettiWidget(
              key: key,
              duration: const Duration(milliseconds: 500),
            ),
          ),
        ),
      );

      key.currentState?.play();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final confettiFinder = find.descendant(
        of: find.byType(KhatmaConfettiWidget),
        matching: find.byType(RepaintBoundary),
      );
      expect(confettiFinder, findsOneWidget);

      // Settle animation to completion
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Back to dismissed
      expect(confettiFinder, findsNothing);
    });

    testWidgets('stop clears the active confetti animation', (tester) async {
      final key = GlobalKey<KhatmaConfettiWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KhatmaConfettiWidget(
              key: key,
              duration: const Duration(milliseconds: 500),
            ),
          ),
        ),
      );

      key.currentState?.play();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final confettiFinder = find.descendant(
        of: find.byType(KhatmaConfettiWidget),
        matching: find.byType(RepaintBoundary),
      );
      expect(confettiFinder, findsOneWidget);

      key.currentState?.stop();
      await tester.pump();
      expect(confettiFinder, findsNothing);
    });
  });
}
