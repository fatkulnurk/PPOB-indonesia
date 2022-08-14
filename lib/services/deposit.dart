import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DepositService {
  Future<Map<String, dynamic>> get(String? fromDate, String? toDate) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final queryParameters = {
      'from_date': fromDate,
      'to_date': toDate,
    };
    var url = Uri.https('kerupiah.com', '/api/deposits', queryParameters);
    var response = await http.get(url, headers: <String, String>{
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });
    Map<String, dynamic> responseData = {};
    Map<String, dynamic> data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      responseData = {"success": true, "data": data['data']};
    } else {
      responseData = {"success": false, "data": data['message']};
    }
    
    return responseData;
  }

  Future<Map<String, dynamic>> create(String amount, String paymentMethodId) async {
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
      responseData = {"success": false, "data": data['message']};
    }

    return responseData;
  }
}
