import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:kerupiah_lite_app/helpers/config.dart' as config;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AccountService {
  Future<Map<String, dynamic>> get() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    var url = Uri.parse('${config.baseUrl}/api/users');

    EasyLoading.show(status: 'loading ...');
    var response = await http.get(url, headers: <String, String>{
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });
    EasyLoading.dismiss();

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    }

    return {};
  }

  Future<bool> update(String name, String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    var url = Uri.parse('${config.baseUrl}/api/users');

    EasyLoading.show(status: 'loading ...');
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(
        <String, String>{'name': name, 'phone_number': phoneNumber},
      ),
    );
    EasyLoading.dismiss();

    print(response.body);
    if (response.statusCode == 200) {
      return true;
    }

    return false;
  }
}
