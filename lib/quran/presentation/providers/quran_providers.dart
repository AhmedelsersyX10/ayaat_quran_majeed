import 'package:ayaat_quran_majeed/cubit/bloc/quran_reading_cubit.dart';
import 'package:ayaat_quran_majeed/quran/data/repositories/bookmark_repository.dart';
import 'package:ayaat_quran_majeed/quran/data/repositories/quran_reading_repository.dart';
import 'package:ayaat_quran_majeed/quran/presentation/cubit/bookmark_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class QuranProviders extends StatelessWidget {
  final Widget child;

  const QuranProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<QuranReadingRepository>(
          create: (_) => const QuranReadingRepository(),
        ),
        RepositoryProvider<BookmarkRepository>(
          create: (_) => const BookmarkRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => QuranReaderCubit(
              context.read<QuranReadingRepository>(),
            )..loadInitialPosition(),
          ),
          BlocProvider(
            create: (context) => BookmarkCubit(
              context.read<BookmarkRepository>(),
            )..loadBookmarks(),
          ),
        ],
        child: child,
      ),
    );
  }
}
