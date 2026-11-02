/// Helper for Arabic text normalization, ensuring accurate alphabetical sorting
/// and search matching by unifying hamzas, yaa/alif maqsura, and taa marbuta/haa.
String normalizeArabic(String s) => s
    .replaceAll(RegExp('[أإآ]'), 'ا')
    .replaceAll('ى', 'ي')
    .replaceAll('ة', 'ه');

/// Alias for concise sorting code mirroring the requested convention.
String normArabic(String s) => normalizeArabic(s);
