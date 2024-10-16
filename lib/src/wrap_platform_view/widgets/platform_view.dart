// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart'
    hide PlatformViewHitTestBehavior, PlatformViewRenderBox, RenderOhosView;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart'
    hide
        PlatformViewController,
        platformViewsRegistry,
        PlatformViewsService,
        PlatformViewCreatedCallback,
        OhosViewController;
import 'package:flutter/widgets.dart';
import 'package:zego_express_engine/src/wrap_platform_view/rendering/platform_view.dart';
import 'package:zego_express_engine/src/wrap_platform_view/services/platform_views.dart';

class OhosView extends StatefulWidget {
  /// Creates a widget that embeds an Ohos view.
  ///
  /// {@template flutter.widgets.OhosView.constructorArgs}
  /// The `viewType` and `hitTestBehavior` parameters must not be null.
  /// If `creationParams` is not null then `creationParamsCodec` must not be null.
  /// {@endtemplate}
  const OhosView({
    super.key,
    required this.viewType,
    this.onPlatformViewCreated,
    this.hitTestBehavior = PlatformViewHitTestBehavior.opaque,
    this.layoutDirection,
    this.gestureRecognizers,
    this.creationParams,
    this.creationParamsCodec,
    this.clipBehavior = Clip.hardEdge,
  })  : assert(viewType != null),
        assert(hitTestBehavior != null),
        assert(creationParams == null || creationParamsCodec != null),
        assert(clipBehavior != null);

  /// The unique identifier for Ohos view type to be embedded by this widget.
  ///
  /// A [PlatformViewFactory](/javadoc/io/flutter/plugin/platform/PlatformViewFactory.html)
  /// for this type must have been registered.
  ///
  /// See also:
  ///
  ///  * [OhosView] for an example of registering a platform view factory.
  final String viewType;

  /// {@template flutter.widgets.OhosView.onPlatformViewCreated}
  /// Callback to invoke after the platform view has been created.
  ///
  /// May be null.
  /// {@endtemplate}
  final PlatformViewCreatedCallback? onPlatformViewCreated;

  /// {@template flutter.widgets.OhosView.hitTestBehavior}
  /// How this widget should behave during hit testing.
  ///
  /// This defaults to [PlatformViewHitTestBehavior.opaque].
  /// {@endtemplate}
  final PlatformViewHitTestBehavior hitTestBehavior;

  /// {@template flutter.widgets.OhosView.layoutDirection}
  /// The text direction to use for the embedded view.
  ///
  /// If this is null, the ambient [Directionality] is used instead.
  /// {@endtemplate}
  final TextDirection? layoutDirection;

  /// Which gestures should be forwarded to the Ohos view.
  ///
  /// {@template flutter.widgets.OhosView.gestureRecognizers.descHead}
  /// The gesture recognizers built by factories in this set participate in the gesture arena for
  /// each pointer that was put down on the widget. If any of these recognizers win the
  /// gesture arena, the entire pointer event sequence starting from the pointer down event
  /// will be dispatched to the platform view.
  ///
  /// When null, an empty set of gesture recognizer factories is used, in which case a pointer event sequence
  /// will only be dispatched to the platform view if no other member of the arena claimed it.
  /// {@endtemplate}
  ///
  /// For example, with the following setup vertical drags will not be dispatched to the Ohos
  /// view as the vertical drag gesture is claimed by the parent [GestureDetector].
  ///
  /// ```dart
  /// GestureDetector(
  ///   onVerticalDragStart: (DragStartDetails d) {},
  ///   child: const OhosView(
  ///     viewType: 'webview',
  ///   ),
  /// )
  /// ```
  ///
  /// To get the [OhosView] to claim the vertical drag gestures we can pass a vertical drag
  /// gesture recognizer factory in [gestureRecognizers] e.g:
  ///
  /// ```dart
  /// GestureDetector(
  ///   onVerticalDragStart: (DragStartDetails details) {},
  ///   child: SizedBox(
  ///     width: 200.0,
  ///     height: 100.0,
  ///     child: OhosView(
  ///       viewType: 'webview',
  ///       gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
  ///         Factory<OneSequenceGestureRecognizer>(
  ///           () => EagerGestureRecognizer(),
  ///         ),
  ///       },
  ///     ),
  ///   ),
  /// )
  /// ```
  ///
  /// {@template flutter.widgets.OhosView.gestureRecognizers.descFoot}
  /// A platform view can be configured to consume all pointers that were put
  /// down in its bounds by passing a factory for an [EagerGestureRecognizer] in
  /// [gestureRecognizers]. [EagerGestureRecognizer] is a special gesture
  /// recognizer that immediately claims the gesture after a pointer down event.
  ///
  /// The [gestureRecognizers] property must not contain more than one factory
  /// with the same [Factory.type].
  ///
  /// Changing [gestureRecognizers] results in rejection of any active gesture
  /// arenas (if the platform view is actively participating in an arena).
  /// {@endtemplate}
  // We use OneSequenceGestureRecognizers as they support gesture arena teams.
  // TODO(amirh): get a list of GestureRecognizers here.
  // https://github.com/flutter/flutter/issues/20953
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  /// Passed as the args argument of [PlatformViewFactory#create](/javadoc/io/flutter/plugin/platform/PlatformViewFactory.html#create-ohos.content.Context-int-java.lang.Object-)
  ///
  /// This can be used by plugins to pass constructor parameters to the embedded Ohos view.
  final dynamic creationParams;

  /// The codec used to encode `creationParams` before sending it to the
  /// platform side. It should match the codec passed to the constructor of [PlatformViewFactory](/javadoc/io/flutter/plugin/platform/PlatformViewFactory.html#PlatformViewFactory-io.flutter.plugin.common.MessageCodec-).
  ///
  /// This is typically one of: [StandardMessageCodec], [JSONMessageCodec], [StringCodec], or [BinaryCodec].
  ///
  /// This must not be null if [creationParams] is not null.
  final MessageCodec<dynamic>? creationParamsCodec;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.hardEdge], and must not be null.
  final Clip clipBehavior;

  @override
  State<OhosView> createState() => _OhosViewState();
}

class _OhosViewState extends State<OhosView> {
  int? _id;
  late OhosViewController _controller;
  TextDirection? _layoutDirection;
  bool _initialized = false;
  FocusNode? _focusNode;

  static final Set<Factory<OneSequenceGestureRecognizer>> _emptyRecognizersSet =
      <Factory<OneSequenceGestureRecognizer>>{};

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onFocusChange: _onFocusChange,
      child: _OhosPlatformView(
        controller: _controller,
        hitTestBehavior: widget.hitTestBehavior,
        gestureRecognizers: widget.gestureRecognizers ?? _emptyRecognizersSet,
        clipBehavior: widget.clipBehavior,
      ),
    );
  }

  void _initializeOnce() {
    if (_initialized) {
      return;
    }
    _initialized = true;
    _createNewOhosView();
    _focusNode = FocusNode(debugLabel: 'OhosView(id: $_id)');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final TextDirection newLayoutDirection = _findLayoutDirection();
    final bool didChangeLayoutDirection =
        _layoutDirection != newLayoutDirection;
    _layoutDirection = newLayoutDirection;

    _initializeOnce();
    if (didChangeLayoutDirection) {
      // The native view will update asynchronously, in the meantime we don't want
      // to block the framework. (so this is intentionally not awaiting).
      _controller.setLayoutDirection(_layoutDirection!);
    }
  }

  @override
  void didUpdateWidget(OhosView oldWidget) {
    super.didUpdateWidget(oldWidget);

    final TextDirection newLayoutDirection = _findLayoutDirection();
    final bool didChangeLayoutDirection =
        _layoutDirection != newLayoutDirection;
    _layoutDirection = newLayoutDirection;

    if (widget.viewType != oldWidget.viewType) {
      _controller.dispose();
      _createNewOhosView();
      return;
    }

    if (didChangeLayoutDirection) {
      _controller.setLayoutDirection(_layoutDirection!);
    }
  }

  TextDirection _findLayoutDirection() {
    assert(
        widget.layoutDirection != null || debugCheckHasDirectionality(context));
    return widget.layoutDirection ?? Directionality.of(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _createNewOhosView() {
    _id = platformViewsRegistry.getNextPlatformViewId();
    _controller = PlatformViewsService.initOhosView(
      id: _id!,
      viewType: widget.viewType,
      layoutDirection: _layoutDirection!,
      creationParams: widget.creationParams,
      creationParamsCodec: widget.creationParamsCodec,
      onFocus: () {
        _focusNode!.requestFocus();
      },
    );
    if (widget.onPlatformViewCreated != null) {
      _controller
          .addOnPlatformViewCreatedListener(widget.onPlatformViewCreated!);
    }
  }

  void _onFocusChange(bool isFocused) {
    if (!_controller.isCreated) {
      return;
    }
    if (!isFocused) {
      _controller.clearFocus().catchError((dynamic e) {
        if (e is MissingPluginException) {
          // We land the framework part of Ohos platform views keyboard
          // support before the engine part. There will be a commit range where
          // clearFocus isn't implemented in the engine. When that happens we
          // just swallow the error here. Once the engine part is rolled to the
          // framework I'll remove this.
          // TODO(amirh): remove this once the engine's clearFocus is rolled.
          return;
        }
      });
      return;
    }
    SystemChannels.textInput.invokeMethod<void>(
      'TextInput.setPlatformViewClient',
      <String, dynamic>{'platformViewId': _id},
    ).catchError((dynamic e) {
      if (e is MissingPluginException) {
        // We land the framework part of Ohos platform views keyboard
        // support before the engine part. There will be a commit range where
        // setPlatformViewClient isn't implemented in the engine. When that
        // happens we just swallow the error here. Once the engine part is
        // rolled to the framework I'll remove this.
        // TODO(amirh): remove this once the engine's clearFocus is rolled.
        return;
      }
    });
  }
}

class _OhosPlatformView extends LeafRenderObjectWidget {
  const _OhosPlatformView({
    required this.controller,
    required this.hitTestBehavior,
    required this.gestureRecognizers,
    this.clipBehavior = Clip.hardEdge,
  })  : assert(controller != null),
        assert(hitTestBehavior != null),
        assert(gestureRecognizers != null),
        assert(clipBehavior != null);

  final OhosViewController controller;
  final PlatformViewHitTestBehavior hitTestBehavior;
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;
  final Clip clipBehavior;

  @override
  RenderObject createRenderObject(BuildContext context) => RenderOhosView(
        viewController: controller,
        hitTestBehavior: hitTestBehavior,
        gestureRecognizers: gestureRecognizers,
        clipBehavior: clipBehavior,
      );

  @override
  void updateRenderObject(BuildContext context, RenderOhosView renderObject) {
    renderObject.controller = controller;
    renderObject.hitTestBehavior = hitTestBehavior;
    renderObject.updateGestureRecognizers(gestureRecognizers);
    renderObject.clipBehavior = clipBehavior;
  }
}

/// The parameters used to create a [PlatformViewController].
///
/// See also:
///
///  * [CreatePlatformViewCallback] which uses this object to create a [PlatformViewController].
class PlatformViewCreationParams {
  const PlatformViewCreationParams._({
    required this.id,
    required this.viewType,
    required this.onPlatformViewCreated,
    required this.onFocusChanged,
  })  : assert(id != null),
        assert(onPlatformViewCreated != null);

  /// The unique identifier for the new platform view.
  ///
  /// [PlatformViewController.viewId] should match this id.
  final int id;

  /// The unique identifier for the type of platform view to be embedded.
  ///
  /// This viewType is used to tell the platform which type of view to
  /// associate with the [id].
  final String viewType;

  /// Callback invoked after the platform view has been created.
  final PlatformViewCreatedCallback onPlatformViewCreated;

  /// Callback invoked when the platform view's focus is changed on the platform side.
  ///
  /// The value is true when the platform view gains focus and false when it loses focus.
  final ValueChanged<bool> onFocusChanged;
}

/// A factory for a surface presenting a platform view as part of the widget hierarchy.
///
/// The returned widget should present the platform view associated with `controller`.
///
/// See also:
///
///  * [PlatformViewSurface], a common widget for presenting platform views.
typedef PlatformViewSurfaceFactory = Widget Function(
    BuildContext context, PlatformViewController controller);

/// Constructs a [PlatformViewController].
///
/// The [PlatformViewController.viewId] field of the created controller must match the value of the
/// params [PlatformViewCreationParams.id] field.
///
/// See also:
///
///  * [PlatformViewLink], which links a platform view with the Flutter framework.
typedef CreatePlatformViewCallback = PlatformViewController Function(
    PlatformViewCreationParams params);

/// Links a platform view with the Flutter framework.
///
/// Provides common functionality for embedding a platform view (e.g an android.view.View on Android)
/// with the Flutter framework.
///
/// {@macro flutter.widgets.AndroidView.lifetime}
///
/// To implement a new platform view widget, return this widget in the `build` method.
/// For example:
///
/// ```dart
/// class FooPlatformView extends StatelessWidget {
///   const FooPlatformView({super.key});
///   @override
///   Widget build(BuildContext context) {
///     return PlatformViewLink(
///       viewType: 'webview',
///       onCreatePlatformView: createFooWebView,
///       surfaceFactory: (BuildContext context, PlatformViewController controller) {
///         return PlatformViewSurface(
///           gestureRecognizers: gestureRecognizers,
///           controller: controller,
///           hitTestBehavior: PlatformViewHitTestBehavior.opaque,
///         );
///       },
///    );
///   }
/// }
/// ```
///
/// The `surfaceFactory` and the `onCreatePlatformView` are only called when the
/// state of this widget is initialized, or when the `viewType` changes.
class PlatformViewLink extends StatefulWidget {
  /// Construct a [PlatformViewLink] widget.
  ///
  /// The `surfaceFactory` and the `onCreatePlatformView` must not be null.
  ///
  /// See also:
  ///
  ///  * [PlatformViewSurface] for details on the widget returned by `surfaceFactory`.
  ///  * [PlatformViewCreationParams] for how each parameter can be used when implementing `createPlatformView`.
  const PlatformViewLink({
    super.key,
    required PlatformViewSurfaceFactory surfaceFactory,
    required CreatePlatformViewCallback onCreatePlatformView,
    required this.viewType,
  })  : assert(surfaceFactory != null),
        assert(onCreatePlatformView != null),
        assert(viewType != null),
        _surfaceFactory = surfaceFactory,
        _onCreatePlatformView = onCreatePlatformView;

  final PlatformViewSurfaceFactory _surfaceFactory;
  final CreatePlatformViewCallback _onCreatePlatformView;

  /// The unique identifier for the view type to be embedded.
  ///
  /// Typically, this viewType has already been registered on the platform side.
  final String viewType;

  @override
  State<StatefulWidget> createState() => _PlatformViewLinkState();
}

class _PlatformViewLinkState extends State<PlatformViewLink> {
  int? _id;
  PlatformViewController? _controller;
  bool _platformViewCreated = false;
  Widget? _surface;
  FocusNode? _focusNode;

  @override
  Widget build(BuildContext context) {
    final PlatformViewController? controller = _controller;
    if (controller == null) {
      return const SizedBox.expand();
    }
    if (!_platformViewCreated) {
      // Depending on the implementation, the first non-empty size can be used
      // to size the platform view.
      return _PlatformViewPlaceHolder(onLayout: (Size size, Offset position) {
        if (controller.awaitingCreation && !size.isEmpty) {
          controller.create(size: size, position: position);
        }
      });
    }
    _surface ??= widget._surfaceFactory(context, controller);
    return Focus(
      focusNode: _focusNode,
      onFocusChange: _handleFrameworkFocusChanged,
      child: _surface!,
    );
  }

  @override
  void initState() {
    _focusNode = FocusNode(debugLabel: 'PlatformView(id: $_id)');
    _initialize();
    super.initState();
  }

  @override
  void didUpdateWidget(PlatformViewLink oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.viewType != oldWidget.viewType) {
      _controller?.dispose();
      // The _surface has to be recreated as its controller is disposed.
      // Setting _surface to null will trigger its creation in build().
      _surface = null;
      _initialize();
    }
  }

  void _initialize() {
    _id = platformViewsRegistry.getNextPlatformViewId();
    _controller = widget._onCreatePlatformView(
      PlatformViewCreationParams._(
        id: _id!,
        viewType: widget.viewType,
        onPlatformViewCreated: _onPlatformViewCreated,
        onFocusChanged: _handlePlatformFocusChanged,
      ),
    );
  }

  void _onPlatformViewCreated(int id) {
    setState(() {
      _platformViewCreated = true;
    });
  }

  void _handleFrameworkFocusChanged(bool isFocused) {
    if (!isFocused) {
      _controller?.clearFocus();
    }
    SystemChannels.textInput.invokeMethod<void>(
      'TextInput.setPlatformViewClient',
      <String, dynamic>{'platformViewId': _id},
    );
  }

  void _handlePlatformFocusChanged(bool isFocused) {
    if (isFocused) {
      _focusNode!.requestFocus();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }
}

/// Integrates a platform view with Flutter's compositor, touch, and semantics subsystems.
///
/// The compositor integration is done by adding a [PlatformViewLayer] to the layer tree. [PlatformViewSurface]
/// isn't supported on all platforms (e.g on Android platform views can be composited by using a [TextureLayer] or
/// [AndroidViewSurface]).
/// Custom Flutter embedders can support [PlatformViewLayer]s by implementing a SystemCompositor.
///
/// The widget fills all available space, the parent of this object must provide bounded layout
/// constraints.
///
/// If the associated platform view is not created the [PlatformViewSurface] does not paint any contents.
///
/// See also:
///
///  * [AndroidView] which embeds an Android platform view in the widget hierarchy using a [TextureLayer].
///  * [UiKitView] which embeds an iOS platform view in the widget hierarchy.
// TODO(amirh): Link to the embedder's system compositor documentation once available.
class PlatformViewSurface extends LeafRenderObjectWidget {
  /// Construct a [PlatformViewSurface].
  ///
  /// The [controller] must not be null.
  const PlatformViewSurface({
    super.key,
    required this.controller,
    required this.hitTestBehavior,
    required this.gestureRecognizers,
  })  : assert(controller != null),
        assert(hitTestBehavior != null),
        assert(gestureRecognizers != null);

  /// The controller for the platform view integrated by this [PlatformViewSurface].
  ///
  /// [PlatformViewController] is used for dispatching touch events to the platform view.
  /// [PlatformViewController.viewId] identifies the platform view whose contents are painted by this widget.
  final PlatformViewController controller;

  /// Which gestures should be forwarded to the PlatformView.
  ///
  /// {@macro flutter.widgets.AndroidView.gestureRecognizers.descHead}
  ///
  /// For example, with the following setup vertical drags will not be dispatched to the platform view
  /// as the vertical drag gesture is claimed by the parent [GestureDetector].
  ///
  /// ```dart
  /// GestureDetector(
  ///   onVerticalDragStart: (DragStartDetails details) { },
  ///   child: PlatformViewSurface(
  ///     gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
  ///     controller: _controller,
  ///     hitTestBehavior: PlatformViewHitTestBehavior.opaque,
  ///   ),
  /// )
  /// ```
  ///
  /// To get the [PlatformViewSurface] to claim the vertical drag gestures we can pass a vertical drag
  /// gesture recognizer factory in [gestureRecognizers] e.g:
  ///
  /// ```dart
  /// GestureDetector(
  ///   onVerticalDragStart: (DragStartDetails details) { },
  ///   child: SizedBox(
  ///     width: 200.0,
  ///     height: 100.0,
  ///     child: PlatformViewSurface(
  ///       gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
  ///         Factory<OneSequenceGestureRecognizer>(
  ///           () => EagerGestureRecognizer(),
  ///         ),
  ///       },
  ///       controller: _controller,
  ///       hitTestBehavior: PlatformViewHitTestBehavior.opaque,
  ///     ),
  ///   ),
  /// )
  /// ```
  ///
  /// {@macro flutter.widgets.AndroidView.gestureRecognizers.descFoot}
  // We use OneSequenceGestureRecognizers as they support gesture arena teams.
  // TODO(amirh): get a list of GestureRecognizers here.
  // https://github.com/flutter/flutter/issues/20953
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  /// {@macro flutter.widgets.AndroidView.hitTestBehavior}
  final PlatformViewHitTestBehavior hitTestBehavior;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return PlatformViewRenderBox(
        controller: controller,
        gestureRecognizers: gestureRecognizers,
        hitTestBehavior: hitTestBehavior);
  }

  @override
  void updateRenderObject(
      BuildContext context, PlatformViewRenderBox renderObject) {
    renderObject
      ..controller = controller
      ..hitTestBehavior = hitTestBehavior
      ..updateGestureRecognizers(gestureRecognizers);
  }
}

class OhosViewSurface extends StatefulWidget {
  /// Construct an `OhosPlatformViewSurface`.
  const OhosViewSurface({
    super.key,
    required this.controller,
    required this.hitTestBehavior,
    required this.gestureRecognizers,
  })  : assert(controller != null),
        assert(hitTestBehavior != null),
        assert(gestureRecognizers != null);

  /// The controller for the platform view integrated by this [OhosViewSurface].
  ///
  /// See [PlatformViewSurface.controller] for details.
  final OhosViewController controller;

  /// Which gestures should be forwarded to the PlatformView.
  ///
  /// See [PlatformViewSurface.gestureRecognizers] for details.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  /// {@macro flutter.widgets.AndroidView.hitTestBehavior}
  final PlatformViewHitTestBehavior hitTestBehavior;

  @override
  State<StatefulWidget> createState() {
    return _OhosViewSurfaceState();
  }
}

class _OhosViewSurfaceState extends State<OhosViewSurface> {
  @override
  void initState() {
    super.initState();
    if (!widget.controller.isCreated) {
      // Schedule a rebuild once creation is complete and the final dislay
      // type is known.
      widget.controller
          .addOnPlatformViewCreatedListener(_onPlatformViewCreated);
    }
  }

  @override
  void dispose() {
    widget.controller
        .removeOnPlatformViewCreatedListener(_onPlatformViewCreated);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller.requiresViewComposition) {
      return _PlatformLayerBasedOhosViewSurface(
        controller: widget.controller,
        hitTestBehavior: widget.hitTestBehavior,
        gestureRecognizers: widget.gestureRecognizers,
      );
    } else {
      return _TextureBasedOhosViewSurface(
        controller: widget.controller,
        hitTestBehavior: widget.hitTestBehavior,
        gestureRecognizers: widget.gestureRecognizers,
      );
    }
  }

  void _onPlatformViewCreated(int _) {
    // Trigger a re-build based on the current controller state.
    setState(() {});
  }
}

class _TextureBasedOhosViewSurface extends PlatformViewSurface {
  const _TextureBasedOhosViewSurface({
    required OhosViewController super.controller,
    required super.hitTestBehavior,
    required super.gestureRecognizers,
  })  : assert(controller != null),
        assert(hitTestBehavior != null),
        assert(gestureRecognizers != null);

  @override
  RenderObject createRenderObject(BuildContext context) {
    final OhosViewController viewController = controller as OhosViewController;
    // Use GL texture based composition.
    // App should use GL texture unless they require to embed a SurfaceView.
    final RenderOhosView renderBox = RenderOhosView(
      viewController: viewController,
      gestureRecognizers: gestureRecognizers,
      hitTestBehavior: hitTestBehavior,
    );
    viewController.pointTransformer =
        (Offset position) => renderBox.globalToLocal(position);
    return renderBox;
  }
}

class _PlatformLayerBasedOhosViewSurface extends PlatformViewSurface {
  const _PlatformLayerBasedOhosViewSurface({
    required OhosViewController super.controller,
    required super.hitTestBehavior,
    required super.gestureRecognizers,
  })  : assert(controller != null),
        assert(hitTestBehavior != null),
        assert(gestureRecognizers != null);

  @override
  RenderObject createRenderObject(BuildContext context) {
    final OhosViewController viewController = controller as OhosViewController;
    final PlatformViewRenderBox renderBox =
        super.createRenderObject(context) as PlatformViewRenderBox;
    viewController.pointTransformer =
        (Offset position) => renderBox.globalToLocal(position);
    return renderBox;
  }
}

/// A callback used to notify the size of the platform view placeholder.
/// This size is the initial size of the platform view.
typedef _OnLayoutCallback = void Function(Size size, Offset position);

/// A [RenderBox] that notifies its size to the owner after a layout.
class _PlatformViewPlaceholderBox extends RenderConstrainedBox {
  _PlatformViewPlaceholderBox({
    required this.onLayout,
  }) : super(
            additionalConstraints: const BoxConstraints.tightFor(
          width: double.infinity,
          height: double.infinity,
        ));

  _OnLayoutCallback onLayout;

  @override
  void performLayout() {
    super.performLayout();
    // A call to `localToGlobal` requires waiting for a frame to render first.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      onLayout(size, localToGlobal(Offset.zero));
    });
  }
}

/// When a platform view is in the widget hierarchy, this widget is used to capture
/// the size of the platform view after the first layout.
/// This placeholder is basically a [SizedBox.expand] with a [onLayout] callback to
/// notify the size of the render object to its parent.
class _PlatformViewPlaceHolder extends SingleChildRenderObjectWidget {
  const _PlatformViewPlaceHolder({
    required this.onLayout,
  });

  final _OnLayoutCallback onLayout;

  @override
  _PlatformViewPlaceholderBox createRenderObject(BuildContext context) {
    return _PlatformViewPlaceholderBox(onLayout: onLayout);
  }

  @override
  void updateRenderObject(
      BuildContext context, _PlatformViewPlaceholderBox renderObject) {
    renderObject.onLayout = onLayout;
  }
}
