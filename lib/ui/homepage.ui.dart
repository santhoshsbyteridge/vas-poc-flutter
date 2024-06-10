// // ignore_for_file: unnecessary_null_comparison

// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:realm/realm.dart';
// import 'package:realm_local_db/apis/homepage.api.dart';
// import 'package:realm_local_db/models/models.db.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   final Future<SharedPreferences> _sharedPreference =
//       SharedPreferences.getInstance();

//   final DateTime _dateTimeNow = DateTime.now().toUtc();
//   late DateTime _lastSyncTime = _dateTimeNow;

//   late Realm usersRealm;
//   late Realm usersRealmInsert;
//   late Realm usersRealmUpdate;
//   late Realm usersRealmDelete;
//   late Realm changeLogRealm;
//   late Configuration configuration;

//   final HomePageApi _homePageApi = HomePageApi();

//   final StreamController<List<Users>> _streamControllerUsers =
//       StreamController<List<Users>>();

//   List<Users> users = [];
//   List<ChangeLog> changeLogsServerData = [];
//   List<ChangeLog> changeLogsLocalData = [];

//   late RealmResults<Users> usersLocal;
//   late RealmResults<ChangeLog> changeLogsLocal;
//   List<Users> displayDatas = [];

//   _MyHomePageState() {
//     final usersConfig = Configuration.local([Users.schema]);
//     usersRealm = Realm(usersConfig);
//     usersRealmInsert = Realm(usersConfig);
//     usersRealmUpdate = Realm(usersConfig);
//     usersRealmDelete = Realm(usersConfig);
//     final changeLogConfig = Configuration.local([ChangeLog.schema]);
//     changeLogRealm = Realm(changeLogConfig);
//   }

//   @override
//   void initState() {
//     _getLastSyncTime();
//     _getUsersFromLocal();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     usersRealmInsert.close();
//     usersRealmUpdate.close();
//     usersRealmDelete.close();
//     changeLogRealm.close();
//     super.dispose();
//   }

//   void _getLastSyncTime() async {
//     final SharedPreferences sharedPreference = await _sharedPreference;
//     final String? lastSyncTimeString =
//         sharedPreference.getString('lastSyncTime');
//     if (lastSyncTimeString != null) {
//       _lastSyncTime = DateTime.parse(lastSyncTimeString);
//       setState(() {});
//     }
//   }

//   void _setLastSyncTime() async {
//     final SharedPreferences sharedPreference = await _sharedPreference;
//     sharedPreference.setString(
//         'lastSyncTime', DateTime.now().toUtc().toString());
//     final String? lastSyncTimeString =
//         sharedPreference.getString('lastSyncTime');
//     if (lastSyncTimeString != null) {
//       _lastSyncTime = DateTime.parse(lastSyncTimeString);
//       setState(() {});
//     }
//   }

//   Future<void> _manipulateLocalData(Users data, String action) async {
//     usersRealm.write(() async {
//       // the below addition value should change
//       switch (action) {
//         case 'INSERT':
//           {
//             usersRealm.add(data);
//             break;
//           }
//         case 'UPDATE':
//           {
//             List<String> updatedFields = [];
//             final oldData = usersRealm.find<Users>(data.email);

//             if (oldData != null) {
//               if (oldData.username != data.username) {
//                 oldData.username = data.username;
//                 updatedFields.add('username');
//               }
//               if (oldData.age != data.age) {
//                 oldData.age = data.age;
//                 updatedFields.add('age');
//               }
//               if (oldData.city != data.city) {
//                 oldData.city = data.city;
//                 updatedFields.add('city');
//               }
//               if (oldData.updatedAt != data.updatedAt) {
//                 oldData.updatedAt = data.updatedAt;
//                 // updatedFields.add('updatedAt');
//               }
//               if (oldData.isActive != data.isActive) {
//                 oldData.isActive = data.isActive;
//                 updatedFields.add('isActive');
//               }
//               data.createdAt = oldData.createdAt;
//               oldData.updatedAt = data.updatedAt;
//               data.updatedAt = oldData.updatedAt;
//             } else {
//               // data not found
//               _insertLocalData(data);
//             }
//             break;
//           }
//         case 'DELETE':
//           {
//             final obj = usersRealm.find<Users>(data.email);
//             if (obj != null && obj.isActive == true) {
//               // soft delete
//               data.id = obj.id;
//               data.username = obj.username;
//               data.createdAt = obj.createdAt;
//               obj.updatedAt = data.updatedAt;
//               data.updatedAt = obj.updatedAt;
//               obj.isActive = false;
//             } else {
//               // data not found
//               data.isActive = false;
//               _insertLocalData(data);
//             }
//             break;
//           }
//       }
//     });
//   }

//   Future<void> _getUsersFromLocal() async {
//     displayDatas.clear();
//     final datas = usersRealm.all<Users>();
//     for (int i = 0; i < datas.length; i++) {
//       displayDatas.add(datas[i]);
//     }
//     setState(() {});
//   }

//   // Future<void> _getUsersFromServer({bool? storeInLocalDB}) async {
//   //   users = await _homePageApi.getUsersApi();
//   //   _streamControllerUsers.add(users);
//   //   if (storeInLocalDB == true) {
//   //     for (int i = 0; i < users.length; i++) {
//   //       final Users userData = Users(
//   //         users[i].id,
//   //         users[i].username,
//   //         users[i].email,
//   //         users[i].age,
//   //         users[i].city,
//   //         users[i].createdAt,
//   //         users[i].updatedAt,
//   //         users[i].isActive,
//   //       );
//   //       await _insertLocalData(userData);
//   //     }
//   //   }
//   // }

//   // insert data to local realm db
//   Future<void> _insertLocalData(Users data) async {
//     bool operationDone = false;

//     usersRealmInsert.close();
//     print('closed');
//     await Future.delayed(const Duration(seconds: 2));
//     final usersConfig = Configuration.local([Users.schema]);
//     usersRealmInsert = Realm(usersConfig);
//     print('re initialized');
//     await Future.delayed(const Duration(seconds: 1));
//     print('write starts');
//     usersRealmInsert.write(() {
//       print('test a 000');
//       // the below addition value should change
//       usersRealmInsert.add(data);
//       print('test a 001');
//       operationDone = true;
//     });
//     if (operationDone == true) {
//       await _addingActionToChangeLogs('INSERT', data);
//     }
//   }

//   // update data to local realm db
//   Future<void> _updateLocalData(Users newData) async {
//     bool operationDone = false;
//     List<String> updatedFields = [];

//     // usersRealm.close();
//     // print('closed');
//     // await Future.delayed(const Duration(seconds: 2));
//     // final usersConfig = Configuration.local([Users.schema]);
//     // usersRealm = Realm(usersConfig);
//     // print('re initialized');
//     // await Future.delayed(const Duration(seconds: 1));
//     // print('write starts');
//     // if (usersRealm.isClosed) {
//     //   final usersConfig = Configuration.local([Users.schema]);
//     //   usersRealm = Realm(usersConfig);
//     //   print('re initialized');
//     //   await Future.delayed(const Duration(seconds: 4));
//     // }
//     // if (!usersRealm.isClosed) {
//     usersRealmUpdate.write(() {
//       final oldData = usersRealmUpdate.find<Users>(newData.email);

//       if (oldData != null) {
//         if (oldData.username != newData.username) {
//           oldData.username = newData.username;
//           updatedFields.add('username');
//         }
//         if (oldData.age != newData.age) {
//           oldData.age = newData.age;
//           updatedFields.add('age');
//         }
//         if (oldData.city != newData.city) {
//           oldData.city = newData.city;
//           updatedFields.add('city');
//         }
//         if (oldData.updatedAt != newData.updatedAt) {
//           oldData.updatedAt = newData.updatedAt;
//           // updatedFields.add('updatedAt');
//         }
//         if (oldData.isActive != newData.isActive) {
//           oldData.isActive = newData.isActive;
//           updatedFields.add('isActive');
//         }
//         newData.createdAt = oldData.createdAt;
//         oldData.updatedAt = newData.updatedAt;
//         newData.updatedAt = oldData.updatedAt;
//         operationDone = true;
//       } else {
//         // data not found
//         _insertLocalData(newData);
//       }
//     });
//     if (operationDone == true) {
//       await _addingActionToChangeLogs('UPDATE', newData,
//           updatedFields: updatedFields);
//     }
//     // }
//   }

//   // delete data to local realm db
//   Future<void> _deleteLocalData(Users data) async {
//     bool operationDone = false;

//     // usersRealm.close();
//     // print('closed');
//     // await Future.delayed(const Duration(seconds: 2));
//     // final usersConfig = Configuration.local([Users.schema]);
//     // usersRealm = Realm(usersConfig);
//     // print('re initialized');
//     // await Future.delayed(const Duration(seconds: 1));
//     // print('write starts');

//     usersRealm.write(() {
//       // the below deletion value should change
//       print('test 000');
//       final obj = usersRealm.find<Users>(data.email);
//       print('test 001');
//       if (obj != null && obj.isActive == true) {
//         print('test 003');
//         // soft delete
//         data.id = obj.id;
//         data.username = obj.username;
//         data.createdAt = obj.createdAt;
//         obj.updatedAt = data.updatedAt;
//         data.updatedAt = obj.updatedAt;
//         obj.isActive = false;
//         operationDone = true;
//         print('test 004');
//       } else {
//         // data not found
//         print('test 005');

//         data.isActive = false;
//         _insertLocalData(data);
//         print('test 006');
//       }
//     });
//     if (operationDone == true) {
//       await _addingActionToChangeLogs('DELETE', data,
//           updatedFields: ['isActive']);
//     }
//   }

//   // adding actions to changelogs table
//   Future<void> _addingActionToChangeLogs(String action, Users data,
//       {List<String>? updatedFields}) async {
//     // changeLogRealm.close();
//     // print('closed');
//     // await Future.delayed(const Duration(seconds: 2));
//     // final changeLogConfig = Configuration.local([ChangeLog.schema]);
//     // changeLogRealm = Realm(changeLogConfig);
//     // print('re initialized');
//     // await Future.delayed(const Duration(seconds: 1));
//     // print('write starts');

//     changeLogRealm.write(() {
//       print('test 007');
//       final List<String> tempUpdateFields = updatedFields ?? [];
//       final oldObject = changeLogRealm.all<ChangeLog>();
//       for (int i = oldObject.length - 1; i >= 0; i--) {
//         if (oldObject[i].userId == data.id &&
//             (action == 'UPDATE' || action == 'DELETE')) {
//           for (int a = 0; a < oldObject[i].updatedFields.length; a++) {
//             if (!(tempUpdateFields.contains(oldObject[i].updatedFields[a]))) {
//               tempUpdateFields.add(oldObject[i].updatedFields[a]);
//             }
//           }
//           break;
//         }
//       }
//       print('test 008');
//       final DateTime createdAt = DateTime.now().toUtc();
//       final dataString = jsonEncode({
//         "id": data.id,
//         "username": data.username,
//         "email": data.email,
//         "age": data.age,
//         "city": data.city,
//         "createdAt": data.createdAt.toString(),
//         "updatedAt": data.updatedAt.toString(),
//         "isActive": data.isActive
//       });
//       print('test 008');
//       changeLogRealm.add(ChangeLog(
//           data.id, action, dataString, createdAt, createdAt, 'USERS',
//           updatedFields: tempUpdateFields.isNotEmpty
//               ? tempUpdateFields as Iterable<String>
//               : []));
//       print('test 009');
//     });
//   }

//   // get fresh new changelogs from local db
//   Future<void> _getFreshCangeLogsFromLocalDb() async {
//     final data = changeLogRealm.all<ChangeLog>();

//     final userIdsAdded = [];

//     // adding in descending order
//     for (int i = data.length - 1; i >= 0; i--) {
//       if (!userIdsAdded.contains(data[i].userId)) {
//         print(data[i].action + ' ' + data[i].data);
//         changeLogsLocalData.add(ChangeLog(
//           data[i].userId,
//           data[i].action,
//           data[i].data,
//           data[i].createdAt,
//           data[i].updatedAt,
//           data[i].tableName,
//           updatedFields: data[i].updatedFields,
//         ));
//         userIdsAdded.add(data[i].userId);
//       }
//     }
//   }

//   // get fresh new changelogs from server
//   Future<void> _getFreshChangeLogsFromServer() async {
//     changeLogsServerData = await _homePageApi.getChangeLogApi(
//         lastSyncedTime: _lastSyncTime.toString());
//   }

//   // delete local db changelogs
//   Future<void> _deleteCangeLogsFromLocalDb() async {
//     changeLogRealm.write(() {
//       changeLogRealm.deleteAll<ChangeLog>();
//     });
//   }

//   Future<void> _printUsersLocalData() async {
//     final datas = usersRealm.all<Users>();
//     print('in _printUsersLocalData method');
//     for (int i = 0; i < datas.length; i++) {
//       print(i);
//       print(datas[i].username);
//       print(datas[i].email);
//       print(datas[i].isActive);
//       print(datas[i].createdAt);
//       print(datas[i].updatedAt);
//     }
//   }

//   Future<void> _printChangeLogLocalData() async {
//     // checking all the data
//     final datas = changeLogRealm.all<ChangeLog>();
//     print('in _printChangeLogLocalData method');
//     for (int i = 0; i < datas.length; i++) {
//       print(i);
//       print(datas[i].userId);
//       print(datas[i].action);
//       print(datas[i].data);
//       print(datas[i].updatedFields);
//       print(datas[i].tableName);
//     }
//   }

//   Future<void> _processData() async {
//     List<ChangeLog> updatesRequiredOnLocal =
//         changeLogsLocalData.isEmpty ? changeLogsServerData : [];
//     List<ChangeLog> updatesRequiredOnServer = [];
//     print('_process data iniialization done');
//     for (int i = changeLogsLocalData.length - 1; i >= 0; i--) {
//       print(changeLogsLocalData[i].action);
//       print(changeLogsLocalData[i].data);
//       String localEmail = jsonDecode(changeLogsLocalData[i].data)['email'];
//       DateTime localUpdatedAt = changeLogsLocalData[i].updatedAt;
//       List<String> updatedFieldsLocal = changeLogsLocalData[i].updatedFields;

//       for (int j = 0; j <= changeLogsServerData.length - 1; j++) {
//         print('changeLogsServerData');
//         print(changeLogsServerData[j].data);
//         String serverEmail = jsonDecode(changeLogsServerData[j].data)['email'];
//         DateTime serverUpdatedAt = changeLogsServerData[j].updatedAt;
//         List<String> updatedFieldsServer =
//             changeLogsServerData[j].updatedFields;

//         if (localEmail == serverEmail) {
//           print('i am here 000');
//           if (updatedFieldsLocal.isNotEmpty &&
//               updatedFieldsServer.isNotEmpty &&
//               !isMergeConflictPresent(
//                   updatedFieldsLocal, updatedFieldsServer)) {
//             print('i am here 001');
//             Map<String, dynamic> resultObj =
//                 jsonDecode(changeLogsLocalData[i].data);

//             List<String> userTableCols = [
//               'username',
//               'email',
//               'age',
//               'city',
//               'isActive'
//             ];

//             for (int a = 0; a < userTableCols.length; a++) {
//               if (updatedFieldsLocal.contains(userTableCols[a])) {
//                 resultObj[userTableCols[a]] =
//                     jsonDecode(changeLogsLocalData[i].data)[userTableCols[a]];
//               } else if (updatedFieldsServer.contains(userTableCols[a])) {
//                 resultObj[userTableCols[a]] =
//                     jsonDecode(changeLogsServerData[j].data)[userTableCols[a]];
//               }
//             }

//             updatesRequiredOnServer.add(ChangeLog(
//               resultObj['userId'] ?? 123,
//               resultObj['action'] ?? 'UPDATE',
//               jsonEncode(resultObj),
//               changeLogsLocalData[i].createdAt,
//               changeLogsLocalData[i].updatedAt,
//               changeLogsLocalData[i].tableName,
//               updatedFields: changeLogsLocalData[i].updatedFields,
//             ));
//             updatesRequiredOnLocal.add(ChangeLog(
//               resultObj['userId'] ?? 123,
//               resultObj['action'] ?? 'UPDATE',
//               jsonEncode(resultObj),
//               changeLogsServerData[j].createdAt,
//               changeLogsServerData[j].updatedAt,
//               changeLogsServerData[j].tableName,
//             ));
//           } else {
//             print('i am here 002');
//             if (localUpdatedAt.compareTo(serverUpdatedAt) > 0) {
//               changeLogsLocalData[i].action = 'UPDATE';
//               // We need to update server with local data
//               updatesRequiredOnServer.add(changeLogsLocalData[i]);
//             } else if (localUpdatedAt.compareTo(serverUpdatedAt) < 0) {
//               changeLogsServerData[j].action = 'UPDATE';
//               // We need to update local with server data
//               updatesRequiredOnLocal.add(changeLogsServerData[j]);
//             }
//           }
//         } else if (localEmail != serverEmail) {
//           updatesRequiredOnServer.add(changeLogsLocalData[i]);
//           updatesRequiredOnLocal.add(changeLogsServerData[j]);
//         }
//       }
//     }
//     print('_process data logic done');

//     // Remove duplicate data from updatesRequiredOnLocal and sort it in ascending order of updatedAt
//     List<ChangeLog> listWithoutDuplicates = [];

//     for (ChangeLog item in updatesRequiredOnLocal) {
//       if (!listWithoutDuplicates.contains(item)) {
//         listWithoutDuplicates.add(item);
//       }
//     }
//     updatesRequiredOnLocal = listWithoutDuplicates;

//     print('_process data removing duplicates done for updatesRequiredOnLocal');
//     print(updatesRequiredOnLocal);

//     // Remove duplicate data from updatesRequiredOnServer and sort it in ascending order of updatedAt
//     listWithoutDuplicates = [];
//     print(updatesRequiredOnServer);
//     updatesRequiredOnServer = changeLogsServerData.isEmpty
//         ? changeLogsLocalData
//         : updatesRequiredOnServer;
//     for (ChangeLog item in updatesRequiredOnServer) {
//       if (!listWithoutDuplicates.contains(item)) {
//         listWithoutDuplicates.add(item);
//       }
//     }
//     updatesRequiredOnServer = listWithoutDuplicates;
//     print('_process data removing duplicates done for updatesRequiredOnServer');
//     print(updatesRequiredOnServer);

//     await _syncDataBackend(updatesRequiredOnServer);
//     print('_process data backend sync done');

//     await _syncDataFrontend(updatesRequiredOnLocal);
//     print('_process data frontend sync done');

//     _deleteCangeLogsFromLocalDb();
//     print('_process data changeLogs local db deletion done');

//     _setLastSyncTime();
//     print('_process data last sync time is set');

//     _deleteCangeLogsFromLocalDb();
//     print('_process data changeLogs local db deletion done');

//     _clearAllArrays();
//     print('_process data all arrays are cleared');

//     print('SYNC DONE');
//   }

//   // Future<void> _processDataV2() async {
//   //   List<ChangeLog> updatesRequiredOnLocal =
//   //       changeLogsLocalData.isEmpty ? changeLogsServerData : [];
//   //   List<ChangeLog> updatesRequiredOnServer = [];
//   //   print('_process data iniialization done');
//   //   for (int i = changeLogsLocalData.length - 1; i >= 0; i--) {
//   //     print(changeLogsLocalData[i].action);
//   //     print(changeLogsLocalData[i].data);
//   //     String localEmail = jsonDecode(changeLogsLocalData[i].data)['email'];
//   //     DateTime localUpdatedAt = changeLogsLocalData[i].updatedAt;
//   //     for (int j = 0; j <= changeLogsServerData.length - 1; j++) {
//   //       print('changeLogsServerData');
//   //       print(changeLogsServerData[i].data);
//   //       String serverEmail = jsonDecode(changeLogsServerData[i].data)['email'];
//   //       DateTime serverUpdatedAt = changeLogsServerData[i].updatedAt;
//   //       if (localEmail == serverEmail) {
//   //         print(localUpdatedAt);
//   //         print('---');
//   //         print(serverUpdatedAt);
//   //         if (localUpdatedAt.compareTo(serverUpdatedAt) > 0) {
//   //           changeLogsLocalData[i].action = 'UPDATE';
//   //           // We need to update server with local data
//   //           updatesRequiredOnServer.add(changeLogsLocalData[i]);
//   //         } else if (localUpdatedAt.compareTo(serverUpdatedAt) < 0) {
//   //           changeLogsServerData[j].action = 'UPDATE';
//   //           // We need to update local with server data
//   //           updatesRequiredOnLocal.add(changeLogsServerData[j]);
//   //         }
//   //       } else if (localEmail != serverEmail) {
//   //         updatesRequiredOnServer.add(changeLogsLocalData[i]);
//   //         updatesRequiredOnLocal.add(changeLogsServerData[j]);
//   //       }
//   //     }
//   //   }
//   //   print('_process data logic done');
//   //   // Remove duplicate data from updatesRequiredOnLocal and sort it in ascending order of updatedAt
//   //   List<ChangeLog> listWithoutDuplicates = [];
//   //   for (ChangeLog item in updatesRequiredOnLocal) {
//   //     if (!listWithoutDuplicates.contains(item)) {
//   //       listWithoutDuplicates.add(item);
//   //     }
//   //   }
//   //   updatesRequiredOnLocal = listWithoutDuplicates;
//   //   print('_process data removing duplicates done for updatesRequiredOnLocal');
//   //   print(updatesRequiredOnLocal);
//   //   // Remove duplicate data from updatesRequiredOnServer and sort it in ascending order of updatedAt
//   //   listWithoutDuplicates = [];
//   //   print(updatesRequiredOnServer);
//   //   updatesRequiredOnServer = changeLogsServerData.isEmpty
//   //       ? changeLogsLocalData
//   //       : updatesRequiredOnServer;
//   //   for (ChangeLog item in updatesRequiredOnServer) {
//   //     if (!listWithoutDuplicates.contains(item)) {
//   //       listWithoutDuplicates.add(item);
//   //     }
//   //   }
//   //   updatesRequiredOnServer = listWithoutDuplicates;
//   //   print('_process data removing duplicates done for updatesRequiredOnServer');
//   //   print(updatesRequiredOnServer);
//   //   await _syncDataFrontend(updatesRequiredOnLocal);
//   //   print('_process data frontend sync done');
//   //   await _syncDataBackend(updatesRequiredOnServer);
//   //   print('_process data backend sync done');
//   //   _setLastSyncTime();
//   //   print('_process data last sync time is set');
//   //   _deleteCangeLogsFromLocalDb();
//   //   print('_process data changeLogs local db deletion done');
//   //   _clearAllArrays();
//   //   print('_process data all arrays are cleared');
//   //   print('SYNC DONE');
//   // }

//   void _clearAllArrays() {
//     changeLogsLocalData = [];
//     changeLogsServerData = [];
//     setState(() {});
//   }

//   Future<void> _syncDataFrontend(List<ChangeLog> data) async {
//     for (int i = 0; i <= data.length - 1; i++) {
//       String action = data[i].action;
//       print(action);
//       Map<String, dynamic> userData = jsonDecode(data[i].data);
//       switch (action) {
//         case 'INSERT':
//           {
//             print('i am in insert');

//             await _insertLocalData(Users(
//               userData['id'],
//               userData['username'],
//               userData['email'],
//               userData['age'],
//               userData['city'],
//               DateTime.parse(userData['createdAt']),
//               DateTime.parse(userData['updatedAt']),
//               userData['isActive'],
//             ));
//             break;
//           }
//         case 'UPDATE':
//           {
//             print('i am in update');

//             await _updateLocalData(Users(
//               userData['id'],
//               userData['username'],
//               userData['email'],
//               userData['age'],
//               userData['city'],
//               DateTime.parse(userData['createdAt']),
//               DateTime.parse(userData['updatedAt']),
//               userData['isActive'],
//             ));
//             break;
//           }
//         case 'DELETE':
//           {
//             print('i am in delete');
//             await _deleteLocalData(Users(
//               userData['id'],
//               userData['username'],
//               userData['email'],
//               userData['age'],
//               userData['city'],
//               DateTime.parse(userData['createdAt']),
//               DateTime.parse(userData['updatedAt']),
//               userData['isActive'],
//             ));
//             break;
//           }
//       }
//     }
//   }

//   Future<void> _syncDataBackend(List<ChangeLog> data) async {
//     await _homePageApi.sendDataToServer(data);
//   }

//   bool isMergeConflictPresent(List<dynamic> list1, List<dynamic> list2) {
//     // Create a sorted copy of the lists
//     List<dynamic> sortedList1 = List.from(list1)..sort();
//     List<dynamic> sortedList2 = List.from(list2)..sort();

//     // Compare the sorted lists
//     for (int i = 0; i < sortedList1.length; i++) {
//       for (int j = 0; j < sortedList2.length; j++) {
//         if (sortedList1[i] == sortedList2[j]) {
//           return true;
//         }
//       }
//     }

//     return false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('VAS POC'),
//       ),
//       body: Center(
//         child: ListView(
//           children: [
//             for (int i = 0; i < displayDatas.length; i++)
//               Card(
//                 child: Column(
//                   children: [
//                     Text(displayDatas[i].username),
//                     Text(displayDatas[i].email),
//                     Text(displayDatas[i].age.toString()),
//                     Text(displayDatas[i].city),
//                     Text(displayDatas[i].isActive.toString()),
//                     Text(displayDatas[i].createdAt.toString()),
//                     Text(displayDatas[i].updatedAt.toString()),
//                   ],
//                 ),
//               ),
//             Container(
//               height: 100,
//             )
//           ],
//         ),
//       ),
//       floatingActionButton: Container(
//         padding: const EdgeInsets.only(left: 30),
//         child: Row(
//           children: [
//             FloatingActionButton(
//               onPressed: () async {
//                 int id = 48;
//                 String username = 'Santhosh48 - FE';
//                 String email = 'Santhosh48@gmail.com';
//                 int age = 21;
//                 String city = 'Pune';
//                 DateTime createdAt = DateTime.now().toUtc();
//                 bool isActive = true;

//                 await _insertLocalData(Users(
//                   id,
//                   username,
//                   email,
//                   age,
//                   city,
//                   createdAt,
//                   createdAt,
//                   isActive,
//                 ));
//                 _getUsersFromLocal();
//               },
//               child: Center(
//                 child: Container(
//                   padding: const EdgeInsets.all(5),
//                   child: const Text(
//                     'Create',
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//             ),
//             const Spacer(),
//             FloatingActionButton(
//               onPressed: () async {
//                 int id = 47;
//                 String username = 'Santhosh47 - FE - updated';
//                 String email = 'Santhosh47@gmail.com';
//                 int age = 10001;
//                 String city = 'Lucknow';
//                 DateTime updatedAt = DateTime.now().toUtc();
//                 bool isActive = true;

//                 await _updateLocalData(Users(
//                   id,
//                   username,
//                   email,
//                   age,
//                   city,
//                   updatedAt,
//                   updatedAt,
//                   isActive,
//                 ));
//                 _getUsersFromLocal();
//               },
//               child: Center(
//                 child: Container(
//                   padding: const EdgeInsets.all(5),
//                   child: const Text(
//                     'Update',
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//             ),
//             const Spacer(),
//             FloatingActionButton(
//               onPressed: () async {
//                 int id = 36;
//                 String username = 'Santhosh36 - FE';
//                 String email = 'Santhosh36@gmail.com';
//                 int age = 21;
//                 String city = 'Pune';
//                 DateTime createdAt = DateTime.now().toUtc();
//                 bool isActive = false;

//                 await _deleteLocalData(Users(
//                   id,
//                   username,
//                   email,
//                   age,
//                   city,
//                   createdAt,
//                   createdAt,
//                   isActive,
//                 ));
//                 _getUsersFromLocal();
//               },
//               child: Center(
//                 child: Container(
//                   padding: const EdgeInsets.all(5),
//                   child: const Text(
//                     'Delete',
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//             ),
//             const Spacer(),
//             FloatingActionButton(
//               onPressed: () async {
//                 await _getFreshCangeLogsFromLocalDb();
//                 await _getFreshChangeLogsFromServer();
//                 setState(() {});
//                 _processData();
//                 _getUsersFromLocal();
//               },
//               child: Center(
//                 child: Container(
//                   padding: const EdgeInsets.all(5),
//                   child: const Text(
//                     'Sync Data',
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//             ),
//             const Spacer(),
//             FloatingActionButton(
//               onPressed: () async {
//                 await _printUsersLocalData();
//                 await _printChangeLogLocalData();
//                 _getUsersFromLocal();
//               },
//               child: Center(
//                 child: Container(
//                   padding: const EdgeInsets.all(5),
//                   child: const Text(
//                     'Print Data',
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//             ),
//             const Spacer(),
//             FloatingActionButton(
//               onPressed: () async {
//                 _deleteCangeLogsFromLocalDb();
//               },
//               child: Center(
//                 child: Container(
//                   padding: const EdgeInsets.all(5),
//                   child: const Text(
//                     'Delete Changelogs',
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
