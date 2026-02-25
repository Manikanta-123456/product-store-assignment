import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stylestore/features/products/data/repositories/product_repository.dart';
import 'package:stylestore/features/products/data/services/api_service.dart';
import 'package:stylestore/features/products/presentation/providers/product_provider.dart';
import 'package:stylestore/features/preferences/data/repositories/preferences_repository.dart';
import 'package:stylestore/features/preferences/presentation/providers/preferences_provider.dart';
import 'package:stylestore/features/browser/data/repositories/browser_history_repository.dart';
import 'package:stylestore/features/browser/presentation/providers/browser_provider.dart';
import 'package:stylestore/app.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => ProductProvider(ProductRepository(ApiService())),
          ),
          ChangeNotifierProvider(
            create: (_) => PreferencesProvider(PreferencesRepository()),
          ),
          ChangeNotifierProvider(
            create: (_) => BrowserProvider(BrowserHistoryRepository()),
          ),
        ],
        child: const StyleStoreApp(),
      ),
    );
    // The app should render a loading indicator on first frame
    expect(find.byType(StyleStoreApp), findsOneWidget);
  });
}
