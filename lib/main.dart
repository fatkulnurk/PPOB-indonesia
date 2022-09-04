import 'dart:async';
import 'dart:convert' as convert;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:kerupiah_lite_app/screens/dashboard/balances/home_screen.dart';
import 'package:kerupiah_lite_app/screens/dashboard/deposits/create_screen.dart';
import 'package:kerupiah_lite_app/screens/dashboard/deposits/home_screen.dart';
import 'package:kerupiah_lite_app/screens/dashboard/home_screen.dart';
import 'package:kerupiah_lite_app/screens/dashboard/profiles/home_screen.dart';
import 'package:kerupiah_lite_app/screens/dashboard/transactions/home_screen.dart';
import 'package:kerupiah_lite_app/screens/login_screen.dart';
import 'package:kerupiah_lite_app/screens/page_screen.dart';
import 'package:kerupiah_lite_app/screens/signup_screen.dart';
import 'package:kerupiah_lite_app/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:kerupiah_lite_app/helpers/config.dart' as config;

Future<void> main() async {
  runApp(App());
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: true,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen(_firebaseMessagingOnListen);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

// background message
Future<void> _firebaseMessagingOnListen(RemoteMessage message) async {
  // print('Got a message whilst in the foreground!');
  // print("Handling a background message: ${message.messageId}");
  // print('Message data: ${message.data}');
  if (message.notification != null) {
    // print('Message also contained a notification: ${message.notification}');
  }
  if (message.data != null) {
    if(message.data['type'].toString().isNotEmpty) {
      switch (message.data['type']) {
        case 'transaction_show':
          {

          }
          break;
      }
    }
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  // print("Background message:");
  // print("Handling a background message: ${message.messageId}");
  // print("Handling a background message: ${message.notification}");
  // print("--------------------------------");
  if (message.data != null) {
    // print("Handling a background message: ${message.data}");
  }
}

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationProvider: _router.routeInformationProvider,
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,
      title: config.appName,
      builder: EasyLoading.init(),
    );
  }

  final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) {
          return LoginPageScreen();
        },
      ),
      GoRoute(
        path: '/signup',
        builder: (BuildContext context, GoRouterState state) {
          return SignUpScreen();
        },
      ),
      GoRoute(
        path: '/dashboard',
        builder: (BuildContext context, GoRouterState state) {
          return const DashboardHomePageScreen();
        },
      ),
      GoRoute(
        path: '/dashboard/balances',
        builder: (BuildContext context, GoRouterState state) {
          return const BalanceHomePageScreen();
        },
      ),
      GoRoute(
        path: '/dashboard/deposits',
        builder: (BuildContext context, GoRouterState state) {
          return const DepositHomePageScreen();
        },
      ),
      GoRoute(
        path: '/dashboard/deposits/create',
        builder: (BuildContext context, GoRouterState state) {
          return const CreateDepositScreen();
        },
      ),
      GoRoute(
        path: '/dashboard/transactions',
        builder: (BuildContext context, GoRouterState state) {
          return const TransactionHomePageScreen();
        },
      ),
      GoRoute(
        path: '/dashboard/profiles/home',
        builder: (BuildContext context, GoRouterState state) {
          return const ProfileHomePageScreen();
        },
      ),
      GoRoute(
        path: '/pages/news',
        builder: (BuildContext context, GoRouterState state) {
          const String url = 'https://kerupiah.com/news';
          const String title = 'Berita Terbaru';
          return const PageWebviewScreen(url: url, title: title);
        },
      ),
      GoRoute(
        path: '/pages/contact-us',
        builder: (BuildContext context, GoRouterState state) {
          const String url = 'https://kerupiah.com/pages/contact-us';
          const String title = 'Hubungi Kami';
          return const PageWebviewScreen(url: url, title: title);
        },
      ),
      GoRoute(
        path: '/pages/terms-of-service',
        builder: (BuildContext context, GoRouterState state) {
          const String url = 'https://kerupiah.com/pages/terms-of-service';
          const String title = 'Ketentuan Layanan';
          return const PageWebviewScreen(url: url, title: title);
        },
      ),
      GoRoute(
        path: '/pages/privacy-policy',
        builder: (BuildContext context, GoRouterState state) {
          const String url = 'https://kerupiah.com/pages/privacy-policy';
          const String title = 'Kebijakan Privasi';
          return const PageWebviewScreen(url: url, title: title);
        },
      ),
    ],
  );
}
