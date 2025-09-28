import 'package:flutter/material.dart';

import 'features/divelog_list/divelog_list.dart';
import 'features/statistics/statistics_screen.dart';
import 'providers/database_service_provider.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // データベースの初期化
  final databaseService = DatabaseService();
  await databaseService.database;

  runApp(MyApp(databaseService: databaseService));
}

class MyApp extends StatelessWidget {
  final DatabaseService databaseService;

  const MyApp({
    super.key,
    required this.databaseService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ダイブログ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue,
          secondary: Colors.lightBlue,
        ),
        useMaterial3: true,
      ),
      home: DatabaseServiceProvider(
        databaseService: databaseService,
        child: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DivelogList(),
    StatisticsScreen(),
  ];

  final List<BottomNavigationBarItem> _navigationItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.list),
      activeIcon: Icon(Icons.list),
      label: 'ログ',
      tooltip: 'ダイビング記録画面を開く',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.analytics_outlined),
      activeIcon: Icon(Icons.analytics),
      label: '統計',
      tooltip: '統計画面を開く',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: _navigationItems,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 8,
      ),
    );
  }
}
