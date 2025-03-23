import 'package:flutter/material.dart';

import '../services/database_service.dart';

class DatabaseServiceProvider extends InheritedWidget {
  final DatabaseService databaseService;

  const DatabaseServiceProvider({
    Key? key,
    required this.databaseService,
    required Widget child,
  }) : super(key: key, child: child);

  static DatabaseServiceProvider of(BuildContext context) {
    final DatabaseServiceProvider? result =
        context.dependOnInheritedWidgetOfExactType<DatabaseServiceProvider>();
    assert(result != null, 'No DatabaseServiceProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(DatabaseServiceProvider oldWidget) =>
      databaseService != oldWidget.databaseService;
}
