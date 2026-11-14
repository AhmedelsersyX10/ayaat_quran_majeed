import 'dart:ui';

import '../../domain/entities/bookmark_item.dart';

/// Extension providing Flutter [Color] projection from pure domain [BookmarkItem].
extension BookmarkItemColor on BookmarkItem {
  Color get color => Color(colorValue);
}
