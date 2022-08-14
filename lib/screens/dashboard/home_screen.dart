import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kerupiah_lite_app/widgets/drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../widgets/action_item.dart';

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

  @override
  Widget build(BuildContext context) {
    var textStyle = Theme.of(context).textTheme;

    return Scaffold(
      drawer: const DrawerWidget(),
      appBar: AppBar(
        title: const Text("KeRupiah.Com"),
        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       context.go('/dashboard');
        //     },
        //     icon: const Icon(
        //       Icons.notifications_active_outlined,
        //       color: Colors.yellow,
        //     ),
        //   )
        // ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              BalanceSection(),
              Container(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                child: Text(
                  'PRODUK & LAYANAN',
                  style: textStyle.headline5,
                ),
              ),
              MyStatefulWidget(),
            ],
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
    String? token = prefs.getString('token');

    var url = Uri.parse('https://kerupiah.com/api/balances');
    var response = await http.get(url, headers: <String, String>{
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        setState(() {
          balance = data['data']['balance'];
          balanceString = data['data']['balance_string'];
          prefs.setString('balance_string', balanceString);
        });
      }
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
                            'Riwayat Saldo',
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
                        context.go('/dashboard/balances');
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

    if (categoryJson.toString().isNotEmpty) {
      Map<String, dynamic> data = jsonDecode(categoryJson.toString());
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
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    var url = Uri.parse('https://kerupiah.com/api/categories');
    var response = await http.get(url, headers: <String, String>{
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });

    if (response.statusCode == 200) {
      prefs.setString('categories_json', response.body);
      Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> items = data['data'];
      if (data.isNotEmpty) {
        setState(() {
          categories = items;
          categoryLength = categories.length;
        });
      }
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
