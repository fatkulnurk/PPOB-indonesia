import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:kerupiah_lite_app/screens/dashboard/checkout_screen.dart';
import 'package:kerupiah_lite_app/services/group.dart';
import 'package:kerupiah_lite_app/services/product.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../helpers/currency.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key, required this.id, required this.categoryName})
      : super(key: key);
  final String id;
  final String categoryName;

  @override
  State<StatefulWidget> createState() => _OrderState();
}

class _OrderState extends State<OrderScreen> {
  TextEditingController customerNumberController = TextEditingController();
  List<dynamic> groups = [];
  List<dynamic> products = [];
  String selectedGroupId = '';
  Map<String, dynamic> group = {};
  bool _validate = false;

  @override
  void initState() {
    super.initState();
    initializeData();
    getProducts();
  }

  void initializeData() async {
    Map<String, dynamic> data = await GroupService().get(widget.id);
    if (data.isNotEmpty) {
      setState(() {
        groups = data['data'];
      });
    }
  }

  void getProducts() async {
    Map<String, dynamic> data = await ProductService().get(widget.id, selectedGroupId);
    if (data.isNotEmpty) {
      setState(() {
        products = data['data'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Beli ${widget.categoryName}"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            // height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(1, 20, 1, 5),
                  child: DropdownButtonFormField(
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                      labelText: "Pilih Group atau Brand",
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    dropdownColor: Colors.white,
                    value: selectedGroupId,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedGroupId = newValue!;
                        group = groups.firstWhere(
                            (element) => element['id'] == selectedGroupId);
                      });

                      getProducts();
                    },
                    items: <DropdownMenuItem<String>>[
                      const DropdownMenuItem(
                        value: "",
                        child: Text("Pilih Group Produk"),
                      ),
                      for (var group in groups)
                        DropdownMenuItem(
                          value: group['id'].toString(),
                          child: Text(
                            group['name'].toString(),
                          ),
                        ),
                    ],
                  ),
                ),
                if (group.isNotEmpty)
                  if (group['label'] != null)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.yellowAccent,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.black),
                      ),
                      margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                      child: ListTile(
                        title: Container(
                          padding: const EdgeInsets.only(top: 5, bottom: 5),
                          child: const Text(
                            "Catatan:",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        subtitle: Container(
                          padding: const EdgeInsets.only(top: 0, bottom: 10),
                          child: Text(
                            "Pada bagian Tujuan Pengisian / Nomor Pelanggan. ${group['label']}",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                Container(
                  margin: const EdgeInsets.fromLTRB(1, 10, 1, 15),
                  child: TextField(
                    controller: customerNumberController,
                    decoration: InputDecoration(
                      errorText: _validate ? "Tujuan Pengisian / Nomor Pelanggan harus disini." : null,
                      border: OutlineInputBorder(),
                      labelText: 'Tujuan Pengisian / Nomor Pelanggan',
                    ),
                    onChanged: (text) {
                      setState(() {});
                    },
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 3, top: 10, bottom: 10),
                  child: const Text(
                    'Pilih Nominal',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                if (products.length > 0)
                  Container(
                    margin: EdgeInsets.all(1),
                    child: ListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: (() {
                            setState(() {
                              customerNumberController.text.isEmpty ? _validate = true : _validate = false;
                            });

                            if (customerNumberController.text.isNotEmpty) {
                              if (products[index]['is_available']) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CheckoutScreen(
                                      product: products[index],
                                      customerNumber:
                                      customerNumberController.text,
                                    ),
                                  ),
                                );
                              }
                            }
                          }),
                          child: Container(
                            margin: EdgeInsets.only(top: 5),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: (products[index]['is_available'])
                                  ? Colors.white
                                  : Colors.yellowAccent,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        products[index]['name'].toString(),
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        products[index]['description']
                                            .toString(),
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      if (!products[index]['is_available'])
                                        const Text(
                                          '[Produk sedang gangguan]',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.red,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  alignment: Alignment.centerRight,
                                  // width: 55,
                                  child: Text(
                                    toRupiah(products[index]['price']),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                    alignment: Alignment.center,
                    child: Card(
                      elevation: 3,
                      shadowColor: Colors.grey,
                      child: ListTile(
                        title: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(top: 15, bottom: 15),
                          child: const Text(
                            "Produk akan ditampilkan setelah anda sudah memilih Group atau Brand.",
                            style: TextStyle(),
                          ),
                        ),
                      ),
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
