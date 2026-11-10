import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/widgets/khatma_time_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildTestApp({required Widget child}) {
  return ScreenUtilInit(
    designSize: const Size(392.7, 800.7),
    builder: (context, _) => MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('KhatmaTimePickerDialog (Reference 23)', () {
    setUp(() {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      binding.platformDispatcher.views.first.physicalSize =
          const Size(1176, 2556);
      binding.platformDispatcher.views.first.devicePixelRatio = 3.0;
    });

    tearDown(() {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      binding.platformDispatcher.views.first.resetPhysicalSize();
      binding.platformDispatcher.views.first.resetDevicePixelRatio();
    });

    testWidgets('renders initial time with Arabic digits and AM/PM toggle',
        (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: const KhatmaTimePickerDialog(
            initialTime: TimeOfDay(hour: 19, minute: 0), // 07:00 PM
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Displays Arabic digits ٠٧ and ٠٠
      expect(find.text('٠٧'), findsOneWidget);
      expect(find.text('٠٠'), findsOneWidget);

      // Displays AM (ص) and PM (م)
      expect(find.text('ص'), findsOneWidget);
      expect(find.text('م'), findsOneWidget);

      // Displays Cancel and OK buttons in Arabic
      expect(find.text('إلغاء'), findsOneWidget);
      expect(find.text('حسنًا'), findsOneWidget);
    });

    testWidgets('tapping AM/PM toggles selected period', (tester) async {
      TimeOfDay? result;

      await tester.pumpWidget(
        _buildTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showKhatmaTimePicker(
                  context: context,
                  initialTime: const TimeOfDay(hour: 19, minute: 0), // 07:00 PM
                );
              },
              child: const Text('Open Picker'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open picker
      await tester.tap(find.text('Open Picker'));
      await tester.pumpAndSettle();

      // Tap 'ص' (AM)
      await tester.tap(find.text('ص'));
      await tester.pumpAndSettle();

      // Confirm with 'حسنًا'
      await tester.tap(find.text('حسنًا'));
      await tester.pumpAndSettle();

      // Result should be 07:00 AM (hour: 7)
      expect(result, isNotNull);
      expect(result?.hour, 7);
      expect(result?.minute, 0);
    });

    testWidgets('tapping minute box switches mode and confirms time',
        (tester) async {
      TimeOfDay? result;

      await tester.pumpWidget(
        _buildTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showKhatmaTimePicker(
                  context: context,
                  initialTime: const TimeOfDay(hour: 7, minute: 15), // 07:15 AM
                );
              },
              child: const Text('Open Picker'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Picker'));
      await tester.pumpAndSettle();

      // Tap minute box '١٥'
      await tester.tap(find.text('١٥'));
      await tester.pumpAndSettle();

      // Confirm
      await tester.tap(find.text('حسنًا'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result?.hour, 7);
      expect(result?.minute, 15);
    });

    testWidgets('tapping إلغاء dismisses dialog and returns null',
        (tester) async {
      TimeOfDay? result = const TimeOfDay(hour: 12, minute: 0);

      await tester.pumpWidget(
        _buildTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showKhatmaTimePicker(
                  context: context,
                  initialTime: const TimeOfDay(hour: 19, minute: 0),
                );
              },
              child: const Text('Open Picker'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Picker'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('إلغاء'));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });
  });
}
