import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/survey_controller.dart';
import '../theme.dart';
import '../widgets/background_scaffold.dart';
import '../widgets/hidden_corner_detector.dart';
import 'admin/admin_screen.dart';
import 'question_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _start(BuildContext context) {
    context.read<SurveyController>().reset();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const QuestionScreen()),
    );
  }

  void _openAdmin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AdminScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return HiddenCornerDetector(
      onUnlock: () => _openAdmin(context),
      child: BackgroundScaffold(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: kLogoReservedHeight),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Cuéntanos tu experiencia',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 44,
                        color: Colors.white.withValues(alpha: 0.95),
                        fontWeight: FontWeight.w600,
                        shadows: const [
                          Shadow(
                            color: Colors.black87,
                            offset: Offset(0, 3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    ElevatedButton.icon(
                      onPressed: () => _start(context),
                      icon: const Icon(Icons.play_arrow_rounded, size: 44),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Comenzar encuesta',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 56, vertical: 28),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 12,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Dura menos de 1 minuto',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 22,
                        shadows: const [
                          Shadow(
                            color: Colors.black54,
                            offset: Offset(0, 2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
