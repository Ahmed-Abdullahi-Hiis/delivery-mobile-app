 import 'package:flutter/material.dart';

class TrackOrderScreen extends StatelessWidget {
  final String orderId;
  const TrackOrderScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    // placeholder tracking UI
    return Scaffold(
      appBar: AppBar(title: Text('Track $orderId')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Rider is on the way', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            const LinearProgressIndicator(value: 0.6),
            const SizedBox(height: 12),
            const Text('Estimated: 12 minutes'),
            const SizedBox(height: 24),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: const Text('Rider: John Doe'),
              subtitle: const Text('Vehicle: Motorbike • Plate ABC-123'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            )
          ],
        ),
      ),
    );
  }
}
