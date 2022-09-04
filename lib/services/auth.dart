import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:kerupiah_lite_app/helpers/config.dart' as config;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthService {
  Future<bool> check() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    var url = Uri.parse('${config.baseUrl}/api/check');

    EasyLoading.show(status: 'check session');
    var response = await http.get(url, headers: <String, String>{
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });
    EasyLoading.dismiss();

    if (response.statusCode == 200) {
      return true;
    }

    return false;
  }

  Future<bool> logout() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    var url = Uri.parse('${config.baseUrl}/api/logout');
    var response = await http.post(url, headers: <String, String>{
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Version': config.appVersion
    });

    if (response.statusCode == 200) {
      await prefs.clear();

      return true;
    }

    return false;
  }

  Future<bool> login(String email, String password) async {
    EasyLoading.show(status: 'loading...');
    final fcmToken = await FirebaseMessaging.instance.getToken();
    final prefs = await SharedPreferences.getInstance();
    var url = Uri.parse('${config.baseUrl}/api/login');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Version': config.appVersion
    };
    var body = jsonEncode(
      {'email': email ?? '', 'password': password ?? '', 'token': fcmToken},
    );
    var response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    EasyLoading.dismiss();

    Map<String, dynamic> data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      prefs.setString('token', data['data']['token']);
      prefs.setString('user_id', data['data']['user']['id']);
      prefs.setString('user_username', data['data']['user']['username']);
      prefs.setString('user_email', data['data']['user']['email']);
      prefs.setString('balance_string', data['data']['balance_string']);
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Berhasil masuk ke akun!');

      return true;
    } else {
      EasyLoading.showError("Gagal: " + data['message']);
      return false;
    }
  }

  Future<Map<String, dynamic>> register(String name, String phoneNumber,
      String username, String email, String password, String refferal) async {
    final prefs = await SharedPreferences.getInstance();

    var url = Uri.parse('${config.baseUrl}/api/register');
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Version': config.appVersion
      },
      body: jsonEncode(
        <String, String>{
          'name': name,
          'phone_number': phoneNumber,
          'username': username,
          'email': email,
          'password': password,
          'refferal': refferal,
        },
      ),
    );

    Map<String, dynamic> data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      prefs.setString('token', data['data']['token']);
      prefs.setString('user_id', data['data']['user']['id']);
      prefs.setString('user_username', data['data']['user']['username']);
      prefs.setString('user_email', data['data']['user']['email']);
      prefs.setString('balance_string', data['data']['balance_string']);

      Map<String, dynamic> responseData = {
        'success': true,
        'data': data['data']
      };

      return responseData;
    }

    Map<String, dynamic> responseData = {
      'success': false,
      'message': data['message']
    };

    return responseData;
  }
}
