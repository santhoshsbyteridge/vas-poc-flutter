import 'package:realm/realm.dart';
part 'models.db.g.dart';

@RealmModel()
class _Users {
  late int id;
  late String username;

  @PrimaryKey()
  late String email;
  late int age;
  late String city;
  late DateTime createdAt;
  late DateTime updatedAt;
  late bool isActive;
}

@RealmModel()
class _ChangeLog {
  late int userId;
  late String action;
  late String data;
  late List<String> updatedFields;
  late DateTime createdAt;
  late DateTime updatedAt;
  late String tableName;
}
