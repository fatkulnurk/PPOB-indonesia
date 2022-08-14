import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kerupiah_lite_app/services/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<StatefulWidget> createState() => _DrawlerWidgetState();
}

class _DrawlerWidgetState extends State<DrawerWidget> {
  String email = '';
  String name = '';

  void initializeData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      email = prefs.getString('user_email')!;
      name = prefs.getString('user_username')!;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      initializeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _drawerHeader(email, name),
          _drawerItem(
            icon: Icons.home,
            text: 'Dashboard',
            onTap: () {
              return context.go('/dashboard');
            },
          ),
          _drawerItem(
            icon: Icons.lock_clock,
            text: 'Riwayat Transaksi',
            onTap: () {
              return context.go('/dashboard/transactions');
            },
          ),
          _drawerItem(
            icon: Icons.wallet,
            text: 'Riwayat Saldo',
            onTap: () {
              return context.go('/dashboard/balances');
            },
          ),
          _drawerItem(
            icon: Icons.money,
            text: 'Riwayat Deposit',
            onTap: () {
              return context.go('/dashboard/deposits');
            },
          ),
          _drawerItem(
            icon: Icons.logout,
            text: 'Logout',
            onTap: () async {
              bool success = await AuthService().logout();

              if (success) {
                return context.go('/');
              }
            },
          ),
          const Divider(height: 25, thickness: 1),
          _drawerItem(
            icon: Icons.newspaper,
            text: 'Berita Terbaru',
            onTap: () {
              return context.go('/pages/news');
            },
          ),
          _drawerItem(
            icon: Icons.call,
            text: 'Hubungi Kami',
            onTap: () {
              return context.go('/pages/contact-us');
            },
          ),
          _drawerItem(
            icon: Icons.warning_amber,
            text: 'Ketentuan Layanan',
            onTap: () {
              return context.go('/pages/terms-of-service');
            },
          ),
          _drawerItem(
            icon: Icons.privacy_tip_outlined,
            text: 'Kebijakan Privasi',
            onTap: () {
              return context.go('/pages/privacy-policy');
            },
          ),
        ],
      ),
    );
  }
}

Widget _drawerHeader(String email, String name) {
  return UserAccountsDrawerHeader(
    currentAccountPicture: const ClipOval(
      child: Image(image: AssetImage('images/logo.png'), fit: BoxFit.cover),
    ),
    accountName: Text(name),
    accountEmail: Text(email),
  );
}

Widget _drawerItem(
    {required IconData icon,
    required String text,
    required GestureTapCallback onTap}) {
  return ListTile(
    title: Row(
      children: <Widget>[
        Icon(icon),
        Padding(
          padding: const EdgeInsets.only(left: 25.0),
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
    onTap: onTap,
  );
}