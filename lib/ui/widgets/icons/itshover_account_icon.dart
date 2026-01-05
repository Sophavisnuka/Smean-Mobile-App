import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Animated account/profile icon inspired by ItsHover; gentle wobble when active.
class ItshoverAccountIcon extends StatefulWidget {
  const ItshoverAccountIcon({
    super.key,
    this.size,
    this.color,
    this.animate = false,
  });

  final double? size;
  final Color? color;
  final bool animate;

  @override
  State<ItshoverAccountIcon> createState() => _ItshoverAccountIconState();
}

class _ItshoverAccountIconState extends State<ItshoverAccountIcon>
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
      TweenSequenceItem(tween: Tween(begin: 0, end: -4), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -4, end: 4), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 4, end: -4), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -4, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.animate) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant ItshoverAccountIcon oldWidget) {
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
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <circle cx="12" cy="8" r="4" />
  <path d="M5.5 20a8.5 8.5 0 0 1 13 0" />
</svg>
''';
