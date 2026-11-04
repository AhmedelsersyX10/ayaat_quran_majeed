import 'package:ayaat_quran_majeed/quran/presentation/controllers/reader_chrome_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReaderChromeController Unit Tests', () {
    test('starts visible by default with initial value true', () {
      final controller = ReaderChromeController();
      expect(controller.value, isTrue);
      expect(controller.isVisible, isTrue);
      controller.dispose();
    });

    test('can be initialized with custom visibility', () {
      final controller = ReaderChromeController(initialVisibility: false);
      expect(controller.value, isFalse);
      expect(controller.isVisible, isFalse);
      controller.dispose();
    });

    test('toggle switches from visible to hidden and back', () {
      final controller = ReaderChromeController(initialVisibility: true);
      int notificationCount = 0;
      controller.addListener(() {
        notificationCount++;
      });

      controller.toggle();
      expect(controller.value, isFalse);
      expect(controller.isVisible, isFalse);
      expect(notificationCount, 1);

      controller.toggle();
      expect(controller.value, isTrue);
      expect(controller.isVisible, isTrue);
      expect(notificationCount, 2);

      controller.dispose();
    });

    test(
      'hide is idempotent and does not notify listeners if already hidden',
      () {
        final controller = ReaderChromeController(initialVisibility: true);
        int notificationCount = 0;
        controller.addListener(() {
          notificationCount++;
        });

        controller.hide();
        expect(controller.value, isFalse);
        expect(notificationCount, 1);

        // Second hide should be a no-op
        controller.hide();
        expect(controller.value, isFalse);
        expect(notificationCount, 1);

        controller.dispose();
      },
    );

    test(
      'show is idempotent and does not notify listeners if already visible',
      () {
        final controller = ReaderChromeController(initialVisibility: false);
        int notificationCount = 0;
        controller.addListener(() {
          notificationCount++;
        });

        controller.show();
        expect(controller.value, isTrue);
        expect(notificationCount, 1);

        // Second show should be a no-op
        controller.show();
        expect(controller.value, isTrue);
        expect(notificationCount, 1);

        controller.dispose();
      },
    );

    test('can be disposed by owner cleanly without error', () {
      final controller = ReaderChromeController();
      expect(() => controller.dispose(), returnsNormally);
    });
  });
}
