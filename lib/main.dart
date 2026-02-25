import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'features/products/data/repositories/product_repository.dart';
import 'features/products/data/services/api_service.dart';
import 'features/products/presentation/providers/product_provider.dart';
import 'features/preferences/data/repositories/preferences_repository.dart';
import 'features/preferences/presentation/providers/preferences_provider.dart';
import 'features/browser/data/repositories/browser_history_repository.dart';
import 'features/browser/presentation/providers/browser_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize repositories (they lazy-init SharedPreferences internally)
  final prefsRepo = PreferencesRepository();
  final historyRepo = BrowserHistoryRepository();
  final productRepo = ProductRepository(ApiService());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProductProvider(productRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => PreferencesProvider(prefsRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => BrowserProvider(historyRepo),
        ),
      ],
      child: const StyleStoreApp(),
    ),
  );
}
