import 'dart:io';

import 'package:zego_express_engine/zego_express_engine.dart' show ZegoScenario;

class ZegoConfig {
  static final ZegoConfig instance = ZegoConfig._internal();

  ZegoConfig._internal();

  int appID = 1657178724;

  // It is for native only, do not use it for web!
  String appSign =
      "98321dcf875c03fb985c80ba98bc431ab6a9cc4b6b925c9b5213ebdc46f5a16d";

  // It is required for web and is recommended for native but not required.
  String token = "";

  ZegoScenario scenario = ZegoScenario.Default;
  bool enablePlatformView = false;

  String userID = Platform.isAndroid ? 'android_user_id' : 'ohos_user_id';
  String userName = Platform.isAndroid ? 'android_user_name' : 'ohos_user_name';

  bool isPreviewMirror = true;
  bool isPublishMirror = false;

  bool enableHardwareEncoder = false;
}
