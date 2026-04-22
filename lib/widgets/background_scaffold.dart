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
                  // Mantenemos el tercio superior (donde vive el logo del
                  // fondo) limpio, y oscurecemos la zona donde ponemos
                  // contenido para asegurar contraste del texto.
                  stops: [0.0, 0.33, 1.0],
                  colors: [
                    Color(0x00000000),
                    Color(0x66000000),
                    Color(0xB3000000),
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
