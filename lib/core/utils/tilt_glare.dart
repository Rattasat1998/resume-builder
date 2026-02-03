import 'dart:math' as math;
import 'package:flutter/material.dart';

class TiltGlareContainer extends StatefulWidget {
  const TiltGlareContainer({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.maxTiltDeg = 10,
    this.perspective = 0.0015,
    this.enableMobileDrag = true,
    this.shadow = true,
  });

  final Widget child;
  final double borderRadius;
  final double maxTiltDeg;
  final double perspective;
  final bool enableMobileDrag;
  final bool shadow;

  @override
  State<TiltGlareContainer> createState() => _TiltGlareContainerState();
}

class _TiltGlareContainerState extends State<TiltGlareContainer> {
  Offset _p = Offset.zero; // -1..1
  bool _active = false;

  void _update(Offset local, Size size) {
    final dx = (local.dx / size.width) * 2 - 1;
    final dy = (local.dy / size.height) * 2 - 1;
    _p = Offset(dx.clamp(-1, 1), dy.clamp(-1, 1));
  }

  void _reset() => setState(() {
    _p = Offset.zero;
    _active = false;
  });

  @override
  Widget build(BuildContext context) {
    final maxTilt = widget.maxTiltDeg * math.pi / 180;

    return LayoutBuilder(
      builder: (context, c) {
        final size = Size(c.maxWidth, c.maxHeight);

        final rotY = _p.dx * maxTilt;
        final rotX = -_p.dy * maxTilt;

        final gx = (_p.dx + 1) / 2;
        final gy = (_p.dy + 1) / 2;

        Widget core = AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          transformAlignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, widget.perspective)
            ..rotateX(_active ? rotX : 0)
            ..rotateY(_active ? rotY : 0)
            ..scale(_active ? 1.015 : 1.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Stack(
              fit: StackFit.expand,
              children: [
                widget.child,

                // overlay gradient (optional)
                IgnorePointer(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: _active ? 1 : 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // glare
                IgnorePointer(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: _active ? 0.9 : 0,
                    child: CustomPaint(
                      painter: _GlarePainter(center: Offset(gx, gy)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        if (widget.shadow) {
          core = AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                BoxShadow(
                  blurRadius: _active ? 26 : 18,
                  offset: const Offset(0, 10),
                  color: Colors.black.withOpacity(_active ? 0.35 : 0.22),
                ),
              ],
            ),
            child: core,
          );
        }

        core = MouseRegion(
          onEnter: (_) => setState(() => _active = true),
          onExit: (_) => _reset(),
          onHover: (e) => setState(() {
            _active = true;
            _update(e.localPosition, size);
          }),
          child: core,
        );

        if (widget.enableMobileDrag) {
          core = GestureDetector(
            onPanStart: (_) => setState(() => _active = true),
            onPanUpdate: (d) {
              final box = context.findRenderObject() as RenderBox?;
              if (box == null) return;
              final local = box.globalToLocal(d.globalPosition);
              setState(() {
                _active = true;
                _update(local, size);
              });
            },
            onPanEnd: (_) => _reset(),
            onPanCancel: _reset,
            child: core,
          );
        }

        return core;
      },
    );
  }
}

class _GlarePainter extends CustomPainter {
  _GlarePainter({required this.center});
  final Offset center; // 0..1

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..blendMode = BlendMode.overlay
      ..shader = RadialGradient(
        center: Alignment(center.dx * 2 - 1, center.dy * 2 - 1),
        radius: 0.9,
        colors: [
          Colors.white.withOpacity(0.85),
          Colors.white.withOpacity(0.0),
        ],
        stops: const [0.0, 0.6],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _GlarePainter oldDelegate) => oldDelegate.center != center;
}