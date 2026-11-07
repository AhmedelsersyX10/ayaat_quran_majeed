import 'package:ayaat_quran_majeed/core/theme/app_colors.dart';
import 'package:ayaat_quran_majeed/features/search/domain/entities/search_navigation_target.dart';
import 'package:ayaat_quran_majeed/features/search/presentation/cubit/search_cubit.dart';
import 'package:ayaat_quran_majeed/features/search/presentation/cubit/search_state.dart';
import 'package:ayaat_quran_majeed/features/search/presentation/widgets/search_empty_state.dart';
import 'package:ayaat_quran_majeed/features/search/presentation/widgets/search_page_card.dart';
import 'package:ayaat_quran_majeed/features/search/presentation/widgets/search_results_counter.dart';
import 'package:ayaat_quran_majeed/features/search/presentation/widgets/search_top_bar.dart';
import 'package:ayaat_quran_majeed/features/search/presentation/widgets/search_verse_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Full screen search view matching reference screenshots 15 & 21.
class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onBack() {
    _focusNode.unfocus();
    Navigator.of(context).pop();
  }

  void _onSelectTarget(SearchNavigationTarget target) {
    _focusNode.unfocus();
    Navigator.of(context).pop(target);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            SearchTopBar(
              controller: _searchController,
              focusNode: _focusNode,
              onChanged: (query) {
                context.read<SearchCubit>().onQueryChanged(query);
              },
              onSubmitted: (query) {
                final cubit = context.read<SearchCubit>();
                cubit.searchImmediate(query);
              },
              onClear: () {
                _searchController.clear();
                context.read<SearchCubit>().clearSearch();
                _focusNode.requestFocus();
              },
              onBack: _onBack,
            ),
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  if (state is SearchLoading) {
                    return Container(
                      color: AppColors.mushafPaperLight,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  }

                  if (state is SearchError) {
                    return Container(
                      color: AppColors.mushafPaperLight,
                      child: SearchEmptyState(message: state.message),
                    );
                  }

                  if (state is SearchLoaded) {
                    final result = state.result;

                    if (result.isEmpty) {
                      return Container(
                        color: AppColors.mushafPaperLight,
                        child: const SearchEmptyState(),
                      );
                    }

                    return Container(
                      color: AppColors.mushafPaperLight,
                      child: ListView(
                        padding: EdgeInsets.only(bottom: 24.h),
                        children: [
                          if (result.pageResult != null)
                            SearchPageCard(
                              pageResult: result.pageResult!,
                              onTap: () {
                                _onSelectTarget(
                                  SearchNavigationTarget(
                                    pageNumber: result.pageResult!.pageNumber,
                                    surahNumber: result.pageResult!.surahNumber,
                                    ayahNumber: result.pageResult!.verseNumber,
                                  ),
                                );
                              },
                            ),
                          if (result.verses.isNotEmpty) ...[
                            SearchResultsCounter(count: result.verses.length),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: result.verses.length,
                              separatorBuilder: (_, __) => const Divider(
                                height: 1,
                                thickness: 1,
                                color: AppColors.divider,
                              ),
                              itemBuilder: (context, index) {
                                final verse = result.verses[index];
                                return SearchVerseTile(
                                  result: verse,
                                  onTap: () {
                                    _onSelectTarget(
                                      SearchNavigationTarget(
                                        pageNumber: verse.pageNumber,
                                        surahNumber: verse.surahNumber,
                                        ayahNumber: verse.verseNumber,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  // Initial empty state matching Screenshot 21:
                  // Scrim overlay over the underlying mushaf reader page
                  return GestureDetector(
                    onTap: _onBack,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      color: AppColors.scrim,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
