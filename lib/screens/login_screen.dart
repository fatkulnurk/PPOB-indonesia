import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginPageScreen extends StatefulWidget {
  const LoginPageScreen({super.key});

  @override
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<LoginPageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.yellowAccent,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: (() {
            context.go('/');
          }),
        ),
        title: const Text('Masuk'),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomLeft,
              colors: [
                Colors.white,
                Colors.white,
              ],
            ),
          ),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.fromLTRB(0, 30, 0, 10),
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(5),
                child: FormWidget(),
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white70,
                    ),
                    child: const Text('Belum punya akun? Mendaftar sekarang'),
                  ),
                ),
                onTap: (() {
                  context.go('/signup');
                }),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class FormWidget extends StatefulWidget {
  const FormWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FormWidgetState();
}

class _FormWidgetState extends State<FormWidget> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      final prefs = await SharedPreferences.getInstance();
      var url = Uri.parse('https://kerupiah.com/api/login');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      };
      var body = jsonEncode({
        'email': _email ?? '',
        'password': _password ?? '',
        'firebase_key': fcmToken
      });
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
        context.go('/dashboard');
      } else {
        showAlertDialog(context, 'Gagal Masuk', data['message'] ?? '');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: TextFormField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              // use the validator to return an error string (or null) based on the input text
              validator: (text) {
                if (text == null || text.isEmpty) {
                  return 'Tidak boleh kosong';
                }

                if (text.length < 4) {
                  return 'Terlalu pendek';
                }

                return null;
              },
              // update the state variable when the text changes
              onChanged: (text) => setState(() => _email = text),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: TextFormField(
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Kata Sandi',
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              // use the validator to return an error string (or null) based on the input text
              validator: (text) {
                if (text == null || text.isEmpty) {
                  return 'Tidak boleh kosong';
                }

                if (text.length < 4) {
                  return 'Terlalu pendek';
                }

                return null;
              },
              // update the state variable when the text changes
              onChanged: (text) => setState(() => _password = text),
            ),
          ),
          Container(
            height: 80,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
            child: ElevatedButton(
              // only enable the button if the text is not empty
              onPressed:
                  _email.isNotEmpty && _password.isNotEmpty ? _submit : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: Text('Masuk'),
            ),
          ),
        ],
      ),
    );
  }
}

showAlertDialog(BuildContext context, String title, String message) {
  // set up the button
  Widget okButton = TextButton(
    child: Text("Tutup"),
    onPressed: () {
      Navigator.pop(context, true);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(message),
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
