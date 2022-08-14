import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class TransactionService {
  Future<Map<String, dynamic>> order(String productId, String customerNumber, String paymentId) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    var url = Uri.parse('https://kerupiah.com/api/orders');
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
    print(data);
    if (response.statusCode == 200) {
      responseData = {'success': true, 'data': data['data']};
    } else {
      responseData = {'success': false, 'message': data['message']};
    }

    return responseData;
  }
}
