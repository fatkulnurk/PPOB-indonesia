import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kerupiah_lite_app/helpers/currency.dart';
import 'package:kerupiah_lite_app/screens/dashboard/transactions/show_screen.dart';
import 'package:kerupiah_lite_app/services/payment_method.dart';
import 'package:kerupiah_lite_app/services/transaction.dart';

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
    Map<String, dynamic> data =
        await PaymentMethodService().get(price: widget.product['price']);

    if (data.isNotEmpty) {
      setState(() {
        balance = data['balance'];
        paymentMethods = data['data'];
      });
    }
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: new Text('Apakah anda yakin ingin kembali?'),
            content: new Text(
                'Jika kembali, data yang sudah anda inputkan akan dihapus.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('Tidak'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: new Text('Iya'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Rincian Pembelian: " + widget.product['name']),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Column(
                children: [
                  Card(
                    elevation: 3,
                    shadowColor: Colors.grey,
                    child: ListTile(
                      title: Text(
                        widget.product['name'].toString(),
                        style: const TextStyle(fontSize: 16),
                      ),
                      subtitle: Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.product['description'].toString(),
                              style: const TextStyle(fontSize: 16),
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
                      title: const Text(
                        "Nomor / Tujuan Pengisian",
                        style: TextStyle(fontSize: 16),
                      ),
                      subtitle: Text(
                        widget.customerNumber,
                        style: const TextStyle(fontSize: 16),
                      ),
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
                              margin:
                                  const EdgeInsets.only(top: 10, bottom: 10),
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
                                style:
                                    TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding:
                        const EdgeInsets.only(left: 3, top: 25, bottom: 10),
                    child: const Text(
                      'Pilih Metode Pembayaran',
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

                            if (response['success']) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ShowTransactionScreen(
                                      id: response['data']['id']),
                                ),
                              );
                            } else {
                              showAlertDialog(
                                  context,
                                  'Gagal melakukan pembelian',
                                  response['message'] ?? '');
                            }
                          }),
                          child: Container(
                            margin: EdgeInsets.only(top: 5),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Colors.blueAccent),
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
                                        paymentMethods[index]['name']
                                            .toString(),
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
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        )
                                      else
                                        const Text(
                                          "(24 Jam Tanpa Offline)",
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
