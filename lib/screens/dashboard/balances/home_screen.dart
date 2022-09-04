import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kerupiah_lite_app/helpers/currency.dart';
import 'package:kerupiah_lite_app/helpers/time.dart';
import 'package:kerupiah_lite_app/screens/dashboard/balances/show_screen.dart';
import 'package:kerupiah_lite_app/services/balance.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class BalanceHomePageScreen extends StatefulWidget {
  const BalanceHomePageScreen({Key? key}) : super(key: key);

  @override
  _BalanceHomePageState createState() => _BalanceHomePageState();
}

class _BalanceHomePageState extends State<BalanceHomePageScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<bool> _onWillPop() async {
    context.go('/dashboard');

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/dashboard'),
            ),
            title: const Text('Mutasi Saldo'),
            bottom: const TabBar(
              tabs: [
                Tab(text: "Semua"),
                Tab(text: "Keluar"),
                Tab(text: "Masuk"),
              ],
            ),
          ),
          body: TabBarView(
            children: [BalanceAll(), BalanceOut(), BalanceIn()],
          ),
        ),
      ),
    );
  }
}

class BalanceAll extends StatefulWidget {
  const BalanceAll({Key? key}) : super(key: key);

  @override
  State<BalanceAll> createState() => _BalanceAllState();
}

class _BalanceAllState extends State<BalanceAll> {
  late List<dynamic> balances = List.empty();

  Future<void> getInitializeData() async {
    List<dynamic> items = await BalanceService().getMutations('');
    setState(() {
      balances = items;
    });
  }

  @override
  void initState() {
    super.initState();
    getInitializeData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(1, 1, 1, 1),
      child: ListView.builder(
        shrinkWrap: true,
        primary: false,
        itemCount: balances.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: (() async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShowBalanceScreen(
                    balanceId: balances[index]['id'].toString(),
                  ),
                ),
              );
            }),
            child: Container(
              margin: EdgeInsets.only(top: 5),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.grey),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          toDateTime(balances[index]['created_at'].toString()),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          balances[index]['message'].toString(),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 1,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          toRupiah(balances[index]['amount']),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          balances[index]['type'].toString() == 'IN'
                              ? 'Masuk'
                              : 'Keluar',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class BalanceOut extends StatefulWidget {
  const BalanceOut({Key? key}) : super(key: key);

  @override
  State<BalanceOut> createState() => _BalanceOutState();
}

class _BalanceOutState extends State<BalanceOut> {
  late List<dynamic> balances = List.empty();

  Future<void> getInitializeData() async {
    List<dynamic> items = await BalanceService().getMutations('OUT');
    setState(() {
      balances = items;
    });
  }

  @override
  void initState() {
    super.initState();
    getInitializeData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(1, 1, 1, 1),
      child: ListView.builder(
        shrinkWrap: true,
        primary: false,
        itemCount: balances.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: (() async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShowBalanceScreen(
                    balanceId: balances[index]['id'].toString(),
                  ),
                ),
              );
            }),
            child: Container(
              margin: EdgeInsets.only(top: 5),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.grey),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          toDateTime(balances[index]['created_at'].toString()),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          balances[index]['message'].toString(),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 1,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          toRupiah(balances[index]['amount']),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          balances[index]['type'].toString() == 'IN'
                              ? 'Masuk'
                              : 'Keluar',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class BalanceIn extends StatefulWidget {
  const BalanceIn({Key? key}) : super(key: key);

  @override
  State<BalanceIn> createState() => _BalanceInState();
}

class _BalanceInState extends State<BalanceIn> {
  late List<dynamic> balances = List.empty();

  Future<void> getInitializeData() async {
    List<dynamic> items = await BalanceService().getMutations('IN');
    setState(() {
      balances = items;
    });
  }

  @override
  void initState() {
    super.initState();
    getInitializeData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(1, 1, 1, 1),
      child: ListView.builder(
        shrinkWrap: true,
        primary: false,
        itemCount: balances.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: (() async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShowBalanceScreen(
                    balanceId: balances[index]['id'].toString(),
                  ),
                ),
              );
            }),
            child: Container(
              margin: EdgeInsets.only(top: 5),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.grey),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          toDateTime(balances[index]['created_at'].toString()),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          balances[index]['message'].toString(),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 1,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          toRupiah(balances[index]['amount']),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          balances[index]['type'].toString() == 'IN'
                              ? 'Masuk'
                              : 'Keluar',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
