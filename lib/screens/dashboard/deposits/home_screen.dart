import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:kerupiah_lite_app/helpers/currency.dart';
import 'package:kerupiah_lite_app/screens/dashboard/deposits/show_screen.dart';
import 'package:kerupiah_lite_app/services/deposit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kerupiah_lite_app/helpers/time.dart';

class DepositHomePageScreen extends StatefulWidget {
  const DepositHomePageScreen({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<DepositHomePageScreen> {
  late List<dynamic> deposits = List.empty();
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();

  Future<void> getDeposits() async {
    var response = await DepositService()
        .get(fromDateController.text, toDateController.text);

    if (response['success']) {
      setState(() {
        deposits = response['data'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getDeposits();
  }

  Future<bool> _onWillPop() async {
    context.go('/dashboard');

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/dashboard'),
          ),
          actions: [
            IconButton(
              onPressed: () => context.go("/dashboard/deposits/create"),
              icon: const Icon(Icons.add),
            )
          ],
          title: const Text("Riwayat Deposit"),
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
                                      DateFormat('yyyy-MM-dd')
                                          .format(pickedDate);
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
                        getDeposits();
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
                  if (fromDateController.text.isEmpty &&
                      toDateController.text.isEmpty)
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      alignment: Alignment.center,
                      child: const Card(
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: ListTile(
                          title: Text(
                              "Data yang kami tampilkan dibawah ini adalah data transaksi anda hari ini. Jika anda ingin melihat data lainnya, silakan gunakan menu filter data."),
                        ),
                      ),
                    ),
                  if (deposits.length > 0)
                    Container(
                      margin: const EdgeInsets.fromLTRB(1, 1, 1, 1),
                      child: ListView.builder(
                        shrinkWrap: true,
                        primary: false,
                        itemCount: deposits.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: (() async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ShowDepositScreen(
                                    id: deposits[index]['id'].toString(),
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
                                          toDateTime(
                                              deposits[index]['created_at']),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        const Text(
                                          "Deposit saldo:",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          toRupiah(deposits[index]['amount']),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 1,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          deposits[index]['payment_method']
                                                  ['name']
                                              .toString(),
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          deposits[index]['status_name']
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
                          title: Text("Data deposit kosong"),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

showAlertDialog(BuildContext context, String title, String message) {
  // set up the button
  Widget okButton = TextButton(
    child: Text("Tutup"),
    onPressed: () {
      Navigator.pop(context, true);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(message),
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
