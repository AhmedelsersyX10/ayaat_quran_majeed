import 'package:ayaat_quran_majeed/quran/presentation/widgets/common/mushaf_return_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createTestableWidget(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(392, 852),
      builder: (_, __) => MaterialApp(
        home: Scaffold(body: child),
      ),
    );
  }

  group('MushafReturnButton Widget Tests', () {
    testWidgets('hidden when returnPage is null', (tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          MushafReturnButton(
            returnPage: null,
            onReturn: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.undo_rounded), findsNothing);
    });

    testWidgets('renders return arrow and Eastern Arabic page number when returnPage is set',
        (tester) async {
      bool returnTapped = false;

      await tester.pumpWidget(
        createTestableWidget(
          MushafReturnButton(
            returnPage: 42,
            onReturn: () => returnTapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.undo_rounded), findsOneWidget);
      // 42 in Arabic-Indic digits is ٤٢
      expect(find.text('٤٢'), findsOneWidget);

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();
      expect(returnTapped, isTrue);
    });
  });
}

