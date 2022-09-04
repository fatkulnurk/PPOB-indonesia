import 'dart:ffi';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:kerupiah_lite_app/helpers/config.dart' as config;

class PaymentMethodService {
  Future<Map<String, dynamic>> get({
    dynamic price = 0,
    int withoutBalance = 0,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    var url = Uri.parse(
        '${config.baseUrl}/api/payment-methods?without_balance=$withoutBalance&active=1&amount=$price');

    EasyLoading.show(status: 'loading...');
    var response = await http.get(url, headers: <String, String>{
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });
    EasyLoading.dismiss();

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);

      print(url);
      print(data);
      return data;
    }

    return {};
  }
}
