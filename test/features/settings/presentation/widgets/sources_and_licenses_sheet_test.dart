import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_button.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_card.dart';
import 'package:ayaat_quran_majeed/features/settings/domain/entities/content_source.dart';
import 'package:ayaat_quran_majeed/features/settings/presentation/widgets/sources_and_licenses_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.physicalSize = const Size(
      1176,
      2556,
    );
    binding.platformDispatcher.views.first.devicePixelRatio = 3.0;
  });

  tearDown(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.resetPhysicalSize();
    binding.platformDispatcher.views.first.resetDevicePixelRatio();
  });

  final testSources = [
    const ContentSource(
      title: 'محرك المصحف الشريف',
      provider: 'مجمع الملك فهد',
      description: 'خطوط الرسم العثماني حفص',
      category: ContentSourceCategory.quranEngine,
      url: 'https://qurancomplex.gov.sa/',
    ),
    const ContentSource(
      title: 'التفسير الميسر',
      provider: 'نخبة من العلماء',
      description: 'تفسير معتمد وميسر',
      category: ContentSourceCategory.tafsir,
    ),
  ];

  Widget buildTestWidget({List<ContentSource>? sources}) {
    return ScreenUtilInit(
      designSize: const Size(392, 852),
      builder: (context, child) => MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(body: SourcesAndLicensesSheet(sources: sources)),
      ),
    );
  }

  group('SourcesAndLicensesSheet Widget Tests', () {
    testWidgets('renders all supplied source cards and details', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(sources: testSources));
      await tester.pumpAndSettle();

      expect(find.byType(AppCard), findsNWidgets(2));
      expect(find.text('محرك المصحف الشريف'), findsOneWidget);
      expect(find.text('مجمع الملك فهد'), findsOneWidget);
      expect(find.text('https://qurancomplex.gov.sa/'), findsOneWidget);

      expect(find.text('التفسير الميسر'), findsOneWidget);
      expect(find.text('نخبة من العلماء'), findsOneWidget);
    });

    testWidgets(
      'renders open-source licenses button and triggers dialog on tap',
      (tester) async {
        await tester.pumpWidget(buildTestWidget(sources: testSources));
        await tester.pumpAndSettle();

        final buttonFinder = find.widgetWithText(
          AppButton,
          'تراخيص البرمجيات مفتوحة المصدر',
        );
        expect(buttonFinder, findsOneWidget);

        await tester.tap(buttonFinder);
        await tester.pumpAndSettle();

        expect(find.byType(LicensePage), findsOneWidget);
      },
    );
  });
}
