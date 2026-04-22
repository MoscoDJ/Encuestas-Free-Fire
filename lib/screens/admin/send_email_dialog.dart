import 'package:flutter/material.dart';

import '../../theme.dart';

class SendEmailDialog extends StatefulWidget {
  const SendEmailDialog({super.key});

  @override
  State<SendEmailDialog> createState() => _SendEmailDialogState();
}

class _SendEmailDialogState extends State<SendEmailDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  static final RegExp _emailRx =
      RegExp(r'^[\w.+\-]+@([\w\-]+\.)+[A-Za-z]{2,}$');

  void _submit() {
    final value = _controller.text.trim();
    if (!_emailRx.hasMatch(value)) {
      setState(() => _error = 'Email inválido');
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceSolid,
      title: const Text(
        'Enviar resultados por email',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Se enviará un archivo XLSX con todas las respuestas al correo indicado.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 18),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            style: const TextStyle(color: Colors.white, fontSize: 22),
            decoration: InputDecoration(
              hintText: 'ejemplo@dominio.com',
              errorText: _error,
            ),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 20)),
        ),
        ElevatedButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.send_rounded),
          label: const Text('Enviar'),
        ),
      ],
    );
  }
}
