import { Any, FlutterPluginBinding, MethodCall, MethodResult } from '@ohos/flutter_ohos';
import ZegoExpressEngine, { ZegoScenario, ZegoEngineProfile, ZegoEngineConfig } from '@ohos/ZegoExpressEngine';
import { EventSink } from '@ohos/flutter_ohos/src/main/ets/plugin/common/EventChannel'
import { zegoLogger } from './ZegoLog';
import { zegoExpressEngineEventHandler } from './ZegoExpressEngineEventHandler';

export default class ZegoExpressEngineMethodHandler {
  private context: Context | null = null
  private pluginBinding: FlutterPluginBinding | null = null
  private pluginReported: boolean = false

  onMethodCall(call: MethodCall, result: MethodResult, binding: FlutterPluginBinding | null,
    sink: EventSink | null): void {
    if (call.method == 'getVersion') {
      this.getVersion(call, result)
    } else if (call.method == 'createEngineWithProfile') {
      this.createEngineWithProfile(call, result, binding, sink)
    } else {
      result.notImplemented()
    }
  }

  getVersion(call: MethodCall, result: MethodResult): void {
    result.success(ZegoExpressEngine.getSDKVersion())
  }

  createEngineWithProfile(call: MethodCall, result: MethodResult, binding: FlutterPluginBinding | null,
    sink: EventSink | null): void {
    if (binding == null) {
      zegoLogger.error('[createEngine] FlutterPluginBinding is null');
      result.success(null);
      return;
    }
    if (sink == null) {
      zegoLogger.error('[createEngine] FlutterEventSink or FlutterPluginBinding is null');
      result.success(null);
      return;
    }

    this.reportPluginInfo();

    this.pluginBinding = binding
    this.context = binding?.getApplicationContext() ?? null
    zegoExpressEngineEventHandler.eventSink = sink

    let profileMap: Map<string, Any> = call.argument('profile')
    let appID: number = profileMap.get('appID')
    let appSign: string = profileMap.get('appSign')
    let scenarioValue = Math.min(10, Math.max(0, profileMap.get('scenario')))
    let zegoScenario: ZegoScenario = scenarioValue as ZegoScenario
    let enablePlatformView: boolean = profileMap.get('enablePlatformView')

    let profile: ZegoEngineProfile = new ZegoEngineProfile(appID, appSign, zegoScenario, this.context)
    ZegoExpressEngine.createEngine(profile).then((engineInstance) => {
      if (engineInstance != null) {
        zegoLogger.debug('create Engine successful!')
        zegoExpressEngineEventHandler.initSDKEvent(engineInstance)
      }
    })
  }

  private reportPluginInfo(): void {
    if (this.pluginReported) {
      return
    }
    this.pluginReported = true;

    let advancedConfigMap = new Map<string, string>();
    advancedConfigMap['thirdparty_framework_info'] = 'flutter'

    let zegoEngineConfig: ZegoEngineConfig = new ZegoEngineConfig()
    zegoEngineConfig.advancedConfig = advancedConfigMap

    ZegoExpressEngine.setEngineConfig(zegoEngineConfig)
  }
}