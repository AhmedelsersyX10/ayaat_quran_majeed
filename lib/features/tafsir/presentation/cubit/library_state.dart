import 'package:flutter/foundation.dart';

import '../../domain/entities/tafsir_book.dart';
import '../../domain/entities/tafsir_category.dart';

enum LibraryStatus {
  initial,
  loading,
  loaded,
  failure,
}

/// State representation for Library Editor ("تحرير المكتبة" - Reference 34).
class LibraryState {
  final LibraryStatus status;
  final List<TafsirBook> myLibraryBooks;
  final List<TafsirBook> availableBooks;
  final Map<String, double> downloadingProgress;
  final Map<String, String> failedDownloads;
  final String? errorMessage;
  final String? userNotice;

  const LibraryState({
    required this.status,
    this.myLibraryBooks = const [],
    this.availableBooks = const [],
    this.downloadingProgress = const {},
    this.failedDownloads = const {},
    this.errorMessage,
    this.userNotice,
  });

  factory LibraryState.initial() {
    return const LibraryState(
      status: LibraryStatus.initial,
      myLibraryBooks: [],
      availableBooks: [],
      downloadingProgress: {},
      failedDownloads: {},
      errorMessage: null,
      userNotice: null,
    );
  }

  /// Groups available books that are NOT currently in [myLibraryBooks] by [TafsirCategory].
  Map<TafsirCategory, List<TafsirBook>> get categorizedAvailableBooks {
    final myIds = myLibraryBooks.map((b) => b.id).toSet();
    final Map<TafsirCategory, List<TafsirBook>> categorized = {
      for (final cat in TafsirCategory.values) cat: [],
    };

    for (final book in availableBooks) {
      if (!myIds.contains(book.id)) {
        categorized[book.category]?.add(book);
      }
    }

    return categorized;
  }

  LibraryState copyWith({
    LibraryStatus? status,
    List<TafsirBook>? myLibraryBooks,
    List<TafsirBook>? availableBooks,
    Map<String, double>? downloadingProgress,
    Map<String, String>? failedDownloads,
    String? errorMessage,
    String? userNotice,
    bool clearError = false,
    bool clearNotice = false,
  }) {
    return LibraryState(
      status: status ?? this.status,
      myLibraryBooks: myLibraryBooks ?? this.myLibraryBooks,
      availableBooks: availableBooks ?? this.availableBooks,
      downloadingProgress: downloadingProgress ?? this.downloadingProgress,
      failedDownloads: failedDownloads ?? this.failedDownloads,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      userNotice: clearNotice ? null : (userNotice ?? this.userNotice),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibraryState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          listEquals(myLibraryBooks, other.myLibraryBooks) &&
          listEquals(availableBooks, other.availableBooks) &&
          mapEquals(downloadingProgress, other.downloadingProgress) &&
          mapEquals(failedDownloads, other.failedDownloads) &&
          errorMessage == other.errorMessage &&
          userNotice == other.userNotice;

  @override
  int get hashCode =>
      status.hashCode ^
      Object.hashAll(myLibraryBooks) ^
      Object.hashAll(availableBooks) ^
      downloadingProgress.hashCode ^
      failedDownloads.hashCode ^
      errorMessage.hashCode ^
      userNotice.hashCode;
}
