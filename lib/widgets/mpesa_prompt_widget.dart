import 'package:flutter/material.dart';
import '../services/mpesa_service.dart';

class MpesaPromptWidget extends StatefulWidget {
  final String phoneNumber;
  final VoidCallback? onSuccess;
  final VoidCallback? onError;

  const MpesaPromptWidget({
    super.key,
    required this.phoneNumber,
    this.onSuccess,
    this.onError,
  });

  @override
  State<MpesaPromptWidget> createState() => _MpesaPromptWidgetState();
}

class _MpesaPromptWidgetState extends State<MpesaPromptWidget> {
  bool _loading = false;
  String _message = "Ready to send M-Pesa prompt";

  Future<void> _sendPrompt() async {
    setState(() {
      _loading = true;
      _message = "Sending M-Pesa prompt to ${widget.phoneNumber}...";
    });

    try {
      final success = await MpesaService.sendPrompt(widget.phoneNumber);

      if (!mounted) return;

      if (success) {
        setState(() {
          _message = "✅ M-Pesa prompt sent successfully!";
        });
        widget.onSuccess?.call();
        
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          setState(() {
            _message = "Ready to send M-Pesa prompt";
            _loading = false;
          });
        }
      } else {
        setState(() {
          _message = "❌ Failed to send prompt. Try again.";
          _loading = false;
        });
        widget.onError?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _message = "Error: $e";
          _loading = false;
        });
        widget.onError?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _message.contains('✅')
                ? Colors.green
                : _message.contains('❌')
                    ? Colors.red
                    : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        if (_loading)
          const SizedBox(
            height: 40,
            width: 40,
            child: CircularProgressIndicator(),
          )
        else
          ElevatedButton.icon(
            onPressed: _sendPrompt,
            icon: const Icon(Icons.phone),
            label: const Text("Send M-Pesa Prompt"),
          ),
      ],
    );
  }
}
