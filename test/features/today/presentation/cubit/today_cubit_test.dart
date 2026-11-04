import 'package:ayaat_quran_majeed/core/errors/failure.dart';
import 'package:ayaat_quran_majeed/features/today/domain/entities/today_ayah.dart';
import 'package:ayaat_quran_majeed/features/today/domain/repositories/today_repository.dart';
import 'package:ayaat_quran_majeed/features/today/presentation/cubit/today_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class MockTodayRepository implements TodayRepository {
  TodayAyah? stubbedAyah;
  Object? exceptionToThrow;

  @override
  Future<TodayAyah> getTodayAyah({DateTime? forDate}) async {
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    return stubbedAyah ??
        TodayAyah(
          surahNumber: 2,
          ayahNumber: 172,
          ayahText:
              'يَٰٓأَيُّهَا ٱلَّذِينَ ءَامَنُوا۟ كُلُوا۟ مِن طَيِّبَٰتِ مَا رَزَقْنَٰكُمْ',
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
  late MockTodayRepository repository;
  late TodayCubit cubit;

  setUp(() {
    repository = MockTodayRepository();
    cubit = TodayCubit(repository);
  });

  tearDown(() {
    cubit.close();
  });

  group('TodayCubit Unit Tests', () {
    test('initial state is TodayInitial', () {
      expect(cubit.state, isA<TodayInitial>());
    });

    test(
      'loadTodayAyah emits [TodayLoading, TodaySuccess] on success',
      () async {
        final states = <TodayState>[];
        cubit.stream.listen(states.add);

        await cubit.loadTodayAyah();
        await pumpEventQueue();

        expect(states.length, 2);
        expect(states[0], isA<TodayLoading>());
        expect(states[1], isA<TodaySuccess>());

        final success = states[1] as TodaySuccess;
        expect(success.ayah.surahNumber, 2);
        expect(success.ayah.ayahNumber, 172);
        expect(success.ayah.hijriDay, '١٩');
      },
    );

    test(
      'loadTodayAyah emits [TodayLoading, TodayFailure] on Failure without leaking exception',
      () async {
        repository.exceptionToThrow = const GeneralFailure(
          'خطأ مخصص في البيانات',
        );

        final states = <TodayState>[];
        cubit.stream.listen(states.add);

        await cubit.loadTodayAyah();
        await pumpEventQueue();

        expect(states.length, 2);
        expect(states[0], isA<TodayLoading>());
        expect(states[1], isA<TodayFailure>());

        final failure = states[1] as TodayFailure;
        expect(failure.message, 'خطأ مخصص في البيانات');
        expect(failure.message.contains('Exception'), isFalse);
      },
    );

    test('loadTodayAyah handles generic unexpected exception safely', () async {
      repository.exceptionToThrow = Exception('Internal db crash');

      final states = <TodayState>[];
      cubit.stream.listen(states.add);

      await cubit.loadTodayAyah();
      await pumpEventQueue();

      expect(states.length, 2);
      expect(states[0], isA<TodayLoading>());
      expect(states[1], isA<TodayFailure>());

      final failure = states[1] as TodayFailure;
      expect(failure.message, 'تعذر تحميل آية اليوم');
      expect(failure.message.contains('Exception'), isFalse);
    });
  });
}
