import 'dart:math';

import 'package:ayaat_quran_majeed/core/localization/app_strings.dart';
import 'package:ayaat_quran_majeed/core/localization/arabic_numbers.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum _TimePickerMode { hour, minute }

/// Shows the custom Arabic Time Picker dialog matching Reference Screenshot 23.
Future<TimeOfDay?> showKhatmaTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) {
  return showDialog<TimeOfDay>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) =>
        KhatmaTimePickerDialog(initialTime: initialTime),
  );
}

/// Custom Arabic Time Picker Dialog matching Reference Screenshot 23.
///
/// Features:
/// - Rounded cream dialog container.
/// - Top row with vertical AM/PM (`ص` / `م`) toggle, Hour box, Minute box, and colon separator.
/// - Analog clock dial face with Eastern Arabic numerals (`١`–`١٢` / `٠٠`–`٥٥`).
/// - Interactive touch and drag gesture recognition with live hand and selector knob tracking.
/// - Bottom action buttons: "إلغاء" and "حَسَنًا".
class KhatmaTimePickerDialog extends StatefulWidget {
  final TimeOfDay initialTime;

  const KhatmaTimePickerDialog({
    super.key,
    required this.initialTime,
  });

  @override
  State<KhatmaTimePickerDialog> createState() => _KhatmaTimePickerDialogState();
}

class _KhatmaTimePickerDialogState extends State<KhatmaTimePickerDialog> {
  late DayPeriod _period;
  late int _selectedHour; // 1 to 12
  late int _selectedMinute; // 0 to 59
  _TimePickerMode _mode = _TimePickerMode.hour;

  @override
  void initState() {
    super.initState();
    _period = widget.initialTime.period;
    final h = widget.initialTime.hourOfPeriod;
    _selectedHour = h == 0 ? 12 : h;
    _selectedMinute = widget.initialTime.minute;
  }

  void _onDialInteraction(Offset localPosition, double size) {
    final center = Offset(size / 2, size / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;

    // Angle in radians measured from 12 o'clock (-pi/2) clockwise
    double angle = atan2(dy, dx) + (pi / 2);
    if (angle < 0) {
      angle += 2 * pi;
    }

    setState(() {
      if (_mode == _TimePickerMode.hour) {
        int rawHour = ((angle / (2 * pi)) * 12).round() % 12;
        _selectedHour = rawHour == 0 ? 12 : rawHour;
      } else {
        _selectedMinute = ((angle / (2 * pi)) * 60).round() % 60;
      }
    });
  }

  void _confirm() {
    final hour24 = _period == DayPeriod.pm
        ? (_selectedHour % 12) + 12
        : (_selectedHour % 12);
    Navigator.of(context).pop(TimeOfDay(hour: hour24, minute: _selectedMinute));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dialSize = 210.w;

    return Dialog(
      backgroundColor: const Color(0xFFFAF8F2),
      surfaceTintColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28.r),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top Row: [ص/م toggle] [Hour box] [ : ] [Minute box]
            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Vertical AM/PM toggle
                  _buildPeriodToggle(colors),
                  SizedBox(width: 14.w),

                  // Hour Box
                  _buildTimeBox(
                    label:
                        toArabicDigits(_selectedHour.toString().padLeft(2, '0')),
                    isSelected: _mode == _TimePickerMode.hour,
                    onTap: () {
                      setState(() => _mode = _TimePickerMode.hour);
                    },
                    colors: colors,
                  ),

                  // Colon separator
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Text(
                      ':',
                      style: TextStyle(
                        fontFamily: AppTypography.arabicFontFamily,
                        fontSize: 28.sp,
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  // Minute Box
                  _buildTimeBox(
                    label: toArabicDigits(
                        _selectedMinute.toString().padLeft(2, '0')),
                    isSelected: _mode == _TimePickerMode.minute,
                    onTap: () {
                      setState(() => _mode = _TimePickerMode.minute);
                    },
                    colors: colors,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Analog Dial Clock Face
            GestureDetector(
              onPanDown: (details) =>
                  _onDialInteraction(details.localPosition, dialSize),
              onPanUpdate: (details) =>
                  _onDialInteraction(details.localPosition, dialSize),
              child: Container(
                width: dialSize,
                height: dialSize,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CustomPaint(
                  size: Size(dialSize, dialSize),
                  painter: _ClockDialPainter(
                    mode: _mode,
                    selectedHour: _selectedHour,
                    selectedMinute: _selectedMinute,
                    primaryColor: colors.primary,
                    textPrimaryColor: colors.textPrimary,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Action Buttons: "إلغاء" and "حَسَنًا" (RTL order)
            Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    style: TextButton.styleFrom(
                      foregroundColor: colors.primary,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 8.h),
                    ),
                    child: Text(
                      AppStrings.tr(AppStrings.cancel),
                      style: AppTypography.titleSmall.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  TextButton(
                    onPressed: _confirm,
                    style: TextButton.styleFrom(
                      foregroundColor: colors.primary,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 8.h),
                    ),
                    child: Text(
                      AppStrings.tr(AppStrings.ok),
                      style: AppTypography.titleSmall.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodToggle(dynamic colors) {
    const activeColor = Color(0xFFD4E7D9);
    final isAm = _period == DayPeriod.am;

    return Container(
      width: 48.w,
      height: 72.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: colors.divider, width: 0.8),
      ),
      child: Column(
        children: [
          // ص (AM)
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _period = DayPeriod.am),
              borderRadius: BorderRadius.vertical(top: Radius.circular(7.r)),
              child: Container(
                decoration: BoxDecoration(
                  color: isAm ? activeColor : Colors.transparent,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(7.r)),
                ),
                alignment: Alignment.center,
                child: Text(
                  AppStrings.tr(AppStrings.amPeriod),
                  style: AppTypography.titleSmall.copyWith(
                    color: isAm ? colors.primary : colors.textPrimary,
                    fontWeight: isAm ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          Divider(height: 1, thickness: 0.8, color: colors.divider),
          // م (PM)
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _period = DayPeriod.pm),
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(7.r)),
              child: Container(
                decoration: BoxDecoration(
                  color: !isAm ? activeColor : Colors.transparent,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(7.r)),
                ),
                alignment: Alignment.center,
                child: Text(
                  AppStrings.tr(AppStrings.pmPeriod),
                  style: AppTypography.titleSmall.copyWith(
                    color: !isAm ? colors.primary : colors.textPrimary,
                    fontWeight: !isAm ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBox({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required dynamic colors,
  }) {
    const activeColor = Color(0xFFD4E7D9);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: 78.w,
        height: 72.h,
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: isSelected
              ? null
              : Border.all(color: colors.divider, width: 0.8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.arabicFontFamily,
            color: isSelected ? colors.primary : colors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 34.sp,
          ),
        ),
      ),
    );
  }
}

/// CustomPainter rendering the analog clock face with Arabic numerals and selector knob.
class _ClockDialPainter extends CustomPainter {
  final _TimePickerMode mode;
  final int selectedHour;
  final int selectedMinute;
  final Color primaryColor;
  final Color textPrimaryColor;

  _ClockDialPainter({
    required this.mode,
    required this.selectedHour,
    required this.selectedMinute,
    required this.primaryColor,
    required this.textPrimaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final numbersRadius = radius - 24.w;

    // 1. Calculate active angle & knob position
    final double activeAngle;
    if (mode == _TimePickerMode.hour) {
      activeAngle = ((selectedHour % 12) / 12.0) * 2 * pi - (pi / 2);
    } else {
      activeAngle = (selectedMinute / 60.0) * 2 * pi - (pi / 2);
    }

    final knobCenter = Offset(
      center.dx + numbersRadius * cos(activeAngle),
      center.dy + numbersRadius * sin(activeAngle),
    );

    // 2. Draw Hand Line
    final handPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(center, knobCenter, handPaint);

    // 3. Draw Center Pivot Dot
    final pivotPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4.0, pivotPaint);

    // 4. Draw Circular Selector Knob
    final knobPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(knobCenter, 18.0, knobPaint);

    // 5. Draw 12 Clock Face Numerals
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 1; i <= 12; i++) {
      final angle = (i / 12.0) * 2 * pi - (pi / 2);
      final numCenter = Offset(
        center.dx + numbersRadius * cos(angle),
        center.dy + numbersRadius * sin(angle),
      );

      final String label;
      final bool isCurrentSelected;

      if (mode == _TimePickerMode.hour) {
        label = toArabicDigits(i);
        isCurrentSelected = i == selectedHour;
      } else {
        final minuteValue = (i * 5) % 60;
        label = toArabicDigits(minuteValue.toString().padLeft(2, '0'));
        isCurrentSelected = (selectedMinute - minuteValue).abs() <= 2;
      }

      textPainter.text = TextSpan(
        text: label,
        style: TextStyle(
          fontFamily: AppTypography.arabicFontFamily,
          fontSize: 15.sp,
          fontWeight: isCurrentSelected ? FontWeight.w700 : FontWeight.w600,
          color: isCurrentSelected ? Colors.white : textPrimaryColor,
        ),
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          numCenter.dx - (textPainter.width / 2),
          numCenter.dy - (textPainter.height / 2),
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ClockDialPainter oldDelegate) {
    return oldDelegate.mode != mode ||
        oldDelegate.selectedHour != selectedHour ||
        oldDelegate.selectedMinute != selectedMinute ||
        oldDelegate.primaryColor != primaryColor;
  }
}
