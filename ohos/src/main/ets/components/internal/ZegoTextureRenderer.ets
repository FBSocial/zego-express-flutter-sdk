import { FlutterRenderer, SurfaceTextureEntry, TextureRegistry } from '@ohos/flutter_ohos';
import { zegoLogger } from './ZegoLog';

export default class ZegoTextureRenderer {
  textureID: number = -1
  surfaceID: number = -1
  private viewWidth: number = 0
  private viewHeight: number = 0
  private textureEntry: SurfaceTextureEntry


  constructor(textureRegistry: TextureRegistry, viewWidth: number, viewHeight: number) {
    this.textureID = textureRegistry.getTextureId()
    this.textureEntry = textureRegistry.registerTexture(this.textureID)
    this.surfaceID = this.textureEntry.getSurfaceId()
    this.viewWidth = viewWidth
    this.viewHeight = viewHeight
    zegoLogger.debug('[ZegoTextureRenderer] [init] renderer')
  }

  updateRenderSize(width: number, height: number) {
    //
    // if (this.viewWidth != width || this.viewHeight != height) {
    //   this.viewWidth = width;
    //   this.viewHeight = height;
    //
    //   this.surfaceTexture.setDefaultBufferSize(viewWidth, viewHeight);
    //   this.surface.release();
    //   this.surface = new Surface(this.surfaceTexture);
    // }
  }

  release() {
    this.textureEntry.release();

    // if (this.surface != null) {
    //   surface.release();
    // }
    //
    // ZegoLog.log("[ZegoTextureRenderer] [release] renderer:%s", this.hashCode());
  }

  // Surface getSurface() {
  //   return this.surface;
  // }
}
