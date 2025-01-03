import 'package:flutter/material.dart';
import '../json/definitions.dart';
import '../constants/app_constants.dart';

class ResponsePage extends StatelessWidget {
  final JsonResponse? jsonResponse;

  const ResponsePage({super.key, this.jsonResponse});

  @override
  Widget build(BuildContext context) {
    if (jsonResponse == null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(AppConstants.noDataMessage),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            spacing: 8.0,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reconstructed Writing',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Divider(),
              Text(
                jsonResponse!.detailed,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
