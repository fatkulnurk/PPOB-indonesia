import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:kerupiah_lite_app/helpers/config.dart' as config;

class CategoryService {
  Future<List> get() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    var url = Uri.parse('${config.baseUrl}/api/categories');

    EasyLoading.show(status: 'loading...');
    var response = await http.get(url, headers: <String, String>{
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });

    if (response.statusCode == 200) {
      EasyLoading.dismiss();
      prefs.setString('categories_json', response.body);
      Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> items = data['data'];

      return items;
    } else {
      EasyLoading.dismiss();

      return [];
    }
  }
}