import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/survey_response.dart';
import '../../services/email_service.dart';
import '../../services/export_service.dart';
import '../../services/storage_service.dart';
import '../../theme.dart';
import '../../widgets/background_scaffold.dart';
import 'send_email_dialog.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final StorageService _storage = StorageService();
  final ExportService _export = ExportService();
  final EmailService _email = EmailService();

  List<SurveyResponse> _responses = [];
  bool _loading = true;
  bool _hasConnectivity = false;
  bool _working = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final items = await _storage.readAll();
    final online = await _email.hasConnectivity();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (!mounted) return;
    setState(() {
      _responses = items;
      _hasConnectivity = online;
      _loading = false;
    });
  }

  Future<void> _exportXlsx() async {
    if (_responses.isEmpty) {
      _snack('No hay respuestas para exportar');
      return;
    }
    setState(() => _working = true);
    try {
      final file = await _export.buildXlsx(_responses);
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Encuestas Casa del Yeti',
        text: 'Resultados exportados el '
            '${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
      );
    } catch (e) {
      _snack('Error al exportar: $e');
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _sendEmail() async {
    if (_responses.isEmpty) {
      _snack('No hay respuestas para enviar');
      return;
    }
    if (!_email.isConfigured) {
      _snack('SendGrid no configurado en el build');
      return;
    }
    final online = await _email.hasConnectivity();
    if (!online) {
      _snack('Sin conexión a internet');
      return;
    }
    if (!mounted) return;
    final to = await showDialog<String>(
      context: context,
      builder: (_) => const SendEmailDialog(),
    );
    if (to == null || to.isEmpty) return;

    setState(() => _working = true);
    try {
      final file = await _export.buildXlsx(_responses);
      final first = _responses.last.createdAt;
      final last = _responses.first.createdAt;
      final dateFmt = DateFormat('yyyy-MM-dd HH:mm');
      final subject =
          'Encuestas Casa del Yeti — ${_responses.length} respuestas';
      final body = 'Total de respuestas: ${_responses.length}\n'
          'Primer registro: ${dateFmt.format(first)}\n'
          'Último registro: ${dateFmt.format(last)}\n\n'
          'Archivo adjunto: ${file.uri.pathSegments.last}';
      final result = await _email.sendReport(
        toEmail: to,
        subject: subject,
        bodyText: body,
        xlsxFile: file,
      );
      if (result.success) {
        _snack('Email enviado a $to', ok: true);
      } else {
        _snack(result.errorMessage ?? 'Error enviando email');
      }
    } catch (e) {
      _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _confirmClear() async {
    final ok1 = await _confirm(
      title: '¿Borrar todas las respuestas?',
      message: 'Se eliminarán ${_responses.length} encuestas. No se puede deshacer.',
      confirmLabel: 'Borrar',
      danger: true,
    );
    if (ok1 != true) return;
    final ok2 = await _confirm(
      title: '¿De verdad?',
      message: 'Confirma una segunda vez para continuar.',
      confirmLabel: 'Sí, borrar todo',
      danger: true,
    );
    if (ok2 != true) return;
    await _storage.clear();
    await _load();
    _snack('Datos borrados', ok: true);
  }

  Future<bool?> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
    bool danger = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceSolid,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(message,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 18)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  danger ? AppColors.danger : AppColors.primary,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  void _snack(String message, {bool ok = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ok ? AppColors.success : AppColors.danger,
        content: Text(message, style: const TextStyle(fontSize: 18)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildStatsAndActions(),
            const SizedBox(height: 20),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded,
              color: Colors.white, size: 36),
          tooltip: 'Volver',
        ),
        const SizedBox(width: 8),
        const Text(
          'Resultados',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: _loading ? null : _load,
          icon: const Icon(Icons.refresh_rounded,
              color: Colors.white, size: 32),
          tooltip: 'Recargar',
        ),
      ],
    );
  }

  Widget _buildStatsAndActions() {
    final total = _responses.length;
    final first =
        _responses.isEmpty ? null : _responses.last.createdAt;
    final last =
        _responses.isEmpty ? null : _responses.first.createdAt;
    final dateFmt = DateFormat('yyyy-MM-dd HH:mm');

    final emailEnabled =
        !_working && total > 0 && _email.isConfigured && _hasConnectivity;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$total',
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    height: 1,
                  ),
                ),
                const Text(
                  'respuestas guardadas',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 18),
                ),
                const SizedBox(height: 8),
                if (first != null && last != null)
                  Text(
                    'Desde ${dateFmt.format(first)}  ·  Hasta ${dateFmt.format(last)}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 16),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      _hasConnectivity
                          ? Icons.wifi_rounded
                          : Icons.wifi_off_rounded,
                      color: _hasConnectivity
                          ? AppColors.success
                          : AppColors.textSecondary,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _hasConnectivity ? 'Online' : 'Offline',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      _email.isConfigured
                          ? Icons.mark_email_read_rounded
                          : Icons.mark_email_unread_rounded,
                      color: _email.isConfigured
                          ? AppColors.success
                          : AppColors.textSecondary,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _email.isConfigured
                          ? 'SendGrid configurado'
                          : 'SendGrid no configurado',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                onPressed: _working || total == 0 ? null : _exportXlsx,
                icon: const Icon(Icons.file_download_rounded),
                label: const Text('Exportar XLSX'),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: emailEnabled ? _sendEmail : null,
                icon: const Icon(Icons.send_rounded),
                label: const Text('Enviar por email'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _working || total == 0 ? null : _confirmClear,
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.danger),
                label: const Text(
                  'Borrar todo',
                  style: TextStyle(color: AppColors.danger),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.danger, width: 2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_responses.isEmpty) {
      return Center(
        child: Text(
          'Aún no hay respuestas.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 22,
          ),
        ),
      );
    }
    final shown = _responses.take(50).toList();
    final dateFmt = DateFormat('yyyy-MM-dd HH:mm');
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: shown.length,
        separatorBuilder: (_, _) => Divider(
          color: Colors.white.withValues(alpha: 0.08),
          height: 1,
        ),
        itemBuilder: (_, i) {
          final r = shown[i];
          final q1 = r.answers['q1']?.toString() ?? '-';
          final q7 = r.answers['q7']?.toString() ?? '-';
          return ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            leading: CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Text(
                '${_responses.length - i}',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              dateFmt.format(r.createdAt),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '$q1  ·  NPS: $q7',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14),
            ),
          );
        },
      ),
    );
  }
}
