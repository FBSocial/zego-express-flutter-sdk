import { MethodCall, MethodResult } from '@ohos/flutter_ohos';
import ZegoExpressEngine from '@ohos/ZegoExpressEngine';

export default class ZegoExpressEngineMethodHandler {
  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (call.method == "getVersion") {
      this.getVersion(call, result)
    } else {
      result.notImplemented()
    }
  }

  getVersion(call: MethodCall, result: MethodResult): void {
    result.success(ZegoExpressEngine.getSDKVersion())
  }
}