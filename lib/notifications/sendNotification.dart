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
          'key=AAAAvCxsCdo:APA91bHvgumizkX-yVWcjb9Y-d1o91ZbknfuiRQYrHyDLOlEfbxatxFWEuscFNV4XkfRYmMbnn_RwAyr6IAZqCWcS2TBGyPz77ut9xXOfSlDnWoAFmhy2H55i2uv9ypsUDMGObdXYEp5'
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
