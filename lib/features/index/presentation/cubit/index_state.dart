import 'package:ayaat_quran_majeed/features/index/domain/entities/index_tab.dart';
import 'package:ayaat_quran_majeed/features/index/domain/entities/juz_group.dart';
import 'package:flutter/foundation.dart';

/// State representation for the Quran Index feature.
class IndexState {
  /// Currently active index tab (Surahs or Quarters).
  final IndexTab selectedTab;

  /// High-level operational status of the index sheet.
  final IndexStatus status;

  /// Optional error or failure message displayed during [IndexStatus.failure].
  final String? errorMessage;

  /// The list of 30 Juz groups containing their respective starting Surahs.
  final List<JuzGroup> juzGroups;

  /// The Surah number of the user's current reading position (1 to 114).
  final int currentReadingSurah;

  const IndexState({
    this.selectedTab = IndexTab.surahs,
    this.status = IndexStatus.initial,
    this.errorMessage,
    this.juzGroups = const [],
    this.currentReadingSurah = 1,
  });

  /// Convenience getters for UI branching.
  bool get isLoading => status == IndexStatus.loading;
  bool get isSuccess => status == IndexStatus.success;
  bool get isEmpty => status == IndexStatus.empty;
  bool get isFailure => status == IndexStatus.failure;

  /// Creates a copy of this state with specified parameters overridden.
  IndexState copyWith({
    IndexTab? selectedTab,
    IndexStatus? status,
    String? errorMessage,
    List<JuzGroup>? juzGroups,
    int? currentReadingSurah,
  }) {
    return IndexState(
      selectedTab: selectedTab ?? this.selectedTab,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      juzGroups: juzGroups ?? this.juzGroups,
      currentReadingSurah: currentReadingSurah ?? this.currentReadingSurah,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IndexState &&
        other.selectedTab == selectedTab &&
        other.status == status &&
        other.errorMessage == errorMessage &&
        listEquals(other.juzGroups, juzGroups) &&
        other.currentReadingSurah == currentReadingSurah;
  }

  @override
  int get hashCode => Object.hash(
        selectedTab,
        status,
        errorMessage,
        Object.hashAll(juzGroups),
        currentReadingSurah,
      );
}
