import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart'; // <- use the generated options
import 'providers/MyAuthProvider.dart';
import 'providers/cart_provider.dart';
import 'providers/restaurant_provider.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'root_screens/root_screen.dart';
import 'screens/cart/cart_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MyAuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => RestaurantProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        initialRoute: FirebaseAuth.instance.currentUser == null
            ? LoginScreen.route
            : RootScreen.route,
        routes: {
          LoginScreen.route: (context) => const LoginScreen(),
          RootScreen.route: (context) => const RootScreen(),
           CartScreen.route: (context) => const CartScreen(), // ✅ ADD THIS
        },
      ),
    );
  }
}
