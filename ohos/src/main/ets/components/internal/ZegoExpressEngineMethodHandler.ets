import { Any, FlutterPluginBinding, MethodCall, MethodResult } from '@ohos/flutter_ohos';
import ZegoExpressEngine, {
  ZegoScenario,
  ZegoEngineProfile,
  ZegoEngineConfig,
  ZegoUser,
  ZegoRoomConfig,
  ZegoRoomState,
} from '@ohos/ZegoExpressEngine';
import { EventSink } from '@ohos/flutter_ohos/src/main/ets/plugin/common/EventChannel'
import { zegoLogger } from './ZegoLog';
import { zegoExpressEngineEventHandler } from './ZegoExpressEngineEventHandler';
import { HashMap } from '@kit.ArkTS';

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
    } else if (call.method == 'setPluginVersion') {
      this.setPluginVersion(call, result)
    } else if (call.method == 'loginRoom') {
      this.loginRoom(call, result)
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
    result.success(null);
  }

  setPluginVersion(call: MethodCall, result: MethodResult): void {
    let version: string = call.argument('version')
    zegoLogger.debug('*** Plugin Version: ' + version)
    result.success(null)
  }

  loginRoom(call: MethodCall, result: MethodResult): void {
    let roomID: string = call.argument('roomID')

    let userMap: Map<string, Any> | null = call.argument('user')
    let user = new ZegoUser()
    if (userMap != null && userMap.size != 0) {
      user.userID = userMap.get('userID')
      user.userName = userMap.get('userName')
    }

    let configMap: Map<string, Any> | null = call.argument('config')
    let roomConfig: ZegoRoomConfig = new ZegoRoomConfig()
    if (configMap != null && configMap.size != 0) {
      roomConfig.isUserStatusNotify = (configMap.get('isUserStatusNotify') as boolean | null) ?? false
      roomConfig.maxMemberCount = (configMap.get('maxMemberCount') as number | null) ?? 0
      roomConfig.token = configMap.get('token')
    }
    ZegoExpressEngine.getInstance()?.loginRoom(roomID, user, roomConfig)
    ZegoExpressEngine.getInstance()?.on('onRoomStateUpdate',
      (roomID: string, state: ZegoRoomState, errorCode: number, extendedData: string) => {
        let map: HashMap<string, Any> = new HashMap()
        map.set('errorCode', errorCode)
        map.set('extendedData', extendedData.toString())
        result.success(map)
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