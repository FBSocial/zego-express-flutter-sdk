import {
  Any,
  EventChannel,
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import { EventSink, StreamHandler } from '@ohos/flutter_ohos/src/main/ets/plugin/common/EventChannel'
import ZegoExpressEngineMethodHandler from '../internal/ZegoExpressEngineMethodHandler'
import { zegoLogger } from '../internal/ZegoLog'
import { zegoPlatformViewFactory } from '../internal/ZegoPlatformViewFactory'

/** ZegoExpressFlutterSdkPlugin **/
export default class ZegoExpressFlutterSdkPlugin implements FlutterPlugin, MethodCallHandler {
  private pluginBinding: FlutterPluginBinding | null = null;
  private methodChannel: MethodChannel | null = null;
  private methodHandler: ZegoExpressEngineMethodHandler | null = null;
  private eventChannel: EventChannel | null = null;
  private eventSink: EventSink | null = null;

  constructor() {
  }

  getUniqueClassName(): string {
    return "ZegoExpressFlutterSdkPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.pluginBinding = binding;

    this.methodChannel = new MethodChannel(binding.getBinaryMessenger(), "plugins.zego.im/zego_express_engine")
    this.methodChannel.setMethodCallHandler(this)
    this.methodHandler = new ZegoExpressEngineMethodHandler()

    this.eventChannel = new EventChannel(binding.getBinaryMessenger(), 'plugins.zego.im/zego_express_event_handler')
    let that = this;
    let streamHandler: StreamHandler = {
      onListen(args: Any, events: EventSink): void {
        that.eventSink = events
        zegoLogger.debug("[FlutterEventSink] [onListen] set eventSink");
      },
      onCancel(args: Any): void {
        zegoLogger.debug("[FlutterEventSink] [onCancel] set eventSink to null");
        that.eventSink = null
      }
    }
    this.eventChannel.setStreamHandler(streamHandler)

    binding.getPlatformViewRegistry()?.registerViewFactory('plugins.zego.im/zego_express_view',
      zegoPlatformViewFactory)
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.methodChannel != null) {
      this.methodChannel.setMethodCallHandler(null)
    }
    if (this.eventChannel != null) {
      this.eventChannel.setStreamHandler(null)
    }
    this.pluginBinding = null;
    this.methodChannel = null;
    this.eventChannel = null;
    this.eventSink = null;
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    zegoLogger.debug(call.method)
    this.methodHandler?.onMethodCall(call, result, this.pluginBinding, this.eventSink)
  }
}