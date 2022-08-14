import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:kerupiah_lite_app/screens/dashboard/transactions/show_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionHomePageScreen extends StatefulWidget {
  const TransactionHomePageScreen({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<TransactionHomePageScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.search),
          )
        ],
        title: const Text("Transaksi"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            DefaultTabController(
              length: 6, // length of tabs
              initialIndex: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 1,
                    ),
                    child: Container(
                      child: TabBar(
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.blue,
                        indicatorColor: Colors.black,
                        tabs: [
                          Tab(text: 'Semua'),
                          Tab(text: 'Sukses'),
                          Tab(text: 'Dalam Proses'),
                          Tab(text: 'Menunggu Pembayaran'),
                          Tab(text: 'Gagal'),
                          Tab(text: 'Refund'),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height*0.68, //height of TabBarView
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: TabBarView(
                      children: <Widget>[
                        TransactionWidget(),
                        TransactionWidget(),
                        TransactionWidget(),
                        TransactionWidget(),
                        TransactionWidget(),
                        TransactionWidget(),
                        TransactionWidget(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class TransactionWidget extends StatefulWidget {
  const TransactionWidget({Key? key}) : super(key: key);

  @override
  State<TransactionWidget> createState() => _TransactionWidgetState();
}

class _TransactionWidgetState extends State<TransactionWidget> {
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
                      ShowTransactionScreen(
                        id: balance['id'].toString(),
                      ),
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