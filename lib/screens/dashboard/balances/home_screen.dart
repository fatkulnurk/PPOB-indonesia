import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kerupiah_lite_app/screens/dashboard/balances/show_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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

  @override
  Widget build(BuildContext context) {
    var textStyle = Theme.of(context).textTheme;
    final dateFormat = DateFormat('yyyy-MM-dd hh:mm');

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/dashboard'),
          ),
          // actions: [
          //   IconButton(
          //     onPressed: () {},
          //     icon: Icon(Icons.date_range),
          //   )
          // ],
          title: const Text('Mutasi Saldo'),
          bottom: TabBar(
            tabs: [
              GestureDetector(
                child: const Tab(
                  text: "Semua",
                ),
                onTap: () {
                },
              ),
              GestureDetector(
                child: const Tab(
                  text: "Keluar",
                ),
                onTap: () {
                },
              ),
              GestureDetector(
                child: const Tab(
                  text: "Masuk",
                ),
                onTap: () {
                },
              )
            ],
          ),
        ),
        body: const TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            BalanceAll(),
            BalanceOut(),
            BalanceIn(),
          ],
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
  int balanceLength = 0;

  Future<void> getInitializeData() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    var url = Uri.parse('https://kerupiah.com/api/balances-mutations');
    var response = await http.get(url, headers: <String, String>{
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> items = data['data'];
      setState(() {
        balances = items;
        balanceLength = balances.length;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getInitializeData();
  }

  @override
  Widget build(BuildContext context) {
    var textStyle = Theme.of(context).textTheme;
    final dateFormat = DateFormat('yyyy-MM-dd hh:mm');

    return ListView(
      children: ListTile.divideTiles(
        color: Colors.deepPurple,
        tiles: balances.map(
              (balance) => ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ShowBalanceScreen(balanceId: balance['id'].toString()),
                ),
              );
            },
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              child: Text(balance['type'].toString()),
            ),
            title: Text(dateFormat
                .format(DateTime.parse(balance['created_at'].toString()))),
            subtitle: Flexible(
              child: RichText(
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                strutStyle: const StrutStyle(
                    fontSize: 10.0, fontWeight: FontWeight.w500),
                text: TextSpan(
                  style: const TextStyle(color: Colors.black),
                  text: balance['message'].toString(),
                ),
              ),
            ),
            trailing: Flexible(
              child: RichText(
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                strutStyle: const StrutStyle(fontSize: 12.0),
                text: TextSpan(
                  style: const TextStyle(color: Colors.black),
                  text: balance['amount'].toString(),
                ),
              ),
            ),
          ),
        ),
      ).toList(),
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
  int balanceLength = 0;

  Future<void> getInitializeData() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    var url = Uri.parse('https://kerupiah.com/api/balances-mutations?type=OUT');
    var response = await http.get(url, headers: <String, String>{
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> items = data['data'];
      setState(() {
        balances = items;
        balanceLength = balances.length;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getInitializeData();
  }

  @override
  Widget build(BuildContext context) {
    var textStyle = Theme.of(context).textTheme;
    final dateFormat = DateFormat('yyyy-MM-dd hh:mm');

    return ListView(
      children: ListTile.divideTiles(
        color: Colors.deepPurple,
        tiles: balances.map(
          (balance) => ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ShowBalanceScreen(balanceId: balance['id'].toString()),
                ),
              );
            },
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              child: Text(balance['type'].toString()),
            ),
            title: Text(dateFormat
                .format(DateTime.parse(balance['created_at'].toString()))),
            subtitle: Flexible(
              child: RichText(
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                strutStyle: const StrutStyle(
                    fontSize: 10.0, fontWeight: FontWeight.w500),
                text: TextSpan(
                  style: const TextStyle(color: Colors.black),
                  text: balance['message'].toString(),
                ),
              ),
            ),
            trailing: Flexible(
              child: RichText(
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                strutStyle: const StrutStyle(fontSize: 12.0),
                text: TextSpan(
                  style: const TextStyle(color: Colors.black),
                  text: balance['amount'].toString(),
                ),
              ),
            ),
          ),
        ),
      ).toList(),
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
  int balanceLength = 0;

  Future<void> getInitializeData() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    var url = Uri.parse('https://kerupiah.com/api/balances-mutations?type=IN');
    var response = await http.get(url, headers: <String, String>{
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> items = data['data'];
      setState(() {
        balances = items;
        balanceLength = balances.length;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getInitializeData();
  }

  @override
  Widget build(BuildContext context) {
    var textStyle = Theme.of(context).textTheme;
    final dateFormat = DateFormat('yyyy-MM-dd hh:mm');

    return ListView(
      children: ListTile.divideTiles(
        color: Colors.deepPurple,
        tiles: balances.map(
              (balance) => ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ShowBalanceScreen(balanceId: balance['id'].toString()),
                ),
              );
            },
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              child: Text(balance['type'].toString()),
            ),
            title: Text(dateFormat
                .format(DateTime.parse(balance['created_at'].toString()))),
            subtitle: Flexible(
              child: RichText(
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                strutStyle: const StrutStyle(
                    fontSize: 10.0, fontWeight: FontWeight.w500),
                text: TextSpan(
                  style: const TextStyle(color: Colors.black),
                  text: balance['message'].toString(),
                ),
              ),
            ),
            trailing: Flexible(
              child: RichText(
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                strutStyle: const StrutStyle(fontSize: 12.0),
                text: TextSpan(
                  style: const TextStyle(color: Colors.black),
                  text: balance['amount'].toString(),
                ),
              ),
            ),
          ),
        ),
      ).toList(),
    );
  }
}
