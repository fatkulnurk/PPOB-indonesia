import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:kerupiah_lite_app/helpers/config.dart' as config;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:kerupiah_lite_app/helpers/config.dart' as config;

class DepositService {
  Future<Map<String, dynamic>> get(String? fromDate, String? toDate) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    var url = Uri.parse('${config.baseUrl}/api/deposits?from_date=${fromDate!}&to_date=${toDate!}');

    EasyLoading.show(status: 'loading...');
    var response = await http.get(url, headers: <String, String>{
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Version': config.appVersion
    });
    Map<String, dynamic> responseData = {};
    Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      responseData = {"success": true, "data": data['data']};
    } else {
      responseData = {"success": false, "data": data['message']};
    }
    EasyLoading.dismiss();

    return responseData;
  }

  Future<Map<String, dynamic>> create(String amount, String paymentMethodId) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    var url = Uri.parse('${config.baseUrl}/api/deposits');

    EasyLoading.show(status: 'loading...');
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Version': config.appVersion
      },
      body: jsonEncode(
        <String, String>{
          'payment_method': paymentMethodId,
          'amount': amount
        },
      ),
    );

    Map<String, dynamic> responseData = {};
    Map<String, dynamic> data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      responseData = {"success": true, "data": data['data']};
    } else {
      responseData = {"success": false, "message": data['message']};
    }
    EasyLoading.dismiss();

    return responseData;
  }
}
