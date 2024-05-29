// ignore_for_file: unnecessary_null_comparison, unused_local_variable, avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
import 'package:realm_local_db/apis/homepage.api.dart';
import 'package:realm_local_db/models/models.db.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Future<SharedPreferences> _sharedPreference =
      SharedPreferences.getInstance();

  final DateTime _dateTimeNow = DateTime.now().toUtc();
  late DateTime _lastSyncTime = _dateTimeNow;

  late Realm usersRealm;
  late Realm usersRealmInsert;
  late Realm usersRealmUpdate;
  late Realm usersRealmDelete;
  late Realm changeLogRealm;
  late Configuration configuration;

  final HomePageApi _homePageApi = HomePageApi();

  List<Users> users = [];
  List<ChangeLog> changeLogsServerData = [];
  List<ChangeLog> changeLogsLocalData = [];

  late RealmResults<Users> usersLocal;
  late RealmResults<ChangeLog> changeLogsLocal;
  List displayDatas = [];
  List<String> displayDataTableName = [];

  _MyHomePageState() {
    final usersConfig = Configuration.local([Users.schema, Book.schema]);
    usersRealm = Realm(usersConfig);
    usersRealmInsert = Realm(usersConfig);
    usersRealmUpdate = Realm(usersConfig);
    usersRealmDelete = Realm(usersConfig);
    final changeLogConfig = Configuration.local([ChangeLog.schema]);
    changeLogRealm = Realm(changeLogConfig);
  }

  @override
  void initState() {
    _getLastSyncTime();
    _getAllDataFromLocal();
    super.initState();
  }

  @override
  void dispose() {
    usersRealmInsert.close();
    usersRealmUpdate.close();
    usersRealmDelete.close();
    changeLogRealm.close();
    super.dispose();
  }

  void _getLastSyncTime() async {
    final SharedPreferences sharedPreference = await _sharedPreference;
    final String? lastSyncTimeString =
        sharedPreference.getString('lastSyncTime');
    if (lastSyncTimeString != null) {
      _lastSyncTime = DateTime.parse(lastSyncTimeString);
      setState(() {});
    }
  }

  void _setLastSyncTime() async {
    final SharedPreferences sharedPreference = await _sharedPreference;
    sharedPreference.setString(
        'lastSyncTime', DateTime.now().toUtc().toString());
    final String? lastSyncTimeString =
        sharedPreference.getString('lastSyncTime');
    if (lastSyncTimeString != null) {
      _lastSyncTime = DateTime.parse(lastSyncTimeString);
      setState(() {});
    }
  }

  Future<void> _getAllDataFromLocal() async {
    displayDatas.clear();
    dynamic datas = usersRealm.all<Users>();
    for (int i = 0; i < datas.length; i++) {
      displayDatas.add(datas[i]);
      displayDataTableName.add('USERS');
    }
    datas = usersRealm.all<Book>();
    for (int i = 0; i < datas.length; i++) {
      displayDatas.add(datas[i]);
      displayDataTableName.add('BOOK');
    }
    setState(() {});
  }

  // Future<void> _getUsersFromServer({bool? storeInLocalDB}) async {
  //   users = await _homePageApi.getUsersApi();
  //   _streamControllerUsers.add(users);
  //   if (storeInLocalDB == true) {
  //     for (int i = 0; i < users.length; i++) {
  //       final Users userData = Users(
  //         users[i].uid,
  //         users[i].username,
  //         users[i].email,
  //         users[i].age,
  //         users[i].city,
  //         users[i].createdAt,
  //         users[i].updatedAt,
  //         users[i].isActive,
  //       );
  //       await _insertLocalData(userData);
  //     }
  //   }
  // }

  // insert data to local realm db
  Future<void> _insertLocalData(Users? usersData, Book? bookData,
      {String tableName = 'USERS'}) async {
    bool operationDone = false;

    usersRealmInsert.write(() {
      // the below addition value should change
      final addedObject = usersData != null
          ? usersRealmInsert.add<Users>(usersData)
          : usersRealmInsert.add<Book>(bookData as Book);

      operationDone = true;
    });
    if (operationDone == true) {
      await _addingActionToChangeLogs('INSERT', usersData ?? bookData,
          tableName: tableName);
    }
  }

  // update data to local realm db
  Future<void> _updateLocalData(Users? usersData, Book? bookData,
      {String tableName = 'USERS'}) async {
    bool operationDone = false;
    List<String> updatedFields = [];

    usersRealmUpdate.write(() {
      final oldData = usersRealmUpdate.find<Users>(usersData?.email);

      if (oldData != null) {
        if (oldData.username != usersData?.username) {
          oldData.username = usersData!.username;
          updatedFields.add('username');
        }
        if (oldData.age != usersData?.age) {
          oldData.age = usersData!.age;
          updatedFields.add('age');
        }
        if (oldData.city != usersData?.city) {
          oldData.city = usersData!.city;
          updatedFields.add('city');
        }
        if (oldData.updatedAt != usersData?.updatedAt) {
          oldData.updatedAt = usersData!.updatedAt;
          // updatedFields.add('updatedAt');
        }
        if (oldData.isActive != usersData?.isActive) {
          oldData.isActive = usersData!.isActive;
          updatedFields.add('isActive');
        }
        usersData?.createdAt = oldData.createdAt;
        oldData.updatedAt = usersData!.updatedAt;
        usersData.updatedAt = oldData.updatedAt;
        operationDone = true;
      } else {
        // data not found
        _insertLocalData(usersData, bookData, tableName: tableName);
      }
    });
    if (operationDone == true) {
      await _addingActionToChangeLogs('UPDATE', usersData ?? bookData,
          updatedFields: updatedFields, tableName: tableName);
    }
  }

  // delete data to local realm db
  Future<void> _deleteLocalData(Users? usersData, Book? bookData,
      {String tableName = 'USERS'}) async {
    bool operationDone = false;

    usersRealm.write(() {
      dynamic obj = usersData != null
          ? usersRealm.find<Users>(usersData.uid)
          : usersRealm.find<Book>(bookData?.uid);

      if (obj != null && obj.isActive == true) {
        if (usersData != null) {
          usersData.createdAt = obj.createdAt;
        } else if (bookData != null) {
          bookData.createdAt = obj.createdAt;
        }

        obj.updatedAt = DateTime.now();

        if (usersData != null) {
          usersData.updatedAt = obj.updatedAt;
        } else if (bookData != null) {
          bookData.updatedAt = obj.updatedAt;
        }

        obj.isActive = false;
        operationDone = true;
      } else {
        if (usersData != null) usersData.isActive = false;
        if (bookData != null) bookData.isActive = false;
        _insertLocalData(usersData, bookData, tableName: tableName);
      }
    });
    if (operationDone == true) {
      await _addingActionToChangeLogs('DELETE', usersData ?? bookData,
          updatedFields: ['isActive'], tableName: tableName);
    }
  }

  // adding actions to changelogs table
  Future<void> _addingActionToChangeLogs(String action, dynamic data,
      {List<String>? updatedFields, String? tableName}) async {
    changeLogRealm.write(() {
      final List<String> tempUpdateFields = updatedFields ?? [];
      final oldObject = changeLogRealm.all<ChangeLog>();
      for (int i = oldObject.length - 1; i >= 0; i--) {
        if (oldObject[i].uid == data.uid &&
            (action == 'UPDATE' || action == 'DELETE')) {
          for (int a = 0; a < oldObject[i].updatedFields.length; a++) {
            if (!(tempUpdateFields.contains(oldObject[i].updatedFields[a]))) {
              tempUpdateFields.add(oldObject[i].updatedFields[a]);
            }
          }
          break;
        }
      }
      final DateTime createdAt = DateTime.now().toUtc();
      final dataString = tableName == 'USERS'
          ? jsonEncode({
              "uid": data.uid,
              "username": data.username,
              "email": data.email,
              "age": data.age,
              "city": data.city,
              "createdAt": data.createdAt.toString(),
              "updatedAt": data.updatedAt.toString(),
              "isActive": data.isActive
            })
          : jsonEncode({
              "uid": data.uid,
              "title": data.title,
              "author": data.author,
              "releaseYear": data.releaseYear,
              "createdAt": data.createdAt.toString(),
              "updatedAt": data.updatedAt.toString(),
              "isActive": data.isActive
            });
      changeLogRealm.add(ChangeLog(
          data.uid, action, dataString, createdAt, createdAt, tableName ?? '',
          updatedFields: tempUpdateFields.isNotEmpty
              ? tempUpdateFields as Iterable<String>
              : []));
    });
  }

  // get fresh new changelogs from local db
  Future<void> _getFreshCangeLogsFromLocalDb() async {
    final data = changeLogRealm.all<ChangeLog>();

    final uIdsAdded = [];

    // adding in descending order
    for (int i = data.length - 1; i >= 0; i--) {
      if (!uIdsAdded.contains(data[i].uid)) {
        changeLogsLocalData.add(ChangeLog(
          data[i].uid,
          data[i].action,
          data[i].data,
          data[i].createdAt,
          data[i].updatedAt,
          data[i].tableName,
          updatedFields: data[i].updatedFields,
        ));
        uIdsAdded.add(data[i].uid);
      }
    }
  }

  // get fresh new changelogs from server
  Future<void> _getFreshChangeLogsFromServer() async {
    changeLogsServerData = await _homePageApi.getChangeLogApi(
        lastSyncedTime: _lastSyncTime.toString());
  }

  // delete local db changelogs
  Future<void> _deleteCangeLogsFromLocalDb() async {
    changeLogRealm.write(() {
      changeLogRealm.deleteAll<ChangeLog>();
    });
  }

  Future<void> _printLocalData() async {
    dynamic datas = usersRealm.all<Users>();

    print('in _printUsersLocalData method');
    for (int i = 0; i < datas.length; i++) {
      print(i);
      print(datas[i].uid);
      print(datas[i].username);
      print(datas[i].email);
      print(datas[i].age);
      print(datas[i].city);
      print(datas[i].isActive);
      print(datas[i].createdAt);
      print(datas[i].updatedAt);
    }
    datas = usersRealm.all<Book>();
    print('in _printUsersLocalData method');
    for (int i = 0; i < datas.length; i++) {
      print(i);
      print(datas[i].uid);
      print(datas[i].title);
      print(datas[i].author);
      print(datas[i].releaseYear);
      print(datas[i].isActive);
      print(datas[i].createdAt);
      print(datas[i].updatedAt);
    }
  }

  Future<void> _printChangeLogLocalData() async {
    // checking all the data
    final datas = changeLogRealm.all<ChangeLog>();
    print('in _printChangeLogLocalData method');
    for (int i = 0; i < datas.length; i++) {
      print(i);
      print(datas[i].uid);
      print(datas[i].action);
      print(datas[i].data);
      print(datas[i].updatedFields);
      print(datas[i].tableName);
    }
  }

  Future<void> _processData() async {
    List<ChangeLog> updatesRequiredOnLocal =
        changeLogsLocalData.isEmpty ? changeLogsServerData : [];
    List<ChangeLog> updatesRequiredOnServer = [];
    for (int i = changeLogsLocalData.length - 1; i >= 0; i--) {
      String localUID = jsonDecode(changeLogsLocalData[i].data)['uid'];
      DateTime localUpdatedAt = changeLogsLocalData[i].updatedAt;
      List<String> updatedFieldsLocal = changeLogsLocalData[i].updatedFields;

      for (int j = 0; j <= changeLogsServerData.length - 1; j++) {
        String serverUID = jsonDecode(changeLogsServerData[j].data)['uid'];
        DateTime serverUpdatedAt = changeLogsServerData[j].updatedAt;
        List<String> updatedFieldsServer =
            changeLogsServerData[j].updatedFields;

        if (localUID == serverUID) {
          if (updatedFieldsLocal.isNotEmpty &&
              updatedFieldsServer.isNotEmpty &&
              !isMergeConflictPresent(
                  updatedFieldsLocal, updatedFieldsServer)) {
            Map<String, dynamic> resultObj =
                jsonDecode(changeLogsLocalData[i].data);

            List<String> tableCols =
                changeLogsServerData[j].tableName == 'USERS'
                    ? ['username', 'email', 'age', 'city', 'isActive']
                    : ['title', 'author', 'releaseYear'];

            for (int a = 0; a < tableCols.length; a++) {
              if (updatedFieldsLocal.contains(tableCols[a])) {
                resultObj[tableCols[a]] =
                    jsonDecode(changeLogsLocalData[i].data)[tableCols[a]];
              } else if (updatedFieldsServer.contains(tableCols[a])) {
                resultObj[tableCols[a]] =
                    jsonDecode(changeLogsServerData[j].data)[tableCols[a]];
              }
            }

            updatesRequiredOnServer.add(ChangeLog(
              resultObj['uid'] ?? 123,
              resultObj['action'] ?? 'UPDATE',
              jsonEncode(resultObj),
              changeLogsLocalData[i].createdAt,
              changeLogsLocalData[i].updatedAt,
              changeLogsLocalData[i].tableName,
              updatedFields: changeLogsLocalData[i].updatedFields,
            ));
            updatesRequiredOnLocal.add(ChangeLog(
              resultObj['uid'] ?? 123,
              resultObj['action'] ?? 'UPDATE',
              jsonEncode(resultObj),
              changeLogsServerData[j].createdAt,
              changeLogsServerData[j].updatedAt,
              changeLogsServerData[j].tableName,
            ));
          } else {
            if (localUpdatedAt.compareTo(serverUpdatedAt) > 0) {
              changeLogsLocalData[i].action = 'UPDATE';
              // We need to update server with local data
              updatesRequiredOnServer.add(changeLogsLocalData[i]);
            } else if (localUpdatedAt.compareTo(serverUpdatedAt) < 0) {
              changeLogsServerData[j].action = 'UPDATE';
              // We need to update local with server data
              updatesRequiredOnLocal.add(changeLogsServerData[j]);
            }
          }
        } else if (localUID != serverUID) {
          updatesRequiredOnServer.add(changeLogsLocalData[i]);
          updatesRequiredOnLocal.add(changeLogsServerData[j]);
        }
      }
    }

    // Remove duplicate data from updatesRequiredOnLocal and sort it in ascending order of updatedAt
    List<ChangeLog> listWithoutDuplicates = [];

    for (ChangeLog item in updatesRequiredOnLocal) {
      if (!listWithoutDuplicates.contains(item)) {
        listWithoutDuplicates.add(item);
      }
    }
    updatesRequiredOnLocal = listWithoutDuplicates;

    // Remove duplicate data from updatesRequiredOnServer and sort it in ascending order of updatedAt
    listWithoutDuplicates = [];
    updatesRequiredOnServer = changeLogsServerData.isEmpty
        ? changeLogsLocalData
        : updatesRequiredOnServer;
    for (ChangeLog item in updatesRequiredOnServer) {
      if (!listWithoutDuplicates.contains(item)) {
        listWithoutDuplicates.add(item);
      }
    }
    updatesRequiredOnServer = listWithoutDuplicates;

    await _syncDataBackend(updatesRequiredOnServer);

    await _syncDataFrontend(updatesRequiredOnLocal);

    _deleteCangeLogsFromLocalDb();

    _setLastSyncTime();

    _deleteCangeLogsFromLocalDb();

    _clearAllArrays();
  }

  void _clearAllArrays() {
    changeLogsLocalData = [];
    changeLogsServerData = [];
    setState(() {});
  }

  Future<void> _syncDataFrontend(List<ChangeLog> data) async {
    for (int i = 0; i <= data.length - 1; i++) {
      String action = data[i].action;
      String tableName = data[i].tableName;
      Map<String, dynamic> userData = jsonDecode(data[i].data);
      switch (action) {
        case 'INSERT':
          {
            if (tableName == 'USERS') {
              await _insertLocalData(
                Users(
                  userData['uid'],
                  userData['username'],
                  userData['email'],
                  userData['age'],
                  userData['city'],
                  DateTime.parse(userData['createdAt']),
                  DateTime.parse(userData['updatedAt']),
                  userData['isActive'],
                ),
                null,
                tableName: 'USERS',
              );
            } else {
              await _insertLocalData(
                null,
                Book(
                  userData['uid'],
                  userData['title'],
                  userData['author'],
                  userData['releaseYear'],
                  DateTime.parse(userData['createdAt']),
                  DateTime.parse(userData['updatedAt']),
                  userData['isActive'],
                ),
                tableName: 'Book',
              );
            }

            break;
          }
        case 'UPDATE':
          {
            if (tableName == 'USERS') {
              await _updateLocalData(
                Users(
                  userData['uid'],
                  userData['username'],
                  userData['email'],
                  userData['age'],
                  userData['city'],
                  DateTime.parse(userData['createdAt']),
                  DateTime.parse(userData['updatedAt']),
                  userData['isActive'],
                ),
                null,
                tableName: 'USERS',
              );
            } else {
              await _updateLocalData(
                null,
                Book(
                  userData['uid'],
                  userData['title'],
                  userData['author'],
                  userData['releaseYear'],
                  DateTime.parse(userData['createdAt']),
                  DateTime.parse(userData['updatedAt']),
                  userData['isActive'],
                ),
                tableName: 'Book',
              );
            }

            break;
          }
        case 'DELETE':
          {
            if (tableName == 'USERS') {
              await _deleteLocalData(
                Users(
                  userData['uid'],
                  userData['username'],
                  userData['email'],
                  userData['age'],
                  userData['city'],
                  DateTime.parse(userData['createdAt']),
                  DateTime.parse(userData['updatedAt']),
                  userData['isActive'],
                ),
                null,
                tableName: 'USERS',
              );
            } else {
              await _deleteLocalData(
                null,
                Book(
                  userData['uid'],
                  userData['title'],
                  userData['author'],
                  userData['releaseYear'],
                  DateTime.parse(userData['createdAt']),
                  DateTime.parse(userData['updatedAt']),
                  userData['isActive'],
                ),
                tableName: 'Book',
              );
            }

            break;
          }
      }
    }
  }

  Future<void> _syncDataBackend(List<ChangeLog> data) async {
    await _homePageApi.sendDataToServer(data);
  }

  bool isMergeConflictPresent(List<dynamic> list1, List<dynamic> list2) {
    // Create a sorted copy of the lists
    List<dynamic> sortedList1 = List.from(list1)..sort();
    List<dynamic> sortedList2 = List.from(list2)..sort();

    // Compare the sorted lists
    for (int i = 0; i < sortedList1.length; i++) {
      for (int j = 0; j < sortedList2.length; j++) {
        if (sortedList1[i] == sortedList2[j]) {
          return true;
        }
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VAS POC'),
      ),
      body: Center(
        child: ListView(
          children: [
            for (int i = 0; i < displayDatas.length; i++)
              displayDataTableName[i] == 'USERS'
                  ? Card(
                      child: Column(
                        children: [
                          Text(displayDatas[i].uid),
                          Text(displayDatas[i].username),
                          Text(displayDatas[i].email),
                          Text(displayDatas[i].age.toString()),
                          Text(displayDatas[i].city),
                          Text(displayDatas[i].isActive.toString()),
                          Text(displayDatas[i].createdAt.toString()),
                          Text(displayDatas[i].updatedAt.toString()),
                        ],
                      ),
                    )
                  : Card(
                      child: Column(
                        children: [
                          Text(displayDatas[i].uid),
                          Text(displayDatas[i].title),
                          Text(displayDatas[i].author),
                          Text(displayDatas[i].releaseYear),
                          Text(displayDatas[i].isActive.toString()),
                          Text(displayDatas[i].createdAt.toString()),
                          Text(displayDatas[i].updatedAt.toString()),
                        ],
                      ),
                    ),
            Container(
              height: 100,
            )
          ],
        ),
      ),
      floatingActionButton: Container(
        padding: const EdgeInsets.only(left: 30),
        child: Column(
          children: [
            const Spacer(),
            Row(
              children: [
                FloatingActionButton(
                  onPressed: () async {
                    var uuid = Uuid.v1();

                    String uid = uuid.toString();
                    String username = 'Santhosh1 - FE';
                    String email = 'Santhosh1@gmail.com';
                    int age = 21;
                    String city = 'Pune';
                    DateTime createdAt = DateTime.now().toUtc();
                    bool isActive = true;

                    await _insertLocalData(
                      Users(
                        uid,
                        username,
                        email,
                        age,
                        city,
                        createdAt,
                        createdAt,
                        isActive,
                      ),
                      null,
                      tableName: 'USERS',
                    );
                    _getAllDataFromLocal();
                  },
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      child: const Text(
                        'Create user',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                FloatingActionButton(
                  onPressed: () async {
                    var uuid = Uuid.v1();

                    String uid = uuid.toString();
                    String username = 'Santhosh47 - FE - updated';
                    String email = 'Santhosh47@gmail.com';
                    int age = 10001;
                    String city = 'Lucknow';
                    DateTime updatedAt = DateTime.now().toUtc();
                    bool isActive = true;

                    await _updateLocalData(
                        Users(
                          uid,
                          username,
                          email,
                          age,
                          city,
                          updatedAt,
                          updatedAt,
                          isActive,
                        ),
                        null,
                        tableName: 'USERS');
                    _getAllDataFromLocal();
                  },
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      child: const Text(
                        'Update user',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                FloatingActionButton(
                  onPressed: () async {
                    var uuid = Uuid.v1();

                    String uid = uuid.toString();
                    String username = 'Santhosh36 - FE';
                    String email = 'Santhosh36@gmail.com';
                    int age = 21;
                    String city = 'Pune';
                    DateTime createdAt = DateTime.now().toUtc();
                    bool isActive = false;

                    await _deleteLocalData(
                      Users(
                        uid,
                        username,
                        email,
                        age,
                        city,
                        createdAt,
                        createdAt,
                        isActive,
                      ),
                      null,
                      tableName: 'USERS',
                    );
                    _getAllDataFromLocal();
                  },
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      child: const Text(
                        'Delete user',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                FloatingActionButton(
                  onPressed: () async {
                    await _getFreshCangeLogsFromLocalDb();
                    await _getFreshChangeLogsFromServer();
                    setState(() {});
                    _processData();
                    _getAllDataFromLocal();
                  },
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      child: const Text(
                        'Sync Data',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                FloatingActionButton(
                  onPressed: () async {
                    await _printLocalData();
                    await _printChangeLogLocalData();
                    _getAllDataFromLocal();
                  },
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      child: const Text(
                        'Print Data',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                FloatingActionButton(
                  onPressed: () async {
                    _deleteCangeLogsFromLocalDb();
                  },
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      child: const Text(
                        'Delete Changelogs',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                FloatingActionButton(
                  onPressed: () async {
                    var uuid = Uuid.v1();

                    String uid = uuid.toString();
                    String title = "book title";
                    String author = "book author";
                    String releaseYear = "1999";
                    DateTime createdAt = DateTime.now();
                    DateTime updatedAt = DateTime.now();
                    bool isActive = true;

                    await _insertLocalData(
                      null,
                      Book(
                        uid,
                        title,
                        author,
                        releaseYear,
                        createdAt,
                        createdAt,
                        isActive,
                      ),
                      tableName: 'BOOK',
                    );
                    _getAllDataFromLocal();
                  },
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      child: const Text(
                        'Create book',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                FloatingActionButton(
                  onPressed: () async {
                    var uuid = Uuid.v1();

                    String uid = uuid.toString();
                    String title = "book title";
                    String author = "book author";
                    String releaseYear = "1999";
                    DateTime createdAt = DateTime.now();
                    DateTime updatedAt = DateTime.now();
                    bool isActive = true;

                    await _updateLocalData(
                      null,
                      Book(
                        uid,
                        title,
                        author,
                        releaseYear,
                        createdAt,
                        createdAt,
                        isActive,
                      ),
                      tableName: 'BOOK',
                    );
                    _getAllDataFromLocal();
                  },
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      child: const Text(
                        'Update book',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                FloatingActionButton(
                  onPressed: () async {
                    var uuid = Uuid.v1();

                    String uid = uuid.toString();
                    String title = "book title";
                    String author = "book author";
                    String releaseYear = "1999";
                    DateTime createdAt = DateTime.now();
                    DateTime updatedAt = DateTime.now();
                    bool isActive = true;

                    await _deleteLocalData(
                      null,
                      Book(
                        uid,
                        title,
                        author,
                        releaseYear,
                        createdAt,
                        createdAt,
                        isActive,
                      ),
                      tableName: 'BOOK',
                    );
                    _getAllDataFromLocal();
                  },
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      child: const Text(
                        'Delete book',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                FloatingActionButton(
                  onPressed: () async {
                    await _getFreshCangeLogsFromLocalDb();
                    await _getFreshChangeLogsFromServer();
                    setState(() {});
                    _processData();
                    _getAllDataFromLocal();
                  },
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      child: const Text(
                        'Sync Data',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                FloatingActionButton(
                  onPressed: () async {
                    await _printLocalData();
                    await _printChangeLogLocalData();
                    _getAllDataFromLocal();
                  },
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      child: const Text(
                        'Print Data',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                FloatingActionButton(
                  onPressed: () async {
                    _deleteCangeLogsFromLocalDb();
                  },
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      child: const Text(
                        'Delete Changelogs',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
