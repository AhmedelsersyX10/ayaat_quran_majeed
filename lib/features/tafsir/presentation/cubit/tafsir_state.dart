import '../../domain/entities/ayah_tafsir.dart';
import '../../domain/entities/tafsir_book.dart';

enum TafsirStatus {
  initial,
  loading,
  loaded,
  empty,
  failure,
}

/// State representation for Tafsir Mode.
class TafsirState {
  final TafsirStatus status;
  final int pageNumber;
  final TafsirBook? selectedBook;
  final List<AyahTafsir> verses;
  final List<TafsirBook> availableBooks;
  final String? errorMessage;

  const TafsirState({
    required this.status,
    required this.pageNumber,
    this.selectedBook,
    this.verses = const [],
    this.availableBooks = const [],
    this.errorMessage,
  });

  factory TafsirState.initial({int initialPage = 1}) {
    return TafsirState(
      status: TafsirStatus.initial,
      pageNumber: initialPage,
      selectedBook: null,
      verses: const [],
      availableBooks: const [],
      errorMessage: null,
    );
  }

  TafsirState copyWith({
    TafsirStatus? status,
    int? pageNumber,
    TafsirBook? selectedBook,
    List<AyahTafsir>? verses,
    List<TafsirBook>? availableBooks,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TafsirState(
      status: status ?? this.status,
      pageNumber: pageNumber ?? this.pageNumber,
      selectedBook: selectedBook ?? this.selectedBook,
      verses: verses ?? this.verses,
      availableBooks: availableBooks ?? this.availableBooks,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TafsirState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          pageNumber == other.pageNumber &&
          selectedBook == other.selectedBook &&
          errorMessage == other.errorMessage &&
          verses.length == other.verses.length;

  @override
  int get hashCode =>
      status.hashCode ^
      pageNumber.hashCode ^
      selectedBook.hashCode ^
      errorMessage.hashCode ^
      verses.length.hashCode;
}

