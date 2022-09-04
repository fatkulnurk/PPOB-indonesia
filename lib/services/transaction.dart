import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:kerupiah_lite_app/helpers/config.dart' as config;

class TransactionService {
  Future<List<dynamic>> get(String fromDate, String toDate) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    var url = Uri.parse('${config.baseUrl}/api/transactions?from_date=${fromDate}&to_date=${toDate}');

    EasyLoading.show(status: 'loading...');
    var response = await http.get(url, headers: <String, String>{
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> items = data['data'];
      EasyLoading.dismiss();

      return items;
    } else {
      EasyLoading.dismiss();

      return [];
    }
  }

  Future<Map<String, dynamic>> order(String productId, String customerNumber, String paymentId) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    var url = Uri.parse('${config.baseUrl}/api/orders');

    EasyLoading.show(status: 'loading...');
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(
        <String, String>{
          'product': productId,
          'payment': paymentId,
          'customer_number': customerNumber,
        },
      ),
    );

    Map<String, dynamic> data = jsonDecode(response.body);
    Map<String, dynamic> responseData = {};
    if (response.statusCode == 200) {
      EasyLoading.dismiss();
      responseData = {'success': true, 'data': data['data']};
    } else {
      EasyLoading.dismiss();
      responseData = {'success': false, 'message': data['message']};
    }

    return responseData;
  }
}
