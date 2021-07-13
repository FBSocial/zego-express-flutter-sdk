import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'zego_express_api.dart';
import 'zego_express_defines.dart';

class ZegoExpressImpl {
  /// Method Channel
  static const MethodChannel _channel =
      const MethodChannel('plugins.zego.im/zego_express_engine');
  static const EventChannel _event =
      const EventChannel('plugins.zego.im/zego_express_event_handler');

  /// Used to receive the native event stream
  static StreamSubscription<dynamic>? _streamSubscription;

  /// Private constructor
  ZegoExpressImpl._internal();

  /// Singleton instance
  static final ZegoExpressImpl instance = ZegoExpressImpl._internal();

  /// Exposing methodChannel to other files
  static MethodChannel get methodChannel => _channel;

  /* Main */

  static Future<void> createEngine(
      int appID, String appSign, bool isTestEnv, ZegoScenario scenario,
      {bool? enablePlatformView}) async {
    _registerEventHandler();

    await _channel.invokeMethod('createEngine', {
      'appID': appID,
      'appSign': appSign,
      'isTestEnv': isTestEnv,
      'scenario': scenario.index,
      'enablePlatformView': enablePlatformView ?? false
    });

    return null;
  }

  static Future<void> destroyEngine() async {
    await _channel.invokeMethod('destroyEngine');

    _unregisterEventHandler();

    return null;
  }

  static Future<void> setEngineConfig(ZegoEngineConfig config) async {
    return await _channel.invokeMethod('setEngineConfig', {
      'config': {
        'logConfig': config.logConfig != null
            ? {
                'logPath': config.logConfig?.logPath,
                'logSize': config.logConfig?.logSize
              }
            : {},
        'advancedConfig': config.advancedConfig ?? {}
      }
    });
  }

  static Future<String> getVersion() async {
    return await _channel.invokeMethod('getVersion');
  }

  Future<void> uploadLog() async {
    return await _channel.invokeMethod('uploadLog');
  }

  Future<void> setDebugVerbose(bool enable, ZegoLanguage language) async {
    return await _channel.invokeMethod(
        'setDebugVerbose', {'enable': enable, 'language': language.index});
  }

  /* Room */

  Future<void> loginRoom(String roomID, ZegoUser user,
      {ZegoRoomConfig? config}) async {
    return await _channel.invokeMethod('loginRoom', {
      'roomID': roomID,
      'user': {'userID': user.userID, 'userName': user.userName},
      'config': config?.toMap() ?? {}
    });
  }

  Future<void> loginMultiRoom(String roomID, {ZegoRoomConfig? config}) async {
    return await _channel.invokeMethod(
        'loginMultiRoom', {'roomID': roomID, 'config': config?.toMap() ?? {}});
  }

  Future<void> logoutRoom(String roomID) async {
    return await _channel.invokeMethod('logoutRoom', {'roomID': roomID});
  }

  Future<void> switchRoom(String fromRoomID, String toRoomID,
      {ZegoRoomConfig? config}) async {
    return await _channel.invokeMethod('switchRoom', {
      'fromRoomID': fromRoomID,
      'toRoomID': toRoomID,
      'config': config?.toMap() ?? {}
    });
  }

  Future<ZegoRoomSetRoomExtraInfoResult> setRoomExtraInfo(
      String roomID, String key, String value) async {
    final Map<dynamic, dynamic> map = await _channel.invokeMethod(
        'setRoomExtraInfo', {'roomID': roomID, 'key': key, 'value': value});

    return ZegoRoomSetRoomExtraInfoResult(map['errorCode']);
  }

  /* Publisher */

  Future<void> startPublishingStream(String streamID,
      {ZegoPublishChannel? channel}) async {
    return await _channel.invokeMethod('startPublishingStream', {
      'streamID': streamID,
      'channel': channel?.index ?? ZegoPublishChannel.Main.index
    });
  }

  Future<void> stopPublishingStream({ZegoPublishChannel? channel}) async {
    return await _channel.invokeMethod('stopPublishingStream',
        {'channel': channel?.index ?? ZegoPublishChannel.Main.index});
  }

  Future<ZegoPublisherSetStreamExtraInfoResult> setStreamExtraInfo(
      String extraInfo,
      {ZegoPublishChannel? channel}) async {
    final Map<dynamic, dynamic> map =
        await _channel.invokeMethod('setStreamExtraInfo', {
      'extraInfo': extraInfo,
      'channel': channel?.index ?? ZegoPublishChannel.Main.index
    });

    return ZegoPublisherSetStreamExtraInfoResult(map['errorCode']);
  }

  Future<void> startPreview(
      {ZegoCanvas? canvas, ZegoPublishChannel? channel}) async {
    return await _channel.invokeMethod('startPreview', {
      'canvas': canvas != null
          ? {
              'view': canvas.view,
              'viewMode':
                  canvas.viewMode?.index ?? ZegoViewMode.AspectFit.index,
              'backgroundColor': canvas.backgroundColor ?? 0x000000
            }
          : {},
      'channel': channel?.index ?? ZegoPublishChannel.Main.index
    });
  }

  Future<void> stopPreview({ZegoPublishChannel? channel}) async {
    return await _channel.invokeMethod('stopPreview',
        {'channel': channel?.index ?? ZegoPublishChannel.Main.index});
  }

  Future<void> setVideoConfig(ZegoVideoConfig config,
      {ZegoPublishChannel? channel}) async {
    return await _channel.invokeMethod('setVideoConfig', {
      'config': config.toMap(),
      'channel': channel?.index ?? ZegoPublishChannel.Main.index
    });
  }

  Future<ZegoVideoConfig> getVideoConfig({ZegoPublishChannel? channel}) async {
    final Map<dynamic, dynamic> map = await _channel.invokeMethod(
        'getVideoConfig',
        {'channel': channel?.index ?? ZegoPublishChannel.Main.index});

    ZegoVideoConfig config = ZegoVideoConfig(
        map['captureWidth'],
        map['captureHeight'],
        map['encodeWidth'],
        map['encodeHeight'],
        map['fps'],
        map['bitrate'],
        ZegoVideoCodecID.values[map['codecID']]);

    return config;
  }

  Future<void> setVideoMirrorMode(ZegoVideoMirrorMode mirrorMode,
      {ZegoPublishChannel? channel}) async {
    return await _channel.invokeMethod('setVideoMirrorMode', {
      'mirrorMode': mirrorMode.index,
      'channel': channel?.index ?? ZegoPublishChannel.Main.index
    });
  }

  Future<void> setAppOrientation(DeviceOrientation orientation,
      {ZegoPublishChannel? channel}) async {
    return await _channel.invokeMethod('setAppOrientation', {
      'orientation': orientation.index,
      'channel': channel?.index ?? ZegoPublishChannel.Main.index
    });
  }

  Future<void> setAudioConfig(ZegoAudioConfig config) async {
    return await _channel.invokeMethod('setAudioConfig', {
      'config': {
        'bitrate': config.bitrate,
        'channel': config.channel.index,
        'codecID': config.codecID.index
      }
    });
  }

  Future<ZegoAudioConfig> getAudioConfig() async {
    final Map<dynamic, dynamic> map =
        await _channel.invokeMethod('getAudioConfig');

    return ZegoAudioConfig(
        map['bitrate'],
        ZegoAudioChannel.values[map['channel']],
        ZegoAudioCodecID.values[map['codecID']]);
  }

  Future<void> setPublishStreamEncryptionKey(String key,
      {ZegoPublishChannel? channel}) async {
    return await _channel.invokeMethod('setPublishStreamEncryptionKey', {
      'key': key,
      'channel': channel?.index ?? ZegoPublishChannel.Main.index
    });
  }

  Future<ZegoPublisherTakeSnapshotResult> takePublishStreamSnapshot(
      {ZegoPublishChannel? channel}) async {
    final Map<dynamic, dynamic> map = await _channel.invokeMethod(
        'takePublishStreamSnapshot',
        {'channel': channel?.index ?? ZegoPublishChannel.Main.index});

    return ZegoPublisherTakeSnapshotResult(map['errorCode'],
        map['image'] != null ? MemoryImage(map['image']) : null);
  }

  Future<void> mutePublishStreamAudio(bool mute,
      {ZegoPublishChannel? channel}) async {
    return await _channel.invokeMethod('mutePublishStreamAudio', {
      'mute': mute,
      'channel': channel?.index ?? ZegoPublishChannel.Main.index
    });
  }

  Future<void> mutePublishStreamVideo(bool mute,
      {ZegoPublishChannel? channel}) async {
    return await _channel.invokeMethod('mutePublishStreamVideo', {
      'mute': mute,
      'channel': channel?.index ?? ZegoPublishChannel.Main.index
    });
  }

  Future<void> enableTrafficControl(bool enable, int property) async {
    return await _channel.invokeMethod(
        'enableTrafficControl', {'enable': enable, 'property': property});
  }

  Future<void> setMinVideoBitrateForTrafficControl(
      int bitrate, ZegoTrafficControlMinVideoBitrateMode mode) async {
    return await _channel.invokeMethod('setMinVideoBitrateForTrafficControl',
        {'bitrate': bitrate, 'mode': mode.index});
  }

  Future<void> setCaptureVolume(int volume) async {
    return await _channel.invokeMethod('setCaptureVolume', {'volume': volume});
  }

  Future<void> setAudioCaptureStereoMode(
      ZegoAudioCaptureStereoMode mode) async {
    return await _channel
        .invokeMethod('setAudioCaptureStereoMode', {'mode': mode.index});
  }

  Future<ZegoPublisherUpdateCdnUrlResult> addPublishCdnUrl(
      String streamID, String targetURL) async {
    final Map<dynamic, dynamic> map = await _channel.invokeMethod(
        'addPublishCdnUrl', {'streamID': streamID, 'targetURL': targetURL});

    return ZegoPublisherUpdateCdnUrlResult(map['errorCode']);
  }

  Future<ZegoPublisherUpdateCdnUrlResult> removePublishCdnUrl(
      String streamID, String targetURL) async {
    final Map<dynamic, dynamic> map = await _channel.invokeMethod(
        'removePublishCdnUrl', {'streamID': streamID, 'targetURL': targetURL});

    return ZegoPublisherUpdateCdnUrlResult(map['errorCode']);
  }

  Future<void> enablePublishDirectToCDN(bool enable,
      {ZegoCDNConfig? config, ZegoPublishChannel? channel}) async {
    return await _channel.invokeMethod('enablePublishDirectToCDN', {
      'enable': enable,
      'config': config != null
          ? {'url': config.url, 'authParam': config.authParam}
          : {},
      'channel': channel?.index ?? ZegoPublishChannel.Main.index
    });
  }

  Future<void> setPublishWatermark(
      {ZegoWatermark? watermark,
      bool? isPreviewVisible,
      ZegoPublishChannel? channel}) async {
    return await _channel.invokeMethod('setPublishWatermark', {
      'watermark': watermark?.toMap() ?? {},
      'isPreviewVisible': isPreviewVisible ?? false,
      'channel': channel?.index ?? ZegoPublishChannel.Main.index
    });
  }

  Future<void> setSEIConfig(ZegoSEIConfig config) async {
    return await _channel.invokeMethod('setSEIConfig', {
      'config': {'type': config.type.index}
    });
  }

  Future<void> sendSEI(Uint8List data, int dataLength,
      {ZegoPublishChannel? channel}) async {
    return await _channel.invokeMethod('sendSEI', {
      'data': data,
      'dataLength': dataLength,
      'channel': channel?.index ?? ZegoPublishChannel.Main.index
    });
  }

  Future<void> enableHardwareEncoder(bool enable) async {
    return await _channel
        .invokeMethod('enableHardwareEncoder', {'enable': enable});
  }

  Future<void> setCapturePipelineScaleMode(
      ZegoCapturePipelineScaleMode mode) async {
    return await _channel
        .invokeMethod('setCapturePipelineScaleMode', {'mode': mode.index});
  }

  /* Player */

  Future<void> startPlayingStream(String streamID,
      {ZegoCanvas? canvas, ZegoPlayerConfig? config}) async {
    return await _channel.invokeMethod('startPlayingStream', {
      'streamID': streamID,
      'canvas': canvas != null
          ? {
              'view': canvas.view,
              'viewMode':
                  canvas.viewMode?.index ?? ZegoViewMode.AspectFit.index,
              'backgroundColor': canvas.backgroundColor ?? 0x000000
            }
          : {},
      'config': config != null
          ? {
              'resourceMode': config.resourceMode.index,
              'cdnConfig': config.cdnConfig != null
                  ? {
                      'url': config.cdnConfig?.url,
                      'authParam': config.cdnConfig?.authParam
                    }
                  : {}
            }
          : {}
    });
  }

  Future<void> stopPlayingStream(String streamID) async {
    return await _channel
        .invokeMethod('stopPlayingStream', {'streamID': streamID});
  }

  Future<void> setPlayStreamDecryptionKey(String streamID, String key) async {
    return await _channel.invokeMethod(
        'setPlayStreamDecryptionKey', {'streamID': streamID, 'key': key});
  }

  Future<ZegoPlayerTakeSnapshotResult> takePlayStreamSnapshot(
      String streamID) async {
    final Map<dynamic, dynamic> map = await _channel
        .invokeMethod('takePlayStreamSnapshot', {'streamID': streamID});

    return ZegoPlayerTakeSnapshotResult(map['errorCode'],
        map['image'] != null ? MemoryImage(map['image']) : null);
  }

  Future<void> setPlayVolume(String streamID, int volume) async {
    return await _channel.invokeMethod(
        'setPlayVolume', {'streamID': streamID, 'volume': volume});
  }

  Future<void> setPlayStreamVideoLayer(
      String streamID, ZegoPlayerVideoLayer videoLayer) async {
    return await _channel.invokeMethod('setPlayStreamVideoLayer',
        {'streamID': streamID, 'videoLayer': videoLayer.index});
  }

  Future<void> setPlayStreamBufferIntervalRange(
      String streamID, int minBufferInterval, int maxBufferInterval) async {
    return await _channel.invokeMethod('setPlayStreamBufferIntervalRange', {
      'streamID': streamID,
      'minBufferInterval': minBufferInterval,
      'maxBufferInterval': maxBufferInterval
    });
  }

  Future<void> mutePlayStreamAudio(String streamID, bool mute) async {
    return await _channel.invokeMethod(
        'mutePlayStreamAudio', {'streamID': streamID, 'mute': mute});
  }

  Future<void> mutePlayStreamVideo(String streamID, bool mute) async {
    return await _channel.invokeMethod(
        'mutePlayStreamVideo', {'streamID': streamID, 'mute': mute});
  }

  Future<void> enableHardwareDecoder(bool enable) async {
    return await _channel
        .invokeMethod('enableHardwareDecoder', {'enable': enable});
  }

  Future<void> enableCheckPoc(bool enable) async {
    return await _channel.invokeMethod('enableCheckPoc', {'enable': enable});
  }

  /* Mixer */

  Future<ZegoMixerStartResult> startMixerTask(ZegoMixerTask task) async {
    Map<String, dynamic> map = task.toMap();

    List<Map<String, dynamic>> inputList = [];
    for (ZegoMixerInput input in task.inputList) {
      inputList.add(input.toMap());
    }
    map['inputList'] = inputList;

    List<Map<String, dynamic>> outputList = [];
    for (ZegoMixerOutput output in task.outputList) {
      outputList.add({'target': output.target});
    }
    map['outputList'] = outputList;

    final Map<dynamic, dynamic> result =
        await _channel.invokeMethod('startMixerTask', map);

    return ZegoMixerStartResult(
        result['errorCode'], jsonDecode(result['extendedData']));
  }

  Future<ZegoMixerStopResult> stopMixerTask(ZegoMixerTask task) async {
    Map<String, dynamic> map = task.toMap();

    List<Map<String, dynamic>> inputList = [];
    for (ZegoMixerInput input in task.inputList) {
      inputList.add(input.toMap());
    }
    map['inputList'] = inputList;

    List<Map<String, dynamic>> outputList = [];
    for (ZegoMixerOutput output in task.outputList) {
      outputList.add({'target': output.target});
    }
    map['outputList'] = outputList;

    final Map<dynamic, dynamic> result =
        await _channel.invokeMethod('stopMixerTask', map);

    return ZegoMixerStopResult(
      result['errorCode'],
    );
  }

  /* Device */

  Future<void> muteMicrophone(bool mute) async {
    return await _channel.invokeMethod('muteMicrophone', {'mute': mute});
  }

  Future<bool> isMicrophoneMuted() async {
    return await _channel.invokeMethod('isMicrophoneMuted');
  }

  Future<void> muteSpeaker(bool mute) async {
    return await _channel.invokeMethod('muteSpeaker', {'mute': mute});
  }

  Future<bool> isSpeakerMuted() async {
    return await _channel.invokeMethod('isSpeakerMuted');
  }

  Future<void> enableAudioCaptureDevice(bool enable) async {
    return await _channel
        .invokeMethod('enableAudioCaptureDevice', {'enable': enable});
  }

  Future<void> setBuiltInSpeakerOn(bool enable) async {
    return await _channel
        .invokeMethod('setBuiltInSpeakerOn', {'enable': enable});
  }

  Future<void> enableCamera(bool enable, {ZegoPublishChannel? channel}) async {
    return await _channel.invokeMethod('enableCamera', {
      'enable': enable,
      'channel': channel?.index ?? ZegoPublishChannel.Main.index
    });
  }

  Future<void> useFrontCamera(bool enable,
      {ZegoPublishChannel? channel}) async {
    return await _channel.invokeMethod('useFrontCamera', {
      'enable': enable,
      'channel': channel?.index ?? ZegoPublishChannel.Main.index
    });
  }

  Future<List<ZegoDeviceInfo>> getAudioDeviceList(
      ZegoAudioDeviceType deviceType) async {
    return await _channel
        .invokeMethod('getAudioDeviceList', {'type': deviceType});
  }

  Future<String> getDefaultAudioDeviceID(ZegoAudioDeviceType deviceType) async {
    return await _channel
        .invokeMethod('getDefaultAudioDeviceID', {'type': deviceType});
  }

  Future<void> useAudioDevice(
      ZegoAudioDeviceType deviceType, String deviceID) async {
    return await _channel.invokeMethod(
        'useAudioDevice', {'type': deviceType, 'deviceID': deviceID});
  }

  Future<void> setCameraZoomFactor(double factor,
      {ZegoPublishChannel? channel}) async {
    return await _channel.invokeMethod('setCameraZoomFactor', {
      'factor': factor,
      'channel': channel?.index ?? ZegoPublishChannel.Main.index
    });
  }

  Future<double> getCameraMaxZoomFactor({ZegoPublishChannel? channel}) async {
    return await _channel.invokeMethod('getCameraMaxZoomFactor',
        {'channel': channel?.index ?? ZegoPublishChannel.Main.index});
  }

  Future<void> startSoundLevelMonitor({int? millisecond}) async {
    return await _channel.invokeMethod(
        'startSoundLevelMonitor', {'millisecond': millisecond ?? 100});
  }

  Future<void> stopSoundLevelMonitor() async {
    return await _channel.invokeMethod('stopSoundLevelMonitor');
  }

  Future<void> startAudioSpectrumMonitor({int? millisecond}) async {
    return await _channel.invokeMethod(
        'startAudioSpectrumMonitor', {'millisecond': millisecond ?? 100});
  }

  Future<void> stopAudioSpectrumMonitor() async {
    return await _channel.invokeMethod('stopAudioSpectrumMonitor');
  }

  Future<void> enableHeadphoneMonitor(bool enable) async {
    return await _channel
        .invokeMethod('enableHeadphoneMonitor', {'enable': enable});
  }

  Future<void> setHeadphoneMonitorVolume(int volume) async {
    return await _channel
        .invokeMethod('setHeadphoneMonitorVolume', {'volume': volume});
  }

  /* PreProcess */

  Future<void> enableAEC(bool enable) async {
    return await _channel.invokeMethod('enableAEC', {'enable': enable});
  }

  Future<void> setAECMode(ZegoAECMode mode) async {
    return await _channel.invokeMethod('setAECMode', {'mode': mode.index});
  }

  Future<void> enableAGC(bool enable) async {
    return await _channel.invokeMethod('enableAGC', {'enable': enable});
  }

  Future<void> enableANS(bool enable) async {
    return await _channel.invokeMethod('enableANS', {'enable': enable});
  }

  Future<void> enableTransientANS(bool enable) async {
    return await _channel
        .invokeMethod('enableTransientANS', {'enable': enable});
  }

  Future<void> setANSMode(ZegoANSMode mode) async {
    return await _channel.invokeMethod('setANSMode', {'mode': mode.index});
  }

  Future<void> enableBeautify(int featureBitmask,
      {ZegoPublishChannel? channel}) async {
    return await _channel.invokeMethod('enableBeautify', {
      'featureBitmask': featureBitmask,
      'channel': channel?.index ?? ZegoPublishChannel.Main.index
    });
  }

  Future<void> setBeautifyOption(ZegoBeautifyOption option,
      {ZegoPublishChannel? channel}) async {
    return await _channel.invokeMethod('setBeautifyOption', {
      'option': {
        'polishStep': option.polishStep,
        'whitenFactor': option.whitenFactor,
        'sharpenFactor': option.sharpenFactor
      },
      'channel': channel?.index ?? ZegoPublishChannel.Main.index
    });
  }

  Future<void> setAudioEqualizerGain(int bandIndex, double bandGain) async {
    return await _channel.invokeMethod('setAudioEqualizerGain',
        {'bandIndex': bandIndex, 'bandGain': bandGain});
  }

  Future<void> setVoiceChangerPreset(ZegoVoiceChangerPreset preset) async {
    return await _channel
        .invokeMethod('setVoiceChangerPreset', {'preset': preset.index});
  }

  Future<void> setVoiceChangerParam(ZegoVoiceChangerParam param) async {
    return await _channel.invokeMethod('setVoiceChangerParam', {
      'param': {'pitch': param.pitch}
    });
  }

  Future<void> setReverbPreset(ZegoReverbPreset preset) async {
    return await _channel
        .invokeMethod('setReverbPreset', {'preset': preset.index});
  }

  Future<void> setReverbAdvancedParam(ZegoReverbAdvancedParam param) async {
    return await _channel.invokeMethod('setReverbAdvancedParam', {
      'param': {
        'roomSize': param.roomSize,
        'reverberance': param.reverberance,
        'damping': param.damping,
        'wetOnly': param.wetOnly,
        'wetGain': param.wetGain,
        'dryGain': param.dryGain,
        'toneLow': param.toneLow,
        'toneHigh': param.toneHigh,
        'preDelay': param.preDelay,
        'stereoWidth': param.stereoWidth
      }
    });
  }

  Future<void> setReverbEchoParam(ZegoReverbEchoParam param) async {
    return await _channel.invokeMethod('setReverbEchoParam', {
      'param': {
        'inGain': param.inGain,
        'outGain': param.outGain,
        'numDelays': param.numDelays,
        'delay': param.delay,
        'decay': param.decay
      }
    });
  }

  Future<void> enableVirtualStereo(bool enable, int angle) async {
    return await _channel.invokeMethod(
        'enableVirtualStereo', {'enable': enable, 'angle': angle});
  }

  /* IM */

  Future<ZegoIMSendBroadcastMessageResult> sendBroadcastMessage(
      String roomID, String message) async {
    final Map<dynamic, dynamic> map = await _channel.invokeMethod(
        'sendBroadcastMessage', {'roomID': roomID, 'message': message});

    return ZegoIMSendBroadcastMessageResult(map['errorCode'], map['messageID']);
  }

  Future<ZegoIMSendBarrageMessageResult> sendBarrageMessage(
      String roomID, String message) async {
    final Map<dynamic, dynamic> map = await _channel.invokeMethod(
        'sendBarrageMessage', {'roomID': roomID, 'message': message});

    return ZegoIMSendBarrageMessageResult(map['errorCode'], map['messageID']);
  }

  Future<ZegoIMSendCustomCommandResult> sendCustomCommand(
      String roomID, String command, List<ZegoUser> toUserList) async {
    List<Map<String, dynamic>> userMapList = [];

    for (ZegoUser user in toUserList) {
      userMapList.add({'userID': user.userID, 'userName': user.userName});
    }

    final Map<dynamic, dynamic> map = await _channel.invokeMethod(
        'sendCustomCommand',
        {'roomID': roomID, 'command': command, 'toUserList': userMapList});

    return ZegoIMSendCustomCommandResult(map['errorCode']);
  }

  /* MediaPlayer */

  static final Map<int, ZegoMediaPlayer> mediaPlayerMap = Map();

  Future<ZegoMediaPlayer?> createMediaPlayer() async {
    int index = await _channel.invokeMethod('createMediaPlayer');

    if (index >= 0) {
      ZegoMediaPlayerImpl mediaPlayerInstance = ZegoMediaPlayerImpl(index);
      mediaPlayerMap[index] = mediaPlayerInstance;

      return mediaPlayerInstance;
    } else {
      return null;
    }
  }

  Future<void> destroyMediaPlayer(ZegoMediaPlayer mediaPlayer) async {
    int index = mediaPlayer.getIndex();

    await _channel.invokeMethod('destroyMediaPlayer', {'index': index});

    mediaPlayerMap.remove(index);

    return;
  }

  /* AudioEffectPlayer */

  static final Map<int, ZegoAudioEffectPlayer> audioEffectPlayerMap = Map();

  Future<ZegoAudioEffectPlayer?> createAudioEffectPlayer() async {
    int index = await _channel.invokeMethod('createAudioEffectPlayer');

    if (index >= 0) {
      ZegoAudioEffectPlayerImpl audioEffectPlayerInstance =
          ZegoAudioEffectPlayerImpl(index);
      audioEffectPlayerMap[index] = audioEffectPlayerInstance;

      return audioEffectPlayerInstance;
    } else {
      return null;
    }
  }

  Future<void> destroyAudioEffectPlayer(
      ZegoAudioEffectPlayer audioEffectPlayer) async {
    int index = audioEffectPlayer.getIndex();

    await _channel.invokeMethod('destroyAudioEffectPlayer', {'index': index});

    audioEffectPlayerMap.remove(index);

    return;
  }

  /* Record */

  Future<void> startRecordingCapturedData(ZegoDataRecordConfig config,
      {ZegoPublishChannel? channel}) async {
    return await _channel.invokeMethod('startRecordingCapturedData', {
      'config': {
        'filePath': config.filePath,
        'recordType': config.recordType.index
      },
      'channel': channel?.index ?? ZegoPublishChannel.Main.index
    });
  }

  Future<void> stopRecordingCapturedData({ZegoPublishChannel? channel}) async {
    return await _channel.invokeMethod('stopRecordingCapturedData',
        {'channel': channel?.index ?? ZegoPublishChannel.Main.index});
  }

  /* Custom Video Capture */

  Future<void> enableCustomVideoCapture(bool enable,
      {ZegoCustomVideoCaptureConfig? config,
      ZegoPublishChannel? channel}) async {
    return await _channel.invokeMethod('enableCustomVideoCapture', {
      'enable': enable,
      'config': config != null ? {'bufferType': config.bufferType.index} : {},
      'channel': channel?.index ?? ZegoPublishChannel.Main.index
    });
  }

  /* Custom Audio IO */
  Future<void> startAudioDataObserver(
      int observerBitMask, ZegoAudioFrameParam param) async {
    return await _channel.invokeMethod('startAudioDataObserver', {
      'observerBitMask': observerBitMask,
      'param': {
        'sampleRate': param.sampleRate.index,
        'channel': param.channel.index
      }
    });
  }

  Future<void> stopAudioDataObserver() async {
    return await _channel.invokeMethod('stopAudioDataObserver', {});
  }

  /* Utilities */

  Future<void> startPerformanceMonitor({int? millisecond}) async {
    return await _channel.invokeMethod(
        'startPerformanceMonitor', {'millisecond': millisecond ?? 2000});
  }

  Future<void> stopPerformanceMonitor() async {
    return await _channel.invokeMethod('stopPerformanceMonitor');
  }

  Future<void> startNetworkSpeedTest(ZegoNetworkSpeedTestConfig config) async {
    return await _channel.invokeMethod('startNetworkSpeedTest', {
      'config': {
        'testUplink': config.testUplink,
        'expectedUplinkBitrate': config.expectedUplinkBitrate,
        'testDownlink': config.testDownlink,
        'expectedDownlinkBitrate': config.expectedDownlinkBitrate
      }
    });
  }

  Future<void> stopNetworkSpeedTest() async {
    return await _channel.invokeMethod('stopNetworkSpeedTest');
  }

  /* EventHandler */

  static void _registerEventHandler() async {
    _streamSubscription =
        _event.receiveBroadcastStream().listen(_eventListener);
  }

  static void _unregisterEventHandler() async {
    await _streamSubscription?.cancel();
    _streamSubscription = null;
  }

  static void _eventListener(dynamic data) {
    final Map<dynamic, dynamic> map = data;
    switch (map['method']) {
      case 'onDebugError':
        if (ZegoExpressEngine.onDebugError == null) return;

        ZegoExpressEngine.onDebugError!(
            map['errorCode'], map['funcName'], map['info']);
        break;

      case 'onEngineStateUpdate':
        if (ZegoExpressEngine.onEngineStateUpdate == null) return;

        ZegoExpressEngine
            .onEngineStateUpdate!(ZegoEngineState.values[map['state']]);
        break;

      /* Room */

      case 'onRoomStateUpdate':
        if (ZegoExpressEngine.onRoomStateUpdate == null) return;

        Map<dynamic, dynamic> extendedData = jsonDecode(map['extendedData']);

        ZegoExpressEngine.onRoomStateUpdate!(
            map['roomID'],
            ZegoRoomState.values[map['state']],
            map['errorCode'],
            Map<String, dynamic>.from(extendedData));
        break;

      case 'onRoomUserUpdate':
        if (ZegoExpressEngine.onRoomUserUpdate == null) return;

        List<dynamic> userMapList = map['userList'];
        List<ZegoUser> userList = [];
        for (Map<dynamic, dynamic> userMap in userMapList) {
          ZegoUser user = ZegoUser(userMap['userID'], userMap['userName']);
          userList.add(user);
        }

        ZegoExpressEngine.onRoomUserUpdate!(
            map['roomID'], ZegoUpdateType.values[map['updateType']], userList);
        break;

      case 'onRoomOnlineUserCountUpdate':
        if (ZegoExpressEngine.onRoomOnlineUserCountUpdate == null) return;

        ZegoExpressEngine.onRoomOnlineUserCountUpdate!(
            map['roomID'], map['count']);
        break;

      case 'onRoomStreamUpdate':
        if (ZegoExpressEngine.onRoomStreamUpdate == null) return;

        List<dynamic> streamMapList = map['streamList'];
        List<ZegoStream> streamList = [];
        for (Map<dynamic, dynamic> streamMap in streamMapList) {
          ZegoStream stream = ZegoStream(
              ZegoUser(
                  streamMap['user']['userID'], streamMap['user']['userName']),
              streamMap['streamID'],
              streamMap['extraInfo']);
          streamList.add(stream);
        }

        Map<dynamic, dynamic> extendedData = jsonDecode(map['extendedData']);

        ZegoExpressEngine.onRoomStreamUpdate!(
            map['roomID'],
            ZegoUpdateType.values[map['updateType']],
            streamList,
            Map<String, dynamic>.from(extendedData));
        break;

      case 'onRoomStreamExtraInfoUpdate':
        if (ZegoExpressEngine.onRoomStreamExtraInfoUpdate == null) return;

        List<dynamic> streamMapList = map['streamList'];
        List<ZegoStream> streamList = [];
        for (Map<dynamic, dynamic> streamMap in streamMapList) {
          ZegoStream stream = ZegoStream(
              ZegoUser(
                  streamMap['user']['userID'], streamMap['user']['userName']),
              streamMap['streamID'],
              streamMap['extraInfo']);
          streamList.add(stream);
        }

        ZegoExpressEngine.onRoomStreamExtraInfoUpdate!(
            map['roomID'], streamList);
        break;

      case 'onRoomExtraInfoUpdate':
        if (ZegoExpressEngine.onRoomExtraInfoUpdate == null) return;

        List<dynamic> roomExtraInfoMapList = map['roomExtraInfoList'];
        List<ZegoRoomExtraInfo> roomExtraInfoList = [];
        for (Map<dynamic, dynamic> infoMap in roomExtraInfoMapList) {
          ZegoRoomExtraInfo info = ZegoRoomExtraInfo(
              infoMap['key'],
              infoMap['value'],
              ZegoUser(infoMap['updateUser']['userID'],
                  infoMap['updateUser']['userName']),
              infoMap['updateTime']);
          roomExtraInfoList.add(info);
        }

        ZegoExpressEngine.onRoomExtraInfoUpdate!(
            map['roomID'], roomExtraInfoList);
        break;

      /* Publisher */

      case 'onPublisherStateUpdate':
        if (ZegoExpressEngine.onPublisherStateUpdate == null) return;

        Map<dynamic, dynamic> extendedData = jsonDecode(map['extendedData']);

        ZegoExpressEngine.onPublisherStateUpdate!(
            map['streamID'],
            ZegoPublisherState.values[map['state']],
            map['errorCode'],
            Map<String, dynamic>.from(extendedData));
        break;

      case 'onPublisherQualityUpdate':
        if (ZegoExpressEngine.onPublisherQualityUpdate == null) return;

        ZegoExpressEngine.onPublisherQualityUpdate!(
            map['streamID'], ZegoPublishStreamQuality.fromMap(map['quality']));
        break;

      case 'onPublisherCapturedAudioFirstFrame':
        if (ZegoExpressEngine.onPublisherCapturedAudioFirstFrame == null)
          return;

        ZegoExpressEngine.onPublisherCapturedAudioFirstFrame!();
        break;

      case 'onPublisherCapturedVideoFirstFrame':
        if (ZegoExpressEngine.onPublisherCapturedVideoFirstFrame == null)
          return;

        ZegoExpressEngine.onPublisherCapturedVideoFirstFrame!(
            ZegoPublishChannel.values[map['channel']]);
        break;

      case 'onPublisherVideoSizeChanged':
        if (ZegoExpressEngine.onPublisherVideoSizeChanged == null) return;

        ZegoExpressEngine.onPublisherVideoSizeChanged!(map['width'],
            map['height'], ZegoPublishChannel.values[map['channel']]);
        break;

      case 'onPublisherRelayCDNStateUpdate':
        if (ZegoExpressEngine.onPublisherRelayCDNStateUpdate == null) return;

        List<dynamic> infoMapList = map['infoList'];
        List<ZegoStreamRelayCDNInfo> infoList = [];
        for (Map<dynamic, dynamic> infoMap in infoMapList) {
          ZegoStreamRelayCDNInfo info = ZegoStreamRelayCDNInfo(infoMap['url'],
              infoMap['state'], infoMap['updateReason'], infoMap['stateTime']);
          infoList.add(info);
        }

        ZegoExpressEngine.onPublisherRelayCDNStateUpdate!(
            map['stream'], infoList);
        break;

      /* Player */

      case 'onPlayerStateUpdate':
        if (ZegoExpressEngine.onPlayerStateUpdate == null) return;

        Map<dynamic, dynamic> extendedData = jsonDecode(map['extendedData']);

        ZegoExpressEngine.onPlayerStateUpdate!(
            map['streamID'],
            ZegoPlayerState.values[map['state']],
            map['errorCode'],
            Map<String, dynamic>.from(extendedData));
        break;

      case 'onPlayerQualityUpdate':
        if (ZegoExpressEngine.onPlayerQualityUpdate == null) return;

        ZegoExpressEngine.onPlayerQualityUpdate!(
            map['streamID'], ZegoPlayStreamQuality.fromMap(map['quality']));
        break;

      case 'onPlayerMediaEvent':
        if (ZegoExpressEngine.onPlayerMediaEvent == null) return;

        ZegoExpressEngine.onPlayerMediaEvent!(
            map['streamID'], ZegoPlayerMediaEvent.values[map['event']]);
        break;

      case 'onPlayerRecvAudioFirstFrame':
        if (ZegoExpressEngine.onPlayerRecvAudioFirstFrame == null) return;

        ZegoExpressEngine.onPlayerRecvAudioFirstFrame!(map['streamID']);
        break;

      case 'onPlayerRecvVideoFirstFrame':
        if (ZegoExpressEngine.onPlayerRecvVideoFirstFrame == null) return;

        ZegoExpressEngine.onPlayerRecvVideoFirstFrame!(map['streamID']);
        break;

      case 'onPlayerRenderVideoFirstFrame':
        if (ZegoExpressEngine.onPlayerRenderVideoFirstFrame == null) return;

        ZegoExpressEngine.onPlayerRenderVideoFirstFrame!(map['streamID']);
        break;

      case 'onPlayerVideoSizeChanged':
        if (ZegoExpressEngine.onPlayerVideoSizeChanged == null) return;

        ZegoExpressEngine.onPlayerVideoSizeChanged!(
            map['streamID'], map['width'], map['height']);
        break;

      case 'onPlayerRecvSEI':
        if (ZegoExpressEngine.onPlayerRecvSEI == null) return;

        ZegoExpressEngine.onPlayerRecvSEI!(map['streamID'], map['data']);
        break;

      /* Mixer*/

      case 'onMixerRelayCDNStateUpdate':
        if (ZegoExpressEngine.onMixerRelayCDNStateUpdate == null) return;

        List<dynamic> infoMapList = map['infoList'];
        List<ZegoStreamRelayCDNInfo> infoList = [];
        for (Map<dynamic, dynamic> infoMap in infoMapList) {
          ZegoStreamRelayCDNInfo info = ZegoStreamRelayCDNInfo(infoMap['url'],
              infoMap['state'], infoMap['updateReason'], infoMap['stateTime']);
          infoList.add(info);
        }

        ZegoExpressEngine.onMixerRelayCDNStateUpdate!(map['taskID'], infoList);
        break;

      case 'onMixerSoundLevelUpdate':
        if (ZegoExpressEngine.onMixerSoundLevelUpdate == null) return;

        Map<dynamic, dynamic> soundLevels = map['soundLevels'];

        ZegoExpressEngine
            .onMixerSoundLevelUpdate!(Map<int, double>.from(soundLevels));
        break;

      /* Device */

      case 'onAudioDeviceStateChanged':
        if (ZegoExpressEngine.onAudioDeviceStateChanged == null) return;

        ZegoDeviceInfo info = ZegoDeviceInfo(
            map['deviceInfo']['deviceID'], map['deviceInfo']['deviceName']);

        ZegoExpressEngine.onAudioDeviceStateChanged!(
            ZegoUpdateType.values[map['updateType']],
            ZegoAudioDeviceType.values[map['deviceType']],
            info);
        break;

      case 'onVideoDeviceStateChanged':
        if (ZegoExpressEngine.onVideoDeviceStateChanged == null) return;

        ZegoDeviceInfo info = ZegoDeviceInfo(
            map['deviceInfo']['deviceID'], map['deviceInfo']['deviceName']);

        ZegoExpressEngine.onVideoDeviceStateChanged!(
            ZegoUpdateType.values[map['updateType']], info);
        break;

      case 'onCapturedSoundLevelUpdate':
        if (ZegoExpressEngine.onCapturedSoundLevelUpdate == null) return;

        ZegoExpressEngine.onCapturedSoundLevelUpdate!(map['soundLevel']);
        break;

      case 'onRemoteSoundLevelUpdate':
        if (ZegoExpressEngine.onRemoteSoundLevelUpdate == null) return;

        Map<dynamic, dynamic> soundLevels = map['soundLevels'];

        ZegoExpressEngine
            .onRemoteSoundLevelUpdate!(Map<String, double>.from(soundLevels));
        break;

      case 'onCapturedAudioSpectrumUpdate':
        if (ZegoExpressEngine.onCapturedAudioSpectrumUpdate == null) return;

        ZegoExpressEngine.onCapturedAudioSpectrumUpdate!(map['audioSpectrum']);
        break;

      case 'onRemoteAudioSpectrumUpdate':
        if (ZegoExpressEngine.onRemoteAudioSpectrumUpdate == null) return;

        Map<dynamic, dynamic> originAudioSpectrums = map['audioSpectrums'];
        Map<String, List<double>> audioSpectrums = Map();
        for (String streamID in originAudioSpectrums.keys) {
          audioSpectrums[streamID] =
              List<double>.from(originAudioSpectrums[streamID]);
        }

        ZegoExpressEngine.onRemoteAudioSpectrumUpdate!(audioSpectrums);
        break;

      case 'onDeviceError':
        if (ZegoExpressEngine.onDeviceError == null) return;

        ZegoExpressEngine.onDeviceError!(map['errorCode'], map['deviceName']);
        break;

      case 'onRemoteCameraStateUpdate':
        if (ZegoExpressEngine.onRemoteCameraStateUpdate == null) return;

        ZegoExpressEngine.onRemoteCameraStateUpdate!(
            map['streamID'], ZegoRemoteDeviceState.values[map['state']]);
        break;

      case 'onRemoteMicStateUpdate':
        if (ZegoExpressEngine.onRemoteMicStateUpdate == null) return;

        ZegoExpressEngine.onRemoteMicStateUpdate!(
            map['streamID'], ZegoRemoteDeviceState.values[map['state']]);
        break;

      case 'onAudioRouteChange':
        if (ZegoExpressEngine.onAudioRouteChange == null) return;

        ZegoExpressEngine
            .onAudioRouteChange!(ZegoAudioRoute.values[map['audioRoute']]);
        break;

      /* IM */

      case 'onIMRecvBroadcastMessage':
        if (ZegoExpressEngine.onIMRecvBroadcastMessage == null) return;

        List<dynamic> messageMapList = map['messageList'];
        List<ZegoBroadcastMessageInfo> messageList = [];
        for (Map<dynamic, dynamic> messageMap in messageMapList) {
          ZegoBroadcastMessageInfo message = ZegoBroadcastMessageInfo(
              messageMap['message'],
              messageMap['messageID'],
              messageMap['sendTime'],
              ZegoUser(messageMap['fromUser']['userID'],
                  messageMap['fromUser']['userName']));
          messageList.add(message);
        }

        ZegoExpressEngine.onIMRecvBroadcastMessage!(map['roomID'], messageList);
        break;

      case 'onIMRecvBarrageMessage':
        if (ZegoExpressEngine.onIMRecvBarrageMessage == null) return;

        List<dynamic> messageMapList = map['messageList'];
        List<ZegoBarrageMessageInfo> messageList = [];
        for (Map<dynamic, dynamic> messageMap in messageMapList) {
          ZegoBarrageMessageInfo message = ZegoBarrageMessageInfo(
              messageMap['message'],
              messageMap['messageID'],
              messageMap['sendTime'],
              ZegoUser(messageMap['fromUser']['userID'],
                  messageMap['fromUser']['userName']));
          messageList.add(message);
        }

        ZegoExpressEngine.onIMRecvBarrageMessage!(map['roomID'], messageList);
        break;

      case 'onIMRecvCustomCommand':
        if (ZegoExpressEngine.onIMRecvCustomCommand == null) return;

        ZegoExpressEngine.onIMRecvCustomCommand!(
            map['roomID'],
            ZegoUser(map['fromUser']['userID'], map['fromUser']['userName']),
            map['command']);
        break;

      /* Utilities */

      case 'onPerformanceStatusUpdate':
        if (ZegoExpressEngine.onPerformanceStatusUpdate == null) return;

        Map<dynamic, dynamic> statusMap = map['status'];
        ZegoExpressEngine.onPerformanceStatusUpdate!(ZegoPerformanceStatus(
            statusMap['cpuUsageApp'],
            statusMap['cpuUsageSystem'],
            statusMap['memoryUsageApp'],
            statusMap['memoryUsageSystem'],
            statusMap['memoryUsedApp']));
        break;

      case 'onNetworkModeChanged':
        if (ZegoExpressEngine.onNetworkModeChanged == null) return;

        ZegoExpressEngine
            .onNetworkModeChanged!(ZegoNetworkMode.values[map['mode']]);
        break;

      case 'onNetworkSpeedTestError':
        if (ZegoExpressEngine.onNetworkSpeedTestError == null) return;

        ZegoExpressEngine.onNetworkSpeedTestError!(
            map['errorCode'], ZegoNetworkSpeedTestType.values[map['type']]);
        break;

      case 'onNetworkSpeedTestQualityUpdate':
        if (ZegoExpressEngine.onNetworkSpeedTestQualityUpdate == null) return;

        ZegoExpressEngine.onNetworkSpeedTestQualityUpdate!(
            ZegoNetworkSpeedTestQuality(map['quality']['connectCost'],
                map['quality']['rtt'], map['quality']['packetLostRate']),
            ZegoNetworkSpeedTestType.values[map['type']]);
        break;

      /* MediaPlayer */

      case 'onMediaPlayerStateUpdate':
        if (ZegoExpressEngine.onMediaPlayerStateUpdate == null) return;

        int? mediaPlayerIndex = map['mediaPlayerIndex'];
        ZegoMediaPlayer? mediaPlayer =
            ZegoExpressImpl.mediaPlayerMap[mediaPlayerIndex!];
        if (mediaPlayer != null) {
          ZegoExpressEngine.onMediaPlayerStateUpdate!(mediaPlayer,
              ZegoMediaPlayerState.values[map['state']], map['errorCode']);
        } else {
          // TODO: Can't find media player
        }
        break;

      case 'onMediaPlayerNetworkEvent':
        if (ZegoExpressEngine.onMediaPlayerNetworkEvent == null) return;

        int? mediaPlayerIndex = map['mediaPlayerIndex'];
        ZegoMediaPlayer? mediaPlayer =
            ZegoExpressImpl.mediaPlayerMap[mediaPlayerIndex!];
        if (mediaPlayer != null) {
          ZegoExpressEngine.onMediaPlayerNetworkEvent!(mediaPlayer,
              ZegoMediaPlayerNetworkEvent.values[map['networkEvent']]);
        } else {
          // TODO: Can't find media player
        }
        break;

      case 'onMediaPlayerPlayingProgress':
        if (ZegoExpressEngine.onMediaPlayerPlayingProgress == null) return;

        int? mediaPlayerIndex = map['mediaPlayerIndex'];
        ZegoMediaPlayer? mediaPlayer =
            ZegoExpressImpl.mediaPlayerMap[mediaPlayerIndex!];
        if (mediaPlayer != null) {
          ZegoExpressEngine.onMediaPlayerPlayingProgress!(
              mediaPlayer, map['millisecond']);
        } else {
          // TODO: Can't find media player
        }
        break;

      case 'onMediaPlayerRecvSEI':
        if (ZegoExpressEngine.onMediaPlayerRecvSEI == null) return;

        int? mediaPlayerIndex = map['mediaPlayerIndex'];
        ZegoMediaPlayer? mediaPlayer =
            ZegoExpressImpl.mediaPlayerMap[mediaPlayerIndex!];
        if (mediaPlayer != null) {
          ZegoExpressEngine.onMediaPlayerRecvSEI!(mediaPlayer, map['data']);
        } else {
          // TODO: Can't find media player
        }
        break;

      /* AudioEffectPlayer */

      case 'onAudioEffectPlayStateUpdate':
        if (ZegoExpressEngine.onAudioEffectPlayStateUpdate == null) return;

        int? audioEffectPlayerIndex = map['audioEffectPlayerIndex'];
        ZegoAudioEffectPlayer? audioEffectPlayer =
            ZegoExpressImpl.audioEffectPlayerMap[audioEffectPlayerIndex!];
        if (audioEffectPlayer != null) {
          ZegoExpressEngine.onAudioEffectPlayStateUpdate!(
              audioEffectPlayer,
              map['audioEffectID'],
              ZegoAudioEffectPlayState.values[map['state']],
              map['errorCode']);
        } else {
          // TODO: Can't find audio effect player
        }
        break;

      /* Record */

      case 'onCapturedDataRecordStateUpdate':
        if (ZegoExpressEngine.onCapturedDataRecordStateUpdate == null) return;

        ZegoExpressEngine.onCapturedDataRecordStateUpdate!(
            ZegoDataRecordState.values[map['state']],
            map['errorCode'],
            ZegoDataRecordConfig(map['config']['filePath'],
                ZegoDataRecordType.values[map['config']['recordType']]),
            ZegoPublishChannel.values[map['channel']]);
        break;

      case 'onCapturedDataRecordProgressUpdate':
        if (ZegoExpressEngine.onCapturedDataRecordProgressUpdate == null)
          return;

        ZegoExpressEngine.onCapturedDataRecordProgressUpdate!(
            ZegoDataRecordProgress(map['progress']['duration'],
                map['progress']['currentFileSize']),
            ZegoDataRecordConfig(map['config']['filePath'],
                ZegoDataRecordType.values[map['config']['recordType']]),
            ZegoPublishChannel.values[map['channel']]);
        break;

      case 'onCapturedAudioData':
        if (ZegoExpressEngine.onCapturedAudioData == null) return;

        Uint8List data = map['data'];
        int dataLength = map['dataLength'];
        Map<dynamic, dynamic> paramMap = map['param'];
        ZegoExpressEngine.onCapturedAudioData!(data, dataLength,
            ZegoAudioFrameParam(paramMap['sampleRate'], paramMap['channel']));
        break;

      case 'onPlaybackAudioData':
        if (ZegoExpressEngine.onPlaybackAudioData == null) return;

        Uint8List data = map['data'];
        int dataLength = map['dataLength'];
        Map<dynamic, dynamic> paramMap = map['param'];
        ZegoExpressEngine.onPlaybackAudioData!(data, dataLength,
            ZegoAudioFrameParam(paramMap['sampleRate'], paramMap['channel']));
        break;

      case 'onMixedAudioData':
        if (ZegoExpressEngine.onMixedAudioData == null) return;

        Uint8List data = map['data'];
        int dataLength = map['dataLength'];
        Map<dynamic, dynamic> paramMap = map['param'];
        ZegoExpressEngine.onMixedAudioData!(data, dataLength,
            ZegoAudioFrameParam(paramMap['sampleRate'], paramMap['channel']));
        break;

      case 'onPlayerAudioData':
        if (ZegoExpressEngine.onPlayerAudioData == null) return;

        Uint8List data = map['data'];
        int dataLength = map['dataLength'];
        Map<dynamic, dynamic> paramMap = map['param'];
        String streamID = map['streamID'];

        ZegoExpressEngine.onPlayerAudioData!(
            data,
            dataLength,
            ZegoAudioFrameParam(paramMap['sampleRate'], paramMap['channel']),
            streamID);
        break;

      default:
        // TODO: Unknown callback
        break;
    }
  }
}

class ZegoMediaPlayerImpl extends ZegoMediaPlayer {
  int _index;

  ZegoMediaPlayerImpl(int index) : _index = index;

  @override
  Future<ZegoMediaPlayerLoadResourceResult> loadResource(String path) async {
    final Map<dynamic, dynamic> map = await ZegoExpressImpl._channel
        .invokeMethod(
            'mediaPlayerLoadResource', {'index': _index, 'path': path});

    return ZegoMediaPlayerLoadResourceResult(map['errorCode']);
  }

  @override
  Future<void> start() async {
    return await ZegoExpressImpl._channel
        .invokeMethod('mediaPlayerStart', {'index': _index});
  }

  @override
  Future<void> stop() async {
    return await ZegoExpressImpl._channel
        .invokeMethod('mediaPlayerStop', {'index': _index});
  }

  @override
  Future<void> pause() async {
    return await ZegoExpressImpl._channel
        .invokeMethod('mediaPlayerPause', {'index': _index});
  }

  @override
  Future<void> resume() async {
    return await ZegoExpressImpl._channel
        .invokeMethod('mediaPlayerResume', {'index': _index});
  }

  @override
  Future<ZegoMediaPlayerSeekToResult> seekTo(int millisecond) async {
    final Map<dynamic, dynamic> map = await ZegoExpressImpl._channel
        .invokeMethod(
            'mediaPlayerSeekTo', {'index': _index, 'millisecond': millisecond});

    return ZegoMediaPlayerSeekToResult(map['errorCode']);
  }

  @override
  Future<void> enableRepeat(bool enable) async {
    return await ZegoExpressImpl._channel.invokeMethod(
        'mediaPlayerEnableRepeat', {'index': _index, 'enable': enable});
  }

  @override
  Future<void> enableAux(bool enable) async {
    return await ZegoExpressImpl._channel.invokeMethod(
        'mediaPlayerEnableAux', {'index': _index, 'enable': enable});
  }

  @override
  Future<void> muteLocal(bool mute) async {
    return await ZegoExpressImpl._channel
        .invokeMethod('mediaPlayerMuteLocal', {'index': _index, 'mute': mute});
  }

  @override
  Future<void> setVolume(int volume) async {
    return await ZegoExpressImpl._channel.invokeMethod(
        'mediaPlayerSetVolume', {'index': _index, 'volume': volume});
  }

  @override
  Future<void> setPlayVolume(int volume) async {
    return await ZegoExpressImpl._channel.invokeMethod(
        'mediaPlayerSetPlayVolume', {'index': _index, 'volume': volume});
  }

  @override
  Future<void> setPublishVolume(int volume) async {
    return await ZegoExpressImpl._channel.invokeMethod(
        'mediaPlayerSetPublishVolume', {'index': _index, 'volume': volume});
  }

  @override
  Future<void> setProgressInterval(int millisecond) async {
    return await ZegoExpressImpl._channel.invokeMethod(
        'mediaPlayerSetProgressInterval',
        {'index': _index, 'millisecond': millisecond});
  }

  @override
  Future<int> getPlayVolume() async {
    return await ZegoExpressImpl._channel
        .invokeMethod('mediaPlayerGetPlayVolume', {'index': _index});
  }

  @override
  Future<int> getPublishVolume() async {
    return await ZegoExpressImpl._channel
        .invokeMethod('mediaPlayerGetPublishVolume', {'index': _index});
  }

  @override
  Future<int> getTotalDuration() async {
    return await ZegoExpressImpl._channel
        .invokeMethod('mediaPlayerGetTotalDuration', {'index': _index});
  }

  @override
  Future<int> getCurrentProgress() async {
    return await ZegoExpressImpl._channel
        .invokeMethod('mediaPlayerGetCurrentProgress', {'index': _index});
  }

  @override
  Future<int> getAudioTrackCount() async {
    return await ZegoExpressImpl._channel
        .invokeMethod('mediaPlayerGetAudioTrackCount', {'index': _index});
  }

  @override
  Future<void> setAudioTrackIndex(int index) async {
    return await ZegoExpressImpl._channel.invokeMethod(
        'mediaPlayerSetAudioTrackIndex',
        {'index': _index, 'trackIndex': index});
  }

  @override
  Future<void> setVoiceChangerParam(ZegoMediaPlayerAudioChannel audioChannel,
      ZegoVoiceChangerParam param) async {
    return await ZegoExpressImpl._channel
        .invokeMethod('mediaPlayerSetVoiceChangerParam', {
      'index': _index,
      'audioChannel': audioChannel.index,
      'param': {'pitch': param.pitch}
    });
  }

  @override
  Future<ZegoMediaPlayerState> getCurrentState() async {
    int state = await ZegoExpressImpl._channel
        .invokeMethod('mediaPlayerGetCurrentState', {'index': _index});

    return ZegoMediaPlayerState.values[state];
  }

  @override
  int getIndex() {
    return _index;
  }
}

class ZegoAudioEffectPlayerImpl extends ZegoAudioEffectPlayer {
  int _index;

  ZegoAudioEffectPlayerImpl(int index) : _index = index;

  @override
  Future<void> start(int audioEffectID,
      {String? path, ZegoAudioEffectPlayConfig? config}) async {
    return await ZegoExpressImpl._channel
        .invokeMethod('audioEffectPlayerStart', {
      'index': _index,
      'audioEffectID': audioEffectID,
      'path': path ?? '',
      'config': config != null
          ? {'playCount': config.playCount, 'isPublishOut': config.isPublishOut}
          : {}
    });
  }

  @override
  Future<void> stop(int audioEffectID) async {
    return await ZegoExpressImpl._channel.invokeMethod('audioEffectPlayerStop',
        {'index': _index, 'audioEffectID': audioEffectID});
  }

  @override
  Future<void> pause(int audioEffectID) async {
    return await ZegoExpressImpl._channel.invokeMethod('audioEffectPlayerPause',
        {'index': _index, 'audioEffectID': audioEffectID});
  }

  @override
  Future<void> resume(int audioEffectID) async {
    return await ZegoExpressImpl._channel.invokeMethod(
        'audioEffectPlayerResume',
        {'index': _index, 'audioEffectID': audioEffectID});
  }

  @override
  Future<void> stopAll() async {
    return await ZegoExpressImpl._channel
        .invokeMethod('audioEffectPlayerStopAll', {'index': _index});
  }

  @override
  Future<void> pauseAll() async {
    return await ZegoExpressImpl._channel
        .invokeMethod('audioEffectPlayerPauseAll', {'index': _index});
  }

  @override
  Future<void> resumeAll() async {
    return await ZegoExpressImpl._channel
        .invokeMethod('audioEffectPlayerResumeAll', {'index': _index});
  }

  @override
  Future<ZegoAudioEffectPlayerSeekToResult> seekTo(
      int audioEffectID, int millisecond) async {
    final Map<dynamic, dynamic> map = await ZegoExpressImpl._channel
        .invokeMethod('audioEffectPlayerSeekTo', {
      'index': _index,
      'audioEffectID': audioEffectID,
      'millisecond': millisecond
    });

    return ZegoAudioEffectPlayerSeekToResult(map['errorCode']);
  }

  @override
  Future<void> setVolume(int audioEffectID, int volume) async {
    return await ZegoExpressImpl._channel.invokeMethod(
        'audioEffectPlayerSetVolume',
        {'index': _index, 'audioEffectID': audioEffectID, 'volume': volume});
  }

  @override
  Future<void> setVolumeAll(int volume) async {
    return await ZegoExpressImpl._channel.invokeMethod(
        'audioEffectPlayerSetVolumeAll', {'index': _index, 'volume': volume});
  }

  @override
  Future<int> getTotalDuration(int audioEffectID) async {
    return await ZegoExpressImpl._channel
        .invokeMethod('audioEffectPlayerGetTotalDuration', {
      'index': _index,
      'audioEffectID': audioEffectID,
    });
  }

  @override
  Future<int> getCurrentProgress(int audioEffectID) async {
    return await ZegoExpressImpl._channel
        .invokeMethod('audioEffectPlayerGetCurrentProgress', {
      'index': _index,
      'audioEffectID': audioEffectID,
    });
  }

  @override
  Future<ZegoAudioEffectPlayerLoadResourceResult> loadResource(
      int audioEffectID, String path) async {
    final Map<dynamic, dynamic> map = await ZegoExpressImpl._channel
        .invokeMethod('audioEffectPlayerLoadResource',
            {'index': _index, 'audioEffectID': audioEffectID, 'path': path});

    return ZegoAudioEffectPlayerLoadResourceResult(map['errorCode']);
  }

  @override
  Future<void> unloadResource(int audioEffectID) async {
    return await ZegoExpressImpl._channel
        .invokeMethod('audioEffectPlayerUnloadResource', {
      'index': _index,
      'audioEffectID': audioEffectID,
    });
  }

  @override
  int getIndex() {
    return _index;
  }
}
