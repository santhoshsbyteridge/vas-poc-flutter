import 'package:realm/realm.dart';
part 'models.db.g.dart';

@RealmModel()
class _Users {
  @PrimaryKey()
  late String uid;

  late String username;
  late String email;
  late int age;
  late String city;
  late DateTime createdAt;
  late DateTime updatedAt;
  late bool isActive;
}

@RealmModel()
class _ChangeLog {
  late String uid;
  late String action;
  late String data;
  late List<String> updatedFields;
  late DateTime createdAt;
  late DateTime updatedAt;
  late String tableName;
}

@RealmModel()
class _Book {
  @PrimaryKey()
  late String uid;

  late String title;
  late String author;
  late String releaseYear;
  late DateTime createdAt;
  late DateTime updatedAt;
  late bool isActive;
}
