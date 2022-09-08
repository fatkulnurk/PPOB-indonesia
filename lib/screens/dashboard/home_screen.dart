import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kerupiah_lite_app/services/balance.dart';
import 'package:kerupiah_lite_app/services/category.dart';
import 'package:kerupiah_lite_app/widgets/drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:kerupiah_lite_app/widgets/action_item.dart';
import 'package:kerupiah_lite_app/helpers/config.dart' as config;

class DashboardHomePageScreen extends StatefulWidget {
  const DashboardHomePageScreen({Key? key}) : super(key: key);

  @override
  State<DashboardHomePageScreen> createState() => _DashboardHomePageScreen();
}

class _DashboardHomePageScreen extends State<DashboardHomePageScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Apakah anda yakin?'),
            content: const Text(
                'Apakah anda yakin ingin menutup aplikasi (anda masih dalam keadaan login).'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batalkan'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Tutup Aplikasi'),
              ),
            ],
          ),
        )) ??
        false;
  }

  int _selectedNavbar = 0;

  void _changeSelectedNavBar(int index) {
    switch (index) {
      case 1:
        context.go('/dashboard/transactions');
        break;
      case 2:
        context.go('/dashboard/deposits/create');
        break;
      case 3:
        context.go('/dashboard/profiles/home');
        break;

    }
  }

  @override
  Widget build(BuildContext context) {
    var textStyle = Theme.of(context).textTheme;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        drawer: const DrawerWidget(),
        appBar: AppBar(
          title: const Text(config.appName),
          actions: <Widget> [
            IconButton(
              icon: const Icon(
                Icons.add_alert_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                context.go('/dashboard/notifications');
              },
            )
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: "Transaksi",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.wallet_rounded),
              label: "Isi Saldo",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Akun",
            ),
          ],
          currentIndex: _selectedNavbar,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          onTap: _changeSelectedNavBar,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                BalanceSection(),
                Container(
                  padding: EdgeInsets.fromLTRB(0, 25, 0, 20),
                  child: Text(
                    'PRODUK & LAYANAN',
                    style: textStyle.headline5,
                  ),
                ),
                MyStatefulWidget(),
                const SizedBox(
                  height: 20,
                ),
                const SizedBox(
                  height: 30,
                ),
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Copyright © 2022 ${config.appName}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BalanceSection extends StatefulWidget {
  const BalanceSection({Key? key}) : super(key: key);

  @override
  State<BalanceSection> createState() => _BalanceSection();
}

class _BalanceSection extends State<BalanceSection> {
  int balance = 0;
  String balanceString = '';

  Future<void> getInitializeBalance() async {
    final prefs = await SharedPreferences.getInstance();
    var balancePref = prefs.getString('balance_string');

    if (balancePref.toString().isNotEmpty) {
      setState(() {
        balanceString = balancePref ?? 'Rp0';
      });
    }
  }

  Future<void> getInitializeData() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> data = await BalanceService().get();
    if (data.isNotEmpty) {
      setState(() {
        balance = data['data']['balance'];
        balanceString = data['data']['balance_string'];
        prefs.setString('balance_string', balanceString);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getInitializeBalance();
    getInitializeData();
  }

  @override
  Widget build(BuildContext context) {
    var textStyle = Theme.of(context).textTheme;

    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.blue, Colors.lightBlueAccent, Colors.blue],
            ),
          ),
          padding: const EdgeInsets.all(0),
          alignment: Alignment.topCenter,
          height: 155,
        ),
        Positioned(
          top: 10,
          left: 0,
          right: 0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saldo Tersedia',
                          style: textStyle.subtitle1,
                        ),
                        Text(
                          balanceString,
                          style: textStyle.headline3,
                        )
                      ],
                    ),
                    const CircleAvatar(
                      radius: 22,
                      child: Icon(
                        Icons.wallet,
                        size: 32,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      child: Row(
                        children: [
                          Text(
                            'Topup Saldo',
                            style: textStyle.subtitle1,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 8,
                              color: Colors.white,
                              // color: color.Colors.accentColor,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        context.go('/dashboard/deposits/create');
                      },
                    ),
                    GestureDetector(
                      child: Row(
                        children: [
                          Text(
                            'Riwayat Transaksi',
                            style: textStyle.subtitle2,
                          ),
                          const Icon(
                            Icons.arrow_right_outlined,
                            color: Colors.blue,
                            // color: color.Colors.accentColor,
                          )
                        ],
                      ),
                      onTap: () {
                        context.go('/dashboard/transactions');
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  late List<dynamic> categories;
  int categoryLength = 0;

  Future<void> getInitializeCategories() async {
    final prefs = await SharedPreferences.getInstance();
    var categoryJson = prefs.getString('categories_json');

    if (categoryJson.toString().isNotEmpty && categoryJson == '') {
      Map<String, dynamic> data = jsonDecode(categoryJson!);
      List<dynamic> items = data['data'];
      if (data.isNotEmpty) {
        setState(() {
          categories = items;
          categoryLength = categories.length;
        });
      }
    }
  }

  Future<void> getInitializeData() async {
    List<dynamic> items = await CategoryService().get();
    if (items.isNotEmpty) {
      setState(() {
        categories = items;
        categoryLength = categories.length;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getInitializeCategories();
    getInitializeData();
  }

  @override
  Widget build(BuildContext context) {
    return GridView(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      primary: false,
      // padding: const EdgeInsets.all(20),
      shrinkWrap: true,
      children: <Widget>[
        for (var i = 0; i < categoryLength; i++)
          Container(
            // padding: const EdgeInsets.all(8),
            color: Colors.transparent,
            child: ActionItem(
              id: categories[i]['id'].toString(),
              imageUrl: categories[i]['logo_url'].toString(),
              title: categories[i]['name'].toString(),
            ),
          ),
      ],
    );
  }
}
