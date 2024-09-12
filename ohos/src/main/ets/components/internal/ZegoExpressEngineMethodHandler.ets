import { Any, FlutterPluginBinding, MethodCall, MethodResult, TextureRegistry } from '@ohos/flutter_ohos';
import ZegoExpressEngine, {
  ZegoScenario,
  ZegoEngineProfile,
  ZegoEngineConfig,
  ZegoUser,
  ZegoRoomConfig,
  ZegoRoomState,
  ZegoPlayerConfig,
  ZegoStreamResourceMode,
  ZegoVideoCodecID,
  ZegoResourceType,
  ZegoStreamResourceSwitchMode,
  ZegoStreamResourceType,
  ZegoCDNConfig,
  ZegoViewMode,
  ZegoView,
  ZegoPublishChannel,
} from '@ohos/ZegoExpressEngine';
import { EventSink } from '@ohos/flutter_ohos/src/main/ets/plugin/common/EventChannel'
import { zegoLogger } from './ZegoLog';
import { zegoExpressEngineEventHandler } from './ZegoExpressEngineEventHandler';
import { HashMap } from '@kit.ArkTS';
import { zegoTextureRendererController } from './ZegoTextureRendererController';
import { zegoPlatformViewFactory } from '../internal/ZegoPlatformViewFactory'

export default class ZegoExpressEngineMethodHandler {
  private context: Context | null = null
  private pluginBinding: FlutterPluginBinding | null = null
  private pluginReported: boolean = false
  private textureRegistry: TextureRegistry | null = null
  private enablePlatformView: boolean = false

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
    } else if (call.method == 'createTextureRenderer') {
      this.createTextureRenderer(call, result)
    } else if (call.method == 'startPlayingStream') {
      this.startPlayingStream(call, result)
    } else if (call.method == 'stopPlayingStream') {
      this.stopPlayingStream(call, result)
    } else if (call.method == 'destroyPlatformView') {
      this.destroyPlatformView(call, result)
    } else if (call.method == 'startPreview') {
      this.startPreview(call, result)
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
    this.textureRegistry = binding?.getTextureRegistry() ?? null
    zegoExpressEngineEventHandler.eventSink = sink

    let profileMap: Map<string, Any> = call.argument('profile')
    let appID: number = profileMap.get('appID')
    let appSign: string = profileMap.get('appSign')
    let scenarioValue = Math.min(10, Math.max(0, profileMap.get('scenario')))
    let zegoScenario: ZegoScenario = scenarioValue as ZegoScenario
    this.enablePlatformView = profileMap.get('enablePlatformView')

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

  createTextureRenderer(call: MethodCall, result: MethodResult): void {
    let width: number = call.argument('width') as number
    let height: number = call.argument('height') as number
    let textureRegistry = this.pluginBinding?.getTextureRegistry()
    let textureID: number = zegoTextureRendererController.createTextureRenderer(textureRegistry, width, height)
    zegoLogger.debug("[createTextureRenderer][Result] w: " + width + ", h: " + height + ", textureID: " + textureID);
    result.success(textureID)
  }

  startPlayingStream(call: MethodCall, result: MethodResult): void {
    let streamID: string = call.argument('streamID')

    // ZegoPlayerConfig
    let playerConfig: ZegoPlayerConfig | null = null
    let playerConfigMap: Map<string, Any> | null = call.argument('config')
    if (playerConfigMap != null && playerConfigMap.size > 0) {
      playerConfig = new ZegoPlayerConfig()
      playerConfig.resourceMode = playerConfigMap.get('resourceMode') as ZegoStreamResourceMode
      playerConfig.videoCodecID = playerConfigMap.get("videoCodecID") as ZegoVideoCodecID
      playerConfig.roomID = playerConfigMap.get('roomID')
      playerConfig.sourceResourceType = playerConfigMap.get("sourceResourceType") as ZegoResourceType
      playerConfig.codecTemplateID = playerConfigMap.get("codecTemplateID")
      playerConfig.resourceSwitchMode = playerConfigMap.get("resourceSwitchMode") as ZegoStreamResourceSwitchMode
      playerConfig.resourceWhenStopPublish = playerConfigMap.get("resourceWhenStopPublish") as ZegoStreamResourceType
      let cdnConfigMap: Map<string, Any> | null = call.argument('cdnConfig')
      if (cdnConfigMap != null && cdnConfigMap.size > 0) {
        let cdnConfig = new ZegoCDNConfig()
        cdnConfig.url = cdnConfigMap.get('url')
        cdnConfig.authParam = cdnConfigMap.get('authParam')
        playerConfig.cdnConfig = cdnConfig
      }
    }

    // ZegoCanvas
    let canvasMap: Map<string, Any> | null = call.argument('canvas')
    if (canvasMap != null && canvasMap.size > 0) {
      let viewID: number = canvasMap.get('view')
      let viewMode = canvasMap.get('viewMode') as ZegoViewMode
      let backgroundColor: number = canvasMap.get("backgroundColor")
      let alphaBlend: boolean = canvasMap.get("alphaBlend")
      if (!this.enablePlatformView) {
        result.error('[startPlayingStream]', 'only support platform view', '')
        return
      }
      let platformView = zegoPlatformViewFactory.getPlatformView(viewID)
      if (platformView == undefined) {
        result.error('startPlayingStream', 'PlatformView undefined',
          `The PlatformView for viewID:${viewID} cannot be found, developer should call createPlatformView first and get the viewID`)
        return
      }

      let zegoView = new ZegoView()
      zegoView.view = platformView.viewId.toString()
      zegoView.viewMode = viewMode
      zegoView.backgroundColor = backgroundColor
      zegoView.alphaBlend = alphaBlend

      ZegoExpressEngine.getInstance()?.startPlayingStream(streamID, zegoView, playerConfig)
    } else {
      ZegoExpressEngine.getInstance()?.startPlayingStream(streamID, null, playerConfig)
    }
    result.success(null)
  }

  stopPlayingStream(call: MethodCall, result: MethodResult): void {
    let streamID: string = call.argument("streamID")
    ZegoExpressEngine.getInstance()?.stopPlayingStream(streamID)
    result.success(null)
  }

  destroyPlatformView(call: MethodCall, result: MethodResult): void {
    let viewId: number = call.argument("viewID")
    let state = zegoPlatformViewFactory.destroyPlatformView(viewId)
    zegoLogger.debug(`[destroyPlatformView][Result] viewID: ${viewId}, success:${state} `)
    result.success(state)
  }

  startPreview(call: MethodCall, result: MethodResult): void {
    let publishChannel = call.argument('channel') as ZegoPublishChannel
    let canvasMap: Map<string, Object> = call.argument('canvas')
    if (canvasMap != null && canvasMap.size > 0) {
      let viewId = canvasMap.get('view') as number
      let viewMode = canvasMap.get('viewMode') as ZegoViewMode
      let backgroundColor = canvasMap.get('backgroundColor') as number
      let alphaBlend = canvasMap.get('alphaBlend') as boolean
      if (!this.enablePlatformView) {
        result.error('[startPreview]', 'only support platform view', '')
        return
      }
      let platformView = zegoPlatformViewFactory.getPlatformView(viewId)
      if (platformView == undefined) {
        result.error('startPreview', 'PlatformView undefined',
          `The PlatformView for viewID:${viewId} cannot be found, developer should call createPlatformView first and get the viewID`)
        return
      }
      let zegoView = new ZegoView()
      zegoView.view = platformView.viewId.toString()
      zegoView.viewMode = viewMode
      zegoView.backgroundColor = backgroundColor
      zegoView.alphaBlend = alphaBlend
      ZegoExpressEngine.getInstance()?.startPreview(zegoView, publishChannel)

    } else {
      ZegoExpressEngine.getInstance()?.startPreview(null, publishChannel)
    }
    result.success(null)
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