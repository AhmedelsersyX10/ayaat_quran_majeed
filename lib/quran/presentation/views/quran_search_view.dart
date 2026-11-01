import 'package:ayaat_quran_majeed/GlobalHelpers/constants.dart';
import 'package:ayaat_quran_majeed/GlobalHelpers/hive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import '../cubit/quran_search_cubit.dart';
import '../widgets/search/quran_search_result_card.dart';

class QuranSearchView extends StatefulWidget {
  const QuranSearchView({Key? key}) : super(key: key);

  @override
  State<QuranSearchView> createState() => _QuranSearchViewState();
}

class _QuranSearchViewState extends State<QuranSearchView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Request focus after the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _onSearchChanged() {
    context.read<QuranSearchCubit>().search(_searchController.text);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final int colorIndex = getValue("quranPageolorsIndex") ?? 0;
    final primaryColor = secondaryColors[colorIndex];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          style: TextStyle(
            fontFamily: 'cairo',
            fontSize: 16.sp,
            color: theme.textTheme.bodyLarge?.color,
          ),
          decoration: InputDecoration(
            hintText: 'ابحث في القرآن الكريم...',
            hintStyle: TextStyle(
              fontFamily: 'cairo',
              fontSize: 16.sp,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
            ),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchController,
              builder: (context, value, child) {
                return value.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: theme.iconTheme.color, size: 20.sp),
                        onPressed: () {
                          _searchController.clear();
                          _focusNode.requestFocus();
                        },
                      )
                    : const SizedBox.shrink();
              },
            ),
          ),
          textDirection: TextDirection.rtl,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: theme.dividerColor.withOpacity(0.1),
            height: 1.0,
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocBuilder<QuranSearchCubit, QuranSearchState>(
          builder: (context, state) {
            Widget child;
            if (state is QuranSearchLoading) {
              child = Center(
                key: const ValueKey('loading'),
                child: CircularProgressIndicator(color: primaryColor),
              );
            } else if (state is QuranSearchError) {
              child = Center(
                key: const ValueKey('error'),
                child: Text(
                  'حدث خطأ أثناء البحث',
                  style: TextStyle(fontFamily: 'cairo', fontSize: 16.sp, color: Colors.red),
                ),
              );
            } else if (state is QuranSearchLoaded) {
              if (state.results.isEmpty) {
                child = _buildEmptyState(theme, 'لا توجد نتائج مطابقة لبحثك', const ValueKey('no_results'));
              } else {
                child = ListView.builder(
                  key: const ValueKey('results'),
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  itemCount: state.results.length,
                  itemBuilder: (context, index) {
                    final result = state.results[index];
                    return QuranSearchResultCard(
                      result: result,
                      query: _searchController.text,
                      onTap: () {
                        _focusNode.unfocus();
                        Navigator.pop(context, result);
                      },
                    );
                  },
                );
              }
            } else {
              child = _buildEmptyState(theme, 'اكتب للبحث في آيات القرآن الكريم', const ValueKey('initial'));
            }

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              child: child,
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, String message, Key key) {
    return Center(
      key: key,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_rounded,
            size: 64.sp,
            color: theme.dividerColor.withOpacity(0.2),
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(
              fontFamily: 'cairo',
              fontSize: 16.sp,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
