import 'package:flutter/material.dart';
import '../json/definitions.dart';
import '../constants/app_constants.dart';

class InspectorPage extends StatelessWidget {
  final JsonResponse? jsonResponse;

  const InspectorPage({super.key, this.jsonResponse});

  Color _getStatusColor(String status) {
    switch(status) {
      case "true": return Colors.green;
      case "implied": return Colors.yellow;
      default: return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (jsonResponse == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(AppConstants.noDataMessage),
        ),
      );
    }

    final entries = jsonResponse!.fiveWoneH.entries.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(entry.value.isProvided),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        entry.value.isProvided == "true" 
                          ? "stated" 
                          : entry.value.isProvided == "implied" 
                            ? "implied" 
                            : "not stated",
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  entry.value.answer.toString(),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
