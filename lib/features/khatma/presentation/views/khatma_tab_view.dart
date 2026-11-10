import 'package:ayaat_quran_majeed/core/di/injection.dart';
import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/cubit/khatma_cubit.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/cubit/khatma_state.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/widgets/khatma_active_view.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/widgets/khatma_empty_view.dart';
import 'package:ayaat_quran_majeed/features/khatma/presentation/widgets/new_khatma_menu_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tab 1: Khatma View.
///
/// Dispatches rendering based on [KhatmaState]:
/// - [KhatmaEmpty] -> Conforms to Reference Screenshot 10 ([KhatmaEmptyView]).
/// - [KhatmaCreating] -> Retains base tab state while [NewKhatmaMenuSheet] (Reference 06) is active.
/// - [KhatmaLoaded] -> Active Khatma dashboard (Reference 26 & 31 - Task 6.04).
/// - [KhatmaLoading] / [KhatmaInitial] -> Centered progress indicator.
class KhatmaTabView extends StatefulWidget {
  const KhatmaTabView({super.key});

  @override
  State<KhatmaTabView> createState() => _KhatmaTabViewState();
}

class _KhatmaTabViewState extends State<KhatmaTabView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // If a KhatmaCubit is already provided in the ancestry (e.g. tests or custom shell), use it.
    try {
      context.read<KhatmaCubit>();
      return const _KhatmaTabViewContent();
    } catch (_) {
      if (sl.isRegistered<KhatmaCubit>()) {
        return BlocProvider<KhatmaCubit>(
          create: (_) => sl<KhatmaCubit>()..loadKhatma(),
          child: const _KhatmaTabViewContent(),
        );
      }
      return KhatmaEmptyView(
        onStartKhatma: () => _KhatmaTabViewContent._onStartKhatmaStatic(context),
      );
    }
  }
}

class _KhatmaTabViewContent extends StatelessWidget {
  const _KhatmaTabViewContent();

  static void _onStartKhatmaStatic(BuildContext context) {
    try {
      context.read<KhatmaCubit>().startCreation();
    } catch (_) {}
    NewKhatmaMenuSheet.show(context);
  }

  void _onStartKhatma(BuildContext context) => _onStartKhatmaStatic(context);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocBuilder<KhatmaCubit, KhatmaState>(
      builder: (context, state) {
        if (state is KhatmaInitial || state is KhatmaLoading) {
          return Scaffold(
            backgroundColor: colors.scaffoldBackground,
            appBar: AppBar(
              backgroundColor: colors.scaffoldBackground,
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: false,
              title: Text(
                AppStrings.tr(AppStrings.khatmaTitle),
                style: AppTypography.displayLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ),
            body: Center(
              child: CircularProgressIndicator(color: colors.primary),
            ),
          );
        }

        if (state is KhatmaFailure) {
          return Scaffold(
            backgroundColor: colors.scaffoldBackground,
            appBar: AppBar(
              backgroundColor: colors.scaffoldBackground,
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: false,
              title: Text(
                AppStrings.tr(AppStrings.khatmaTitle),
                style: AppTypography.displayLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ),
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyLarge.copyWith(
                        color: colors.error,
                      ),
                    ),
                    SizedBox(height: AppSpacing.lg),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<KhatmaCubit>().loadKhatma(),
                      child: Text(AppStrings.tr(AppStrings.returnHome)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is KhatmaLoaded) {
          return KhatmaActiveView(loadedState: state);
        }

        // Default: KhatmaEmpty (Reference 10) or in-progress KhatmaCreating
        return KhatmaEmptyView(
          onStartKhatma: () => _onStartKhatma(context),
        );
      },
    );
  }
}
