import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class SendNotification {
  sendNotification(String reveiverToken, String title, String body) async {
    var data = {
      'to': reveiverToken,
      'notification': {
        'title': title,
        'body': body,
      },
      'android': {
        'notification': {
          'notification_count': 23,
        },
      },
      'data': {'type': 'msj', 'id': 'civil app'}
    };

    await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
        body: jsonEncode(data),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
          'key=AAAAV4YkUdc:APA91bH8rsPSqDdwhZfZKK-xC3_g6TJj1xFF7t3h6dNhu5m15NZ8vYhtyL6xw_qLnwYYAFK_NsYSUo_ClxHzszp-XZWCaZmAmdh1y_yiX3ACWtCsNwxiOhSKB0RwiaGplGO2IzHdxDjb'
        }).then((value) {
      if (kDebugMode) {
        print(value.body.toString());
      }
    }).onError((error, stackTrace) {
      if (kDebugMode) {
        print(error);
      }
    });
  }
}