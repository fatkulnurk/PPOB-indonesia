import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:kerupiah_lite_app/helpers/config.dart' as config;

class BalanceService {
  Future<Map<String, dynamic>> get() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    var url = Uri.parse('${config.baseUrl}/api/balances');
    EasyLoading.show(status: 'loading...');

    var response = await http.get(url, headers: <String, String>{
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      EasyLoading.dismiss();

      return data;
    } else {
      EasyLoading.dismiss();

      return {};
    }
  }

  Future<List<dynamic>> getMutations(String type) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    var url = Uri.parse('https://kerupiah.com/api/balances-mutations?type=$type');

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
}
