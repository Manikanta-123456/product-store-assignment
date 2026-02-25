import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/products/presentation/screens/product_feed_screen.dart';

class StyleStoreApp extends StatelessWidget {
  const StyleStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StyleStore',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const ProductFeedScreen(),
    );
  }
}
