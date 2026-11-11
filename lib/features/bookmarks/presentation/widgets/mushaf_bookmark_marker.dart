import 'package:ayaat_quran_majeed/features/bookmarks/domain/entities/bookmark_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Decorative bookmark ribbon marker displayed on the page edge in the Mushaf reader.
/// Matches references 11 and 27.
class MushafBookmarkMarker extends StatelessWidget {
  final List<BookmarkItem> bookmarks;
  final VoidCallback? onTap;

  const MushafBookmarkMarker({super.key, required this.bookmarks, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (bookmarks.isEmpty) return const SizedBox.shrink();

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: bookmarks.map((b) => _buildSingleRibbon(b)).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildSingleRibbon(BookmarkItem bookmark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      width: 14.w,
      height: 28.h,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipPath(
        clipper: BookmarkRibbonClipper(),
        child: Container(color: bookmark.color),
      ),
    );
  }
}

/// Creates a standard ribbon tab with a V-notch cut at the bottom.
class BookmarkRibbonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width / 2, size.height - (size.width * 0.45));
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
