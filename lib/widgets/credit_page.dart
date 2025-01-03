import 'package:flutter/material.dart';

class CreditPage extends StatelessWidget {
  const CreditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('About'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description Detailer',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text('Version 0.5.0'),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Created by',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text('AnotherFireFox'),
            const SizedBox(height: 24),
            Text(
              'Powered by',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text('Flutter & OpenAI'),
          ],
        ),
      ),
    );
  }
}
