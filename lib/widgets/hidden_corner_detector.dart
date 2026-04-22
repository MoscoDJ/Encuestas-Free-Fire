import 'package:flutter/material.dart';

class HiddenCornerDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback onUnlock;
  final Duration window;
  final double hotspotSize;

  const HiddenCornerDetector({
    super.key,
    required this.child,
    required this.onUnlock,
    this.window = const Duration(seconds: 3),
    this.hotspotSize = 90,
  });

  @override
  State<HiddenCornerDetector> createState() => _HiddenCornerDetectorState();
}

class _HiddenCornerDetectorState extends State<HiddenCornerDetector> {
  static const List<int> _expected = [0, 1, 2]; // top-left, top-right, bottom-left
  final List<int> _sequence = [];
  DateTime? _firstAt;

  void _tap(int corner) {
    final now = DateTime.now();
    if (_firstAt != null && now.difference(_firstAt!) > widget.window) {
      _sequence.clear();
      _firstAt = null;
    }
    _sequence.add(corner);
    _firstAt ??= now;

    // Check whether current sequence is a valid prefix of expected.
    for (var i = 0; i < _sequence.length; i++) {
      if (i >= _expected.length || _sequence[i] != _expected[i]) {
        _sequence.clear();
        _firstAt = null;
        return;
      }
    }

    if (_sequence.length == _expected.length) {
      _sequence.clear();
      _firstAt = null;
      widget.onUnlock();
    }
  }

  Widget _hotspot(int index, {Alignment? alignment}) {
    return Align(
      alignment: alignment!,
      child: SizedBox(
        width: widget.hotspotSize,
        height: widget.hotspotSize,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _tap(index),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        _hotspot(0, alignment: Alignment.topLeft),
        _hotspot(1, alignment: Alignment.topRight),
        _hotspot(2, alignment: Alignment.bottomLeft),
      ],
    );
  }
}
