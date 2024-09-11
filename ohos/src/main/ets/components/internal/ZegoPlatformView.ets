import PlatformView, { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';

export default class ZegoPlatformView extends PlatformView {
  viewId: number = 0

  constructor(context: Context, viewId: number) {
    super()
    this.viewId = viewId
  }

  getView(): WrappedBuilder<[Params]> {
    return new WrappedBuilder(ZegoPlatformViewBuilder)
  }

  dispose(): void {
  }
}

@Component
struct ZegoPlatformViewComponent {
  @Prop params: Params
  zegoPlatformView: ZegoPlatformView = this.params.platformView as ZegoPlatformView

  build() {
    XComponent({
      id: this.zegoPlatformView.viewId.toString(),
      type: XComponentType.SURFACE,
      libraryname: 'ZegoExpressEngine'
    })
  }
}

@Builder
function ZegoPlatformViewBuilder(params: Params) {
  ZegoPlatformViewComponent({ params: params })
}