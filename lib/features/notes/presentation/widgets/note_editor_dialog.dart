import 'package:ayaat_quran_majeed/core/di/injection.dart';
import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_card.dart';
import 'package:ayaat_quran_majeed/features/notes/domain/entities/note_item.dart';
import 'package:ayaat_quran_majeed/features/notes/presentation/cubit/notes_cubit.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';

/// Modal dialog for authoring, editing, and sharing notes on a specific Ayah.
/// Pixel-faithful implementation matching reference screenshot 29_note_editor_dialog.
class NoteEditorDialog extends StatefulWidget {
  final int surahNumber;
  final int verseNumber;
  final int? pageNumber;
  final NoteItem? existingNote;

  const NoteEditorDialog({
    super.key,
    required this.surahNumber,
    required this.verseNumber,
    this.pageNumber,
    this.existingNote,
  });

  /// Standard helper to show the dialog over the mushaf reader.
  static Future<void> show({
    required BuildContext context,
    required int surahNumber,
    required int verseNumber,
    int? pageNumber,
    NoteItem? existingNote,
  }) {
    NotesCubit? cubit;
    try {
      cubit = context.read<NotesCubit>();
    } catch (_) {}

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        final content = NoteEditorDialog(
          surahNumber: surahNumber,
          verseNumber: verseNumber,
          pageNumber: pageNumber,
          existingNote: existingNote,
        );
        if (cubit != null) {
          return BlocProvider<NotesCubit>.value(
            value: cubit,
            child: content,
          );
        }
        return content;
      },
    );
  }

  @override
  State<NoteEditorDialog> createState() => _NoteEditorDialogState();
}

class _NoteEditorDialogState extends State<NoteEditorDialog> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  final QuranMetadataService _meta = const QuranMetadataService();

  String? _activeNoteId;
  late String _surahName;
  late String _ayahText;
  late int _resolvedPage;

  @override
  void initState() {
    super.initState();
    _activeNoteId = widget.existingNote?.id;
    _controller = TextEditingController(text: widget.existingNote?.noteText ?? '');
    _focusNode = FocusNode();

    _surahName = _meta.getSurahNameArabic(widget.surahNumber);
    _ayahText = _meta.getVerse(widget.surahNumber, widget.verseNumber);
    _resolvedPage = widget.pageNumber ??
        widget.existingNote?.pageNumber ??
        _meta.getPageNumber(widget.surahNumber, widget.verseNumber);

    // Auto-focus text field after frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _saveCurrentNote() async {
    final text = _controller.text.trim();
    if (!mounted) return;

    NotesCubit? cubit;
    try {
      cubit = context.read<NotesCubit>();
    } catch (_) {
      if (sl.isRegistered<NotesCubit>()) {
        cubit = sl<NotesCubit>();
      }
    }
    if (cubit == null) return;

    if (text.isEmpty) {
      if (_activeNoteId != null) {
        await cubit.deleteNote(_activeNoteId!);
        _activeNoteId = null;
      }
    } else {
      final saved = await cubit.addOrUpdateNote(
        id: _activeNoteId,
        surahNumber: widget.surahNumber,
        verseNumber: widget.verseNumber,
        pageNumber: _resolvedPage,
        noteText: text,
      );
      if (saved != null) {
        _activeNoteId = saved.id;
      }
    }
  }

  Future<void> _onAddAnotherNote() async {
    await _saveCurrentNote();
    if (!mounted) return;

    setState(() {
      _activeNoteId = null;
      _controller.clear();
    });
    _focusNode.requestFocus();
  }

  void _onShare() {
    final noteText = _controller.text.trim();
    final buffer = StringBuffer();

    if (noteText.isNotEmpty) {
      buffer.writeln(noteText);
      buffer.writeln();
    }
    buffer.writeln('{$_ayahText}');
    buffer.writeln();
    buffer.writeln(
      '[${formatPageAyahLabel(surahName: _surahName, ayahNumber: widget.verseNumber, pageNumber: _resolvedPage)}]',
    );

    Share.share(buffer.toString());
  }

  Future<void> _onClose() async {
    await _saveCurrentNote();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final arabicVerseNum = toArabicDigits(widget.verseNumber);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _saveCurrentNote();
        }
      },
      child: Dialog(
        backgroundColor: colors.surface,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.radiusLg,
        ),
        insetPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 420.w,
            maxHeight: 520.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header Row (Ref 29: Surah & Verse on right, 3 green action icons on left)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                child: Row(
                  children: [
                    // Action Icons (left side in RTL)
                    // (1) Close button X
                    IconButton(
                      icon: const Icon(Icons.close),
                      iconSize: 22.sp,
                      color: colors.primary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: _onClose,
                      tooltip: AppStrings.tr(AppStrings.cancel),
                    ),
                    SizedBox(width: 14.w),
                    // (2) Share button
                    IconButton(
                      icon: const Icon(Icons.share_outlined),
                      iconSize: 22.sp,
                      color: colors.primary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: _onShare,
                      tooltip: AppStrings.tr(AppStrings.shareNote),
                    ),
                    SizedBox(width: 14.w),
                    // (3) Add another note on same Ayah (+)
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      iconSize: 22.sp,
                      color: colors.primary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: _onAddAnotherNote,
                      tooltip: AppStrings.tr(AppStrings.addNote),
                    ),
                    const Spacer(),
                    // Title: e.g. "البقرة: ٤" (right side in RTL)
                    Text(
                      '$_surahName: $arabicVerseNum',
                      style: AppTypography.titleLarge.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),

              Divider(
                color: colors.divider.withOpacity(0.4),
                height: 1,
                thickness: 0.8,
              ),

              // 2. Editor Body (Text Field + Quoted Ayah)
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // User note editable text field
                      TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        maxLines: null,
                        minLines: 3,
                        keyboardType: TextInputType.multiline,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: AppTypography.bodyLarge.copyWith(
                          color: colors.textPrimary,
                          height: 1.6,
                        ),
                        decoration: InputDecoration(
                          hintText: AppStrings.tr(AppStrings.noteHint),
                          hintStyle: AppTypography.bodyMedium.copyWith(
                            color: colors.textSecondary.withOpacity(0.6),
                          ),
                          hintTextDirection: TextDirection.rtl,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),

                      SizedBox(height: 12.h),

                      // Quoted Ayah presentation matching Screen 29
                      AppCard.quote(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        child: Text(
                          '{$_ayahText}',
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: AppTypography.quranText.copyWith(
                            fontSize: 16.sp,
                            height: 1.8,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
