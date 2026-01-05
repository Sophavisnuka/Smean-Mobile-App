import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Minimal Flutter port of the ItsHover magnifier icon.
/// Animates with a small wobble when activated, so it fits bottom nav use.
class ItshoverMagnifierIcon extends StatefulWidget {
  const ItshoverMagnifierIcon({
    super.key,
    this.size,
    this.color,
    this.animate = false,
  });

  final double? size;
  final Color? color;
  final bool animate;

  @override
  State<ItshoverMagnifierIcon> createState() => _ItshoverMagnifierIconState();
}

class _ItshoverMagnifierIconState extends State<ItshoverMagnifierIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _dx;
  late final Animation<double> _dy;
  late final Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _dx = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0, end: -1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -1, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _dy = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -1, end: -2), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -2, end: -1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -1, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _rotation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -5), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -5, end: 5), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 5, end: -5), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -5, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.animate) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant ItshoverMagnifierIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !oldWidget.animate) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final double size = widget.size ?? iconTheme.size ?? 24;
    final Color color = widget.color ?? iconTheme.color ?? Colors.black;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_dx.value, _dy.value),
          child: Transform.rotate(
            angle: _rotation.value * math.pi / 180,
            child: child,
          ),
        );
      },
      child: SvgPicture.string(
        _svgData,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
    );
  }
}

const String _svgData = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32" fill="none" stroke="currentColor" stroke-width="2" stroke-miterlimit="10" stroke-linecap="square">
  <g>
    <path d="m21.393,18.565l7.021,7.021c.781.781.781,2.047,0,2.828h0c-.781.781-2.047.781-2.828,0l-7.021-7.021" />
    <circle cx="13" cy="13" r="10" />
  </g>
</svg>
''';
