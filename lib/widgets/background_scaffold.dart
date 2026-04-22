import 'package:flutter/material.dart';

class BackgroundScaffold extends StatelessWidget {
  final Widget child;
  final bool dimBackground;

  const BackgroundScaffold({
    super.key,
    required this.child,
    this.dimBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/background/fondo_tablet.png',
            fit: BoxFit.cover,
          ),
          if (dimBackground)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x80000000),
                    Color(0xCC000000),
                  ],
                ),
              ),
            ),
          SafeArea(child: child),
        ],
      ),
    );
  }
}
