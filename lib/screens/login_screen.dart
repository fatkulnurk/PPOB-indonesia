import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth.dart';

class LoginPageScreen extends StatefulWidget {
  const LoginPageScreen({super.key});

  @override
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<LoginPageScreen> {
  Future<bool> _onWillPop() async {
    context.go('/');

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
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
      bool isLoggin = await AuthService().login(_email, _password);
      if (isLoggin) {
        context.go('/dashboard');
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
