import 'package:flutter/material.dart';
import '../services/mpesa_service.dart';

/// Quick helper to send M-Pesa prompt
/// Usage: sendMpesaPrompt(context);
void sendMpesaPrompt(BuildContext context, [String phone = '+254793027220']) {
  _showPromptDialog(context, phone);
}

void _showPromptDialog(BuildContext context, String phone) {
  showDialog(
    context: context,
    builder: (dialogContext) => _PromptDialog(phone: phone),
  );
}

class _PromptDialog extends StatefulWidget {
  final String phone;

  const _PromptDialog({required this.phone});

  @override
  State<_PromptDialog> createState() => _PromptDialogState();
}

class _PromptDialogState extends State<_PromptDialog> {
  bool _isLoading = false;
  String _message = "";

  @override
  void initState() {
    super.initState();
    _message = "Send M-Pesa prompt to ${widget.phone}?";
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("M-Pesa Prompt"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_message),
          if (_isLoading) ...[
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ]
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: _isLoading ? null : _sendPrompt,
          child: const Text("Send"),
        ),
      ],
    );
  }

  Future<void> _sendPrompt() async {
    setState(() {
      _isLoading = true;
      _message = "Sending...";
    });

    try {
      final success = await MpesaService.sendPrompt(widget.phone);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _message = success ? "✅ Prompt sent!" : "❌ Failed to send prompt";
        });

        if (success) {
          await Future.delayed(
            const Duration(seconds: 1),
            () {
              if (mounted) Navigator.pop(context);
            },
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _message = "Error: $e";
        });
      }
    }
  }
}
