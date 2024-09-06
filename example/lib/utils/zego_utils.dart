import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ZegoUtils {
  static showAlert(BuildContext context, String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Tips'),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  static bool get isOHOS =>
      !kIsWeb && Platform.operatingSystem.toLowerCase().contains('ohos');
}
