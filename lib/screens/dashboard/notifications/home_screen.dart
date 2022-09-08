import 'package:flutter/material.dart';

class NotificationHomePageScreen extends StatefulWidget {
  const NotificationHomePageScreen({Key? key}) : super(key: key);

  @override
  _NotificationHomePageState createState() => _NotificationHomePageState();
}

class _NotificationHomePageState extends State<NotificationHomePageScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pemberitahuan"),
      ),
      body: Text('aaa')
    );
  }
}