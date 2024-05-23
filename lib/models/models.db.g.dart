// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.db.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class Users extends _Users with RealmEntity, RealmObjectBase, RealmObject {
  Users(
    int id,
    String username,
    String email,
    int age,
    String city,
    DateTime createdAt,
    DateTime updatedAt,
    bool isActive,
  ) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'username', username);
    RealmObjectBase.set(this, 'email', email);
    RealmObjectBase.set(this, 'age', age);
    RealmObjectBase.set(this, 'city', city);
    RealmObjectBase.set(this, 'createdAt', createdAt);
    RealmObjectBase.set(this, 'updatedAt', updatedAt);
    RealmObjectBase.set(this, 'isActive', isActive);
  }

  Users._();

  @override
  int get id => RealmObjectBase.get<int>(this, 'id') as int;
  @override
  set id(int value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get username =>
      RealmObjectBase.get<String>(this, 'username') as String;
  @override
  set username(String value) => RealmObjectBase.set(this, 'username', value);

  @override
  String get email => RealmObjectBase.get<String>(this, 'email') as String;
  @override
  set email(String value) => RealmObjectBase.set(this, 'email', value);

  @override
  int get age => RealmObjectBase.get<int>(this, 'age') as int;
  @override
  set age(int value) => RealmObjectBase.set(this, 'age', value);

  @override
  String get city => RealmObjectBase.get<String>(this, 'city') as String;
  @override
  set city(String value) => RealmObjectBase.set(this, 'city', value);

  @override
  DateTime get createdAt =>
      RealmObjectBase.get<DateTime>(this, 'createdAt') as DateTime;
  @override
  set createdAt(DateTime value) =>
      RealmObjectBase.set(this, 'createdAt', value);

  @override
  DateTime get updatedAt =>
      RealmObjectBase.get<DateTime>(this, 'updatedAt') as DateTime;
  @override
  set updatedAt(DateTime value) =>
      RealmObjectBase.set(this, 'updatedAt', value);

  @override
  bool get isActive => RealmObjectBase.get<bool>(this, 'isActive') as bool;
  @override
  set isActive(bool value) => RealmObjectBase.set(this, 'isActive', value);

  @override
  Stream<RealmObjectChanges<Users>> get changes =>
      RealmObjectBase.getChanges<Users>(this);

  @override
  Users freeze() => RealmObjectBase.freezeObject<Users>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Users._);
    return const SchemaObject(ObjectType.realmObject, Users, 'Users', [
      SchemaProperty('id', RealmPropertyType.int),
      SchemaProperty('username', RealmPropertyType.string),
      SchemaProperty('email', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('age', RealmPropertyType.int),
      SchemaProperty('city', RealmPropertyType.string),
      SchemaProperty('createdAt', RealmPropertyType.timestamp),
      SchemaProperty('updatedAt', RealmPropertyType.timestamp),
      SchemaProperty('isActive', RealmPropertyType.bool),
    ]);
  }
}

class ChangeLog extends _ChangeLog
    with RealmEntity, RealmObjectBase, RealmObject {
  ChangeLog(
    int userId,
    String action,
    String data,
    DateTime createdAt,
    DateTime updatedAt,
    String tableName, {
    Iterable<String> updatedFields = const [],
  }) {
    RealmObjectBase.set(this, 'userId', userId);
    RealmObjectBase.set(this, 'action', action);
    RealmObjectBase.set(this, 'data', data);
    RealmObjectBase.set(this, 'createdAt', createdAt);
    RealmObjectBase.set(this, 'updatedAt', updatedAt);
    RealmObjectBase.set(this, 'tableName', tableName);
    RealmObjectBase.set<RealmList<String>>(
        this, 'updatedFields', RealmList<String>(updatedFields));
  }

  ChangeLog._();

  @override
  int get userId => RealmObjectBase.get<int>(this, 'userId') as int;
  @override
  set userId(int value) => RealmObjectBase.set(this, 'userId', value);

  @override
  String get action => RealmObjectBase.get<String>(this, 'action') as String;
  @override
  set action(String value) => RealmObjectBase.set(this, 'action', value);

  @override
  String get data => RealmObjectBase.get<String>(this, 'data') as String;
  @override
  set data(String value) => RealmObjectBase.set(this, 'data', value);

  @override
  RealmList<String> get updatedFields =>
      RealmObjectBase.get<String>(this, 'updatedFields') as RealmList<String>;
  @override
  set updatedFields(covariant RealmList<String> value) =>
      throw RealmUnsupportedSetError();

  @override
  DateTime get createdAt =>
      RealmObjectBase.get<DateTime>(this, 'createdAt') as DateTime;
  @override
  set createdAt(DateTime value) =>
      RealmObjectBase.set(this, 'createdAt', value);

  @override
  DateTime get updatedAt =>
      RealmObjectBase.get<DateTime>(this, 'updatedAt') as DateTime;
  @override
  set updatedAt(DateTime value) =>
      RealmObjectBase.set(this, 'updatedAt', value);

  @override
  String get tableName =>
      RealmObjectBase.get<String>(this, 'tableName') as String;
  @override
  set tableName(String value) => RealmObjectBase.set(this, 'tableName', value);

  @override
  Stream<RealmObjectChanges<ChangeLog>> get changes =>
      RealmObjectBase.getChanges<ChangeLog>(this);

  @override
  ChangeLog freeze() => RealmObjectBase.freezeObject<ChangeLog>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(ChangeLog._);
    return const SchemaObject(ObjectType.realmObject, ChangeLog, 'ChangeLog', [
      SchemaProperty('userId', RealmPropertyType.int),
      SchemaProperty('action', RealmPropertyType.string),
      SchemaProperty('data', RealmPropertyType.string),
      SchemaProperty('updatedFields', RealmPropertyType.string,
          collectionType: RealmCollectionType.list),
      SchemaProperty('createdAt', RealmPropertyType.timestamp),
      SchemaProperty('updatedAt', RealmPropertyType.timestamp),
      SchemaProperty('tableName', RealmPropertyType.string),
    ]);
  }
}
