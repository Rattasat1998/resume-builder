import 'dart:math' as math;
import 'package:flutter/material.dart';

class NeonHoloTiltContainer extends StatefulWidget {
  const NeonHoloTiltContainer({
    super.key,
    required this.child,
    this.borderRadius = 18,
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
  State<NeonHoloTiltContainer> createState() => _NeonHoloTiltContainerState();
}

class _NeonHoloTiltContainerState extends State<NeonHoloTiltContainer>
    with SingleTickerProviderStateMixin {
  Offset _p = Offset.zero; // -1..1
  bool _active = false;

  late final AnimationController _holoCtrl;

  @override
  void initState() {
    super.initState();
    _holoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _holoCtrl.dispose();
    super.dispose();
  }

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

        // glare center 0..1
        final gx = (_p.dx + 1) / 2;
        final gy = (_p.dy + 1) / 2;

        Widget core = AnimatedBuilder(
          animation: _holoCtrl,
          builder: (context, _) {
            final t = _holoCtrl.value; // 0..1

            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              transformAlignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, widget.perspective)
                ..rotateX(_active ? rotX : 0)
                ..rotateY(_active ? rotY : 0)
                ..scale(_active ? 1.02 : 1.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Base content (PdfPreview)
                    widget.child,

                    // 1) Neon border glow (เบาๆ)
                    IgnorePointer(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 180),
                        opacity: _active ? 1 : 0,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1.2,
                              color: Colors.cyanAccent.withOpacity(0.35),
                            ),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 22,
                                spreadRadius: 2,
                                color: Colors.cyanAccent.withOpacity(0.12),
                              ),
                              BoxShadow(
                                blurRadius: 28,
                                spreadRadius: 1,
                                color: Colors.purpleAccent.withOpacity(0.10),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 2) Hologram sweep (แสงไล่สีวิ่งเฉียง)
                    IgnorePointer(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 180),
                        opacity: _active ? 0.95 : 0,
                        child: _HoloSweep(
                          t: t,
                          // ให้แสงตอบสนองกับตำแหน่งเมาส์นิดๆ
                          shift: Offset((gx - 0.5) * 0.25, (gy - 0.5) * 0.25),
                        ),
                      ),
                    ),

                    // 3) Glare highlight (radial) + blend overlay
                    IgnorePointer(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 180),
                        opacity: _active ? 0.9 : 0,
                        child: CustomPaint(
                          painter: _GlarePainter(center: Offset(gx, gy)),
                        ),
                      ),
                    ),

                    // 4) Subtle prism overlay (เพิ่มความ “ล้ำ”)
                    IgnorePointer(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 180),
                        opacity: _active ? 0.65 : 0,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.transparent,
                                Colors.pinkAccent.withOpacity(0.10),
                                Colors.transparent,
                                Colors.blueAccent.withOpacity(0.10),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );

        if (widget.shadow) {
          core = AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                BoxShadow(
                  blurRadius: _active ? 30 : 18,
                  offset: const Offset(0, 12),
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

class _HoloSweep extends StatelessWidget {
  const _HoloSweep({required this.t, required this.shift});

  final double t; // 0..1
  final Offset shift;

  @override
  Widget build(BuildContext context) {
    // sweep position -0.8..1.8
    final x = (t * 2.6) - 0.8 + shift.dx;

    // ShaderMask ให้ไล่สีแบบ hologram และใช้ blend ให้เหมือน “แสง”
    return ShaderMask(
      blendMode: BlendMode.screen, // ให้สว่างแบบ add-ish
      shaderCallback: (rect) {
        return LinearGradient(
          begin: Alignment(-1.0 + x, 1.0),
          end: Alignment(1.0 + x, -1.0),
          colors: [
            Colors.transparent,
            Colors.cyanAccent.withOpacity(0.65),
            Colors.purpleAccent.withOpacity(0.55),
            Colors.pinkAccent.withOpacity(0.45),
            Colors.transparent,
          ],
          stops: const [0.0, 0.35, 0.55, 0.75, 1.0],
        ).createShader(rect);
      },
      child: Container(
        color: Colors.white.withOpacity(0.08), // base for mask
      ),
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
        radius: 0.95,
        colors: [
          Colors.white.withOpacity(0.9),
          Colors.white.withOpacity(0.0),
        ],
        stops: const [0.0, 0.6],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _GlarePainter oldDelegate) => oldDelegate.center != center;
}