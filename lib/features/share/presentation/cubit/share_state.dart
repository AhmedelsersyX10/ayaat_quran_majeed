import 'package:flutter/material.dart';
import '../../domain/entities/share_params.dart';
import '../theme/share_card_theme.dart';

enum ShareActionStatus {
  idle,
  loadingTafsir,
  sharingText,
  sharingImage,
  savingToGallery,
  shareSuccess,
  saveSuccess,
  failure,
}

class ShareState {
  final ShareParams params;
  final ShareCardTheme cardTheme;
  final double fontSize;
  final TextAlign alignment;
  final ShareActionStatus status;
  final String? errorMessage;
  final String? successMessage;
  final int totalVersesInSurah;

  const ShareState({
    required this.params,
    this.cardTheme = ShareCardTheme.defaultTheme,
    this.fontSize = 22.0,
    this.alignment = TextAlign.center,
    this.status = ShareActionStatus.idle,
    this.errorMessage,
    this.successMessage,
    this.totalVersesInSurah = 1,
  });

  bool get isLoading =>
      status == ShareActionStatus.loadingTafsir ||
      status == ShareActionStatus.sharingText ||
      status == ShareActionStatus.sharingImage ||
      status == ShareActionStatus.savingToGallery;

  ShareState copyWith({
    ShareParams? params,
    ShareCardTheme? cardTheme,
    double? fontSize,
    TextAlign? alignment,
    ShareActionStatus? status,
    String? errorMessage,
    String? successMessage,
    int? totalVersesInSurah,
  }) {
    return ShareState(
      params: params ?? this.params,
      cardTheme: cardTheme ?? this.cardTheme,
      fontSize: fontSize ?? this.fontSize,
      alignment: alignment ?? this.alignment,
      status: status ?? this.status,
      errorMessage: errorMessage,
      successMessage: successMessage,
      totalVersesInSurah: totalVersesInSurah ?? this.totalVersesInSurah,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShareState &&
        other.params == params &&
        other.cardTheme == cardTheme &&
        other.fontSize == fontSize &&
        other.alignment == alignment &&
        other.status == status &&
        other.errorMessage == errorMessage &&
        other.successMessage == successMessage &&
        other.totalVersesInSurah == totalVersesInSurah;
  }

  @override
  int get hashCode => Object.hash(
    params,
    cardTheme,
    fontSize,
    alignment,
    status,
    errorMessage,
    successMessage,
    totalVersesInSurah,
  );
}
