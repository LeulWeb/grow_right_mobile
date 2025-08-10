// lib/pages/recommendation_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grow_right_mobile/models/farmer_request_models.dart';
import 'package:grow_right_mobile/services/farmer_request_services.dart';
import 'package:grow_right_mobile/widgets/empty_widget.dart';

class RecommendationPage extends StatelessWidget {
  const RecommendationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FarmerRequestService();

    return FutureBuilder<List<FarmerRequestModel>>(
      future: service.fetchFarmerRequests(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snap.error}')),
          );
        }

        final all = (snap.data ?? [])..sort((a, b) {
          // newest request first
          final ad = a.createdAt ?? DateTime(0);
          final bd = b.createdAt ?? DateTime(0);
          return bd.compareTo(ad);
        });

        // keep only requests that already have a response (latestOfMany in relation)
        final withResponse = all.where((r) => r.farmerResponse != null).toList();

        if (withResponse.isEmpty) {
          return EmptyPageWidget(
            title: "No Recommendation",
            message: "There are no recommendation yet",
            retryText: "Find Best Crops",
            onRetry: () => context.push("/askRecommendation"),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Your Recommendations')),
          body: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: withResponse.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final req = withResponse[i];
              final resp = req.farmerResponse!;
              return _RecommendationCard(request: req, response: resp);
            },
          ),
        );
      },
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final FarmerRequestModel request;
  final FarmerResponseModel response;

  const _RecommendationCard({
    required this.request,
    required this.response,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header: address + demand badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    request.address,
                    style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                _demandChip(response.marketDemand),
              ],
            ),
            const SizedBox(height: 6),

            // meta
            Wrap(
              spacing: 10,
              runSpacing: 6,
              children: [
                _metaPill('Irrigation', request.hasIrrigation ? 'Yes' : 'No'),
                _metaPill('Season', '${request.seasonId}'),
                if (request.lat != null && request.lng != null)
                  _metaPill('Coords', '${request.lat}, ${request.lng}'),
                if (request.createdAt != null)
                  _metaPill('Requested',
                      request.createdAt!.toLocal().toString().split('.').first),
                if (response.createdAt != null)
                  _metaPill('Recommended',
                      response.createdAt!.toLocal().toString().split('.').first),
              ],
            ),

            const SizedBox(height: 12),
            const Text('Recommended Crops',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: response.recommendations
                  .map((r) => Chip(label: Text(r.value)))
                  .toList(),
            ),

            if ((response.plantingWindows ?? '').isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Planting Window',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(response.plantingWindows!),
            ],

            if ((response.reasoning ?? '').isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Why These Crops?',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(response.reasoning!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _metaPill(String k, String v) => Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text('$k: $v'),
      );

  Widget _demandChip(String? demand) {
    final label = switch (demand) {
      'h' => 'High',
      'm' => 'Medium',
      'l' => 'Low',
      _ => 'Unknown',
    };

    final color = switch (demand) {
      'h' => Colors.green,
      'm' => Colors.orange,
      'l' => Colors.red,
      _ => Colors.grey,
    };

    return Chip(
      label: Text(label),
      backgroundColor: color.withOpacity(0.15),
      side: BorderSide(color: color),
      labelStyle: TextStyle(color: color.shade700),
    );
  }
}
