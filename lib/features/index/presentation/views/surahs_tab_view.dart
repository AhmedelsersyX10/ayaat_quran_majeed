import 'package:ayaat_quran_majeed/core/di/injection.dart';
import 'package:ayaat_quran_majeed/core/routing/app_routes.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/features/index/domain/entities/index_tab.dart';
import 'package:ayaat_quran_majeed/features/index/domain/entities/juz_group.dart';
import 'package:ayaat_quran_majeed/features/index/domain/entities/quarter_index_item.dart';
import 'package:ayaat_quran_majeed/features/index/domain/repositories/index_repository.dart';
import 'package:ayaat_quran_majeed/features/index/presentation/cubit/index_cubit.dart';
import 'package:ayaat_quran_majeed/features/index/presentation/widgets/index_sheet_shell.dart';
import 'package:ayaat_quran_majeed/features/index/presentation/widgets/quarters_list_view.dart';
import 'package:ayaat_quran_majeed/features/index/presentation/widgets/surahs_grouped_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Tab 0: Surahs & Quarters Index View.
/// Conforms to reference screenshots 03_index_surahs_tab and 04_index_quarters_tab.
/// Uses [IndexSheetShell] driven by [IndexCubit], rendering [SurahsGroupedListView] for Tab 0
/// and [QuartersListView] for Tab 1.
class SurahsTabView extends StatelessWidget {
  const SurahsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<IndexCubit>(
      create: (_) => sl.isRegistered<IndexCubit>()
          ? (sl<IndexCubit>()..loadState())
          : (IndexCubit(const _FallbackIndexRepository())..loadState()),
      child: const _SurahsTabViewContent(),
    );
  }
}

class _FallbackIndexRepository implements IndexRepository {
  const _FallbackIndexRepository();

  @override
  Future<IndexTab> getActiveTab() async => IndexTab.surahs;

  @override
  Future<void> setActiveTab(IndexTab tab) async {}

  @override
  Future<List<JuzGroup>> getSurahsGroupedByJuz() async => const [];

  @override
  Future<int> getCurrentReadingSurah() async => 1;

  @override
  Future<List<QuarterIndexItem>> getQuarters() async => const [];

  @override
  Future<int> getCurrentReadingQuarter() async => 1;
}

class _SurahsTabViewContent extends StatefulWidget {
  const _SurahsTabViewContent();

  @override
  State<_SurahsTabViewContent> createState() => _SurahsTabViewContentState();
}

class _SurahsTabViewContentState extends State<_SurahsTabViewContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void _navigateToPage(int pageNumber) {
    if (context.mounted) {
      context.go('${AppRoutes.reader}?page=$pageNumber');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      body: IndexSheetShell(
        heightFactor: 1.0,
        showDragHandle: false,
        surahsBuilder: (ctx) {
          final state = ctx.watch<IndexCubit>().state;
          return SurahsGroupedListView(
            groups: state.juzGroups,
            currentReadingSurah: state.currentReadingSurah,
            onSurahSelected: (page, _) => _navigateToPage(page),
            onJuzSelected: (page, _) => _navigateToPage(page),
          );
        },
        quartersBuilder: (ctx) {
          final state = ctx.watch<IndexCubit>().state;
          return QuartersListView(
            quarters: state.quarters,
            currentReadingQuarter: state.currentReadingQuarter,
            onQuarterSelected: (page, _) => _navigateToPage(page),
          );
        },
      ),
    );
  }
}
