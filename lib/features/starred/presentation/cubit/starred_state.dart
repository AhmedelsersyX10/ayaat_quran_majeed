import 'package:ayaat_quran_majeed/features/starred/domain/entities/starred_ayah_item.dart';
import 'package:ayaat_quran_majeed/features/starred/domain/entities/starred_surah_group.dart';

class StarredState {
  final bool isLoading;
  final List<StarredAyahItem> items;
  final List<StarredSurahGroup> groups;
  final Set<String> starredKeys;
  final String? errorMessage;

  const StarredState({
    required this.isLoading,
    required this.items,
    required this.groups,
    required this.starredKeys,
    this.errorMessage,
  });

  factory StarredState.initial() => const StarredState(
        isLoading: true,
        items: [],
        groups: [],
        starredKeys: {},
        errorMessage: null,
      );

  bool get isEmpty => !isLoading && items.isEmpty;

  bool isStarred(int surahNumber, int verseNumber) =>
      starredKeys.contains('$surahNumber:$verseNumber');

  StarredState copyWith({
    bool? isLoading,
    List<StarredAyahItem>? items,
    List<StarredSurahGroup>? groups,
    Set<String>? starredKeys,
    String? errorMessage,
  }) {
    return StarredState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      groups: groups ?? this.groups,
      starredKeys: starredKeys ?? this.starredKeys,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! StarredState) return false;
    return isLoading == other.isLoading &&
        errorMessage == other.errorMessage &&
        starredKeys.length == other.starredKeys.length &&
        items.length == other.items.length &&
        groups.length == other.groups.length;
  }

  @override
  int get hashCode => Object.hash(
        isLoading,
        errorMessage,
        Object.hashAll(starredKeys),
      );
}

