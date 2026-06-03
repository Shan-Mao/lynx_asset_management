import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Interactive 1:1 square crop editor.
///
/// **Algorithm** — drag a corner handle to resize:
/// 1. The opposite corner is the **anchor** and stays fixed.
/// 2. Compute the handle's new position: current corner + drag delta.
/// 3. New side length = max(|handleX - anchorX|, |handleY - anchorY|).
/// 4. Place the square so the anchor corner remains in place.
///
/// → Handle far from anchor = enlarge.
/// → Handle close to anchor = shrink.
class ImageEditorScreen extends StatefulWidget {
  const ImageEditorScreen({super.key, required this.imageBytes});
  final Uint8List imageBytes;

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  late Uint8List _srcBytes;

  Size _imgSize = Size.zero;
  late Rect _cropRect;    // in image-pixel coordinates
  double _scale = 1;      // display-pixel per image-pixel
  bool _saving = false;
  String? _dragCorner;    // 'tl','tr','bl','br' or null (move)

  // ---------------------------------------------------------------------------
  // Init
  // ---------------------------------------------------------------------------

  Future<void> _decodeSize() async {
    final codec = await ui.instantiateImageCodec(_srcBytes);
    final frame = await codec.getNextFrame();
    if (mounted) {
      final w = frame.image.width.toDouble();
      final h = frame.image.height.toDouble();
      final side = min(w, h) * 0.8;
      setState(() {
        _imgSize = Size(w, h);
        _cropRect = Rect.fromCenter(center: Offset(w / 2, h / 2), width: side, height: side);
      });
    }
    frame.image.dispose();
    codec.dispose();
  }

  @override
  void initState() {
    super.initState();
    _srcBytes = widget.imageBytes;
    _cropRect = Rect.zero;
    _decodeSize();
  }

  // ---------------------------------------------------------------------------
  // Layout helpers
  // ---------------------------------------------------------------------------

  void _layout(Size box) {
    if (_imgSize.isEmpty) return;
    _scale = min(box.width / _imgSize.width, box.height / _imgSize.height);
  }

  Rect _toDisplayRect(Rect r) => Rect.fromLTWH(
        r.left * _scale, r.top * _scale,
        r.width * _scale, r.height * _scale,
      );

  // ---------------------------------------------------------------------------
  // Gestures
  // ---------------------------------------------------------------------------

  void _applyMove(Offset displayDelta) {
    final d = displayDelta / _scale;
    setState(() {
      _cropRect = _cropRect.translate(d.dx, d.dy);
      _clampCrop();
    });
  }

  void _applyResize(String corner, Offset displayDelta) {
    final d = displayDelta / _scale;
    setState(() {
      // 1. Anchor = the corner opposite to the dragged handle
      final Offset anchor;
      switch (corner) {
        case 'tl': anchor = _cropRect.bottomRight; break;
        case 'tr': anchor = Offset(_cropRect.left, _cropRect.bottom); break;
        case 'bl': anchor = Offset(_cropRect.right, _cropRect.top); break;
        case 'br': anchor = _cropRect.topLeft; break;
        default: return;
      }
      // 2. Handle's new position = current corner + drag delta
      final Offset handle;
      switch (corner) {
        case 'tl': handle = _cropRect.topLeft + d; break;
        case 'tr': handle = Offset(_cropRect.right + d.dx, _cropRect.top + d.dy); break;
        case 'bl': handle = Offset(_cropRect.left + d.dx, _cropRect.bottom + d.dy); break;
        case 'br': handle = _cropRect.bottomRight + d; break;
        default: return;
      }
      // 3. New side = max of X/Y distance from anchor to handle
      final side = max((handle.dx - anchor.dx).abs(), (handle.dy - anchor.dy).abs()).clamp(10.0, 99999.0);
      // 4. Place square so the anchor stays in place
      final l = anchor.dx < handle.dx ? anchor.dx : anchor.dx - side;
      final t = anchor.dy < handle.dy ? anchor.dy : anchor.dy - side;
      _cropRect = Rect.fromLTWH(l, t, side, side);
      _clampCrop();
    });
  }

  void _clampCrop() {
    final iw = _imgSize.width;
    final ih = _imgSize.height;
    if (iw <= 0 || ih <= 0) return;
    final maxSide = min(iw, ih);
    double side = _cropRect.width.clamp(10.0, maxSide);
    double l = _cropRect.left.clamp(0.0, iw - side);
    double t = _cropRect.top.clamp(0.0, ih - side);
    _cropRect = Rect.fromLTWH(l, t, side, side);
  }

  // ---------------------------------------------------------------------------
  // Save
  // ---------------------------------------------------------------------------

  Future<void> _done() async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      final codec = await ui.instantiateImageCodec(_srcBytes);
      final frame = await codec.getNextFrame();
      final ui.Image src = frame.image;

      final cropX = _cropRect.left.round().clamp(0, src.width);
      final cropY = _cropRect.top.round().clamp(0, src.height);
      final cropW = _cropRect.width.round().clamp(1, src.width - cropX);
      final cropH = _cropRect.height.round().clamp(1, src.height - cropY);
      // Output is already square (cropW == cropH).

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, cropW.toDouble(), cropH.toDouble()));
      canvas.drawImageRect(
        src,
        Rect.fromLTWH(cropX.toDouble(), cropY.toDouble(), cropW.toDouble(), cropH.toDouble()),
        Rect.fromLTWH(0, 0, cropW.toDouble(), cropH.toDouble()),
        Paint(),
      );

      final picture = recorder.endRecording();
      final resultImg = await picture.toImage(cropW, cropH);
      final data = await resultImg.toByteData(format: ui.ImageByteFormat.png);

      src.dispose();
      resultImg.dispose();
      codec.dispose();

      if (data != null && mounted) {
        Navigator.pop(context, data.buffer.asUint8List());
      }
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        centerTitle: true,
        actions: [
          TextButton(onPressed: _saving ? null : _done, child: const Text('完成')),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: LayoutBuilder(builder: (context, box) {
            final boxSize = Size(box.maxWidth, box.maxHeight);
            _layout(boxSize);

            final displayW = _imgSize.width * _scale;
            final displayH = _imgSize.height * _scale;
            final displayCrop = _toDisplayRect(_cropRect);

            return GestureDetector(
              onPanUpdate: (d) {
                if (_dragCorner == null) _applyMove(d.delta);
              },
              child: Stack(children: [
                // Centered image + crop overlay
                Center(
                  child: SizedBox(
                    width: displayW,
                    height: displayH,
                    child: Stack(children: [
                      // Background: full image
                      Image.memory(_srcBytes, width: displayW, height: displayH, fit: BoxFit.fill),
                      // Dim panels outside crop
                      ..._buildOverlay(displayCrop, displayW, displayH),
                      // Crop border
                      if (!displayCrop.isEmpty)
                        Positioned.fromRect(
                          rect: displayCrop,
                          child: IgnorePointer(child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 2)))),
                        ),
                      // Corner handles
                      ..._buildHandles(displayCrop),
                    ]),
                  ),
                ),
              ]),
            );
          }),
        ),
        // ---- Instructions ----
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('操作说明', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('• 拖拽裁剪框内部 → 移动裁剪区域', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            Text('• 拖拽四角白色方块 → 调整裁剪大小（始终保持 1:1 正方形）', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text('裁剪算法', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('• 固定对角：拖拽手柄的对角作为锚点，位置不动', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            Text('• 新手柄位置 = 当前角坐标 + 拖拽偏移量', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            Text('• 新边长 = max(|手柄X − 锚点X|, |手柄Y − 锚点Y|)', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            Text('• 手柄离锚点远 → 放大 · 手柄靠近锚点 → 缩小', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ]),
        ),
        const SizedBox(height: 8),
      ]),
    );
  }

  List<Widget> _buildOverlay(Rect crop, double totalW, double totalH) {
    if (crop.isEmpty) return [];
    return [
      if (crop.top > 0) Positioned(left: 0, top: 0, right: 0, height: crop.top, child: Container(color: Colors.black54)),
      if (crop.bottom < totalH) Positioned(left: 0, top: crop.bottom, right: 0, bottom: 0, child: Container(color: Colors.black54)),
      if (crop.left > 0) Positioned(left: 0, top: crop.top, width: crop.left, height: crop.height, child: Container(color: Colors.black54)),
      if (crop.right < totalW) Positioned(left: crop.right, top: crop.top, right: 0, height: crop.height, child: Container(color: Colors.black54)),
    ];
  }

  List<Widget> _buildHandles(Rect r) {
    if (r.isEmpty) return [];
    const s = 24.0;
    return [
      _buildHandle(r.topLeft - const Offset(s / 2, s / 2), 'tl'),
      _buildHandle(Offset(r.right - s / 2, r.top - s / 2), 'tr'),
      _buildHandle(Offset(r.left - s / 2, r.bottom - s / 2), 'bl'),
      _buildHandle(Offset(r.right - s / 2, r.bottom - s / 2), 'br'),
    ];
  }

  Widget _buildHandle(Offset pos, String corner) {
    return Positioned(
      left: pos.dx,
      top: pos.dy,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (_) => _dragCorner = corner,
        onPanUpdate: (d) => _applyResize(corner, d.delta),
        onPanEnd: (_) => _dragCorner = null,
        child: Container(width: 24, height: 24, decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.blueAccent, width: 2), borderRadius: BorderRadius.circular(4))),
      ),
    );
  }
}
