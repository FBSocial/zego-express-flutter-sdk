import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';

import ZegoExpressEngineMethodHandler from '../internal/ZegoExpressEngineMethodHandler'
import { zegoLogger } from '../internal/ZegoLog'

/** ZegoExpressFlutterSdkPlugin **/
export default class ZegoExpressFlutterSdkPlugin implements FlutterPlugin, MethodCallHandler {
  private channel: MethodChannel | null = null;
  private methodHandler: ZegoExpressEngineMethodHandler | null = null;

  constructor() {
  }

  getUniqueClassName(): string {
    return "ZegoExpressFlutterSdkPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "plugins.zego.im/zego_express_engine");
    this.channel.setMethodCallHandler(this)
    this.methodHandler = new ZegoExpressEngineMethodHandler();
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null)
    }
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    zegoLogger.debug(call.method)
    this.methodHandler?.onMethodCall(call, result)
  }
}