import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'statistics_template.dart';
import 'use_statistics.dart';

class StatisticsScreen extends HookWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final statisticsResult = useStatistics();

    return Scaffold(
      appBar: AppBar(
        title: const Text('統計'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: StatisticsTemplate(
        isLoading: statisticsResult.isLoading,
        diveDuration: statisticsResult.diveDuration,
        diveCount: statisticsResult.diveCount,
        error: statisticsResult.error,
      ),
    );
  }
}
