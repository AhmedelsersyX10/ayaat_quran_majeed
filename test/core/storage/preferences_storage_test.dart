import 'package:ayaat_quran_majeed/core/storage/preferences_storage_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPrefsStorage storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'existing_bool': true,
      'existing_int': 42,
      'existing_double': 3.14,
      'existing_string': 'مرحبا',
      'existing_list': <String>['أ', 'ب', 'ج'],
    });
    final prefs = await SharedPreferences.getInstance();
    storage = SharedPrefsStorage(prefs);
  });

  group('PreferencesStorage (SharedPrefsStorage) CRUD Tests', () {
    test('reads existing primitive values correctly', () {
      expect(storage.getBool('existing_bool'), isTrue);
      expect(storage.getInt('existing_int'), equals(42));
      expect(storage.getDouble('existing_double'), equals(3.14));
      expect(storage.getString('existing_string'), equals('مرحبا'));
      expect(storage.getStringList('existing_list'), equals(['أ', 'ب', 'ج']));
    });

    test('returns null for nonexistent keys', () {
      expect(storage.getBool('nonexistent'), isNull);
      expect(storage.getInt('nonexistent'), isNull);
      expect(storage.getDouble('nonexistent'), isNull);
      expect(storage.getString('nonexistent'), isNull);
      expect(storage.getStringList('nonexistent'), isNull);
    });

    test('writes and reads new boolean values', () async {
      final success = await storage.setBool('new_bool', false);
      expect(success, isTrue);
      expect(storage.getBool('new_bool'), isFalse);
    });

    test('writes and reads new integer values', () async {
      final success = await storage.setInt('new_int', 604);
      expect(success, isTrue);
      expect(storage.getInt('new_int'), equals(604));
    });

    test('writes and reads new double values', () async {
      final success = await storage.setDouble('new_double', 24.5);
      expect(success, isTrue);
      expect(storage.getDouble('new_double'), equals(24.5));
    });

    test('writes and reads new string values', () async {
      final success = await storage.setString('new_string', 'سورة البقرة');
      expect(success, isTrue);
      expect(storage.getString('new_string'), equals('سورة البقرة'));
    });

    test('writes and reads new string list values', () async {
      final success = await storage.setStringList('new_list', ['1', '2', '3']);
      expect(success, isTrue);
      expect(storage.getStringList('new_list'), equals(['1', '2', '3']));
    });

    test('containsKey correctly identifies existing and missing keys', () {
      expect(storage.containsKey('existing_bool'), isTrue);
      expect(storage.containsKey('nonexistent_key'), isFalse);
    });

    test('removes specific keys cleanly', () async {
      expect(storage.containsKey('existing_int'), isTrue);
      final removed = await storage.remove('existing_int');
      expect(removed, isTrue);
      expect(storage.containsKey('existing_int'), isFalse);
      expect(storage.getInt('existing_int'), isNull);
    });

    test('clears all storage keys', () async {
      expect(storage.getKeys().isNotEmpty, isTrue);
      final cleared = await storage.clear();
      expect(cleared, isTrue);
      expect(storage.getKeys(), isEmpty);
    });

    test('SharedPrefsStorage.create() initializes properly from platform', () async {
      final created = await SharedPrefsStorage.create();
      expect(created, isNotNull);
      expect(created, isA<SharedPrefsStorage>());
    });
  });
}

