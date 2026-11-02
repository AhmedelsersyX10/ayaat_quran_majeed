import 'package:ayaat_quran_majeed/core/theme/app_colors.dart';
import 'package:ayaat_quran_majeed/core/theme/app_spacing.dart';
import 'package:ayaat_quran_majeed/core/theme/app_theme_extension.dart';
import 'package:ayaat_quran_majeed/core/theme/app_typography.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_bottom_nav.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_bottom_sheet_shell.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_button.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_card.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_checkmark.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_dialog_shell.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_empty_state.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_feedback_states.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_icon_button.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_list_tile.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_section_header.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_segmented_tabs.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_stepper.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_switch.dart';
import 'package:ayaat_quran_majeed/core/widgets/app_text_field.dart';
import 'package:ayaat_quran_majeed/core/widgets/hizb_quarter_circle.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Internal test harness & visual component catalog.
/// Used for visual verification, regression testing, and developer reference.
/// Not linked in the end-user production navigation.
class DesignSystemCatalogPage extends StatefulWidget {
  const DesignSystemCatalogPage({super.key});

  @override
  State<DesignSystemCatalogPage> createState() =>
      _DesignSystemCatalogPageState();
}

class _DesignSystemCatalogPageState extends State<DesignSystemCatalogPage> {
  int _tabIndex = 0;
  int _navIndex = 0;
  bool _switchVal = true;
  int _stepperVal = 3;
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('معرض نظام التصميم'),
        ),
        body: ListView(
          padding: EdgeInsets.all(AppSpacing.lg),
          children: [
            // 1. Color Palette Tokens
            _buildSection(
              title: '1. لوحة الألوان الأساسية (Colors)',
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _colorChip('الأخضر الأساسي', colors.primary),
                  _colorChip('الخلفية العامة', colors.scaffoldBackground),
                  _colorChip('السطح الأبيض', colors.surface),
                  _colorChip('شريط التنقل', colors.bottomNavBackground),
                  _colorChip('أصفر الفاصلة', colors.bookmarkYellow),
                  _colorChip('أخضر الفاصلة', colors.bookmarkGreen),
                  _colorChip('أزرق الفاصلة', colors.bookmarkBlue),
                  _colorChip('وردي الفاصلة', colors.bookmarkPink),
                  _colorChip('إجراء الحذف', colors.destructive),
                ],
              ),
            ),

            // 2. Typography
            _buildSection(
              title: '2. الطباعة والخطوط (Typography)',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Display Large - ٢٤ خط عريض',
                      style: AppTypography.displayLarge),
                  SizedBox(height: AppSpacing.xs),
                  Text('Title Large - ١٨ خط عريض',
                      style: AppTypography.titleLarge),
                  SizedBox(height: AppSpacing.xs),
                  Text('Title Medium - ١٦ شبه عريض',
                      style: AppTypography.titleMedium),
                  SizedBox(height: AppSpacing.xs),
                  Text('Title Small - ١٤ شبه عريض',
                      style: AppTypography.titleSmall),
                  SizedBox(height: AppSpacing.xs),
                  Text('Body Large - ١٥ نص عادي للملاحظات',
                      style: AppTypography.bodyLarge),
                  SizedBox(height: AppSpacing.xs),
                  Text('Body Medium - ١٣ العناوين الفرعية والبيانات',
                      style: AppTypography.bodyMedium),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                      'الخط العثماني: ﴿بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ﴾',
                      style: AppTypography.quranText),
                ],
              ),
            ),

            // 3. Buttons
            _buildSection(
              title: '3. الأزرار (Buttons & Icon Buttons)',
              child: Column(
                children: [
                  AppButton.primary(
                    text: 'زر أساسي (Primary CTA)',
                    onPressed: () {},
                  ),
                  SizedBox(height: AppSpacing.sm),
                  AppButton.secondary(
                    text: 'زر ثانوي (Secondary)',
                    onPressed: () {},
                  ),
                  SizedBox(height: AppSpacing.sm),
                  AppButton.destructive(
                    text: 'زر تحذيري (حذف الختمة)',
                    onPressed: () {},
                  ),
                  SizedBox(height: AppSpacing.sm),
                  const AppButton.primary(
                    text: 'زر في حالة تحميل',
                    isLoading: true,
                    onPressed: null,
                  ),
                  SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      AppIconButton.ghost(
                        icon: const Icon(Iconsax.arrow_right_3),
                        onPressed: () {},
                      ),
                      AppIconButton.filled(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () {},
                      ),
                      AppIconButton.badge(
                        icon: const Icon(Icons.remove),
                        onPressed: () {},
                      ),
                      const AppCheckmark(),
                    ],
                  ),
                ],
              ),
            ),

            // 4. Segmented Tabs
            _buildSection(
              title: '4. التبويبات الكبسولية (Segmented Tabs)',
              child: AppSegmentedTabs(
                tabs: const ['السور', 'الأرباع', 'الأجزاء'],
                selectedIndex: _tabIndex,
                onTabChanged: (i) => setState(() => _tabIndex = i),
              ),
            ),

            // 5. Controls: Switch & Stepper
            _buildSection(
              title: '5. المفاتيح والعدادات (Switch & Stepper)',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text('تنبيه الورد: ', style: AppTypography.bodyMedium),
                      AppSwitch(
                        value: _switchVal,
                        onChanged: (v) => setState(() => _switchVal = v),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text('تكرار: ', style: AppTypography.bodyMedium),
                      AppStepper(
                        value: _stepperVal,
                        onChanged: (v) => setState(() => _stepperVal = v),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 6. Cards & Containers
            _buildSection(
              title: '6. البطاقات والحاويات (Cards)',
              child: Column(
                children: [
                  AppCard.standard(
                    child: Text('بطاقة قياسية بيضاء دافئة (#FFFCF7)',
                        style: AppTypography.bodyMedium),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  AppCard.primary(
                    child: Text(
                      'بطاقة خضراء بارزة للورد المكتمل (#007430)',
                      style: AppTypography.bodyLarge
                          .copyWith(color: colors.textOnPrimary),
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  AppCard.quote(
                    child: Text(
                      '﴿إِنَّ هَٰذَا الْقُرْآنَ يَهْدِي لِلَّتِي هِيَ أَقْوَمُ﴾',
                      style: AppTypography.quranText,
                    ),
                  ),
                ],
              ),
            ),

            // 7. Inputs
            _buildSection(
              title: '7. حقول البحث والإدخال (Inputs)',
              child: Column(
                children: [
                  AppSearchBar(controller: _searchCtrl),
                  SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    label: 'إضافة ملاحظة',
                    hintText: 'اكتب ملاحظتك وتأملك هنا...',
                    minLines: 3,
                    maxLines: 4,
                    controller: _noteCtrl,
                  ),
                ],
              ),
            ),

            // 8. List Tiles & Section Headers
            _buildSection(
              title: '8. صفوف القوائم وترويسات الأقسام (List Tiles)',
              child: Column(
                children: [
                  const AppSectionHeader(title: 'الجزء الأول'),
                  AppListTile(
                    leading: const AppCheckmark(),
                    title: const Text('سورة الفاتحة'),
                    subtitle: const Text('مكية - ٧ آيات'),
                    trailing: Text('ص ١', style: AppTypography.bodySmall),
                    onTap: () {},
                  ),
                  AppListTile(
                    leading: const HizbQuarterIndicator(
                      type: HizbQuarterType.half,
                      size: 22,
                    ),
                    title: const Text('سورة البقرة'),
                    subtitle: const Text('مدنية - ٢٨٦ آية'),
                    trailing: Text('ص ٢', style: AppTypography.bodySmall),
                    onTap: () {},
                  ),
                ],
              ),
            ),

            // 9. Modals (Bottom Sheet & Dialog)
            _buildSection(
              title: '9. النوافذ والقوائم السفلية (Modals)',
              child: Row(
                children: [
                  Expanded(
                    child: AppButton.secondary(
                      text: 'فتح القائمة السفلية',
                      onPressed: () {
                        AppBottomSheetShell.show(
                          context: context,
                          title: 'معاينة القائمة السفلية',
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.lg),
                            child: const Text(
                                'محتوى تجريبي داخل شل القائمة السفلية.'),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppButton.secondary(
                      text: 'فتح النافذة الحوارية',
                      onPressed: () {
                        AppDialogShell.show(
                          context: context,
                          title: 'تأكيد الحفظ',
                          actions: [
                            AppButton.text(
                              text: 'إلغاء',
                              onPressed: () => Navigator.pop(context),
                            ),
                            AppButton.primary(
                              text: 'حفظ',
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                          child: const Text('هل تريد حفظ التعديلات الحالية؟'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // 10. Feedback & Empty States
            _buildSection(
              title: '10. حالات التغذية الراجعة والفراغ (States)',
              child: Column(
                children: [
                  const AppErrorState(
                    message:
                        'تعذر الاتصال بالخادم. يرجى التحقق من اتصال الإنترنت.',
                  ),
                  SizedBox(height: AppSpacing.sm),
                  AppEmptyState(
                    icon: Icon(Iconsax.note_favorite,
                        size: 48, color: colors.textMuted),
                    title: 'لا توجد ملاحظات محفوظة',
                    description: 'يمكنك إضافة ملاحظات وتأملات أثناء القراءة.',
                    buttonText: 'ابدأ القراءة',
                    onButtonPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: AppBottomNav(
          currentIndex: _navIndex,
          onTap: (i) => setState(() => _navIndex = i),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  AppTypography.titleMedium.copyWith(color: AppColors.primary)),
          SizedBox(height: AppSpacing.sm),
          child,
          Divider(color: AppColors.divider, height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _colorChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadii.radiusSm,
        border: Border.all(color: Colors.black12, width: 0.5),
      ),
      child: Text(
        label,
        style: AppTypography.bodySmall.copyWith(
          color: color.computeLuminance() > 0.5 ? Colors.black87 : Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
