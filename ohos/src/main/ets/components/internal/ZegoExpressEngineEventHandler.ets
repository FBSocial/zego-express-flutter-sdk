import { Any } from '@ohos/flutter_ohos';
import { EventSink } from '@ohos/flutter_ohos/src/main/ets/plugin/common/EventChannel'
import ZegoExpressEngine, {
  ZegoEngineState,
  ZegoRoomState,
  ZegoRoomStateChangedReason,
  ZegoUpdateType,
  ZegoUser,
  ZegoStream,
  ZegoRoomExtraInfo,
  ZegoPublisherState,
  ZegoPublishStreamQuality,
  ZegoPublishChannel,
  ZegoStreamRelayCDNInfo,
  ZegoVideoCodecID,
  ZegoStreamEvent,
  ZegoObjectSegmentationState,
  ZegoPlayerState,
  ZegoPlayStreamQuality,
  ZegoPlayerMediaEvent,
  ZegoDeviceExceptionType,
  ZegoDeviceType,
  ZegoRemoteDeviceState,
  ZegoAudioRoute,
  ZegoAudioVADStableStateMonitorType,
  ZegoAudioVADType,
  ZegoBroadcastMessageInfo,
  ZegoNetworkSpeedTestQuality,
  ZegoNetworkSpeedTestType,
  ZegoStreamQualityLevel,
  ZegoBarrageMessageInfo,
} from 'ZegoExpressEngine';
import { zegoLogger } from './ZegoLog'
import { ArrayList, HashMap } from '@kit.ArkTS';

export default class ZegoExpressEngineEventHandler {
  public eventSink: EventSink | null = null

  guardSink(): boolean {
    if (this.eventSink == null) {
      zegoLogger.error("FlutterEventSink is null")
      return true
    }
    return false
  }

  initSDKEvent(engine: ZegoExpressEngine): void {
    if (this.guardSink()) {
      return
    }
    engine.on('onDebugError', (errorCode: number, funcName: string, info: string) => {
      zegoLogger.debug('[onDebugError] code: ' + errorCode + ', function: ' + funcName + ', info: ' + info)
      if (this.guardSink()) {
        return
      }
      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onDebugError')
      map.set('errorCode', errorCode)
      map.set('funcName', funcName)
      map.set('info', info)
      this.eventSink!.success(map)
    })

    engine.on('onEngineStateUpdate', (state: ZegoEngineState) => {
      zegoLogger.debug("[onEngineStateUpdate] state: " + state.toString());
      if (this.guardSink()) {
        return
      }

      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onEngineStateUpdate')
      map.set('state', state.valueOf())
      this.eventSink!.success(map)
    })

    engine.on('onNetworkTimeSynchronized', () => {
      zegoLogger.debug("[onNetworkTimeSynchronized]");
      if (this.guardSink()) {
        return;
      }

      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onNetworkTimeSynchronized')
      this.eventSink!.success(map)
    })


    engine.on('onRoomStateUpdate', (roomID: string, state: ZegoRoomState, errorCode: number, extendedData: string) => {
      zegoLogger.debug("[onRoomStateUpdate] roomID: " + roomID + ", state: " + state.toString() + ", errorCode:" +
        errorCode)
      if (this.guardSink()) {
        return
      }

      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onRoomStateUpdate')
      map.set('roomID', roomID)
      map.set('state', state.valueOf())
      map.set('errorCode', errorCode)
      map.set('extendedData', extendedData.toString())

      this.eventSink!.success(map)
    })

    engine.on('onRoomStateChanged',
      (roomID: string, reason: ZegoRoomStateChangedReason, errorCode: number, extendedData: string) => {
        zegoLogger.debug("[onRoomStateChanged] roomID: " + roomID + ", reason: " + reason.toString() + ", errorCode:" +
          errorCode)
        if (this.guardSink()) {
          return
        }

        let map: HashMap<string, Any> = new HashMap()
        map.set('method', 'onRoomStateChanged')
        map.set('roomID', roomID)
        map.set('reason', reason.valueOf())
        map.set('errorCode', errorCode)
        map.set('extendedData', extendedData.toString())
        this.eventSink!.success(map)
      })

    engine.on('onRoomUserUpdate', (roomID: string, updateType: ZegoUpdateType, userList: ZegoUser[]) => {
      zegoLogger.debug("[onRoomUserUpdate] roomID: " + roomID + ", updateType: " + updateType.toString() +
        ", userListCount: " + userList.length)
      if (this.guardSink()) {
        return
      }

      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onRoomUserUpdate')
      map.set('roomID', roomID)
      map.set('updateType', updateType.valueOf())
      map.set('userList', this.mapListFromUserList(userList))
      this.eventSink!.success(map)
    })

    engine.on('onRoomOnlineUserCountUpdate', (roomID: string, count: number) => {
      zegoLogger.debug("[onRoomOnlineUserCountUpdate] roomID: " + roomID + ", count:" + count)
      if (this.guardSink()) {
        return
      }

      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onRoomOnlineUserCountUpdate')
      map.set('roomID', roomID)
      map.set('count', count)
      this.eventSink!.success(map)
    })

    engine.on('onRoomStreamUpdate',
      (roomID: string, updateType: ZegoUpdateType, streamList: ZegoStream[], extendedData: string) => {
        zegoLogger.debug("[onRoomStreamUpdate] roomID: " + roomID + ", updateType: " + updateType.toString() +
          ", streamListCount: " + streamList.length + ", extendedDataLength: " + extendedData.length)
        if (this.guardSink()) {
          return
        }

        let map: HashMap<string, Any> = new HashMap()
        map.set('method', 'onRoomStreamUpdate')
        map.set('roomID', roomID)
        map.set('updateType', updateType.valueOf())
        map.set('streamList', this.mapListFromStreamList(streamList))
        map.set('extendedData', extendedData.toString())

        this.eventSink!.success(map)
      })

    engine.on('onRoomStreamExtraInfoUpdate', (roomID: string, streamList: ZegoStream[]) => {
      zegoLogger.debug("[onRoomStreamExtraInfoUpdate] roomID: " + roomID + ", streamListCount: " + streamList.length)
      if (this.guardSink()) {
        return
      }

      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onRoomStreamExtraInfoUpdate')
      map.set('roomID', roomID)
      map.set('streamList', this.mapListFromStreamList(streamList))
      this.eventSink!.success(map)
    })

    engine.on('onRoomExtraInfoUpdate', (roomID: string, roomExtraInfoList: ZegoRoomExtraInfo[]) => {
      zegoLogger.debug("[onRoomExtraInfoUpdate] roomID: " + roomID + ", roomExtraInfoListCount: " +
      roomExtraInfoList.length)
      if (this.guardSink()) {
        return
      }

      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onRoomExtraInfoUpdate')
      map.set('roomID', roomID)
      map.set('roomExtraInfoList', this.mapListFromRoomExtraInfoList(roomExtraInfoList))
      this.eventSink!.success(map)
    })

    engine.on('onRoomTokenWillExpire', (roomID: string, remainTimeInSecond: number) => {
      zegoLogger.debug("[onRoomTokenWillExpire] roomID: " + roomID + ", remainTimeInSecond: " + remainTimeInSecond)
      if (this.guardSink()) {
        return
      }

      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onRoomTokenWillExpire')
      map.set('roomID', roomID)
      map.set('remainTimeInSecond', remainTimeInSecond)
      this.eventSink!.success(map)
    })


    /// Publisher

    engine.on('onPublisherStateUpdate',
      (streamID: string, state: ZegoPublisherState, errorCode: number, extendedData: string) => {
        zegoLogger.debug("[onPublisherStateUpdate] streamID: " + streamID + ", state: " + state.toString() +
          ", errorCode: " + errorCode)
        if (this.guardSink()) {
          return
        }

        let map: HashMap<string, Any> = new HashMap()
        map.set('method', 'onPublisherStateUpdate')
        map.set('streamID', streamID)
        map.set('state', state.valueOf())
        map.set('errorCode', errorCode)
        map.set('extendedData', extendedData.toString())
        this.eventSink!.success(map)
      })

    engine.on('onPublisherQualityUpdate', (streamID: string, quality: ZegoPublishStreamQuality) => {
      // High frequency callbacks do not log
      if (this.guardSink()) {
        return
      }

      let qualityMap: HashMap<String, Object> = this.convertPublishStreamQuality(quality);
      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onPublisherQualityUpdate')
      map.set('streamID', streamID)
      map.set('quality', qualityMap)
      this.eventSink!.success(map)
    })

    engine.on('onPublisherCapturedAudioFirstFrame', () => {
      zegoLogger.debug("[onPublisherCapturedAudioFirstFrame]")
      if (this.guardSink()) {
        return;
      }

      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onPublisherCapturedAudioFirstFrame')
      this.eventSink!.success(map)
    })

    engine.on('onPublisherCapturedVideoFirstFrame', (channel: ZegoPublishChannel) => {
      zegoLogger.debug("[onPublisherCapturedVideoFirstFrame] channel: " + channel.toString())
      if (this.guardSink()) {
        return
      }

      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onPublisherCapturedVideoFirstFrame')
      map.set('channel', channel.valueOf())
      this.eventSink!.success(map)
    })

    engine.on('onPublisherRenderVideoFirstFrame', (channel: ZegoPublishChannel) => {
      zegoLogger.debug("[onPublisherRenderVideoFirstFrame] channel: " + channel.toString())
      if (this.guardSink()) {
        return;
      }

      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onPublisherRenderVideoFirstFrame')
      map.set('channel', channel.valueOf())
      this.eventSink!.success(map)
    })

    engine.on('onPublisherVideoSizeChanged', (width: number, height: number, channel: ZegoPublishChannel) => {
      zegoLogger.debug("[onPublisherVideoSizeChanged] width: " + width + ", height: " + height + ", channel: " +
      channel.toString())

      if (this.guardSink()) {
        return;
      }

      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onPublisherVideoSizeChanged')
      map.set('width', width)
      map.set('height', height)
      map.set('channel', channel.valueOf())
      this.eventSink!.success(map)
    })

    engine.on('onPublisherRelayCDNStateUpdate', (streamID: string, infoList: ZegoStreamRelayCDNInfo[]) => {
      zegoLogger.debug("[onPublisherRelayCDNStateUpdate] streamID: " + streamID + ", streamInfoListCount: " +
      infoList.length)
      if (this.guardSink()) {
        return;
      }

      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onPublisherRelayCDNStateUpdate')
      map.set('streamID', streamID)
      map.set('streamInfoList', this.mapListFromStreamRelayCdnInfoList(infoList))
      this.eventSink!.success(map)
    })

    engine.on('onPublisherVideoEncoderChanged',
      (fromCodecID: ZegoVideoCodecID, toCodecID: ZegoVideoCodecID, channel: ZegoPublishChannel) => {
        zegoLogger.debug("[onPublisherVideoEncoderChanged] fromCodecID: " + fromCodecID.toString() + ", toCodecID: " +
        toCodecID.toString() + ", channel: " + channel.toString())
        if (this.guardSink()) {
          return
        }

        let map: HashMap<string, Any> = new HashMap()
        map.set('method', 'onPublisherVideoEncoderChanged')
        map.set('fromCodecID', fromCodecID.valueOf())
        map.set('toCodecID', toCodecID.valueOf())
        map.set('channel', channel.valueOf())
        this.eventSink!.success(map)
      })

    engine.on('onPublisherStreamEvent', (eventID: ZegoStreamEvent, streamID: string, extraInfo: string) => {
      zegoLogger.debug("[onPublisherStreamEvent] eventID: " + eventID.toString() + ", streamID: " + streamID +
        ", extraInfo: " + extraInfo)
      if (this.guardSink()) {
        return;
      }

      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onPublisherStreamEvent')
      map.set('eventID', eventID.valueOf())
      map.set('streamID', streamID)
      map.set('extraInfo', extraInfo)
      this.eventSink!.success(map)
    })

    engine.on('onVideoObjectSegmentationStateChanged',
      (state: ZegoObjectSegmentationState, channel: ZegoPublishChannel, errorCode: number) => {
        zegoLogger.debug("[onVideoObjectSegmentationStateChanged] state: " + state.toString() + ", channel: " +
        channel.toString() + ", errorCode: " + errorCode)
        if (this.guardSink()) {
          return
        }

        let map: HashMap<string, Any> = new HashMap()
        map.set('method', 'onVideoObjectSegmentationStateChanged')
        map.set('state', state.valueOf())
        map.set('channel', channel.valueOf())
        map.set('errorCode', errorCode)
        this.eventSink!.success(map)
      })

    engine.on('onPublisherLowFpsWarning', (codecID: ZegoVideoCodecID, channel: ZegoPublishChannel) => {
      zegoLogger.debug("[onPublisherLowFpsWarning] codecID: " + codecID.toString() + ", channel: " + channel.toString())
      if (this.guardSink()) {
        return
      }

      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onPublisherLowFpsWarning')
      map.set('codecID', codecID.valueOf())
      map.set('channel', channel.valueOf())
      this.eventSink!.success(map)
    })


    /// Player

    engine.on('onPlayerStateUpdate',
      (streamID: string, state: ZegoPlayerState, errorCode: number, extendedData: string) => {
        zegoLogger.debug("[onPlayerStateUpdate] streamID: " + streamID + ", state: " + state.toString() +
          ", errorCode: " + errorCode)
        if (this.guardSink()) {
          return
        }

        let map: HashMap<string, Any> = new HashMap()
        map.set('method', 'onPlayerStateUpdate')
        map.set('streamID', streamID)
        map.set('state', state.valueOf())
        map.set('errorCode', errorCode)
        map.set('extendedData', extendedData.toString())
        this.eventSink!.success(map);
      })

    engine.on('onPlayerQualityUpdate', (streamID: string, quality: ZegoPlayStreamQuality) => {
      // High frequency callbacks do not log
      if (this.guardSink()) {
        return
      }

      let qualityMap: Map<string, Any> = new Map()
      qualityMap.set("videoRecvFPS", quality.videoRecvFPS)
      qualityMap.set("videoDejitterFPS", quality.videoDejitterFPS)
      qualityMap.set("videoDecodeFPS", quality.videoDecodeFPS)
      qualityMap.set("videoRenderFPS", quality.videoRenderFPS)
      qualityMap.set("videoKBPS", quality.videoKBPS)
      qualityMap.set("videoBreakRate", quality.videoBreakRate)
      qualityMap.set("audioRecvFPS", quality.audioRecvFPS)
      qualityMap.set("audioDejitterFPS", quality.audioDejitterFPS)
      qualityMap.set("audioDecodeFPS", quality.audioDecodeFPS)
      qualityMap.set("audioRenderFPS", quality.audioRenderFPS)
      qualityMap.set("audioKBPS", quality.audioKBPS)
      qualityMap.set("audioBreakRate", quality.audioBreakRate)
      qualityMap.set("mos", quality.mos)
      qualityMap.set("rtt", quality.rtt)
      qualityMap.set("packetLostRate", quality.packetLostRate)
      qualityMap.set("peerToPeerDelay", quality.peerToPeerDelay)
      qualityMap.set("peerToPeerPacketLostRate", quality.peerToPeerPacketLostRate)
      qualityMap.set("level", quality.level.valueOf())
      qualityMap.set("delay", quality.delay)
      qualityMap.set("avTimestampDiff", quality.avTimestampDiff)
      qualityMap.set("isHardwareDecode", quality.isHardwareDecode)
      qualityMap.set("videoCodecID", quality.videoCodecID.valueOf())
      qualityMap.set("totalRecvBytes", quality.totalRecvBytes)
      qualityMap.set("audioRecvBytes", quality.audioRecvBytes)
      qualityMap.set("videoRecvBytes", quality.videoRecvBytes)
      qualityMap.set("audioCumulativeBreakCount", quality.audioCumulativeBreakCount)
      qualityMap.set("videoCumulativeBreakCount", quality.videoCumulativeBreakCount)
      qualityMap.set("audioCumulativeBreakTime", quality.audioCumulativeBreakTime)
      qualityMap.set("videoCumulativeBreakTime", quality.videoCumulativeBreakTime)
      qualityMap.set("audioCumulativeBreakRate", quality.audioCumulativeBreakRate)
      qualityMap.set("videoCumulativeBreakRate", quality.videoCumulativeBreakRate)
      qualityMap.set("audioCumulativeDecodeTime", quality.audioCumulativeDecodeTime)
      qualityMap.set("videoCumulativeDecodeTime", quality.videoCumulativeDecodeTime)
      qualityMap.set("muteVideo", quality.muteVideo)
      qualityMap.set("muteAudio", quality.muteAudio)
      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onPlayerQualityUpdate')
      map.set('streamID', streamID)
      map.set('quality', qualityMap)
      this.eventSink!.success(map)
    })

    engine.on('onPlayerMediaEvent', (streamID: string, event: ZegoPlayerMediaEvent) => {
      zegoLogger.debug("[onPlayerMediaEvent] streamID: " + streamID + ", event: " + event.toString())
      if (this.guardSink()) {
        return
      }

      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onPlayerMediaEvent')
      map.set('streamID', streamID)
      map.set('event', event.valueOf())
      this.eventSink!.success(map)
    })

    engine.on('onPlayerRecvAudioFirstFrame', (streamID: string) => {
      zegoLogger.debug("[onPlayerRecvAudioFirstFrame] streamID: " + streamID)
      if (this.guardSink()) {
        return
      }

      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onPlayerRecvAudioFirstFrame')
      map.set('streamID', streamID)
      this.eventSink!.success(map)
    })


    engine.on('onPlayerRecvVideoFirstFrame', (streamID: string) => {
      zegoLogger.debug("[onPlayerRecvVideoFirstFrame] streamID: " + streamID)
      if (this.guardSink()) {
        return
      }

      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onPlayerRecvVideoFirstFrame')
      map.set('streamID', streamID)
      this.eventSink!.success(map)
    })

    engine.on('onPlayerRenderVideoFirstFrame', (streamID: string) => {
      zegoLogger.debug("[onPlayerRenderVideoFirstFrame] streamID: " + streamID)
      if (this.guardSink()) {
        return
      }

      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onPlayerRenderVideoFirstFrame')
      map.set('streamID', streamID)
      this.eventSink!.success(map)
    })

    engine.on('onPlayerVideoSizeChanged', (streamID: string, width: number, height: number) => {
      zegoLogger.debug("[onPlayerVideoSizeChanged] streamID: " + streamID + ", width: " + width + ", height: " + height)
      if (this.guardSink()) {
        return
      }
      let map: HashMap<string, Any> = new HashMap()

      map.set('method', 'onPlayerVideoSizeChanged')
      map.set('streamID', streamID)
      map.set('width', width)
      map.set('height', height)
      this.eventSink!.success(map)
    })

    engine.on('onPlayerRecvSEI', (streamID: string, data: ArrayBuffer) => {
      // Do not log high frequency callback
      if (this.guardSink()) {
        return
      }
      let map: HashMap<string, Any> = new HashMap()

      map.set('method', 'onPlayerRecvSEI')
      map.set('streamID', streamID)
      map.set('data', data)
      this.eventSink!.success(map)
    })

    engine.on('onPlayerRecvAudioSideInfo', (streamID: string, data: ArrayBuffer) => {
      // Do not log high frequency callback
      if (this.guardSink()) {
        return
      }

      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onPlayerRecvAudioSideInfo')
      map.set('streamID', streamID)
      map.set('data', data)
      this.eventSink!.success(map)
    })

    engine.on('onPlayerLowFpsWarning', (codecID: ZegoVideoCodecID, streamID: string) => {
      zegoLogger.debug("[onPlayerLowFpsWarning] ZegoVideoCodecID: " + codecID.toString() + ", streamID: " + streamID)
      if (this.guardSink()) {
        return
      }

      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onPlayerLowFpsWarning')
      map.set('codecID', codecID.valueOf())
      map.set('streamID', streamID)
      this.eventSink!.success(map)
    })

    engine.on('onPlayerStreamEvent', (eventID: ZegoStreamEvent, streamID: string, extraInfo: string) => {
      zegoLogger.debug("[onPlayerStreamEvent] eventID: " + eventID.toString() + ", streamID: " + streamID +
        ", extraInfo: " + extraInfo)
      if (this.guardSink()) {
        return
      }

      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onPlayerStreamEvent')
      map.set('eventID', eventID.valueOf())
      map.set('streamID', streamID)
      map.set('extraInfo', extraInfo)
      this.eventSink!.success(map)
    })

    engine.on('onPlayerRenderCameraVideoFirstFrame', (streamID: string) => {
      zegoLogger.debug("[onPlayerRenderCameraVideoFirstFrame] streamID: " + streamID)
      if (this.guardSink()) {
        return
      }

      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onPlayerRenderCameraVideoFirstFrame')
      map.set('streamID', streamID)
      this.eventSink!.success(map)
    })

    engine.on('onPlayerVideoSizeChanged', (streamID: string, width: number, height: number) => {
      zegoLogger.debug("[onPlayerVideoSizeChanged] streamID: " + streamID + ", width: " + width + ", height: " + height)
      if (this.guardSink()) {
        return
      }

      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onPlayerVideoSizeChanged')
      map.set('streamID', streamID)
      map.set('width', width)
      map.set('height', height)
      this.eventSink!.success(map)
    })

    engine.on('onPlayerStreamEvent', (eventID: ZegoStreamEvent, streamID: string, extraInfo: string) => {
      zegoLogger.debug("[onPlayerStreamEvent] eventID: " + eventID.toString() + ", streamID: " + streamID +
        ", extraInfo: " + extraInfo)
      if (this.guardSink()) {
        return
      }

      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onPlayerVideoSizeChanged')
      map.set('streamID', streamID)
      map.set('eventID', eventID.valueOf())
      map.set('extraInfo', extraInfo)
      this.eventSink!.success(map)
    })


    /// Mixer

    engine.on('onMixerRelayCDNStateUpdate', (taskID: string, infoList: ZegoStreamRelayCDNInfo[]) => {
      zegoLogger.debug("[onMixerRelayCDNStateUpdate] taskID: " + taskID + ", infosCount: " + infoList.length)
      if (this.guardSink()) {
        return
      }

      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onMixerRelayCDNStateUpdate')
      map.set('infoList', this.mapListFromStreamRelayCdnInfoList(infoList))
      map.set('taskID', taskID)
      this.eventSink!.success(map)
    })

    engine.on('onMixerSoundLevelUpdate', (soundLevels: Object) => {
      // Super high frequency callbacks do not log, do not guard sink
      if (this.guardSink()) {
        return
      }

      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onMixerSoundLevelUpdate')
      map.set('soundLevels', soundLevels)
      this.eventSink!.success(map)
    })


    /// Device

    engine.on('onCapturedSoundLevelUpdate', (soundLevel: number) => {
      // Super high frequency callbacks do not log, do not guard sink
      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onCapturedSoundLevelUpdate')
      map.set('soundLevel', soundLevel)
      this.eventSink!.success(map)
    })

    engine.on('onRemoteSoundLevelUpdate', (soundLevels: Object) => {
      // Super high frequency callbacks do not log, do not guard sink
      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onRemoteSoundLevelUpdate')
      map.set('soundLevels', soundLevels)
      this.eventSink!.success(map)
    })

    engine.on('onCapturedAudioSpectrumUpdate', (audioSpectrum: number[]) => {
      // Super high frequency callbacks do not log, do not guard sink
      let audioSpectrumList: ArrayList<number> = new ArrayList()

      for (let spectrumValue of audioSpectrum) {
        audioSpectrumList.add(spectrumValue)
      }
      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onCapturedAudioSpectrumUpdate')
      map.set('audioSpectrum', audioSpectrumList)
      this.eventSink!.success(map)
    })

    engine.on('onRemoteAudioSpectrumUpdate', (audioSpectrums: Object) => {
      // Super high frequency callbacks do not log, do not guard sink
      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onRemoteAudioSpectrumUpdate')
      map.set('audioSpectrums', audioSpectrums)
      this.eventSink!.success(map)
    })

    engine.on('onLocalDeviceExceptionOccurred',
      (exceptionType: ZegoDeviceExceptionType, deviceType: ZegoDeviceType, deviceID: string) => {
        zegoLogger.debug("[onLocalDeviceExceptionOccurred] deviceID: " + deviceID + ", exceptionType: " +
        exceptionType.toString() + ", deviceType: " + deviceType.toString())
        if (this.guardSink()) {
          return
        }

        let map: HashMap<string, Any> = new HashMap()
        map.set('method', 'onLocalDeviceExceptionOccurred')
        map.set('deviceID', deviceID)
        map.set('exceptionType', exceptionType.valueOf())
        map.set('deviceType', deviceType.valueOf())
        this.eventSink!.success(map)
      })

    engine.on('onRemoteCameraStateUpdate', (streamID: string, state: ZegoRemoteDeviceState) => {
      zegoLogger.debug("[onRemoteCameraStateUpdate] streamID: " + streamID + ", state: " + state.toString())
      if (this.guardSink()) {
        return
      }

      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onRemoteCameraStateUpdate')
      map.set('streamID', streamID)
      map.set('state', state.valueOf())
      this.eventSink!.success(map)
    })

    engine.on('onRemoteSpeakerStateUpdate', (streamID: string, state: ZegoRemoteDeviceState) => {
      zegoLogger.debug("[onRemoteSpeakerStateUpdate] streamID: " + streamID + ", state: " + state.toString())
      if (this.guardSink()) {
        return
      }

      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onRemoteSpeakerStateUpdate')
      map.set('streamID', streamID)
      map.set('state', state.valueOf())
      this.eventSink!.success(map)
    })

    engine.on('onRemoteMicStateUpdate', (streamID: string, state: ZegoRemoteDeviceState) => {
      zegoLogger.debug("[onRemoteMicStateUpdate] streamID: " + streamID + ", state: " + state.toString())
      if (this.guardSink()) {
        return
      }

      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onRemoteMicStateUpdate')
      map.set('streamID', streamID)
      map.set('state', state.valueOf())
      this.eventSink!.success(map)
    })

    engine.on('onAudioRouteChange', (audioRoute: ZegoAudioRoute) => {
      zegoLogger.debug("[onAudioRouteChange] audioRoute: " + audioRoute.toString())
      if (this.guardSink()) {
        return
      }

      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onAudioRouteChange')
      map.set('audioRoute', audioRoute.valueOf())
      this.eventSink!.success(map)
    })

    engine.on('onAudioVADStateUpdate', (type: ZegoAudioVADStableStateMonitorType, state: ZegoAudioVADType) => {
      zegoLogger.debug("[onAudioVADStateUpdate] type: " + type.toString() + ", state: " + state.toString())
      if (this.guardSink()) {
        return
      }

      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onAudioVADStateUpdate')
      map.set('type', type.valueOf())
      map.set('state', state.valueOf())
      this.eventSink!.success(map)
    })


    /// IM

    engine.on('onIMRecvBroadcastMessage', (roomID: string, messageList: ZegoBroadcastMessageInfo[]) => {
      zegoLogger.debug("[onIMRecvBroadcastMessage] roomID: " + roomID + ", messageListCount: " + messageList.length)
      if (this.guardSink()) {
        return
      }

      let map: HashMap<string, Any> = new HashMap()
      let messageArrayList: ArrayList<HashMap<String, Object>> = new ArrayList()

      for (let message of messageList) {
        let userMap: HashMap<String, Object> = new HashMap()
        userMap["userID"] = message.fromUser.userID
        userMap["userName"] = message.fromUser.userName
        let messageMap: HashMap<String, Object> = new HashMap()
        messageMap["message"] = message.message
        messageMap["messageID"] = message.messageID
        messageMap["sendTime"] = message.sendTime
        messageMap["fromUser"] = userMap
        messageArrayList.add(messageMap)
      }

      map.set('method', 'onIMRecvBroadcastMessage')
      map.set('roomID', roomID)
      map.set('messageList', messageArrayList)
      this.eventSink!.success(map)
    })

    engine.on('onIMRecvBarrageMessage', (roomID: string, messageList: ZegoBarrageMessageInfo[]) => {
      zegoLogger.debug("[onIMRecvBarrageMessage] roomID: " + roomID + ", messageListCount: " + messageList.length)
      if (this.guardSink()) {
        return
      }

      let map: HashMap<string, Any> = new HashMap()
      let messageArrayList: ArrayList<HashMap<String, Object>> = new ArrayList()

      for (let message of messageList) {
        let userMap: HashMap<String, Object> = new HashMap()
        userMap["userID"] = message.fromUser.userID
        userMap["userName"] = message.fromUser.userName
        let messageMap: HashMap<String, Object> = new HashMap()
        messageMap["message"] = message.message
        messageMap["messageID"] = message.messageID
        messageMap["sendTime"] = message.sendTime
        messageMap["fromUser"] = userMap
        messageArrayList.add(messageMap);
      }

      map.set('method', 'onIMRecvBarrageMessage')
      map.set('roomID', roomID)
      map.set('messageList', messageArrayList)
      this.eventSink!.success(map)
    })

    engine.on('onIMRecvCustomCommand', (roomID: string, fromUser: ZegoUser, command: string) => {
      zegoLogger.debug("[onIMRecvCustomCommand] roomID: " + roomID + ", fromUserID: " + fromUser.userID +
        ", fromUserName: " + fromUser.userName + ", command: " + command)
      if (this.guardSink()) {
        return
      }

      let userMap: HashMap<String, Object> = new HashMap()
      userMap["userID"] = fromUser.userID
      userMap["userName"] = fromUser.userName

      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onIMRecvCustomCommand')
      map.set('roomID', roomID)
      map.set('fromUser', userMap)
      map.set('command', command)
      this.eventSink!.success(map)
    })


    /// Utilities

    engine.on('onNetworkSpeedTestError', (errorCode: number, type: ZegoNetworkSpeedTestType) => {
      zegoLogger.debug("[onNetworkSpeedTestError] errorCode: " + errorCode + ", type: " + type.toString())
      if (this.guardSink()) {
        return
      }

      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onNetworkSpeedTestError')
      map.set('errorCode', errorCode)
      map.set('type', type.valueOf())
      this.eventSink!.success(map)
    })

    engine.on('onNetworkSpeedTestQualityUpdate',
      (quality: ZegoNetworkSpeedTestQuality, type: ZegoNetworkSpeedTestType) => {
        // High frequency callbacks do not log
        if (this.guardSink()) {
          return;
        }

        let qualityMap: HashMap<String, Object> = new HashMap()
        qualityMap["connectCost"] = quality.connectCost
        qualityMap["rtt"] = quality.rtt
        qualityMap["packetLostRate"] = quality.packetLostRate
        qualityMap["quality"] = quality.quality.valueOf()

        let map: HashMap<string, Any> = new HashMap()
        map.set('method', 'onNetworkSpeedTestQualityUpdate')
        map.set('quality', qualityMap)
        map.set('type', type.valueOf())
        this.eventSink!.success(map)
      })

    engine.on('onRecvExperimentalAPI', (content: string) => {
      zegoLogger.debug("[onRecvExperimentalAPI] content: " + content)
      if (this.guardSink()) {
        return
      }

      let map: HashMap<string, Any> = new HashMap()
      map.set('method', 'onRecvExperimentalAPI')
      map.set('content', content)
      this.eventSink!.success(map)
    })

    engine.on('onNetworkQuality',
      (userID: string, upstreamQuality: ZegoStreamQualityLevel, downstreamQuality: ZegoStreamQualityLevel) => {
        // High frequency callbacks do not log
        if (this.guardSink()) {
          return;
        }

        let map: HashMap<string, Any> = new HashMap()
        map.set('method', 'onNetworkQuality')
        map.set('userID', userID)
        map.set('upstreamQuality', upstreamQuality.valueOf())
        map.set('downstreamQuality', downstreamQuality.valueOf())
        this.eventSink!.success(map)
      })
  }

  /* Private Utils */

  private convertPublishStreamQuality(quality: ZegoPublishStreamQuality): HashMap<String, Object> {
    let qualityMap: HashMap<String, Object> = new HashMap()
    qualityMap.set("videoCaptureFPS", quality.videoCaptureFPS)
    qualityMap.set("videoEncodeFPS", quality.videoEncodeFPS)
    qualityMap.set("videoSendFPS", quality.videoSendFPS)
    qualityMap.set("videoKBPS", quality.videoKBPS)
    qualityMap.set("audioCaptureFPS", quality.audioCaptureFPS)
    qualityMap.set("audioSendFPS", quality.audioSendFPS)
    qualityMap.set("audioKBPS", quality.audioKBPS)
    qualityMap.set("rtt", quality.rtt)
    qualityMap.set("packetLostRate", quality.packetLostRate)
    qualityMap.set("level", quality.level.valueOf())
    qualityMap.set("isHardwareEncode", quality.isHardwareEncode)
    qualityMap.set("videoCodecID", quality.videoCodecID.valueOf())
    qualityMap.set("totalSendBytes", quality.totalSendBytes)
    qualityMap.set("audioSendBytes", quality.audioSendBytes)
    qualityMap.set("videoSendBytes", quality.videoSendBytes)
    return qualityMap;
  }

  private mapListFromUserList(userList: ZegoUser[]): ArrayList<HashMap<string, Object>> {
    let arrayList: ArrayList<HashMap<string, Any>> = new ArrayList()

    for (let user of userList) {
      let map: HashMap<string, Object> = new HashMap()
      map.set('userID', user.userID)
      map.set('userName', user.userName)
      arrayList.add(map)
    }
    return arrayList
  }

  private mapListFromStreamList(streamList: ZegoStream[]): ArrayList<HashMap<String, Object>> {
    let arrayList: ArrayList<HashMap<String, Object>> = new ArrayList()
    for (let stream of streamList) {
      let userMap: HashMap<String, Object> = new HashMap()
      userMap.set('userID', stream.user.userID)
      userMap.set('userName', stream.user.userName)

      let map: HashMap<string, Any> = new HashMap()
      map.set('user', userMap)
      map.set('streamID', stream.streamID)
      map.set('extraInfo', stream.extraInfo)
      arrayList.add(map);
    }
    return arrayList;
  }

  private mapListFromRoomExtraInfoList(roomExtraInfoList: ZegoRoomExtraInfo[]): ArrayList<HashMap<String, Object>> {
    let arrayList: ArrayList<HashMap<String, Object>> = new ArrayList()

    for (let extraInfo of roomExtraInfoList) {
      let userMap: HashMap<String, Object> = new HashMap()
      userMap.set('userID', extraInfo.updateUser.userID)
      userMap.set('userName', extraInfo.updateUser.userName)

      let map: HashMap<string, Object> = new HashMap()
      map.set('key', extraInfo.key)
      map.set('value', extraInfo.value)
      map.set('updateUser', userMap)
      map.set('updateTime', extraInfo.updateTime)
      arrayList.add(map);
    }
    return arrayList;
  }

  private mapListFromStreamRelayCdnInfoList(infoList: ZegoStreamRelayCDNInfo[]): ArrayList<HashMap<String, Object>> {
    let arrayList: ArrayList<HashMap<String, Object>> = new ArrayList()

    for (let info of infoList) {
      let map: HashMap<string, Any> = new HashMap()
      map.set('url', info.url)
      map.set('state', info.state.valueOf())
      map.set('updateReason', info.updateReason.valueOf())
      map.set('stateTime', info.stateTime)
      arrayList.add(map);
    }
    return arrayList;
  }
}

export let zegoExpressEngineEventHandler = new ZegoExpressEngineEventHandler()

