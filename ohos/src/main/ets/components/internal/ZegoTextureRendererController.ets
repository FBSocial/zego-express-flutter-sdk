import {
  Any,
  FlutterPluginBinding,
  MethodCall,
  MethodResult,
  TextureRegistry,
  SurfaceTextureEntry
} from '@ohos/flutter_ohos';
import ZegoTextureRenderer from './ZegoTextureRenderer'
import { zegoLogger } from './ZegoLog';
import { HashMap } from '@kit.ArkTS';

export default class ZegoTextureRendererController {
  private renderers: HashMap<number, ZegoTextureRenderer> = new HashMap()

  createTextureRenderer(textureRegistry: TextureRegistry | undefined, viewWidth: number,
    viewHeight: number): number {
    if (textureRegistry == undefined) {
      return -1;
    }
    let renderer = new ZegoTextureRenderer(textureRegistry, viewWidth, viewHeight)
    zegoLogger.debug("[createTextureRenderer] textureID:" + renderer.textureID)
    this.renderers.set(renderer.textureID, renderer)
    this.logCurrentRenderers()
    return renderer.textureID;
  }


  destroyTextureRenderer(textureID: number): boolean {
    let renderer: ZegoTextureRenderer = this.renderers.get(textureID)
    if (renderer == null) {
      zegoLogger.debug("[destroyTextureRenderer] renderer for textureID:" + textureID + " not exists")
      this.logCurrentRenderers()
      return false;
    }

    zegoLogger.debug("[destroyTextureRenderer] textureID:" + textureID)
    this.renderers.remove(textureID);
    renderer.release()
    this.logCurrentRenderers()
    return true;
  }


  getTextureRenderer(textureID: number): ZegoTextureRenderer {
    let renderer: ZegoTextureRenderer = this.renderers.get(textureID);
    zegoLogger.debug("[getTextureRenderer] textureID:" + textureID + ", surfaceID:" + renderer.surfaceID)
    this.logCurrentRenderers();
    return renderer;
  }

  private logCurrentRenderers() {
    let desc: string = ''
    for (const id of this.renderers.keys()) {
      let eachRenderer: ZegoTextureRenderer = this.renderers.get(id)
      desc += "[ID:" + id + "|Rnd:" + (eachRenderer.textureID) + "]"
    }
    zegoLogger.debug("[ZegoTextureRendererController] currentRenderers: " + desc)
  }
}

export let zegoTextureRendererController = new ZegoTextureRendererController();