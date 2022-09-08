import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:kerupiah_lite_app/services/account.dart';
import 'package:kerupiah_lite_app/services/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileHomePageScreen extends StatefulWidget {
  const ProfileHomePageScreen({Key? key}) : super(key: key);

  @override
  _ProfileHomePageState createState() => _ProfileHomePageState();
}

class _ProfileHomePageState extends State<ProfileHomePageScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    initializeData();
    super.initState();
  }

  void initializeData() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> account = await AccountService().get();

    setState(() {
      emailController.text = prefs.getString('user_email')!;
      usernameController.text = prefs.getString('user_username')!;
      if(account.isNotEmpty) {
        nameController.text = account['data']['name'];
        phoneNumberController.text = account['data']['phone_number'];
      }
    });
  }

  Future<bool> _onWillPop() async {
    context.go('/dashboard');
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Akun"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/dashboard'),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 15, 10, 10),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Nama Lengkap',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: phoneNumberController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Nomor Telepon',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: usernameController,
                        enabled: false,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Username',
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: emailController,
                        enabled: false,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Email',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50), // NEW
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              bool isSuccess = await AccountService().update(
                                  nameController.text,
                                  phoneNumberController.text,
                              );

                              if(isSuccess) {
                                EasyLoading.showSuccess("Berhasil memperbarui data.");
                              } else {
                                EasyLoading.showError('Gagal memperbarui data.');
                              }
                            }
                          },
                          child: const Text(
                            'Update Akun',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () async {
                      EasyLoading.show(status: 'Sedang mengeluarkan akun');
                      bool isSuccess = await AuthService().logout();

                      if (isSuccess) {
                        EasyLoading.dismiss();
                        context.go('/');
                      } else {
                        EasyLoading.dismiss();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Gagal mengeluarkan akun'),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Keluarkan Akun',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
