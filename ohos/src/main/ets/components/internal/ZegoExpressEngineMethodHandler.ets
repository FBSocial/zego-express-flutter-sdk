import { Any, FlutterPluginBinding, MethodCall, MethodResult, TextureRegistry } from '@ohos/flutter_ohos';
import ZegoExpressEngine, {
  ZegoScenario,
  ZegoEngineProfile,
  ZegoEngineConfig,
  ZegoUser,
  ZegoRoomConfig,
  ZegoPlayerConfig,
  ZegoStreamResourceMode,
  ZegoVideoCodecID,
  ZegoViewMode,
  ZegoView,
  ZegoPublishChannel,
  ZegoPublisherConfig,
  ZegoVideoConfig,
  ZegoNetworkSpeedTestConfig,
  ZegoVideoMirrorMode,
  ZegoRoomStateChangedReason,
  ZegoVideoStreamType,
  ZegoAECMode,
  ZegoANSMode,
  ZegoVideoCodecBackend,
  ZegoAudioConfig,
  ZegoAudioChannel,
  ZegoAudioCodecID,
  ZegoSoundLevelConfig,
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
    } else if (call.method == 'createEngine') {
      this.createEngine(call, result, binding, sink)
    } else if (call.method == 'createEngineWithProfile') {
      this.createEngineWithProfile(call, result, binding, sink)
    } else if (call.method == 'setPluginVersion') {
      this.setPluginVersion(call, result)
    } else if (call.method == 'loginRoom') {
      this.loginRoom(call, result)
    } else if (call.method == 'logoutRoom') {
      this.logoutRoom(call, result)
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
    } else if (call.method == 'stopPreview') {
      this.stopPreview(call, result)
    } else if (call.method == 'startPublishingStream') {
      this.startPublishingStream(call, result)
    } else if (call.method == 'stopPublishingStream') {
      this.stopPublishingStream(call, result)
    } else if (call.method == 'destroyEngine') {
      this.destroyEngine(call, result)
    } else if (call.method == 'setEngineConfig') {
      this.setEngineConfig(call, result)
    } else if (call.method == 'callExperimentalAPI') {
      this.callExperimentalAPI(call, result)
    } else if (call.method == 'setVideoConfig') {
      this.setVideoConfig(call, result)
    } else if (call.method == 'setCaptureVolume') {
      this.setCaptureVolume(call, result)
    } else if (call.method == 'enableCamera') {
      this.enableCamera(call, result)
    } else if (call.method == 'setStreamExtraInfo') {
      this.setStreamExtraInfo(call, result)
    } else if (call.method == 'startNetworkSpeedTest') {
      this.startNetworkSpeedTest(call, result)
    } else if (call.method == 'stopNetworkSpeedTest') {
      this.stopNetworkSpeedTest(call, result)
    } else if (call.method == 'getAudioRouteType') {
      this.getAudioRouteType(call, result)
    } else if (call.method == 'setAudioRouteToSpeaker') {
      this.setAudioRouteToSpeaker(call, result)
    } else if (call.method == 'enableHardwareEncoder') {
      this.enableHardwareEncoder(call, result)
    } else if (call.method == 'enableHardwareDecoder') {
      this.enableHardwareDecoder(call, result)
    } else if (call.method == 'muteMicrophone') {
      this.muteMicrophone(call, result)
    } else if (call.method == 'setVideoMirrorMode') {
      this.setVideoMirrorMode(call, result)
    } else if (call.method == 'useFrontCamera') {
      this.useFrontCamera(call, result)
    } else if (call.method == 'mutePublishStreamAudio') {
      this.mutePublishStreamAudio(call, result)
    } else if (call.method == 'mutePublishStreamVideo') {
      this.mutePublishStreamVideo(call, result)
    } else if (call.method == 'setPlayStreamVideoType') {
      this.setPlayStreamVideoType(call, result)
    } else if (call.method == 'enableAudioCaptureDevice') {
      this.enableAudioCaptureDevice(call, result)
    } else if (call.method == 'isMicrophoneMuted') {
      this.isMicrophoneMuted(call, result)
    } else if (call.method == 'muteSpeaker') {
      this.muteSpeaker(call, result)
    } else if (call.method == 'isSpeakerMuted') {
      this.isSpeakerMuted(call, result)
    } else if (call.method == 'muteAllPlayStreamAudio') {
      this.muteAllPlayStreamAudio(call, result)
    } else if (call.method == 'mutePlayStreamAudio') {
      this.mutePlayStreamAudio(call, result)
    } else if (call.method == 'mutePlayStreamVideo') {
      this.mutePlayStreamVideo(call, result)
    } else if (call.method == 'setRoomExtraInfo') {
      this.setRoomExtraInfo(call, result)
    } else if (call.method == 'setAECMode') {
      this.setAECMode(call, result)
    } else if (call.method == 'setANSMode') {
      this.setANSMode(call, result)
    } else if (call.method == 'enableHeadphoneAEC') {
      this.enableHeadphoneAEC(call, result)
    } else if (call.method == 'enableAEC') {
      this.enableAEC(call, result)
    } else if (call.method == 'enableAGC') {
      this.enableAGC(call, result)
    } else if (call.method == 'enableANS') {
      this.enableANS(call, result)
    } else if (call.method == 'isVideoEncoderSupported') {
      this.isVideoEncoderSupported(call, result)
    } else if (call.method == 'setAudioConfig') {
      this.setAudioConfig(call, result)
    } else if (call.method == 'setMinVideoFpsForTrafficControl') {
      this.setMinVideoFpsForTrafficControl(call, result)
    } else if (call.method == 'startSoundLevelMonitor') {
      this.startSoundLevelMonitor(call, result)
    } else if (call.method == 'stopSoundLevelMonitor') {
      this.stopSoundLevelMonitor(call, result)
    } else {
      result.notImplemented()
    }
  }

  getVersion(call: MethodCall, result: MethodResult): void {
    result.success(ZegoExpressEngine.getSDKVersion())
  }

  createEngine(call: MethodCall, result: MethodResult, binding: FlutterPluginBinding | null,
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

    let appID: number = call.argument('appID')
    let appSign: string = call.argument('appSign')
    let isTestEnv: boolean = call.argument('isTestEnv')
    let scenarioValue = Math.min(10, Math.max(0, call.argument('scenario')))
    let zegoScenario: ZegoScenario = scenarioValue as ZegoScenario
    this.enablePlatformView = call.argument('enablePlatformView')

    let profile: ZegoEngineProfile = new ZegoEngineProfile(appID, appSign, zegoScenario, this.context)
    ZegoExpressEngine.createEngine(profile).then((engineInstance) => {
      if (engineInstance != null) {
        zegoLogger.debug('create Engine successful!')
        zegoExpressEngineEventHandler.initSDKEvent(engineInstance)
      }
    })
    result.success(null)
  }

  createEngineWithProfile(call: MethodCall, result: MethodResult, binding: FlutterPluginBinding | null,
    sink: EventSink | null): void {
    if (binding == null) {
      zegoLogger.error('[createEngine] FlutterPluginBinding is null')
      result.success(null)
      return
    }
    if (sink == null) {
      zegoLogger.error('[createEngine] FlutterEventSink or FlutterPluginBinding is null')
      result.success(null)
      return
    }

    this.reportPluginInfo()

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
    result.success(null)
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
    ZegoExpressEngine.getInstance()?.on('onRoomStateChanged',
      (roomID: string, reason: ZegoRoomStateChangedReason, errorCode: number, extendedData: string) => {
        let map: HashMap<string, Any> = new HashMap()
        map.set('errorCode', errorCode)
        map.set('extendedData', (extendedData == undefined || extendedData.length == 0) ? '{}' : extendedData)
        result.success(map)
      })
  }

  logoutRoom(call: MethodCall, result: MethodResult): void {
    let roomID: string = call.argument('roomID')
    ZegoExpressEngine.getInstance()?.logoutRoom(roomID)
    ZegoExpressEngine.getInstance()?.on('onRoomStateChanged',
      (roomID: string, reason: ZegoRoomStateChangedReason, errorCode: number, extendedData: string) => {
        let map: HashMap<string, Any> = new HashMap()
        map.set('errorCode', errorCode)
        map.set('extendedData', (extendedData == undefined || extendedData.length == 0) ? '{}' : extendedData)
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
      if (playerConfig.videoCodecID >= 5) {
        playerConfig.videoCodecID = ZegoVideoCodecID.Unknown
      }
      // playerConfig.roomID = playerConfigMap.get('roomID')
      // playerConfig.sourceResourceType = playerConfigMap.get("sourceResourceType") as ZegoResourceType
      // playerConfig.codecTemplateID = playerConfigMap.get("codecTemplateID")
      // playerConfig.resourceSwitchMode = playerConfigMap.get("resourceSwitchMode") as ZegoStreamResourceSwitchMode
      // playerConfig.resourceWhenStopPublish = playerConfigMap.get("resourceWhenStopPublish") as ZegoStreamResourceType
      // let cdnConfigMap: Map<string, Any> | null = call.argument('cdnConfig')
      // if (cdnConfigMap != null && cdnConfigMap.size > 0) {
      //   let cdnConfig = new ZegoCDNConfig()
      //   cdnConfig.url = cdnConfigMap.get('url')
      //   cdnConfig.authParam = cdnConfigMap.get('authParam')
      //   playerConfig.cdnConfig = cdnConfig
      // }
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

  stopPreview(call: MethodCall, result: MethodResult): void {
    let publishChannel = call.argument('channel') as ZegoPublishChannel
    ZegoExpressEngine.getInstance()?.stopPreview(publishChannel)
    result.success(null)
  }

  startPublishingStream(call: MethodCall, result: MethodResult): void {
    let streamID = call.argument('streamID') as string
    let publishChannel = call.argument('channel') as ZegoPublishChannel
    let config: ZegoPublisherConfig | undefined
    let configMap: Map<string, Object> = call.argument('config')
    if (configMap != null && configMap.size > 0) {
      config = new ZegoPublisherConfig()
      config.roomID = configMap.get('roomID') as string
      config.forceSynchronousNetworkTime = configMap.get('forceSynchronousNetworkTime') as number
    }
    ZegoExpressEngine.getInstance()?.startPublishingStream(streamID, config, publishChannel)
    result.success(null)
  }

  stopPublishingStream(call: MethodCall, result: MethodResult): void {
    let publishChannel = call.argument("channel") as ZegoPublishChannel
    ZegoExpressEngine.getInstance()?.stopPublishingStream(publishChannel)
    result.success(null)
  }

  destroyEngine(call: MethodCall, result: MethodResult): void {
    ZegoExpressEngine.destroyEngine()
    result.success(null)
  }

  setEngineConfig(call: MethodCall, result: MethodResult): void {
    this.reportPluginInfo()
    let configMap: Map<string, Object> = call.argument('config')
    if (configMap != null && configMap.size > 0) {
      let configObject = new ZegoEngineConfig()
      configObject.advancedConfig = configMap["advancedConfig"] as Map<string, string>
      // let  logConfigMap =configMap.get("logConfig") as Map<string, Object>
      // if (logConfigMap != null && logConfigMap.size>0) {
      //   let logConfigObject = new ZegoLogConfig()
      //   logConfigObject.logPath =  logConfigMap.get("logPath") as string
      //   logConfigObject.logSize  = logConfigMap.get("logSize") as number
      //   logConfigObject.logCount =  logConfigMap.get("logCount") as number
      //   configObject.logConfig = logConfigObject;
      // }
      //
      ZegoExpressEngine.setEngineConfig(configObject)
      result.success(null)
    } else {
      result.error("setEngineConfig_null_config".toUpperCase(), "Invoke `setEngineConfig` with null config", null)
    }
  }

  callExperimentalAPI(call: MethodCall, result: MethodResult): void {
    let params: string = call.argument("params")
    let callResult = ZegoExpressEngine.getInstance()?.callExperimentalAPI(params)
    result.success(callResult?.toString() ?? '')
  }

  setVideoConfig(call: MethodCall, result: MethodResult): void {
    let configMap: Map<string, Object> = call.argument('config')
    if (configMap == undefined || configMap.size <= 0) {
      result.error("setVideoConfig_Null_Config".toUpperCase(), "[setVideoConfig] Null config", null);
      return
    }

    let captureWidth = configMap.get('captureWidth') as number
    let captureHeight = configMap.get('captureHeight') as number
    let encodeWidth = configMap.get('encodeWidth') as number
    let encodeHeight = configMap.get('encodeHeight') as number
    let fps = configMap.get('fps') as number
    let bitrate = configMap.get('bitrate') as number
    let codecID = configMap.get('codecID') as number

    let config: ZegoVideoConfig = new ZegoVideoConfig()
    config.captureWidth = captureWidth
    config.captureHeight = captureHeight
    config.encodeWidth = encodeWidth
    config.encodeHeight = encodeHeight
    config.fps = fps
    config.bitrate = bitrate
    if (codecID >= 5) {
      config.codecID = ZegoVideoCodecID.Unknown
    } else {
      config.codecID = codecID as ZegoVideoCodecID
    }
    if (configMap.has("keyFrameInterval") && configMap.get("keyFrameInterval") != undefined) {
      config.keyFrameInterval = configMap.get("keyFrameInterval") as number
    }
    let channel = call.argument("channel") as ZegoPublishChannel
    ZegoExpressEngine.getInstance()?.setVideoConfig(config, channel)
    result.success(null)
  }

  setCaptureVolume(call: MethodCall, result: MethodResult): void {
    let volume = call.argument('volume') as number
    ZegoExpressEngine.getInstance()?.setCaptureVolume(volume)
    result.success(null)
  }

  enableCamera(call: MethodCall, result: MethodResult): void {
    let enable = call.argument('enable') as boolean
    let channel = call.argument('channel') as ZegoPublishChannel
    ZegoExpressEngine.getInstance()?.enableCamera(enable, channel)
    result.success(null)
  }

  setStreamExtraInfo(call: MethodCall, result: MethodResult): void {
    let extraInfo = call.argument('extraInfo') as string
    let channel = call.argument('channel') as ZegoPublishChannel
    ZegoExpressEngine.getInstance()?.setStreamExtraInfo(extraInfo, channel).then((value) => {
      let resultMap: HashMap<string, Object> = new HashMap()
      resultMap.set('errorCode', value)
      result.success(resultMap)
    })
  }

  startNetworkSpeedTest(call: MethodCall, result: MethodResult): void {
    let configMap: Map<string, Object> = call.argument("config")
    if (configMap == null || configMap.size <= 0) {
      result.error("startNetworkSpeedTest_Null_Config".toUpperCase(), "[startNetworkSpeedTest] Null config", null)
      return
    }

    let config = new ZegoNetworkSpeedTestConfig()
    config.testUplink = configMap.get("testUplink") as boolean
    config.expectedUplinkBitrate = call.argument("expectedUplinkBitrate") as number
    config.testDownlink = configMap.get("testDownlink") as boolean
    config.expectedDownlinkBitrate = call.argument("expectedDownlinkBitrate") as number

    let interval = call.argument("interval") as number
    ZegoExpressEngine.getInstance()?.startNetworkSpeedTest(config, interval)
    result.success(null)
  }

  stopNetworkSpeedTest(call: MethodCall, result: MethodResult): void {
    ZegoExpressEngine.getInstance()?.stopNetworkSpeedTest()
    result.success(null)
  }

  getAudioRouteType(call: MethodCall, result: MethodResult): void {
    let route = ZegoExpressEngine.getInstance()?.getAudioRouteType()
    result.success(route == null ? 0 : (route as number))
  }

  setAudioRouteToSpeaker(call: MethodCall, result: MethodResult): void {
    let defaultToSpeaker = call.argument('defaultToSpeaker') as boolean
    ZegoExpressEngine.getInstance()?.setAudioRouteToSpeaker(defaultToSpeaker)
    result.success(null)
  }

  enableHardwareEncoder(call: MethodCall, result: MethodResult): void {
    let enable = call.argument('enable') as boolean
    ZegoExpressEngine.getInstance()?.enableHardwareEncoder(enable)
    result.success(null)
  }

  enableHardwareDecoder(call: MethodCall, result: MethodResult): void {
    let enable = call.argument('enable') as boolean
    ZegoExpressEngine.getInstance()?.enableHardwareDecoder(enable)
    result.success(null)
  }

  muteMicrophone(call: MethodCall, result: MethodResult): void {
    let mute = call.argument('mute') as boolean
    ZegoExpressEngine.getInstance()?.muteMicrophone(mute)
    result.success(null)
  }

  setVideoMirrorMode(call: MethodCall, result: MethodResult): void {
    let mirrorMode = call.argument('mirrorMode') as ZegoVideoMirrorMode
    let channel = call.argument('channel') as ZegoPublishChannel
    ZegoExpressEngine.getInstance()?.setVideoMirrorMode(mirrorMode, channel)
    result.success(null);
  }

  useFrontCamera(call: MethodCall, result: MethodResult): void {
    let enable = call.argument('enable') as boolean
    let channel = call.argument('channel') as ZegoPublishChannel
    ZegoExpressEngine.getInstance()?.useFrontCamera(enable, channel)
    result.success(null)
  }

  mutePublishStreamAudio(call: MethodCall, result: MethodResult): void {
    let mute = call.argument('mute') as boolean
    let channel = call.argument('channel') as ZegoPublishChannel
    ZegoExpressEngine.getInstance()?.mutePublishStreamAudio(mute, channel)
    result.success(null)
  }

  mutePublishStreamVideo(call: MethodCall, result: MethodResult): void {
    let mute = call.argument('mute') as boolean
    let channel = call.argument('channel') as ZegoPublishChannel
    ZegoExpressEngine.getInstance()?.mutePublishStreamVideo(mute, channel)
    result.success(null)
  }

  setPlayStreamVideoType(call: MethodCall, result: MethodResult): void {
    let streamID = call.argument('streamID') as string
    let streamType = call.argument('streamType') as ZegoVideoStreamType
    ZegoExpressEngine.getInstance()?.setPlayStreamVideoType(streamID, streamType)
    result.success(null)
  }

  enableAudioCaptureDevice(call: MethodCall, result: MethodResult): void {
    let enable = call.argument('enable') as boolean
    ZegoExpressEngine.getInstance()?.enableAudioCaptureDevice(enable)
    result.success(null)
  }

  isMicrophoneMuted(call: MethodCall, result: MethodResult): void {
    let muted = ZegoExpressEngine.getInstance()?.isMicrophoneMuted()
    result.success(muted)
  }

  muteSpeaker(call: MethodCall, result: MethodResult): void {
    let mute = call.argument('mute') as boolean
    ZegoExpressEngine.getInstance()?.muteSpeaker(mute)
    result.success(null)
  }

  isSpeakerMuted(call: MethodCall, result: MethodResult): void {
    let muted = ZegoExpressEngine.getInstance()?.isSpeakerMuted()
    result.success(muted)
  }

  muteAllPlayStreamAudio(call: MethodCall, result: MethodResult): void {
    let mute = call.argument('mute') as boolean
    ZegoExpressEngine.getInstance()?.muteAllPlayStreamAudio(mute)
    result.success(null)
  }

  mutePlayStreamAudio(call: MethodCall, result: MethodResult): void {
    let streamID = call.argument('streamID') as string
    let mute = call.argument('mute') as boolean
    ZegoExpressEngine.getInstance()?.mutePlayStreamAudio(streamID, mute)
    result.success(null)
  }

  mutePlayStreamVideo(call: MethodCall, result: MethodResult): void {
    let streamID = call.argument('streamID') as string
    let mute = call.argument('mute') as boolean
    ZegoExpressEngine.getInstance()?.mutePlayStreamVideo(streamID, mute)
    result.success(null)

  }

  setRoomExtraInfo(call: MethodCall, result: MethodResult): void {
    let roomID = call.argument('roomID') as string
    let key = call.argument('key') as string
    let value = call.argument('value') as string
    ZegoExpressEngine.getInstance()?.setRoomExtraInfo(roomID, key, value).then((errorCode) => {
      let resultMap: HashMap<String, Object> = new HashMap()
      resultMap.set('errorCode', errorCode)
      result.success(resultMap);
    });
  }

  setAECMode(call: MethodCall, result: MethodResult): void {
    let mode = call.argument('mode') as ZegoAECMode
    ZegoExpressEngine.getInstance()?.setAECMode(mode)
    result.success(null);
  }

  setANSMode(call: MethodCall, result: MethodResult): void {
    let mode = call.argument('mode') as ZegoANSMode
    ZegoExpressEngine.getInstance()?.setANSMode(mode)
    result.success(null)
  }

  enableHeadphoneAEC(call: MethodCall, result: MethodResult): void {
    let enable = call.argument('enable') as boolean
    ZegoExpressEngine.getInstance()?.enableHeadphoneAEC(enable)
    result.success(null);
  }

  enableAEC(call: MethodCall, result: MethodResult): void {
    let enable = call.argument('enable') as boolean
    ZegoExpressEngine.getInstance()?.enableAEC(enable)
    result.success(null)
  }

  enableAGC(call: MethodCall, result: MethodResult): void {
    let enable = call.argument('enable') as boolean
    ZegoExpressEngine.getInstance()?.enableAGC(enable)
    result.success(null)
  }

  enableANS(call: MethodCall, result: MethodResult): void {
    let enable = call.argument('enable') as boolean
    ZegoExpressEngine.getInstance()?.enableANS(enable)
    result.success(null)
  }

  isVideoEncoderSupported(call: MethodCall, result: MethodResult): void {
    let codecIDIndex = call.argument('codecID') as number
    let codecID = codecIDIndex as ZegoVideoCodecID
    if (codecIDIndex >= 5) {
      codecID = ZegoVideoCodecID.Unknown
    }

    let supportRet: number = 0
    if (call.argument("codecBackend") != null && call.argument("codecBackend") != undefined) {
      let codecBackendIndex = call.argument("codecBackend") as number
      let codecBackend = codecBackendIndex as ZegoVideoCodecBackend
      supportRet = ZegoExpressEngine.getInstance()?.isVideoEncoderSupported(codecID, codecBackend) ?? 0
    }

    result.success(supportRet)
  }

  setAudioConfig(call: MethodCall, result: MethodResult): void {
    let channel = call.argument('channel') as ZegoPublishChannel
    let configMap: Map<string, Object> = call.argument('config')

    if (configMap == null || configMap == undefined) {
      result.error("setAudioConfig_Null_Config".toUpperCase(), "[setAudioConfig] Null config", null);
      return
    }

    let bitrate = configMap.get('bitrate') as number
    let audioChannel = configMap.get('channel') as ZegoAudioChannel
    let codecID = configMap.get('codecID') as ZegoAudioCodecID
    let config: ZegoAudioConfig = new ZegoAudioConfig()
    config.bitrate = bitrate
    config.channel = audioChannel
    config.codecID = codecID
    ZegoExpressEngine.getInstance()?.setAudioConfig(config, channel)
    result.success(null)
  }

  setMinVideoFpsForTrafficControl(call: MethodCall, result: MethodResult): void {
    let fps = call.argument('fps') as number
    let channel = call.argument('channel') as ZegoPublishChannel
    ZegoExpressEngine.getInstance()?.setMinVideoFpsForTrafficControl(fps, channel)
    result.success(null)
  }

  startSoundLevelMonitor(call: MethodCall, result: MethodResult): void {
    let config = new ZegoSoundLevelConfig()
    let configMap: Map<string, Object> = call.argument('config')
    config.millisecond = configMap.get('millisecond') as number
    config.enableVAD = configMap.get('enableVAD') as boolean
    ZegoExpressEngine.getInstance()?.startSoundLevelMonitor(config)
    result.success(null);
  }

  stopSoundLevelMonitor(call: MethodCall, result: MethodResult): void {
    ZegoExpressEngine.getInstance()?.stopSoundLevelMonitor()
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