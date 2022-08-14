import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kerupiah_lite_app/helpers/currency.dart';
import 'package:kerupiah_lite_app/screens/dashboard/transactions/show_screen.dart';
import 'package:kerupiah_lite_app/services/transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen(
      {super.key, required this.customerNumber, required this.product});

  final String customerNumber;
  final Map<String, dynamic> product;

  @override
  State<StatefulWidget> createState() => _CheckoutState();
}

class _CheckoutState extends State<CheckoutScreen> {
  List<dynamic> paymentMethods = [];
  int balance = 0;

  @override
  void initState() {
    super.initState();
    getPaymentMethods();
  }

  void getPaymentMethods() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    var url = Uri.parse(
        'https://kerupiah.com/api/payment-methods?active=1&amount=${widget.product['price']}');
    var response = await http.get(url, headers: <String, String>{
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      setState(() {
        balance = data['balance'];
        paymentMethods = data['data'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rincian Pembelian: " + widget.product['name']),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
            child: Column(
              children: [
                Card(
                  elevation: 3,
                  shadowColor: Colors.grey,
                  child: ListTile(
                    title: Text(widget.product['name'].toString()),
                    subtitle: Column(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.product['description'].toString(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 3,
                  shadowColor: Colors.grey,
                  child: ListTile(
                    title: Text("Nomor / Tujuan Pengisian"),
                    subtitle: Text(widget.customerNumber),
                  ),
                ),
                if (widget.product['price'] > 0)
                  Card(
                    elevation: 3,
                    shadowColor: Colors.grey,
                    child: ListTile(
                      title: Container(
                        margin: const EdgeInsets.only(top: 5, bottom: 0),
                        alignment: Alignment.center,
                        child: const Text(
                          "TOTAL HARGA",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      subtitle: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 10, bottom: 10),
                            alignment: Alignment.center,
                            child: Text(
                              toRupiah(widget.product['price']),
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 1, bottom: 10),
                            alignment: Alignment.center,
                            child: const Text(
                              "Total harga diatas belum termasuk total dengan kode unik",
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 3, top: 25, bottom: 10),
                  child: const Text(
                    'Metode Pembayaran',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(1, 1, 1, 1),
                  child: ListView.builder(
                    shrinkWrap: true,
                    primary: false,
                    itemCount: paymentMethods.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: (() async {
                          Map<String, dynamic> response =
                              await TransactionService().order(
                                  widget.product['id'],
                                  widget.customerNumber,
                                  paymentMethods[index]['id']);

                          print(response);
                          if(response['success']) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ShowTransactionScreen(id: response['data']['id']),
                              ),
                            );
                          } else {
                            showAlertDialog(
                                context, 'Gagal melakukan pembelian', response['message'] ?? '');
                          }
                        }),
                        child: Container(
                          margin: EdgeInsets.only(top: 5),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.blueAccent),
                            // boxShadow: [
                            //   BoxShadow(color: Colors.red, spreadRadius: 1),
                            // ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      paymentMethods[index]['name'].toString(),
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    if (paymentMethods[index]['is_balance'])
                                      Container(
                                        padding: EdgeInsets.only(top: 3),
                                        child: Text(
                                          "Sisa Saldo Anda: " +
                                              toRupiah(balance),
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      )
                                    else
                                      Text(
                                        "Untuk menggunakan metode pembayaran ini, minimum tagihan adalah " +
                                            toRupiah(paymentMethods[index]
                                                ['min_amount']),
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Container(
                                alignment: Alignment.centerRight,
                                width: 45,
                                child: Image.network(paymentMethods[index]
                                        ['logo_url']
                                    .toString()),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
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
