import 'package:ayaat_quran_majeed/core/errors/failure.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/ayah_timing.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/moshaf.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/reciter.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/entities/reciter_surah.dart';
import 'package:ayaat_quran_majeed/features/audio/domain/repositories/audio_repository.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/cubit/reciter_selection_cubit.dart';
import 'package:ayaat_quran_majeed/features/audio/presentation/widgets/reciter_selection_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class StubAudioRepository implements AudioRepository {
  List<Reciter> reciters = [];
  Reciter? selectedReciter;
  Moshaf? selectedMoshaf;
  Failure? failureToThrow;

  int? savedReciterId;
  int? savedMoshafId;

  @override
  Future<List<Reciter>> getReciters({bool forceRefresh = false}) async {
    if (failureToThrow != null) throw failureToThrow!;
    return reciters;
  }

  @override
  Future<Reciter?> getSelectedReciter() async {
    if (failureToThrow != null) throw failureToThrow!;
    return selectedReciter;
  }

  @override
  Future<Moshaf?> getSelectedMoshaf() async {
    if (failureToThrow != null) throw failureToThrow!;
    return selectedMoshaf;
  }

  @override
  Future<void> setSelectedReciterAndMoshaf({
    required int reciterId,
    required int moshafId,
  }) async {
    if (failureToThrow != null) throw failureToThrow!;
    savedReciterId = reciterId;
    savedMoshafId = moshafId;
  }

  @override
  Future<Reciter?> getReciterById(int reciterId) async => null;

  @override
  Future<List<int>> getTimingSupportedMoshafIds({bool forceRefresh = false}) async => [];

  @override
  Future<List<int>> getTimingSurahListForRead(int readId) async => [];

  @override
  Future<List<AyahTiming>> getAyahTiming({
    required int readId,
    required int surahNumber,
  }) async =>
      [];

  @override
  Future<List<ReciterSurah>> getSurahsForMoshaf({
    required int reciterId,
    required Moshaf moshaf,
  }) async =>
      [];

  @override
  Future<bool> isSurahDownloaded({
    required int readId,
    required int surahNumber,
  }) async =>
      false;

  @override
  Future<String> getPlayableAudioUri({
    required Moshaf moshaf,
    required int surahNumber,
  }) async =>
      '';

  @override
  Future<void> downloadSurah({
    required Moshaf moshaf,
    required int surahNumber,
    void Function(int received, int total)? onProgress,
    dynamic cancelToken,
  }) async {}

  @override
  Future<void> deleteDownloadedSurah({
    required int readId,
    required int surahNumber,
  }) async {}
}

void main() {
  late StubAudioRepository repository;
  late ReciterSelectionCubit cubit;

  const moshafHosaryMurattal = Moshaf(
    id: 118,
    name: 'حفص عن عاصم - مرتل',
    server: 'https://server.com/118/',
    surahTotal: 114,
    moshafType: 1,
    surahList: [1, 2],
    hasTiming: true,
  );

  const moshafHosaryMujawwad = Moshaf(
    id: 119,
    name: 'حفص عن عاصم - مجود',
    server: 'https://server.com/119/',
    surahTotal: 114,
    moshafType: 2,
    surahList: [1, 2],
    hasTiming: true,
  );

  const reciterHosary = Reciter(
    id: 1,
    name: 'محمود خليل الحصري',
    letter: 'م',
    moshafs: [moshafHosaryMurattal, moshafHosaryMujawwad],
  );

  const moshafGhamadi = Moshaf(
    id: 30,
    name: 'حفص عن عاصم',
    server: 'https://server.com/30/',
    surahTotal: 114,
    moshafType: 1,
    surahList: [1, 2],
    hasTiming: true,
  );

  const reciterGhamadi = Reciter(
    id: 2,
    name: 'سعد الغامدي',
    letter: 'س',
    moshafs: [moshafGhamadi],
  );

  setUp(() {
    repository = StubAudioRepository();
    cubit = ReciterSelectionCubit(audioRepository: repository);

    repository.reciters = [reciterHosary, reciterGhamadi];
    repository.selectedReciter = reciterHosary;
    repository.selectedMoshaf = moshafHosaryMurattal;
  });

  tearDown(() async {
    await cubit.close();
  });

  Widget buildTestWidget({
    required ReciterSelectionCubit testCubit,
    ValueChanged<Reciter>? onReciterInfoTap,
  }) {
    return ScreenUtilInit(
      designSize: const Size(392, 852),
      builder: (context, child) => MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: BlocProvider.value(
            value: testCubit,
            child: ReciterSelectionSheet(
              onReciterInfoTap: onReciterInfoTap,
            ),
          ),
        ),
      ),
    );
  }

  group('ReciterSelectionSheet Widget Tests (Reference 18)', () {
    testWidgets('renders RTL layout with header, green close ✕, and title',
        (tester) async {
      await cubit.loadReciters();

      await tester.pumpWidget(buildTestWidget(testCubit: cubit));
      await tester.pumpAndSettle();

      // RTL Directionality check inside sheet
      final directionality = tester.widget<Directionality>(
        find.descendant(
          of: find.byType(ReciterSelectionSheet),
          matching: find.byType(Directionality),
        ).first,
      );
      expect(directionality.textDirection, equals(TextDirection.rtl));

      // Header title: "اختيار القارئ"
      expect(find.text('اختيار القارئ'), findsOneWidget);

      // Close button icon (✕)
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('excludes audio-tafsir section and contains no photo dependencies',
        (tester) async {
      await cubit.loadReciters();

      await tester.pumpWidget(buildTestWidget(testCubit: cubit));
      await tester.pumpAndSettle();

      // Audio-tafsir cancelled items must NOT be present
      expect(find.text('المختصر الصوتي'), findsNothing);
      expect(find.text('التفسير'), findsNothing);

      // No image widgets should be used for reciters (text/icon treatment only)
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('renders section header "التلاوات" and qualified reciters with speaker and info icons',
        (tester) async {
      await cubit.loadReciters();

      await tester.pumpWidget(buildTestWidget(testCubit: cubit));
      await tester.pumpAndSettle();

      // Section header "التلاوات"
      expect(find.text('التلاوات'), findsOneWidget);

      // Both qualified reciters present
      expect(find.text('محمود خليل الحصري'), findsOneWidget);
      expect(find.text('سعد الغامدي'), findsOneWidget);

      // Speaker icons on the right (at least 2 for the 2 reciter tiles)
      expect(find.byIcon(Icons.volume_up_outlined), findsAtLeastNWidgets(2));

      // Info (i) icons on the left in green (at least 2 for the 2 reciter tiles)
      expect(find.byIcon(Icons.info_outline_rounded), findsAtLeastNWidgets(2));
    });

    testWidgets('tapping info (i) icon triggers onReciterInfoTap callback',
        (tester) async {
      Reciter? tappedReciter;
      await cubit.loadReciters();

      await tester.pumpWidget(buildTestWidget(
        testCubit: cubit,
        onReciterInfoTap: (r) => tappedReciter = r,
      ));
      await tester.pumpAndSettle();

      // Tap info icon for Saad Al-Ghamadi
      final infoIcons = find.byIcon(Icons.info_outline_rounded);
      await tester.tap(infoIcons.first);
      await tester.pumpAndSettle();

      expect(tappedReciter, isNotNull);
    });

    testWidgets('tapping reciter with single moshaf selects and persists choice',
        (tester) async {
      await cubit.loadReciters();

      await tester.pumpWidget(buildTestWidget(testCubit: cubit));
      await tester.pumpAndSettle();

      // Saad Al-Ghamadi has 1 qualified moshaf (id: 30)
      await tester.tap(find.text('سعد الغامدي'));
      await tester.pumpAndSettle();

      expect(repository.savedReciterId, equals(2));
      expect(repository.savedMoshafId, equals(30));
    });

    testWidgets('tapping reciter with multiple moshafs opens edition picker',
        (tester) async {
      await cubit.loadReciters();

      await tester.pumpWidget(buildTestWidget(testCubit: cubit));
      await tester.pumpAndSettle();

      // Al-Hosary has 2 qualified moshafs (murattal and mujawwad)
      await tester.tap(find.text('محمود خليل الحصري'));
      await tester.pumpAndSettle();

      // Picker should display "اختر الرواية / المصحف"
      expect(find.text('اختر الرواية / المصحف'), findsOneWidget);
      expect(find.text('حفص عن عاصم - مرتل'), findsOneWidget);
      expect(find.text('حفص عن عاصم - مجود'), findsOneWidget);

      // Tap mujawwad
      await tester.tap(find.text('حفص عن عاصم - مجود'));
      await tester.pumpAndSettle();

      expect(repository.savedReciterId, equals(1));
      expect(repository.savedMoshafId, equals(119));
    });

    testWidgets('renders failure state and handles retry', (tester) async {
      repository.failureToThrow = const ServerFailure('تعذر الاتصال بالخادم');
      await cubit.loadReciters();

      await tester.pumpWidget(buildTestWidget(testCubit: cubit));
      await tester.pumpAndSettle();

      expect(find.text('تعذر الاتصال بالخادم'), findsOneWidget);
      expect(find.text('أعد المحاولة'), findsOneWidget);

      // Now heal the repository and tap retry
      repository.failureToThrow = null;
      await tester.tap(find.text('أعد المحاولة'));
      await tester.pumpAndSettle();

      expect(find.text('التلاوات'), findsOneWidget);
      expect(find.text('محمود خليل الحصري'), findsOneWidget);
    });

    testWidgets('renders empty state when no reciters qualify', (tester) async {
      repository.reciters = [];
      await cubit.loadReciters();

      await tester.pumpWidget(buildTestWidget(testCubit: cubit));
      await tester.pumpAndSettle();

      expect(find.text('لا يوجد قرّاء متاحون'), findsOneWidget);
      expect(find.byIcon(Icons.mic_off_outlined), findsOneWidget);
    });
  });
}
