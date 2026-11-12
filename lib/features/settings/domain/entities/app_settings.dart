/// Immutable domain entity representing user-configurable application settings.
class AppSettings {
  final bool keepScreenAwake;
  final int hijriOffset;
  final double mushafFontSize;
  final bool isMushafTextSizingSupported;

  const AppSettings({
    this.keepScreenAwake = true,
    this.hijriOffset = 0,
    this.mushafFontSize = 23.0,
    this.isMushafTextSizingSupported = false,
  });

  AppSettings copyWith({
    bool? keepScreenAwake,
    int? hijriOffset,
    double? mushafFontSize,
    bool? isMushafTextSizingSupported,
  }) {
    return AppSettings(
      keepScreenAwake: keepScreenAwake ?? this.keepScreenAwake,
      hijriOffset: hijriOffset ?? this.hijriOffset,
      mushafFontSize: mushafFontSize ?? this.mushafFontSize,
      isMushafTextSizingSupported:
          isMushafTextSizingSupported ?? this.isMushafTextSizingSupported,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          runtimeType == other.runtimeType &&
          keepScreenAwake == other.keepScreenAwake &&
          hijriOffset == other.hijriOffset &&
          mushafFontSize == other.mushafFontSize &&
          isMushafTextSizingSupported == other.isMushafTextSizingSupported;

  @override
  int get hashCode =>
      keepScreenAwake.hashCode ^
      hijriOffset.hashCode ^
      mushafFontSize.hashCode ^
      isMushafTextSizingSupported.hashCode;

  @override
  String toString() {
    return 'AppSettings('
        'keepScreenAwake: $keepScreenAwake, '
        'hijriOffset: $hijriOffset, '
        'mushafFontSize: $mushafFontSize, '
        'isMushafTextSizingSupported: $isMushafTextSizingSupported)';
  }
}
