// ignore_for_file: file_names

import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';

/// Legacy bridge forwarding to the centralized [toArabicDigits] formatter.
///
/// Prevents runtime FormatExceptions on non-digit characters and supports
/// backward compatibility across legacy views until full rebuild.
String convertToArabicNumber(String number) {
  return toArabicDigits(number);
}
