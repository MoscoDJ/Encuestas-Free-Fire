import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/survey_controller.dart';
import '../theme.dart';
import '../widgets/background_scaffold.dart';

class ThankYouScreen extends StatefulWidget {
  const ThankYouScreen({super.key});

  @override
  State<ThankYouScreen> createState() => _ThankYouScreenState();
}

class _ThankYouScreenState extends State<ThankYouScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 4), _returnHome);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _returnHome() {
    if (!mounted) return;
    context.read<SurveyController>().reset();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.85),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  size: 110,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                '¡Gracias!',
                style: TextStyle(
                  fontSize: 96,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: Colors.black87,
                      offset: Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Tu opinión ya quedó guardada.',
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.white.withValues(alpha: 0.92),
                ),
              ),
              const SizedBox(height: 40),
              TextButton(
                onPressed: _returnHome,
                child: const Text(
                  'Continuar',
                  style: TextStyle(
                    fontSize: 22,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
