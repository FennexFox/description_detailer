import 'package:flutter/material.dart';
import '../json/definitions.dart';

class DetailerPreviewGrid extends StatelessWidget {
  final JsonResponse? jsonResponse;
  final bool isLoading;

  const DetailerPreviewGrid({
    super.key,
    required this.jsonResponse,
    required this.isLoading,
  });

  Color _getStatusColor(String? status) {
    switch(status) {
      case "true": return Colors.green;
      case "implied": return Colors.yellow;
      default: return Colors.red;
    }
  }

  Widget _buildPreviewItem(BuildContext context, String answerKey) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.all(12.0),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: isLoading 
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : jsonResponse == null 
                    ? const Icon(Icons.circle, size: 12, color: Colors.grey)
                    : Icon(
                        Icons.circle,
                        size: 12,
                        color: _getStatusColor(jsonResponse!.fiveWoneH[answerKey]?.isProvided),
                      ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  answerKey,
                  textAlign: TextAlign.start,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildPreviewItem(context, "Who")),
            Expanded(child: _buildPreviewItem(context, "When")),
          ],
        ),
        Row(
          children: [
            Expanded(child: _buildPreviewItem(context, "Where")),
            Expanded(child: _buildPreviewItem(context, "What")),
          ],
        ),
        Row(
          children: [
            Expanded(child: _buildPreviewItem(context, "Why")),
            Expanded(child: _buildPreviewItem(context, "How")),
          ],
        ),
      ],
    );
  }
}
