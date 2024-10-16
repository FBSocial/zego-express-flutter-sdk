import 'package:flutter/material.dart';
import 'package:zego_express_engine/src/wrap_platform_view/widgets/platform_view.dart' as wrap_platform_view;
import '../utils/zego_express_utils.dart';

/// Native implementation of [createPlatformView]
class ZegoExpressPlatformViewImpl {
  /// Create a PlatformView and return the view ID
  static Widget? createPlatformView(Function(int viewID) onViewCreated,
      {Key? key}) {
    if (kIsIOS || kIsMacOS) {
      return UiKitView(
          key: key,
          viewType: 'plugins.zego.im/zego_express_view',
          onPlatformViewCreated: (int viewID) {
            onViewCreated(viewID);
          });
    } else if (kIsAndroid) {
      return AndroidView(
          key: key,
          viewType: 'plugins.zego.im/zego_express_view',
          onPlatformViewCreated: (int viewID) {
            onViewCreated(viewID);
          });
    } else if (kIsOHOS) {
      return wrap_platform_view.OhosView(
          key: key,
          viewType: 'plugins.zego.im/zego_express_view',
          onPlatformViewCreated: (int viewID) {
            onViewCreated(viewID);
          });
    }
    return null;
  }
}
