import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:http/http.dart' as http;
import 'package:kerupiah_lite_app/screens/dashboard/deposits/show_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateDepositScreen extends StatefulWidget {
  const CreateDepositScreen({super.key});

  @override
  State<StatefulWidget> createState() => _CreateDepositState();
}

class _CreateDepositState extends State<CreateDepositScreen> {
  List<dynamic> paymentMethods = [];
  TextEditingController amountController = TextEditingController();
  late String paymentMethod;
  String selectedPaymentMethod = '';

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  void initializeData() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    var url = Uri.parse(
        'https://kerupiah.com/api/payment-methods?without_balance=1&active=1');
    var responseCategory = await http.get(url, headers: <String, String>{
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });

    if (responseCategory.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(responseCategory.body);
      List<dynamic> items = data['data'];
      setState(() {
        paymentMethods = items;
      });
    }
  }

  void requestDeposit(String amount, String paymentMethodId) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    var url = Uri.parse('https://kerupiah.com/api/deposits');
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, String>{
        'amount': amount.toString(),
        'payment_method': paymentMethodId,
      }),
    );

    Map<String, dynamic> data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ShowDepositScreen(id: data['data']['id'].toString()),
        ),
      );
    } else {
      showAlertDialog(context, 'Deposit Gagal', data['message'] ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard/deposits'),
        ),
        actions: [
          IconButton(
            onPressed: () => context.go('/dashboard'),
            icon: const Icon(Icons.home_outlined),
          )
        ],
        title: const Text("Buat Deposit"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.all(10),
                child: TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Jumlah Deposit',
                  ),
                  onChanged: (text) {
                    setState(
                      () {},
                    );
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                child: DropdownButtonFormField(
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2),
                    ),
                    labelText: "Metode Pembayaran",
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  dropdownColor: Colors.white,
                  value: selectedPaymentMethod,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedPaymentMethod = newValue!;
                    });
                  },
                  items: <DropdownMenuItem<String>>[
                    const DropdownMenuItem(
                      value: "",
                      child: Text("Pilih metode pembayaran"),
                    ),
                    for (var payment in paymentMethods)
                      DropdownMenuItem(
                        value: payment['id'].toString(),
                        child: Text(payment['name'].toString()),
                      ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text('DEPOSIT'),
                  onPressed: () {
                    requestDeposit(
                        amountController.text, selectedPaymentMethod);
                  },
                ),
              ),
            ],
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
