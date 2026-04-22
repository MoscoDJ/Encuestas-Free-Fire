import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class EmailServiceResult {
  final bool success;
  final String? errorMessage;

  const EmailServiceResult({required this.success, this.errorMessage});
}

class EmailService {
  static const String apiKey =
      String.fromEnvironment('SENDGRID_API_KEY', defaultValue: '');
  static const String fromAddress =
      String.fromEnvironment('SENDGRID_FROM', defaultValue: '');
  static const String fromName =
      String.fromEnvironment('SENDGRID_FROM_NAME', defaultValue: 'Casa del Yeti');

  static const String _endpoint = 'https://api.sendgrid.com/v3/mail/send';

  bool get isConfigured => apiKey.isNotEmpty && fromAddress.isNotEmpty;

  Future<bool> hasConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  Future<EmailServiceResult> sendReport({
    required String toEmail,
    required String subject,
    required String bodyText,
    required File xlsxFile,
  }) async {
    if (!isConfigured) {
      return const EmailServiceResult(
        success: false,
        errorMessage:
            'SendGrid no configurado. Compila con --dart-define=SENDGRID_API_KEY=... y --dart-define=SENDGRID_FROM=...',
      );
    }

    final bytes = await xlsxFile.readAsBytes();
    final attachmentBase64 = base64Encode(bytes);
    final filename = xlsxFile.uri.pathSegments.last;

    final payload = {
      'personalizations': [
        {
          'to': [
            {'email': toEmail}
          ],
        }
      ],
      'from': {
        'email': fromAddress,
        'name': fromName,
      },
      'subject': subject,
      'content': [
        {
          'type': 'text/plain',
          'value': bodyText,
        }
      ],
      'attachments': [
        {
          'content': attachmentBase64,
          'type':
              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          'filename': filename,
          'disposition': 'attachment',
        }
      ],
    };

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );
      if (response.statusCode == 202) {
        return const EmailServiceResult(success: true);
      }
      return EmailServiceResult(
        success: false,
        errorMessage:
            'SendGrid respondió ${response.statusCode}: ${response.body}',
      );
    } catch (e) {
      return EmailServiceResult(
        success: false,
        errorMessage: 'Error de red: $e',
      );
    }
  }
}
