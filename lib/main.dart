


// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'providers/favorite_provider.dart';
// import 'providers/order_provider.dart';
// import 'screens/orders/order_history_screen.dart';

// import 'firebase_options.dart';
// import 'providers/MyAuthProvider.dart';
// import 'providers/cart_provider.dart';
// import 'providers/restaurant_provider.dart';
// import 'providers/theme_provider.dart';
// import 'theme/app_theme.dart';

// import 'screens/auth/login_screen.dart';
// import 'root_screens/root_screen.dart';
// import 'screens/cart/cart_screen.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => MyAuthProvider()),
//         ChangeNotifierProvider(create: (_) => CartProvider()),
//         ChangeNotifierProvider(create: (_) => RestaurantProvider()),
//         ChangeNotifierProvider(create: (_) => ThemeProvider()),
//         ChangeNotifierProvider(create: (_) => FavoriteProvider()),
//         ChangeNotifierProvider(create: (_) => OrderProvider()),


//       ],
//       child: Consumer<ThemeProvider>(
//         builder: (context, theme, _) {
//           return MaterialApp(
//             debugShowCheckedModeBanner: false,

//             /// 🎨 THEMES
//             theme: AppTheme.light,
//             darkTheme: AppTheme.dark,
//             themeMode: theme.themeMode,

//             /// 🔐 AUTH FLOW
//             initialRoute:
//                 FirebaseAuth.instance.currentUser == null
//                     ? LoginScreen.route
//                     : RootScreen.route,

//             /// 🧭 ROUTES
//             routes: {
//               LoginScreen.route: (_) => const LoginScreen(),
//               RootScreen.route: (_) => const RootScreen(),
//               CartScreen.route: (_) => const CartScreen(),
//               OrderHistoryScreen.route: (_) => const OrderHistoryScreen(),

//             },
//           );
//         },
//       ),
//     );
//   }
// }









import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';

import 'providers/MyAuthProvider.dart';
import 'providers/cart_provider.dart';
import 'providers/restaurant_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/order_provider.dart';

import 'theme/app_theme.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password.dart';

import 'root_screens/root_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/orders/order_history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,

            /// 🎨 THEMES
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: theme.themeMode,

            /// 🔐 AUTH FLOW
            initialRoute:
                FirebaseAuth.instance.currentUser == null
                    ? LoginScreen.route
                    : RootScreen.route,

            /// 🧭 ROUTES (🔥 FIXED)
            routes: {
              LoginScreen.route: (_) => const LoginScreen(),
              RegisterScreen.route: (_) => const RegisterScreen(),
              ForgotPasswordScreen.route: (_) =>
                  const ForgotPasswordScreen(),

              RootScreen.route: (_) => const RootScreen(),
              CartScreen.route: (_) => const CartScreen(),
              OrderHistoryScreen.route: (_) =>
                  const OrderHistoryScreen(),
            },
          );
        },
      ),
    );
  }
}
