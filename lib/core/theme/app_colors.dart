import 'package:flutter/material.dart';

/// Design tokens for colors extracted and measured directly from the
/// 39 reference screenshots and playback video in `docs/design/reference/`.
abstract class AppColors {
  // --- Primary Brand Green Palette ---
  /// Main green used in primary CTA buttons, active tabs, checkmarks, steppers (#007330).
  static const Color primary = Color(0xFF007330);

  /// Dark green used for pressed button states and active khatma banner (#005C27).
  static const Color primaryDark = Color(0xFF005C27);

  /// Medium sage green used for active switch tracks and secondary highlights (#519D6F).
  static const Color primaryLight = Color(0xFF519D6F);

  /// Muted green used for subtle borders and secondary indicators (#7AAB8B).
  static const Color primaryMuted = Color(0xFF7AAB8B);

  /// Soft pale green container used in the note editor quoted ayah banner (#D6EED8).
  static const Color primaryContainer = Color(0xFFD6EED8);

  // --- Backgrounds & Surfaces ---
  /// Warm sand/parchment background for general pages, appbars, and headers (#F4EFE9).
  static const Color scaffoldLight = Color(0xFFF4EFE9);

  /// Warm white surface used for cards, bottom sheets interior, and dialogs (#FFFCF7).
  static const Color surface = Color(0xFFFFFCF7);

  /// Warm cream background of the bottom navigation bar (#FEFAF1).
  static const Color bottomNavBackground = Color(0xFFFEFAF1);

  /// Reader toolbar and floating player surface (#F1E9DC).
  static const Color readerSurface = Color(0xFFF1E9DC);

  /// Mushaf reading page paper color (#FFF9F1).
  static const Color mushafPaperLight = Color(0xFFFFF9F1);

  /// Ayah card header background in Tafsir mode (#F7EBDD).
  static const Color ayahHeaderSurface = Color(0xFFF7EBDD);

  /// Modal bottom sheet and dialog barrier scrim (45% black, blending to #ADAAA5).
  static const Color scrim = Color(0x73000000);

  // --- Dark Mode Backgrounds (Reserved for future dark mode support) ---
  static const Color scaffoldDark = Color(0xFF1A1C1A);
  static const Color mushafPaperDark = Color(0xFF222222);
  static const Color surfaceDark = Color(0xFF292C31);
  static const Color deepNavyBlack = Color(0xFF11121B);

  // --- Text & Typography ---
  /// Primary text color: warm charcoal black (#201C19).
  static const Color textPrimary = Color(0xFF201C19);

  /// Secondary text color: medium warm gray (#656460) for subtitles, metadata.
  static const Color textSecondary = Color(0xFF656460);

  /// Muted text & placeholder color (#9B9893) for drag handle, hint texts, faded ayah preview.
  static const Color textMuted = Color(0xFF9B9893);

  /// White text for primary buttons, active tab capsules, and checkmark icons (#FFFFFF).
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  /// Deep warm brown for Tafsir explanation text (#422E23).
  static const Color textTafsir = Color(0xFF422E23);

  // --- Borders & Dividers ---
  /// Divider line color between list rows and sections (#E6DED3).
  static const Color divider = Color(0xFFE6DED3);

  /// Subtle border for containers, cards, and segmented tab shells (#DDD6CA).
  static const Color border = Color(0xFFDDD6CA);

  // --- 4 Standard Bookmarks Palette (Screens 11 & 27) ---
  /// Yellow / Gold ribbon bookmark (#D7AC3C).
  static const Color bookmarkYellow = Color(0xFFD7AC3C);

  /// Sage Green ribbon bookmark (#62A77B).
  static const Color bookmarkGreen = Color(0xFF62A77B);

  /// Sky Blue ribbon bookmark (#218FC9).
  static const Color bookmarkBlue = Color(0xFF218FC9);

  /// Berry Pink / Soft Red ribbon bookmark (#C9484A).
  static const Color bookmarkPink = Color(0xFFC9484A);

  // --- Highlights & Tints ---
  /// Semi-transparent green tint for follow-along audio playback highlight (Video 37).
  static const Color playbackHighlight = Color(0x33007330);

  /// Semi-transparent sage tint on mushaf verses that have notes (Screen 29).
  static const Color noteHighlight = Color(0x33D6EED8);

  // --- Status & Feedback ---
  /// Error and destructive actions (e.g. Delete Khatma, Red minus badge) (#D32F2F).
  static const Color error = Color(0xFFD32F2F);
  static const Color destructive = Color(0xFFD32F2F);

  /// Success state and download completion checkmarks (#007330).
  static const Color success = Color(0xFF007330);

  // --- Backward-Compatibility Aliases ---
  static const Color paperBeige = scaffoldLight;
  static const Color softOffWhite = surface;
  static const Color charcoalDarkGray = textPrimary;
  static const Color mediumGray = textSecondary;
  static const Color lightGray = divider;
  static const Color mutedGreen = primaryLight;
  static const Color tealBlue = bookmarkBlue;
  static const Color darkWarmBrown = textTafsir;
}
