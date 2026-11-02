import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

void nullValidator(String hiveFieldName, dynamic value) {
  if (Hive.isBoxOpen('name')) {
    final box = Hive.box('name');
    if (box.get(hiveFieldName) == null) {
      box.put(hiveFieldName, value);
    }
  }
}

dynamic getValue(dynamic field) {
  if (Hive.isBoxOpen('name')) {
    return Hive.box('name').get(field);
  }
  return null;
}

void updateValue(dynamic field, dynamic value) {
  if (Hive.isBoxOpen('name')) {
    Hive.box('name').put(field, value);
  }
}

Future<void> initializeHive() async {
  if (!Hive.isBoxOpen('name')) {
    final p = await getApplicationDocumentsDirectory();
    Hive.init(p.path);
    await Hive.openBox('name');
  }
}
