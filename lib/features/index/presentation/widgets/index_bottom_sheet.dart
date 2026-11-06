import 'package:ayaat_quran_majeed/core/di/injection.dart';
import 'package:ayaat_quran_majeed/core/routing/app_routes.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/features/index/presentation/cubit/index_cubit.dart';
import 'package:ayaat_quran_majeed/features/index/presentation/widgets/index_sheet_shell.dart';
import 'package:ayaat_quran_majeed/features/index/presentation/widgets/surahs_grouped_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Modal bottom sheet launcher for the Quran Index conforming to References 03 and 04.
abstract class IndexBottomSheet {
  /// Displays the Index bottom sheet as a modal overlay over the Quran reader.
  static Future<T?> show<T>(
    BuildContext context, {
    WidgetBuilder? surahsBuilder,
    WidgetBuilder? quartersBuilder,
    Widget? surahsChild,
    Widget? quartersChild,
    double heightFactor = 0.88,
    bool showDragHandle = true,
  }) {
    final colors = context.colors;

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: colors.scrim,
      enableDrag: true,
      builder: (sheetContext) {
        return BlocProvider<IndexCubit>(
          create: (_) => sl<IndexCubit>()..loadState(),
          child: IndexSheetShell(
            surahsBuilder: surahsBuilder ??
                (surahsChild != null
                    ? null
                    : (ctx) {
                        final state = ctx.watch<IndexCubit>().state;
                        return SurahsGroupedListView(
                          groups: state.juzGroups,
                          currentReadingSurah: state.currentReadingSurah,
                          onSurahSelected: (page, _) {
                            Navigator.of(sheetContext).maybePop(page);
                            context.go('${AppRoutes.reader}?page=$page');
                          },
                          onJuzSelected: (page, _) {
                            Navigator.of(sheetContext).maybePop(page);
                            context.go('${AppRoutes.reader}?page=$page');
                          },
                        );
                      }),
            quartersBuilder: quartersBuilder,
            surahsChild: surahsChild,
            quartersChild: quartersChild,
            heightFactor: heightFactor,
            showDragHandle: showDragHandle,
            onClose: () => Navigator.of(sheetContext).maybePop(),
          ),
        );
      },
    );
  }
}
