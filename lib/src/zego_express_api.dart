
import 'dart:typed_data';
import 'zego_express_impl.dart';
import 'zego_express_defines.dart';

class ZegoExpressEngine {

  /// Private constructor
  ZegoExpressEngine._internal();

  /// Engine singleton instance
  static final ZegoExpressEngine instance = ZegoExpressEngine._internal();

  /// Creates a singleton instance of ZegoExpressEngine.
  ///
  /// The engine needs to be created and initialized before calling other functions. The SDK only supports the creation of one instance of ZegoExpressEngine. Multiple calls to this function return the same object.
  ///
  /// - [profile] The basic configuration information is used to create the engine.
  static Future<void> createEngineWithProfile(ZegoEngineProfile profile) async {
    return await ZegoExpressImpl.createEngineWithProfile(profile);
  }

  /// [Deprecated] Creates a singleton instance of ZegoExpressEngine.
  ///
  /// Deprecated since 2.14.0, please use the method with the same name without [isTestEnv] parameter instead.
  /// The engine needs to be created and initialized before calling other functions. The SDK only supports the creation of one instance of ZegoExpressEngine. Multiple calls to this function return the same object.
  ///
  /// @deprecated Deprecated since 2.14.0, please use the method with the same name without [isTestEnv] parameter instead.
  /// - [appID] Application ID issued by ZEGO for developers, please apply from the ZEGO Admin Console https://console-express.zego.im The value ranges from 0 to 4294967295.
  /// - [appSign] Application signature for each AppID, please apply from the ZEGO Admin Console. Application signature is a 64 character string. Each character has a range of '0' ~ '9', 'a' ~ 'z'.
  /// - [isTestEnv] Choose to use a test environment or a formal commercial environment, the formal environment needs to submit work order configuration in the ZEGO management console. The test environment is for test development, with a limit of 10 rooms and 50 users. Official environment App is officially launched. ZEGO will provide corresponding server resources according to the configuration records submitted by the developer in the management console. The test environment and the official environment are two sets of environments and cannot be interconnected.
  /// - [scenario] The application scenario. Developers can choose one of ZegoScenario based on the scenario of the app they are developing, and the engine will preset a more general setting for specific scenarios based on the set scenario. After setting specific scenarios, developers can still call specific functions to set specific parameters if they have customized parameter settings.
  /// - [enablePlatformView] Set whether to use Platform View for rendering, true: rendering using Platform View, false: rendering using Texture, default is false
  @Deprecated('Deprecated since 2.14.0, please use the method with the same name without [isTestEnv] parameter instead.')
  static Future<void> createEngine(int appID, String appSign, bool isTestEnv, ZegoScenario scenario, {bool? enablePlatformView}) async {
    return await ZegoExpressImpl.createEngine(appID, appSign, isTestEnv, scenario, enablePlatformView: enablePlatformView);
  }

  /// Creates a singleton instance of ZegoExpressEngine.
  ///
  /// The engine needs to be created and initialized before calling other functions. The SDK only supports the creation of one instance of ZegoExpressEngine. Multiple calls to this function return the same object.
  ///
  /// - [appID] Application ID issued by ZEGO for developers, please apply from the ZEGO Admin Console https://console-express.zego.im The value ranges from 0 to 4294967295.
  /// - [appSign] Application signature for each AppID, please apply from the ZEGO Admin Console. Application signature is a 64 character string. Each character has a range of '0' ~ '9', 'a' ~ 'z'.
  /// - [isTestEnv] Choose to use a test environment or a formal commercial environment, the formal environment needs to submit work order configuration in the ZEGO management console. The test environment is for test development, with a limit of 10 rooms and 50 users. Official environment App is officially launched. ZEGO will provide corresponding server resources according to the configuration records submitted by the developer in the management console. The test environment and the official environment are two sets of environments and cannot be interconnected.
  /// - [scenario] The application scenario. Developers can choose one of ZegoScenario based on the scenario of the app they are developing, and the engine will preset a more general setting for specific scenarios based on the set scenario. After setting specific scenarios, developers can still call specific functions to set specific parameters if they have customized parameter settings.
  /// - [enablePlatformView] Set whether to use Platform View for rendering, true: rendering using Platform View, false: rendering using Texture, default is false
  static Future<void> createEngine(int appID, String appSign, bool isTestEnv, ZegoScenario scenario, {bool? enablePlatformView}) async {
    return await ZegoExpressImpl.createEngine(appID, appSign, isTestEnv, scenario, enablePlatformView: enablePlatformView);
  }

  /// Destroys the singleton instance of ZegoExpressEngine asynchronously.
  ///
  /// Used to release resources used by ZegoExpressEngine.
  static Future<void> destroyEngine() async {
    return await ZegoExpressImpl.destroyEngine();
  }

  /// Set advanced engine configuration.
  ///
  /// Developers need to call this function to set advanced function configuration when they need advanced functions of the engine.
  ///
  /// - [config] Advanced engine configuration
  static Future<void> setEngineConfig(ZegoEngineConfig config) async {
    return await ZegoExpressImpl.setEngineConfig(config);
  }

  /// Set room mode
  ///
  /// It must be called before the SDK is initialized, otherwise it will fail.
  /// If you need to use the multi-room feature, please contact the instant technical support to configure the server support.
  ///
  /// - [mode] Room mode, the default is single room mode
  static Future<void> setRoomMode(ZegoRoomMode mode) async {
    return await ZegoExpressImpl.setRoomMode(mode);
  }

  /// Gets the SDK's version number.
  ///
  /// When the SDK is running, the developer finds that it does not match the expected situation and submits the problem and related logs to the ZEGO technical staff for locating. The ZEGO technical staff may need the information of the engine version to assist in locating the problem.
  /// Developers can also collect this information as the version information of the engine used by the app, so that the SDK corresponding to each version of the app on the line.
  ///
  /// - Returns SDK version
  static Future<String> getVersion() async {
    return await ZegoExpressImpl.getVersion();
  }

  /// Uploads logs to the ZEGO server.
  ///
  /// By default, SDK creates and prints log files in the app's default directory. Each log file defaults to a maximum of 5MB. Three log files are written over and over in a circular fashion. When calling this function, SDK will auto package and upload the log files to the ZEGO server.
  /// Developers can provide a business “feedback” channel in the app. When users feedback problems, they can call this function to upload the local log information of SDK to help locate user problems.
  /// The function is valid for the entire life cycle of the SDK.
  Future<void> uploadLog() async {
    return await ZegoExpressImpl.instance.uploadLog();
  }

  /// Call the RTC experimental API
  ///
  /// ZEGO provides some technical previews or special customization functions in RTC business through this API. If you need to get the use of the function or the details, please consult ZEGO technical support
  ///
  /// - [params] You need to pass in a parameter in the form of a JSON string
  /// - Returns Returns an argument in the format of a JSON string
  Future<String> callExperimentalAPI(String params) async {
    return await ZegoExpressImpl.instance.callExperimentalAPI(params);
  }

  /// The callback for obtaining debugging error information.
  ///
  /// When the SDK functions are not used correctly, the callback prompts for detailed error information, which is controlled by the [setDebugVerbose] function
  ///
  /// - [errorCode] Error code, please refer to the error codes document https://doc-en.zego.im/en/5548.html for details.
  /// - [funcName] Function name
  /// - [info] Detailed error information
  static void Function(int errorCode, String funcName, String info)? onDebugError;

  /// The callback triggered when the audio/video engine state changes.
  ///
  /// When the developer calls the function that enables audio and video related functions, such as calling [startPreview], [startPublishingStream], [startPlayingStream] and MediaPlayer related function, the audio/video engine will start; when all audio and video functions are stopped, the engine state will become stopped.
  /// When the developer has been [loginRoom], once [logoutRoom] is called, the audio/video engine will stop (preview, publishing/playing stream, MediaPlayer and other audio and video related functions will also stop).
  ///
  /// - [state] The audio/video engine state
  static void Function(ZegoEngineState state)? onEngineStateUpdate;

  /// The callback triggered when the room connection state changes.
  ///
  /// This callback is triggered when the connection status of the room changes, and the reason for the change is notified. Developers can use this callback to determine the status of the current user in the room.
  /// When the user starts to log in to the room, the room is successfully logged in, or the room fails to log in, the [onRoomStateUpdate] callback will be triggered to notify the developer of the status of the current user connected to the room.
  /// If the connection is being requested for a long time, the general probability is that the user's network is unstable.
  ///
  /// - [roomID] Room ID, a string of up to 128 bytes in length.
  /// - [state] Changed room state
  /// - [errorCode] Error code, please refer to the error codes document https://doc-en.zego.im/en/5548.html for details.
  /// - [extendedData] Extended Information with state updates. When the room login is successful, the key "room_session_id" can be used to obtain the unique RoomSessionID of each audio and video communication, which identifies the continuous communication from the first user in the room to the end of the audio and video communication. It can be used in scenarios such as call quality scoring and call problem diagnosis.
  static void Function(String roomID, ZegoRoomState state, int errorCode, Map<String, dynamic> extendedData)? onRoomStateUpdate;

  /// The callback triggered when the number of other users in the room increases or decreases.
  ///
  /// This callback is used to monitor the increase or decrease of other users in the room, and the developer can judge the situation of the users in the room based on this callback.
  /// If developers need to use ZEGO room users notifications, please ensure that the [ZegoRoomConfig] sent by each user when logging in to the room has the [isUserStatusNotify] property set to true, otherwise the callback notification will not be received.
  /// The user logs in to the room, and there is no other user in the room at this time, the callback will not be triggered.
  /// The user logs in to the room. If multiple other users already exist in the room, the callback will be triggered. At this time, the callback belongs to the ADD type and contains the full list of users in the room. At the same time, other users in the room will also receive this callback of the ADD type, but there are only new current users in the received user list.
  /// When the user is already in the room, this callback will be triggered when other users in the room log in or log out of the room.
  ///
  /// - [roomID] Room ID where the user is logged in, a string of up to 128 bytes in length.
  /// - [updateType] Update type (add/delete)
  /// - [userList] List of users changed in the current room
  static void Function(String roomID, ZegoUpdateType updateType, List<ZegoUser> userList)? onRoomUserUpdate;

  /// The callback triggered every 30 seconds to report the current number of online users.
  ///
  /// This function is called back every 30 seconds.
  /// Developers can use this callback to show the number of user online in the current room.
  ///
  /// - [roomID] Room ID where the user is logged in, a string of up to 128 bytes in length.
  /// - [count] Count of online users
  static void Function(String roomID, int count)? onRoomOnlineUserCountUpdate;

  /// The callback triggered when the number of streams published by the other users in the same room increases or decreases.
  ///
  /// This callback is used to monitor stream addition or stream deletion notifications of other users in the room. Developers can use this callback to determine whether other users in the same room start or stop publishing stream, so as to achieve active playing stream [startPlayingStream] or take the initiative to stop the playing stream [stopPlayingStream], and use it to change the UI controls at the same time.
  /// The user logs in to the room, and there is no other stream in the room at this time, the callback will not be triggered.
  /// The user logs in to the room. If there are multiple streams of other users in the room, the callback will be triggered. At this time, the callback belongs to the ADD type and contains the full list of streams in the room.
  /// When the user is already in the room, when other users in the room start or stop publishing stream (that is, when a stream is added or deleted), this callback will be triggered to notify the changed stream list.
  ///
  /// - [roomID] Room ID where the user is logged in, a string of up to 128 bytes in length.
  /// - [updateType] Update type (add/delete)
  /// - [streamList] Updated stream list
  /// - [extendedData] Extended information with stream updates.
  static void Function(String roomID, ZegoUpdateType updateType, List<ZegoStream> streamList, Map<String, dynamic> extendedData)? onRoomStreamUpdate;

  /// The callback triggered when there is an update on the extra information of the streams published by other users in the same room.
  ///
  /// When a user publishing the stream update the extra information of the stream in the same room, other users in the same room will receive the callback.
  /// The stream extra information is an extra information identifier of the stream ID. Unlike the stream ID, which cannot be modified during the publishing process, the stream extra information can be modified midway through the stream corresponding to the stream ID.
  /// Developers can synchronize variable content related to stream IDs based on stream additional information.
  ///
  /// - [roomID] Room ID where the user is logged in, a string of up to 128 bytes in length.
  /// - [streamList] List of streams that the extra info was updated.
  static void Function(String roomID, List<ZegoStream> streamList)? onRoomStreamExtraInfoUpdate;

  /// The callback triggered when there is an update on the extra information of the room.
  ///
  /// When a user update the room extra information, other users in the same room will receive the callback.
  ///
  /// - [roomID] Room ID where the user is logged in, a string of up to 128 bytes in length.
  /// - [roomExtraInfoList] List of the extra info updated.
  static void Function(String roomID, List<ZegoRoomExtraInfo> roomExtraInfoList)? onRoomExtraInfoUpdate;

  /// The callback triggered when the state of stream publishing changes.
  ///
  /// After publishing the stream successfully, the notification of the publish stream state change can be obtained through the callback function.
  /// You can roughly judge the user's uplink network status based on whether the state parameter is in [PUBLISH_REQUESTING].
  /// The parameter [extendedData] is extended information with state updates. If you use ZEGO's CDN content distribution network, after the stream is successfully published, the keys of the content of this parameter are [flv_url_list], [rtmp_url_list], [hls_url_list]. These correspond to the publishing stream URLs of the flv, rtmp, and hls protocols.
  ///
  /// - [streamID] Stream ID
  /// - [state] State of publishing stream
  /// - [errorCode] The error code corresponding to the status change of the publish stream, please refer to the error codes document https://doc-en.zego.im/en/5548.html for details.
  /// - [extendedData] Extended information with state updates.
  static void Function(String streamID, ZegoPublisherState state, int errorCode, Map<String, dynamic> extendedData)? onPublisherStateUpdate;

  /// Callback for current stream publishing quality.
  ///
  /// After calling the [startPublishingStream] successfully, the callback will be received every 3 seconds. Through the callback, the collection frame rate, bit rate, RTT, packet loss rate and other quality data of the published audio and video stream can be obtained, and the health of the publish stream can be monitored in real time.
  /// You can monitor the health of the published audio and video streams in real time according to the quality parameters of the callback function, in order to show the uplink network status in real time on the device UI.
  /// If you does not know how to use the parameters of this callback function, you can only pay attention to the [level] field of the [quality] parameter, which is a comprehensive value describing the uplink network calculated by SDK based on the quality parameters.
  ///
  /// - [streamID] Stream ID
  /// - [quality] Publishing stream quality, including audio and video framerate, bitrate, RTT, etc.
  static void Function(String streamID, ZegoPublishStreamQuality quality)? onPublisherQualityUpdate;

  /// The callback triggered when the first audio frame is captured.
  ///
  /// After the [startPublishingStream] function is called successfully, this callback will be called when SDK received the first frame of audio data.
  /// In the case of no startPublishingStream audio and video stream or preview, the first startPublishingStream audio and video stream or first preview, that is, when the engine of the audio and video module inside SDK starts, it will collect audio data of the local device and receive this callback.
  /// Developers can use this callback to determine whether SDK has actually collected audio data. If the callback is not received, the audio capture device is occupied or abnormal.
  static void Function()? onPublisherCapturedAudioFirstFrame;

  /// The callback triggered when the first video frame is captured.
  ///
  /// After the [startPublishingStream] function is called successfully, this callback will be called when SDK received the first frame of video data.
  /// In the case of no startPublishingStream video stream or preview, the first startPublishingStream video stream or first preview, that is, when the engine of the audio and video module inside SDK starts, it will collect video data of the local device and receive this callback.
  /// Developers can use this callback to determine whether SDK has actually collected video data. If the callback is not received, the video capture device is occupied or abnormal.
  ///
  /// - [channel] Publishing stream channel.If you only publish one audio and video stream, you can ignore this parameter.
  static void Function(ZegoPublishChannel channel)? onPublisherCapturedVideoFirstFrame;

  /// The callback triggered when the video capture resolution changes.
  ///
  /// After the successful publish, the callback will be received if there is a change in the video capture resolution in the process of publishing the stream.
  /// When the audio and video stream is not published or previewed for the first time, the publishing stream or preview first time, that is, the engine of the audio and video module inside the SDK is started, the video data of the local device will be collected, and the collection resolution will change at this time.
  /// You can use this callback to remove the cover of the local preview UI and similar operations.You can also dynamically adjust the scale of the preview view based on the resolution of the callback.
  ///
  /// - [width] Video capture resolution width
  /// - [height] Video capture resolution height
  /// - [channel] Publishing stream channel.If you only publish one audio and video stream, you can ignore this parameter.
  static void Function(int width, int height, ZegoPublishChannel channel)? onPublisherVideoSizeChanged;

  /// The callback triggered when the state of relayed streaming to CDN changes.
  ///
  /// After the ZEGO RTC server relays the audio and video streams to the CDN, this callback will be received if the CDN relay status changes, such as a stop or a retry.
  /// Developers can use this callback to determine whether the audio and video streams of the relay CDN are normal. If they are abnormal, further locate the cause of the abnormal audio and video streams of the relay CDN and make corresponding disaster recovery strategies.
  /// If you do not understand the cause of the abnormality, you can contact ZEGO technicians to analyze the specific cause of the abnormality.
  ///
  /// - [streamID] Stream ID
  /// - [infoList] List of information that the current CDN is relaying
  static void Function(String streamID, List<ZegoStreamRelayCDNInfo> infoList)? onPublisherRelayCDNStateUpdate;

  /// The callback triggered when the state of stream playing changes.
  ///
  /// After publishing the stream successfully, the notification of the publish stream state change can be obtained through the callback function.
  /// You can roughly judge the user's downlink network status based on whether the state parameter is in [PLAY_REQUESTING].
  ///
  /// - [streamID] stream ID
  /// - [state] State of playing stream
  /// - [errorCode] The error code corresponding to the status change of the playing stream, please refer to the error codes document https://doc-en.zego.im/en/5548.html for details.
  /// - [extendedData] Extended Information with state updates. As the standby, only an empty json table is currently returned
  static void Function(String streamID, ZegoPlayerState state, int errorCode, Map<String, dynamic> extendedData)? onPlayerStateUpdate;

  /// Callback for current stream playing quality.
  ///
  /// After calling the [startPlayingStream] successfully, this callback will be triggered every 3 seconds. The collection frame rate, bit rate, RTT, packet loss rate and other quality data can be obtained, such the health of the publish stream can be monitored in real time.
  /// You can monitor the health of the played audio and video streams in real time according to the quality parameters of the callback function, in order to show the downlink network status on the device UI in real time.
  /// If you does not know how to use the various parameters of the callback function, you can only focus on the level field of the quality parameter, which is a comprehensive value describing the downlink network calculated by SDK based on the quality parameters.
  ///
  /// - [streamID] Stream ID
  /// - [quality] Playing stream quality, including audio and video framerate, bitrate, RTT, etc.
  static void Function(String streamID, ZegoPlayStreamQuality quality)? onPlayerQualityUpdate;

  /// The callback triggered when a media event occurs during streaming playing.
  ///
  /// This callback is triggered when an event such as audio and video jamming and recovery occurs in the playing stream.
  /// You can use this callback to make statistics on stutters or to make friendly displays in the UI of the app.
  ///
  /// - [streamID] Stream ID
  /// - [event] Specific events received when playing the stream.
  static void Function(String streamID, ZegoPlayerMediaEvent event)? onPlayerMediaEvent;

  /// The callback triggered when the first audio frame is received.
  ///
  /// After the [startPlayingStream] function is called successfully, this callback will be called when SDK received the first frame of audio data.
  ///
  /// - [streamID] Stream ID
  static void Function(String streamID)? onPlayerRecvAudioFirstFrame;

  /// The callback triggered when the first video frame is received.
  ///
  /// After the [startPlayingStream] function is called successfully, this callback will be called when SDK received the first frame of video data.
  ///
  /// - [streamID] Stream ID
  static void Function(String streamID)? onPlayerRecvVideoFirstFrame;

  /// The callback triggered when the first video frame is rendered.
  ///
  /// After the [startPlayingStream] function is called successfully, this callback will be called when SDK rendered the first frame of video data.
  /// Developer can use this callback to count time consuming that take the first frame time or update the UI for playing stream.
  ///
  /// - [streamID] Stream ID
  static void Function(String streamID)? onPlayerRenderVideoFirstFrame;

  /// The callback triggered when the stream playback resolution changes.
  ///
  /// If there is a change in the video resolution of the playing stream, the callback will be triggered, and the user can adjust the display for that stream dynamically.
  /// If the publishing stream end triggers the internal stream flow control of SDK due to a network problem, the encoding resolution of the streaming end may be dynamically reduced, and this callback will also be received at this time.
  /// If the stream is only audio data, the callback will not be received.
  /// This callback will be triggered when the played audio and video stream is actually rendered to the set UI play canvas. You can use this callback notification to update or switch UI components that actually play the stream.
  ///
  /// - [streamID] Stream ID
  /// - [width] Video decoding resolution width
  /// - [height] Video decoding resolution height
  static void Function(String streamID, int width, int height)? onPlayerVideoSizeChanged;

  /// The callback triggered when Supplemental Enhancement Information is received.
  ///
  /// After the remote stream is successfully played, when the remote stream sends SEI (such as directly calling [sendSEI], audio mixing with SEI data, and sending custom video capture encoded data with SEI, etc.), the local end will receive this callback.
  /// Since the video encoder itself generates an SEI with a payload type of 5, or when a video file is used for publishing, such SEI may also exist in the video file. Therefore, if the developer needs to filter out this type of SEI, it can be before [createEngine] Call [ZegoEngineConfig.advancedConfig("unregister_sei_filter", "XXXXX")]. Among them, unregister_sei_filter is the key, and XXXXX is the uuid filter string to be set.
  ///
  /// - [streamID] Stream ID
  /// - [data] SEI content
  static void Function(String streamID, Uint8List data)? onPlayerRecvSEI;

  /// The callback triggered when the state of relayed streaming of the mixed stream to CDN changes.
  ///
  /// In the general case of the ZEGO RTC server's stream mixing task, the output stream is published to the CDN using the RTMP protocol, and changes in the state during the publish will be notified from this callback function.
  ///
  /// - [taskID] Stream mixing task ID
  /// - [infoList] List of information that the current CDN is being mixed
  static void Function(String taskID, List<ZegoStreamRelayCDNInfo> infoList)? onMixerRelayCDNStateUpdate;

  /// The callback triggered when the sound level of any input stream changes in the stream mixing process.
  ///
  /// You can use this callback to show the effect of the anchors sound level when the audience plays the mixed stream. So audience can notice which anchor is speaking.
  ///
  /// - [soundLevels] Sound level hash map, key is the soundLevelID of every single stream in this mixer stream, value is the sound level value of that single stream, value ranging from 0.0 to 100.0
  static void Function(Map<int, double> soundLevels)? onMixerSoundLevelUpdate;

  /// The callback triggered when there is a change to audio devices (i.e. new device added or existing device deleted).
  ///
  /// Only supports desktop.
  /// This callback is triggered when an audio device is added or removed from the system. By listening to this callback, users can update the sound collection or output using a specific device when necessary.
  ///
  /// - [updateType] Update type (add/delete)
  /// - [deviceType] Audio device type
  /// - [deviceInfo] Audio device information
  static void Function(ZegoUpdateType updateType, ZegoAudioDeviceType deviceType, ZegoDeviceInfo deviceInfo)? onAudioDeviceStateChanged;

  /// The callback triggered when there is a change to video devices (i.e. new device added or existing device deleted).
  ///
  /// This callback is triggered when a video device is added or removed from the system. By listening to this callback, users can update the video capture using a specific device when necessary.
  ///
  /// - [updateType] Update type (add/delete)
  /// - [deviceInfo] Audio device information
  static void Function(ZegoUpdateType updateType, ZegoDeviceInfo deviceInfo)? onVideoDeviceStateChanged;

  /// The local captured audio sound level callback.
  ///
  /// To trigger this callback function, the [startSoundLevelMonitor] function must be called to start the sound level monitor and you must be in a state where it is publishing the audio and video stream or be in [startPreview] state.
  /// The callback notification period is the setting parameter of [startSoundLevelMonitor].
  ///
  /// - [soundLevel] Locally captured sound level value, ranging from 0.0 to 100.0
  static void Function(double soundLevel)? onCapturedSoundLevelUpdate;

  /// The remote playing streams audio sound level callback.
  ///
  /// To trigger this callback function, the [startSoundLevelMonitor] function must be called to start the sound level monitor and you must be in a state where it is playing the audio and video stream.
  /// The callback notification period is the setting parameter of [startSoundLevelMonitor].
  ///
  /// - [soundLevels] Remote sound level hash map, key is the streamID, value is the sound level value of the corresponding streamID, value ranging from 0.0 to 100.0
  static void Function(Map<String, double> soundLevels)? onRemoteSoundLevelUpdate;

  /// The local captured audio spectrum callback.
  ///
  /// To trigger this callback function, the [startAudioSpectrumMonitor] function must be called to start the audio spectrum monitor and you must be in a state where it is publishing the audio and video stream or be in [startPreview] state.
  /// The callback notification period is the setting parameter of [startAudioSpectrumMonitor].
  ///
  /// - [audioSpectrum] Locally captured audio spectrum value list. Spectrum value range is [0-2^30]
  static void Function(List<double> audioSpectrum)? onCapturedAudioSpectrumUpdate;

  /// The remote playing streams audio spectrum callback.
  ///
  /// To trigger this callback function, the [startAudioSpectrumMonitor] function must be called to start the audio spectrum monitor and you must be in a state where it is playing the audio and video stream.
  /// The callback notification period is the setting parameter of [startAudioSpectrumMonitor].
  ///
  /// - [audioSpectrums] Remote audio spectrum hash map, key is the streamID, value is the audio spectrum list of the corresponding streamID. Spectrum value range is [0-2^30]
  static void Function(Map<String, List<double>> audioSpectrums)? onRemoteAudioSpectrumUpdate;

  /// The callback triggered when a device exception occurs.
  ///
  /// This callback is triggered when an exception occurs when reading or writing the audio and video device.
  ///
  /// - [errorCode] The error code corresponding to the status change of the playing stream, please refer to the error codes document https://doc-en.zego.im/en/5548.html for details.
  /// - [deviceName] device name
  static void Function(int errorCode, String deviceName)? onDeviceError;

  /// The callback triggered when the state of the remote camera changes.
  ///
  /// When the state of the remote camera device changes, such as switching the camera, by monitoring this callback, it is possible to obtain an event related to the far-end camera, which can be used to prompt the user that the video may be abnormal.
  /// Developers of 1v1 education scenarios or education small class scenarios and similar scenarios can use this callback notification to determine whether the camera device of the remote publishing stream device is working normally, and preliminary understand the cause of the device problem according to the corresponding state.
  /// This callback will not be called back when the remote stream is play from the CDN, and will not be called back if the remote stream end user has enabled custom video capture function.
  ///
  /// - [streamID] Stream ID
  /// - [state] Remote camera status
  static void Function(String streamID, ZegoRemoteDeviceState state)? onRemoteCameraStateUpdate;

  /// The callback triggered when the state of the remote microphone changes.
  ///
  /// When the state of the remote microphone device is changed, such as switching a microphone, etc., by listening to the callback, it is possible to obtain an event related to the remote microphone, which can be used to prompt the user that the audio may be abnormal.
  /// Developers of 1v1 education scenarios or education small class scenarios and similar scenarios can use this callback notification to determine whether the microphone device of the remote publishing stream device is working normally, and preliminary understand the cause of the device problem according to the corresponding state.
  /// This callback will not be called back when the remote stream is play from the CDN, and will not be called back if the remote stream end user has enabled custom audio capture function.
  ///
  /// - [streamID] Stream ID
  /// - [state] Remote microphone status
  static void Function(String streamID, ZegoRemoteDeviceState state)? onRemoteMicStateUpdate;

  /// Callback for device's audio route changed.
  ///
  /// This callback will be called when there are changes in audio routing such as earphone plugging, speaker and receiver switching, etc.
  ///
  /// - [audioRoute] Current audio route
  static void Function(ZegoAudioRoute audioRoute)? onAudioRouteChange;

  /// The callback triggered when Broadcast Messages are received.
  ///
  /// This callback is used to receive broadcast messages sent by other users, and broadcast messages sent by users themselves will not be notified through this callback.
  ///
  /// - [roomID] Room ID
  /// - [messageList] list of received messages.
  static void Function(String roomID, List<ZegoBroadcastMessageInfo> messageList)? onIMRecvBroadcastMessage;

  /// The callback triggered when Barrage Messages are received.
  ///
  /// This callback is used to receive barrage messages sent by other users, and barrage messages sent by users themselves will not be notified through this callback.
  ///
  /// - [roomID] Room ID
  /// - [messageList] list of received messages.
  static void Function(String roomID, List<ZegoBarrageMessageInfo> messageList)? onIMRecvBarrageMessage;

  /// The callback triggered when a Custom Command is received.
  ///
  /// This callback is used to receive custom signaling sent by other users, and barrage messages sent by users themselves will not be notified through this callback.
  ///
  /// - [roomID] Room ID
  /// - [fromUser] Sender of the command
  /// - [command] Command content received
  static void Function(String roomID, ZegoUser fromUser, String command)? onIMRecvCustomCommand;

  /// The callback triggered when the state of the media player changes.
  ///
  /// - [mediaPlayer] Callback player object
  /// - [state] Media player status
  /// - [errorCode] Error code, please refer to the error codes document https://doc-en.zego.im/en/5548.html for details.
  static void Function(ZegoMediaPlayer mediaPlayer, ZegoMediaPlayerState state, int errorCode)? onMediaPlayerStateUpdate;

  /// The callback triggered when the network status of the media player changes.
  ///
  /// - [mediaPlayer] Callback player object
  /// - [networkEvent] Network status event
  static void Function(ZegoMediaPlayer mediaPlayer, ZegoMediaPlayerNetworkEvent networkEvent)? onMediaPlayerNetworkEvent;

  /// The callback to report the current playback progress of the media player.
  ///
  /// - [mediaPlayer] Callback player object
  /// - [millisecond] Progress in milliseconds
  static void Function(ZegoMediaPlayer mediaPlayer, int millisecond)? onMediaPlayerPlayingProgress;

  /// The callback triggered when the media player got media side info.
  ///
  /// - [mediaPlayer] Callback player object
  /// - [data] SEI content
  static void Function(ZegoMediaPlayer mediaPlayer, Uint8List data)? onMediaPlayerRecvSEI;

  /// Audio effect playback state callback.
  ///
  /// This callback is triggered when the playback state of a audio effect of the audio effect player changes.
  ///
  /// - [audioEffectPlayer] Audio effect player instance that triggers this callback
  /// - [audioEffectID] The ID of the audio effect resource that triggered this callback
  /// - [state] The playback state of the audio effect
  /// - [errorCode] Error code, please refer to the error codes document https://doc-en.zego.im/en/5548.html for details.
  static void Function(ZegoAudioEffectPlayer audioEffectPlayer, int audioEffectID, ZegoAudioEffectPlayState state, int errorCode)? onAudioEffectPlayStateUpdate;

  /// The callback triggered when the state of data recording (to a file) changes.
  ///
  /// - [state] File recording status, according to which you should determine the state of the file recording or the prompt of the UI.
  /// - [errorCode] Error code, please refer to the error codes document https://doc-en.zego.im/en/5548.html for details.
  /// - [config] Record config
  /// - [channel] Publishing stream channel
  static void Function(ZegoDataRecordState state, int errorCode, ZegoDataRecordConfig config, ZegoPublishChannel channel)? onCapturedDataRecordStateUpdate;

  /// The callback to report the current recording progress.
  ///
  /// - [progress] File recording progress, which allows developers to hint at the UI, etc.
  /// - [config] Record config
  /// - [channel] Publishing stream channel
  static void Function(ZegoDataRecordProgress progress, ZegoDataRecordConfig config, ZegoPublishChannel channel)? onCapturedDataRecordProgressUpdate;

  /// The system performance status callback.
  ///
  /// To trigger this callback function, the [startPerformanceMonitor] function must be called to start the system performance monitor.
  /// The callback notification period is the setting parameter of [startPerformanceMonitor].
  ///
  /// - [status] The system performance status.
  static void Function(ZegoPerformanceStatus status)? onPerformanceStatusUpdate;

  /// Callback for network mode changed.
  ///
  /// This callback will be called when the device's network mode changes, such as switching from WiFi to 5G, or when the network is disconnected.
  ///
  /// - [mode] Current network mode.
  static void Function(ZegoNetworkMode mode)? onNetworkModeChanged;

  /// The callback triggered when error occurred when testing network speed.
  ///
  /// - [errorCode] The error code corresponding to the network speed test, please refer to the error codes document https://doc-en.zego.im/en/5548.html for details.
  /// - [type] Uplink or downlink
  static void Function(int errorCode, ZegoNetworkSpeedTestType type)? onNetworkSpeedTestError;

  /// The callback triggered when quality updated when testing network speed.
  ///
  /// When error occurs or called stopNetworkSpeedTest, this callback will be stopped.
  ///
  /// - [quality] Network speed quality
  /// - [type] Uplink or downlink
  static void Function(ZegoNetworkSpeedTestQuality quality, ZegoNetworkSpeedTestType type)? onNetworkSpeedTestQualityUpdate;

  /// The callback for obtaining the audio data captured by the local microphone.
  ///
  /// In non-custom audio capture mode, the SDK capture the microphone's sound, but the developer may also need to get a copy of the audio data captured by the SDK is available through this callback.
  /// On the premise of calling [setAudioDataHandler] to set the listener callback, after calling [enableAudioDataCallback] to set the mask 0b01 that means 1 << 0, this callback will be triggered only when it is in the publishing stream state.
  ///
  /// - [data] Audio data in PCM format
  /// - [dataLength] Length of the data
  /// - [param] Parameters of the audio frame
  static void Function(Uint8List data, int dataLength, ZegoAudioFrameParam param)? onCapturedAudioData;

  /// The callback for obtaining the audio data of all the streams playback by SDK.
  ///
  /// This function will callback all the mixed audio data to be playback. This callback can be used for that you needs to fetch all the mixed audio data to be playback to proccess.
  /// On the premise of calling [setAudioDataHandler] to set the listener callback, after calling [enableAudioDataCallback] to set the mask 0b100 that means 1 << 2, this callback will be triggered only when it is in the SDK inner audio and video engine started(called the [startPreivew] or [startPlayingStream] or [startPublishingStream]).
  /// When the engine is started in the non-playing stream state or the media player is not used to play the media file, the audio data to be called back is muted audio data.
  ///
  /// - [data] Audio data in PCM format
  /// - [dataLength] Length of the data
  /// - [param] Parameters of the audio frame
  static void Function(Uint8List data, int dataLength, ZegoAudioFrameParam param)? onPlaybackAudioData;

  /// The callback for obtaining the mixed audio data. Such mixed auido data are generated by the SDK by mixing the audio data of all the remote playing streams and the auido data captured locally.
  ///
  /// The audio data of all playing data is mixed with the data captured by the local microphone before it is sent to the loudspeaker, and calleback out in this way.
  /// On the premise of calling [setAudioDataHandler] to set the listener callback, after calling [enableAudioDataCallback] to set the mask 0x04, this callback will be triggered only when it is in the publishing stream state or playing stream state.
  ///
  /// - [data] Audio data in PCM format
  /// - [dataLength] Length of the data
  /// - [param] Parameters of the audio frame
  static void Function(Uint8List data, int dataLength, ZegoAudioFrameParam param)? onMixedAudioData;

  /// The callback for obtaining the audio data of each stream.
  ///
  /// This function will call back the data corresponding to each playing stream. Different from [onPlaybackAudioData], the latter is the mixed data of all playing streams. If developers need to process a piece of data separately, they can use this callback.
  /// On the premise of calling [setAudioDataHandler] to set up listening for this callback, calling [enableAudioDataCallback] to set the mask 0x08 that is 1 << 3, and this callback will be triggered when the SDK audio and video engine starts to play the stream.
  ///
  /// - [data] Audio data in PCM format
  /// - [dataLength] Length of the data
  /// - [param] Parameters of the audio frame
  /// - [streamID] Corresponding stream ID
  static void Function(Uint8List data, int dataLength, ZegoAudioFrameParam param, String streamID)? onPlayerAudioData;

}

extension ZegoExpressEngineDeprecatedApi on ZegoExpressEngine {

  /// Set the selected video layer of playing stream.
  ///
  /// When the publisher has set the codecID to SVC through [setVideoConfig], the player can dynamically set whether to use the standard layer or the base layer (the resolution of the base layer is one-half of the standard layer)
  /// Under normal circumstances, when the network is weak or the rendered UI form is small, you can choose to use the video that plays the base layer to save bandwidth.
  /// It can be set before and after playing stream.
  ///
  /// @deprecated This function has been deprecated since version 2.3.0. Please use [setPlayStreamVideoType] instead.
  /// - [streamID] Stream ID.
  /// - [videoLayer] Video layer of playing stream. AUTO by default.
  @Deprecated('This function has been deprecated since version 2.3.0. Please use [setPlayStreamVideoType] instead.')
  Future<void> setPlayStreamVideoLayer(String streamID, ZegoPlayerVideoLayer videoLayer) async {
    return await ZegoExpressImpl.instance.setPlayStreamVideoLayer(streamID, videoLayer);
  }

  /// Logs in multi room.
  ///
  /// You must log in the main room with [loginRoom] before invoke this function to logging in to multi room.
  /// Currently supports logging into 1 main room and 1 multi room at the same time.
  /// When logging out, you must log out of the multi room before logging out of the main room.
  /// User can only publish the stream in the main room, but can play the stream in the main room and multi room at the same time, and can receive the signaling and callback in each room.
  /// The advantage of multi room is that you can login another room without leaving the current room, receive signaling and callback from another room, and play streams from another room.
  /// To prevent the app from being impersonated by a malicious user, you can add authentication before logging in to the room, that is, the [token] parameter in the ZegoRoomConfig object passed in by the [config] parameter.
  /// Different users who log in to the same room can get room related notifications in the same room (eg [onRoomUserUpdate], [onRoomStreamUpdate], etc.), and users in one room cannot receive room signaling notifications in another room.
  /// Messages sent in one room (e.g. [setStreamExtraInfo], [sendBroadcastMessage], [sendBarrageMessage], [sendCustomCommand], etc.) cannot be received callback ((eg [onRoomStreamExtraInfoUpdate], [onIMRecvBroadcastMessage], [onIMRecvBarrageMessage], [onIMRecvCustomCommand], etc) in other rooms. Currently, SDK does not provide the ability to send messages across rooms. Developers can integrate the SDK of third-party IM to achieve.
  /// SDK supports startPlayingStream audio and video streams from different rooms under the same appID, that is, startPlayingStream audio and video streams across rooms. Since ZegoExpressEngine's room related callback notifications are based on the same room, when developers want to startPlayingStream streams across rooms, developers need to maintain related messages and signaling notifications by themselves.
  /// If the network is temporarily interrupted due to network quality reasons, the SDK will automatically reconnect internally. You can get the current connection status of the local room by listening to the [onRoomStateUpdate] callback method, and other users in the same room will receive [onRoomUserUpdate] callback notification.
  /// It is strongly recommended that userID corresponds to the user ID of the business APP, that is, a userID and a real user are fixed and unique, and should not be passed to the SDK in a random userID. Because the unique and fixed userID allows ZEGO technicians to quickly locate online problems.
  ///
  /// @deprecated This method has been deprecated after version 2.9.0. If you want to access the multi-room feature, Please set [setRoomMode] to select multi-room mode before the engine started, and then call [loginRoom] to use multi-room. If you call [loginRoom] function to log in to multiple rooms, please make sure to pass in the same user information.
  /// - [roomID] Room ID, a string of up to 128 bytes in length. Only support numbers, English characters and '~', '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '+', '=', '-', '`', ';', '’', ',', '.', '<', '>', '/', '\'
  /// - [config] Advanced room configuration
  @Deprecated('This method has been deprecated after version 2.9.0. If you want to access the multi-room feature, Please set [setRoomMode] to select multi-room mode before the engine started, and then call [loginRoom] to use multi-room. If you call [loginRoom] function to log in to multiple rooms, please make sure to pass in the same user information.')
  Future<void> loginMultiRoom(String roomID, {ZegoRoomConfig? config}) async {
    return await ZegoExpressImpl.instance.loginMultiRoom(roomID, config: config);
  }

  /// Turns on/off verbose debugging and sets up the log language.
  ///
  /// The debug switch is set to on and the language is English by default.
  ///
  /// @deprecated This method has been deprecated after version 2.3.0, please use the [setEngineConfig] function to set the advanced configuration property advancedConfig to achieve the original function.
  /// - [enable] Detailed debugging information switch
  /// - [language] Debugging information language
  @Deprecated('This method has been deprecated after version 2.3.0, please use the [setEngineConfig] function to set the advanced configuration property advancedConfig to achieve the original function.')
  Future<void> setDebugVerbose(bool enable, ZegoLanguage language) async {
    return await ZegoExpressImpl.instance.setDebugVerbose(enable, language);
  }

  /// Whether to use the built-in speaker to play audio.This function has been deprecated since version 2.3.0. Please use [setAudioRouteToSpeaker] instead.
  ///
  /// When you choose not to use the built-in speaker to play sound, that is, set to false, the SDK will select the currently highest priority audio output device to play the sound according to the system schedule
  ///
  /// @deprecated This function has been deprecated since version 2.3.0. Please use [setAudioRouteToSpeaker] instead.
  /// - [enable] Whether to use the built-in speaker to play sound, true: use the built-in speaker to play sound, false: use the highest priority audio output device scheduled by the current system to play sound
  @Deprecated('This function has been deprecated since version 2.3.0. Please use [setAudioRouteToSpeaker] instead.')
  Future<void> setBuiltInSpeakerOn(bool enable) async {
    return await ZegoExpressImpl.instance.setBuiltInSpeakerOn(enable);
  }

}
