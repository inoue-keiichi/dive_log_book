import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/database_service_provider.dart';
import 'statistics_template.dart';
import 'use_statistics.dart';

class StatisticsScreen extends HookConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final da = ref.watch(dataAccessProvider);
    final statisticsResult = useStatistics(da);

    return Scaffold(
      appBar: AppBar(
        title: const Text('統計'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: StatisticsTemplate(
        isLoading: statisticsResult.isLoading.value,
        diveDuration: statisticsResult.diveDuration.value,
        diveCount: statisticsResult.diveCount.value,
        error: statisticsResult.error.value,
      ),
    );
  }
}
