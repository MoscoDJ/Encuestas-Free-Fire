import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../widgets/background_scaffold.dart';

/// Full-screen confirmation for destructive actions.
///
/// Requires the same triple-corner tap sequence used to enter the admin panel:
/// superior izquierda -> superior derecha -> inferior izquierda, dentro de
/// [window]. Si la secuencia se rompe, se resetea el progreso.
class DeleteConfirmationScreen extends StatefulWidget {
  final int totalResponses;
  final Duration window;
  final double hotspotSize;

  const DeleteConfirmationScreen({
    super.key,
    required this.totalResponses,
    this.window = const Duration(seconds: 5),
    this.hotspotSize = 140,
  });

  @override
  State<DeleteConfirmationScreen> createState() =>
      _DeleteConfirmationScreenState();
}

class _DeleteConfirmationScreenState extends State<DeleteConfirmationScreen> {
  static const List<int> _expected = [0, 1, 2]; // TL, TR, BL
  final List<int> _sequence = [];
  DateTime? _firstAt;
  bool _confirmed = false;

  void _onCornerTap(int corner) {
    if (_confirmed) return;
    final now = DateTime.now();

    setState(() {
      if (_firstAt != null && now.difference(_firstAt!) > widget.window) {
        _sequence.clear();
        _firstAt = null;
      }

      final expectedNext = _sequence.length < _expected.length
          ? _expected[_sequence.length]
          : null;

      if (expectedNext != null && corner == expectedNext) {
        _sequence.add(corner);
        _firstAt ??= now;
      } else {
        _sequence.clear();
        _firstAt = null;
        if (corner == _expected.first) {
          _sequence.add(corner);
          _firstAt = now;
        }
      }
    });

    if (_sequence.length == _expected.length) {
      _confirmed = true;
      Navigator.of(context).pop(true);
    }
  }

  void _cancel() => Navigator.of(context).pop(false);

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildContent(),
          _cornerHotspot(0, Alignment.topLeft),
          _cornerHotspot(1, Alignment.topRight),
          _cornerHotspot(2, Alignment.bottomLeft),
          _cornerMarker(0, Alignment.topLeft),
          _cornerMarker(1, Alignment.topRight),
          _cornerMarker(2, Alignment.bottomLeft),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(48, kLogoReservedHeight, 48, 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.danger.withValues(alpha: 0.15),
              border: Border.all(color: AppColors.danger, width: 3),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              size: 88,
              color: AppColors.danger,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Borrar TODOS los registros',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1,
              shadows: [
                Shadow(
                  color: Colors.black87,
                  offset: Offset(0, 3),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Se eliminarán ${widget.totalResponses} encuestas. '
            'Esta acción no se puede deshacer.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 36),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Para confirmar, toca las 3 esquinas en este orden',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _stepChip(0, 'Sup. izq.'),
                    _stepArrow(),
                    _stepChip(1, 'Sup. der.'),
                    _stepArrow(),
                    _stepChip(2, 'Inf. izq.'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: _cancel,
            icon: const Icon(Icons.close_rounded),
            label: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Widget _stepChip(int corner, String label) {
    final done = _sequence.contains(corner);
    final isNext = !done &&
        _sequence.length < _expected.length &&
        _expected[_sequence.length] == corner;
    final color = done
        ? AppColors.success
        : isNext
            ? AppColors.primary
            : Colors.white.withValues(alpha: 0.12);
    final border = done
        ? AppColors.success
        : isNext
            ? AppColors.primary
            : Colors.white.withValues(alpha: 0.3);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: done ? 0.85 : 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            done ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 20,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepArrow() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Icon(
          Icons.arrow_forward_rounded,
          size: 20,
          color: Colors.white.withValues(alpha: 0.7),
        ),
      );

  Widget _cornerHotspot(int index, Alignment alignment) {
    return Align(
      alignment: alignment,
      child: SizedBox(
        width: widget.hotspotSize,
        height: widget.hotspotSize,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _onCornerTap(index),
        ),
      ),
    );
  }

  Widget _cornerMarker(int index, Alignment alignment) {
    final done = _sequence.contains(index);
    final isNext = !done &&
        _sequence.length < _expected.length &&
        _expected[_sequence.length] == index;

    final color = done
        ? AppColors.success
        : isNext
            ? AppColors.primary
            : Colors.white.withValues(alpha: 0.35);

    const markerSize = 72.0;
    const inset = 24.0;

    return IgnorePointer(
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: EdgeInsets.only(
            left: alignment.x < 0 ? inset : 0,
            right: alignment.x > 0 ? inset : 0,
            top: alignment.y < 0 ? inset : 0,
            bottom: alignment.y > 0 ? inset : 0,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: markerSize,
            height: markerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: done ? 0.85 : 0.2),
              border: Border.all(color: color, width: 3),
              boxShadow: isNext
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.6),
                        blurRadius: 22,
                        spreadRadius: 2,
                      ),
                    ]
                  : const [],
            ),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
