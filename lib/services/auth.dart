import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthService {
  Future<bool> logout() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    var url = Uri.parse('https://kerupiah.com/api/logout');
    var response = await http.post(url, headers: <String, String>{
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });

    if (response.statusCode == 200) {
      await prefs.clear();

      return true;
    }

    return false;
  }

  Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    var url = Uri.parse('https://kerupiah.com/api/login');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };
    var body = jsonEncode({'email': email ?? '', 'password': password ?? ''});
    var response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    Map<String, dynamic> data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      prefs.setString('token', data['data']['token']);
      prefs.setString('user_id', data['data']['user']['id']);
      prefs.setString('user_username', data['data']['user']['username']);
      prefs.setString('user_email', data['data']['user']['email']);
      prefs.setString('balance_string', data['data']['balance_string']);

      return true;
    }

    return false;
  }

  Future<Map<String, dynamic>> register(String name, String phoneNumber, String username,
      String email, String password, String refferal) async {
    final prefs = await SharedPreferences.getInstance();

    var url = Uri.parse('https://kerupiah.com/api/register');
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-type': 'application/json',
        'Accept': 'application/json',
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
