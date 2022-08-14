import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:kerupiah_lite_app/helpers/time.dart';
import 'package:kerupiah_lite_app/screens/dashboard/transactions/show_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionHomePageScreen extends StatefulWidget {
  const TransactionHomePageScreen({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<TransactionHomePageScreen> {
  late List<dynamic> transactions = List.empty();
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();

  Future<void> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final queryParameters = {
      'from_date': fromDateController.text,
      'to_date': toDateController.text,
    };
    var url = Uri.https('kerupiah.com', '/api/transactions', queryParameters);
    var response = await http.get(url, headers: <String, String>{
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> items = data['data'];
      setState(() {
        transactions = items;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        // actions: [
        //   IconButton(
        //     onPressed: () {},
        //     icon: const Icon(Icons.search),
        //   )
        // ],
        title: const Text("Riwayat Transaksi"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: TextField(
                          controller: fromDateController,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.calendar_today),
                            labelText: "Dari Tanggal",
                          ),
                          readOnly: true,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );

                            if (pickedDate != null) {
                              //pickedDate output format => 2021-03-10 00:00:00.000
                              // print(pickedDate);
                              String formattedDate =
                                  DateFormat('yyyy-MM-dd').format(pickedDate);
                              //formatted date output using intl package =>  2021-03-16
                              // print(formattedDate);

                              setState(() {
                                fromDateController.text = formattedDate;
                              });
                            } else {
                              // print("Date is not selected");
                            }
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: TextField(
                          controller: toDateController,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.calendar_today),
                            labelText: "Sampai Tanggal",
                          ),
                          readOnly: true,
                          onTap: () async {
                            var initDate = fromDateController.text;
                            if (initDate == null ||
                                initDate == '' ||
                                initDate.isEmpty) {
                            } else {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: (initDate != null)
                                    ? DateTime.parse(initDate)
                                    : DateTime.now(),
                                firstDate: (initDate != null)
                                    ? DateTime.parse(initDate)
                                    : DateTime.now(),
                                lastDate: DateTime.now(),
                              );

                              if (pickedDate != null) {
                                //pickedDate output format => 2021-03-10 00:00:00.000
                                // print(pickedDate);
                                String formattedDate =
                                    DateFormat('yyyy-MM-dd').format(pickedDate);
                                //formatted date output using intl package =>  2021-03-16
                                // print(formattedDate);

                                setState(() {
                                  toDateController.text = formattedDate;
                                });
                              } else {}
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  margin: EdgeInsets.all(1),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text('Tampilkan Data'),
                    onPressed: () {
                      getTransactions();
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    "Riwayat Transaksi:",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                if (fromDateController.text.isEmpty && toDateController.text.isEmpty)Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  alignment: Alignment.center,
                  child: const Card(
                    margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: ListTile(
                      title: Text("Data yang kami tampilkan dibawah ini adalah data transaksi anda hari ini. Jika anda ingin melihat data lainnya, silakan gunakan menu filter data."),
                    ),
                  ),
                ),
                if (transactions.length > 0)
                  Container(
                    margin: const EdgeInsets.fromLTRB(1, 1, 1, 1),
                    child: ListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: (() async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ShowTransactionScreen(
                                  id: transactions[index]['id'].toString(),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        transactions[index]['product']['name']
                                            .toString(),
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        transactions[index]['customer_no']
                                            .toString(),
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
                                        toDateTime(transactions[index]
                                            ['product']['created_at']),
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        transactions[index]['status_name']
                                            .toString(),
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
                  )
                else
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    alignment: Alignment.center,
                    child: const Card(
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: ListTile(
                        title: Text("Data transaksi kosong"),
                      ),
                    ),
                  ),
              ],
            ),
          ),
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
  late List<dynamic> transactions = List.empty();
  int transactionLength = 0;

  Future<void> getInitializeData() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    var url = Uri.parse('https://kerupiah.com/api/transactions');
    var response = await http.get(url, headers: <String, String>{
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> items = data['data'];
      setState(() {
        transactions = items;
        transactionLength = transactions.length;
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
        tiles: transactions.map(
          (transaction) => ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShowTransactionScreen(
                    id: transaction['id'].toString(),
                  ),
                ),
              );
            },
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              child:
                  Text(transaction['status_name'].toString().substring(0, 2)),
            ),
            title: Text(dateFormat
                .format(DateTime.parse(transaction['created_at'].toString()))),
            subtitle: Flexible(
              child: RichText(
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                strutStyle: const StrutStyle(
                    fontSize: 10.0, fontWeight: FontWeight.w500),
                text: TextSpan(
                  style: const TextStyle(color: Colors.black),
                  text: transaction['customer_no'].toString(),
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
                  text: transaction['status_name'].toString(),
                ),
              ),
            ),
          ),
        ),
      ).toList(),
    );
  }
}
