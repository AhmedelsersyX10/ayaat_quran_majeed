import 'dart:typed_data';
import 'package:ayaat_quran_majeed/core/di/injection.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/features/share/domain/entities/share_params.dart';
import 'package:ayaat_quran_majeed/features/share/domain/repositories/share_repository.dart';
import 'package:ayaat_quran_majeed/features/share/domain/usecases/format_share_text_use_case.dart';
import 'package:ayaat_quran_majeed/features/share/domain/usecases/save_ayah_image_to_gallery_use_case.dart';
import 'package:ayaat_quran_majeed/features/share/domain/usecases/share_ayah_image_use_case.dart';
import 'package:ayaat_quran_majeed/features/share/domain/usecases/share_ayah_text_use_case.dart';
import 'package:ayaat_quran_majeed/features/share/presentation/cubit/share_cubit.dart';
import 'package:ayaat_quran_majeed/features/share/presentation/views/share_card_preview_page.dart';
import 'package:ayaat_quran_majeed/features/share/presentation/widgets/share_ayah_dialog.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockShareRepository implements ShareRepository {
  bool shareTextCalled = false;
  String? lastSharedText;

  @override
  String formatShareText(ShareParams params) => 'نص تجريبي للآية';

  @override
  Future<void> shareText({required String text, String? subject}) async {
    shareTextCalled = true;
    lastSharedText = text;
  }

  @override
  Future<String> shareImage({
    required Uint8List imageBytes,
    required String fileName,
    String? text,
  }) async => '/mock/path/$fileName';

  @override
  Future<void> saveImageToGallery({
    required Uint8List imageBytes,
    required String fileName,
  }) async {}

  @override
  Future<void> cleanOldShareFiles({
    Duration olderThan = const Duration(hours: 2),
  }) async {}
}

void main() {
  late _MockShareRepository mockRepo;
  late ShareCubit cubit;

  setUp(() {
    mockRepo = _MockShareRepository();
    cubit = ShareCubit(
      formatShareTextUseCase: FormatShareTextUseCase(mockRepo),
      shareAyahTextUseCase: ShareAyahTextUseCase(mockRepo),
      shareAyahImageUseCase: ShareAyahImageUseCase(mockRepo),
      saveAyahImageToGalleryUseCase: SaveAyahImageToGalleryUseCase(mockRepo),
      metadataService: const QuranMetadataService(),
    );

    if (sl.isRegistered<ShareCubit>()) {
      sl.unregister<ShareCubit>();
    }
    sl.registerFactory<ShareCubit>(() => cubit);
  });

  tearDown(() async {
    if (sl.isRegistered<ShareCubit>()) {
      sl.unregister<ShareCubit>();
    }
  });

  Widget createWidgetUnderTest() {
    return ScreenUtilInit(
      designSize: const Size(392, 852),
      builder: (context, child) => MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('ar'),
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Builder(
              builder: (ctx) => Center(
                child: ElevatedButton(
                  onPressed: () => showDialog(
                    context: ctx,
                    builder: (_) =>
                        const ShareAyahDialog(surahNumber: 1, verseNumber: 1),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('ShareAyahDialog Widget Tests', () {
    testWidgets(
      'renders dialog with header, range selectors, and action buttons',
      (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Open dialog
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.text('مشاركة الآية - سورة الفاتحة'), findsOneWidget);
        expect(find.text('من'), findsOneWidget);
        expect(find.text('إلى'), findsOneWidget);
        expect(find.text('بدون تشكيل؟'), findsOneWidget);
        expect(find.text('إضافة التفسير'), findsOneWidget);
        expect(find.text('إضافة توقيع التطبيق'), findsOneWidget);
        expect(find.text('مشاركة كنص'), findsOneWidget);
        expect(find.text('مشاركة كصورة'), findsOneWidget);
      },
    );

    testWidgets(
      'toggles checkboxes for withoutTashkeel, includeTafsir and includeAppBranding',
      (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // Toggle without tashkeel checkbox
        final withoutTashkeelTile = find.widgetWithText(
          CheckboxListTile,
          'بدون تشكيل؟',
        );
        expect(withoutTashkeelTile, findsOneWidget);
        await tester.tap(withoutTashkeelTile);
        await tester.pumpAndSettle();
        expect(cubit.state.params.withoutTashkeel, isTrue);

        // Toggle tafsir checkbox
        final tafsirTile = find.widgetWithText(
          CheckboxListTile,
          'إضافة التفسير',
        );
        expect(tafsirTile, findsOneWidget);
        await tester.tap(tafsirTile);
        await tester.pumpAndSettle();
        expect(cubit.state.params.includeTafsir, isTrue);

        // Toggle branding checkbox
        final brandingTile = find.widgetWithText(
          CheckboxListTile,
          'إضافة توقيع التطبيق',
        );
        expect(brandingTile, findsOneWidget);
        await tester.tap(brandingTile);
        await tester.pumpAndSettle();
        expect(cubit.state.params.includeAppBranding, isFalse);
      },
    );

    testWidgets(
      'tapping "مشاركة كنص" invokes text sharing flow and pops dialog',
      (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('مشاركة كنص'));
        await tester.pumpAndSettle();

        expect(mockRepo.shareTextCalled, isTrue);
        // Dialog popped
        expect(find.text('مشاركة الآية - سورة الفاتحة'), findsNothing);
      },
    );

    testWidgets('tapping "مشاركة كصورة" pushes ShareCardPreviewPage', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('مشاركة كصورة'));
      await tester.pumpAndSettle();

      expect(find.byType(ShareCardPreviewPage), findsOneWidget);
      expect(find.text('معاينة البطاقة'), findsOneWidget);
    });
  });
}
