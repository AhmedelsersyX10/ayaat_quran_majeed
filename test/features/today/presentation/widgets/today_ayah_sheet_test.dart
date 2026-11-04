import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/features/today/domain/entities/today_ayah.dart';
import 'package:ayaat_quran_majeed/features/today/domain/repositories/today_repository.dart';
import 'package:ayaat_quran_majeed/features/today/presentation/cubit/today_cubit.dart';
import 'package:ayaat_quran_majeed/features/today/presentation/widgets/today_ayah_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class StubTodayRepository implements TodayRepository {
  TodayAyah? ayah;
  bool shouldFail = false;

  @override
  Future<TodayAyah> getTodayAyah({DateTime? forDate}) async {
    if (shouldFail) {
      throw Exception('Database locked');
    }
    return ayah ??
        TodayAyah(
          surahNumber: 2,
          ayahNumber: 172,
          ayahText:
              'يَٰٓأَيُّهَا ٱلَّذِينَ ءَامَنُوا۟ كُلُوا۟ مِن طَيِّبَٰتِ مَا رَزَقْنَٰكُمْ وَٱشْكُرُوا۟ لِلَّهِ إِن كُنتُمْ إِيَّاهُ تَعْبُدُونَ',
          ayahEndSymbol: '﴿١٧٢﴾',
          pageNumber: 26,
          surahNameArabic: 'البقرة',
          hijriDay: '١٩',
          hijriMonthName: 'جمادى الأولى',
          gregorianDay: '٣٠',
          gregorianMonthName: 'أكتوبر',
          localDate: DateTime(2023, 10, 30),
        );
  }
}

void main() {
  late StubTodayRepository stubRepository;
  late TodayCubit todayCubit;

  setUp(() {
    stubRepository = StubTodayRepository();
    todayCubit = TodayCubit(stubRepository);
  });

  tearDown(() {
    todayCubit.close();
  });

  Widget buildTestWidget({
    required TodayCubit cubit,
    ValueChanged<TodayAyah>? onShare,
    ValueChanged<TodayAyah>? onTafsir,
  }) {
    return ScreenUtilInit(
      designSize: const Size(392, 852),
      builder: (context, child) => MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: BlocProvider.value(
            value: cubit,
            child: TodayAyahSheet(
              onShare: onShare ?? (_) {},
              onTafsir: onTafsir ?? (_) {},
            ),
          ),
        ),
      ),
    );
  }

  group('TodayAyahSheet Widget Tests', () {
    testWidgets('renders loading indicator while fetching', (tester) async {
      await tester.pumpWidget(buildTestWidget(cubit: todayCubit));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('اليوم'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('renders failure state and retries on button tap', (
      tester,
    ) async {
      stubRepository.shouldFail = true;
      await todayCubit.loadTodayAyah();

      await tester.pumpWidget(buildTestWidget(cubit: todayCubit));
      await tester.pumpAndSettle();

      expect(find.text('تعذر تحميل آية اليوم'), findsOneWidget);
      expect(find.text('أعد المحاولة'), findsOneWidget);

      // Change stub to succeed and tap retry
      stubRepository.shouldFail = false;
      await tester.tap(find.text('أعد المحاولة'));
      await tester.pumpAndSettle();

      expect(find.text('تعذر تحميل آية اليوم'), findsNothing);
      expect(find.text('جمادى الأولى'), findsOneWidget);
    });

    testWidgets('renders complete success sheet matching reference 16 layout', (
      tester,
    ) async {
      await todayCubit.loadTodayAyah();

      await tester.pumpWidget(buildTestWidget(cubit: todayCubit));
      await tester.pumpAndSettle();

      // Top title and close icon
      expect(find.text('اليوم'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      // Two Date cards: Hijri ("جمادى الأولى", "١٩") and Gregorian ("أكتوبر", "٣٠")
      expect(find.text('جمادى الأولى'), findsOneWidget);
      expect(find.text('١٩'), findsOneWidget);
      expect(find.text('أكتوبر'), findsOneWidget);
      expect(find.text('٣٠'), findsOneWidget);

      // Ayah of the day section header & share action
      expect(find.text('آية اليوم'), findsOneWidget);
      expect(find.byIcon(Icons.share_outlined), findsOneWidget);

      // Ayah Card: Text and verse end symbol
      expect(
        find.textContaining('يَٰٓأَيُّهَا ٱلَّذِينَ ءَامَنُوا۟'),
        findsOneWidget,
      );
      expect(find.textContaining('﴿١٧٢﴾'), findsOneWidget);

      // Tafsir button on bottom of card
      expect(find.text('التفسير'), findsOneWidget);
    });

    testWidgets(
      'tapping share and tafsir buttons triggers respective callbacks with TodayAyah',
      (tester) async {
        TodayAyah? sharedAyah;
        TodayAyah? tafsirAyah;

        await todayCubit.loadTodayAyah();

        await tester.pumpWidget(
          buildTestWidget(
            cubit: todayCubit,
            onShare: (ayah) => sharedAyah = ayah,
            onTafsir: (ayah) => tafsirAyah = ayah,
          ),
        );
        await tester.pumpAndSettle();

        // Tap share
        await tester.tap(find.byIcon(Icons.share_outlined));
        await tester.pumpAndSettle();
        expect(sharedAyah, isNotNull);
        expect(sharedAyah!.surahNumber, 2);
        expect(sharedAyah!.ayahNumber, 172);

        // Tap tafsir
        await tester.ensureVisible(find.text('التفسير'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('التفسير'));
        await tester.pumpAndSettle();
        expect(tafsirAyah, isNotNull);
        expect(tafsirAyah!.surahNumber, 2);
        expect(tafsirAyah!.ayahNumber, 172);
      },
    );

    testWidgets('tapping close icon pops the sheet navigator', (tester) async {
      await todayCubit.loadTodayAyah();

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(392, 852),
          builder: (context, child) => MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: Builder(
                builder: (ctx) => ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: ctx,
                      isScrollControlled: true,
                      builder: (_) => BlocProvider.value(
                        value: todayCubit,
                        child: TodayAyahSheet(
                          onShare: (_) {},
                          onTafsir: (_) {},
                        ),
                      ),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byType(TodayAyahSheet), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(TodayAyahSheet), findsNothing);
    });
  });
}
