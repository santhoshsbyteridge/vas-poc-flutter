import 'package:http/http.dart';
import 'package:realm_local_db/models/models.db.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePageApi {
  Future<List<Users>> getUsersApi() async {
    final List<Users> result = await http
        .get(Uri.parse(
            'https://1f10-2401-4900-1c53-1630-31db-ccc8-8676-c374.ngrok-free.app/api/user/getUsers'))
        .then((Response result) {
      final jsonData = jsonDecode(result.body);
      if (jsonData.isNotEmpty) {
        List<Users> usersResult = [];

        for (int i = 0; i < jsonData['data'].length; i++) {
          usersResult.add(Users(
            jsonData['data'][i]['id'],
            jsonData['data'][i]['username'],
            jsonData['data'][i]['email'],
            jsonData['data'][i]['age'],
            jsonData['data'][i]['city'],
            DateTime.parse(jsonData['data'][i]['createdAt']),
            DateTime.parse(jsonData['data'][i]['updatedAt']),
            jsonData['data'][i]['isActive'],
          ));
        }

        return usersResult;
      } else {
        return [];
      }
    });

    return result;
  }

  Future<List<ChangeLog>> getChangeLogApi({String? lastSyncedTime}) async {
    final List<ChangeLog> result = await http.post(
        Uri.parse(
            'https://1f10-2401-4900-1c53-1630-31db-ccc8-8676-c374.ngrok-free.app/api/changeLog/getChangeLogs'),
        body: {
          "timeStamp":
              DateTime.parse(lastSyncedTime.toString()).toUtc().toString()
        }).then((Response result) {
      final jsonData = jsonDecode(result.body);

      if (jsonData.isNotEmpty) {
        List<ChangeLog> usersResult = [];

        for (int i = 0; i < jsonData['data'].length; i++) {
          usersResult.add(ChangeLog(
            jsonData['data'][i]['userId'],
            jsonData['data'][i]['action'],
            jsonEncode(jsonData['data'][i]['data']),
            DateTime.parse(jsonData['data'][i]['createdAt']),
            DateTime.parse(jsonData['data'][i]['updatedAt']),
            jsonData['data'][i]['tableName'],
            updatedFields: jsonData['data'][i]['updatedFields'].cast<String>(),
          ));
        }

        return usersResult;
      } else {
        return [];
      }
    });

    return result;
  }

  Future<void> sendDataToServer(List<ChangeLog> data) async {
    List<Map<String, dynamic>> resultObj = [];

    for (int i = 0; i < data.length; i++) {
      Map<String, dynamic> tempData = {
        "uid": data[i].uid,
        "action": data[i].action,
        "data": jsonDecode(data[i].data),
        "tableName": data[i].tableName,
        "updatedFields": data[i].updatedFields,
        "createdAt": data[i].createdAt.toString(),
        "updatedAt": data[i].updatedAt.toString(),
      };

      resultObj.add(tempData);
    }

    await http.post(
        Uri.parse(
            'https://1f10-2401-4900-1c53-1630-31db-ccc8-8676-c374.ngrok-free.app/api/changeLog/syncData'),
        body: {"changeLogArray": jsonEncode(resultObj)});
    resultObj = [];
  }
}
