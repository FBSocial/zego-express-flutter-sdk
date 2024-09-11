import { PlatformView, PlatformViewFactory, StandardMessageCodec } from '@ohos/flutter_ohos';
import ZegoPlatformView from './ZegoPlatformView';
import { HashMap } from '@kit.ArkTS';
import { zegoLogger } from './ZegoLog';

export class ZegoPlatformViewFactory extends PlatformViewFactory {
  platformViews: HashMap<number, ZegoPlatformView> = new HashMap()

  destroyPlatformView(viewId: number): boolean {
    let platformView = this.platformViews.get(viewId)
    if (platformView == null) {
      zegoLogger.debug("[destroyPlatformView] platform view for viewID:" + viewId + " not exists")
      this.logCurrentPlatformViews()
      return false
    }
    zegoLogger.debug("[destroyPlatformView] viewID:" + viewId)
    this.platformViews.remove(viewId)
    this.logCurrentPlatformViews();
    return true;
  }

  getPlatformView(viewId: number): ZegoPlatformView {
    zegoLogger.debug("[getPlatformView] viewID:" + viewId)
    this.logCurrentPlatformViews()
    return this.platformViews.get(viewId)
  }

  private addPlatformView(viewId: number, view: ZegoPlatformView): void {
    zegoLogger.debug("[createPlatformView] viewID:" + viewId)
    this.platformViews.set(viewId, view)
    this.logCurrentPlatformViews()
  }

  public create(context: Context, viewId: number, args: Object): PlatformView {
    let zegoPlatformView = new ZegoPlatformView(context, viewId)
    this.addPlatformView(viewId, zegoPlatformView)
    return zegoPlatformView
  }

  private logCurrentPlatformViews(): void {
    let desc: string = ''
    for (let viewId of this.platformViews.keys()) {
      let eachPlatformView = this.platformViews.get(viewId)
      if (eachPlatformView == null) {
        continue;
      }
      // desc.append(String.format(Locale.ENGLISH, "[ID:%d|View:%s] ", id, eachPlatformView.getSurfaceView() == null ? "null" : eachPlatformView.getSurfaceView().hashCode()));
      desc += `[ViewID:${viewId}] `
    }
    zegoLogger.debug("[ZegoPlatformViewFactory] currentPlatformViews: " + desc)
  }
}

export let zegoPlatformViewFactory = new ZegoPlatformViewFactory(StandardMessageCodec.INSTANCE)
