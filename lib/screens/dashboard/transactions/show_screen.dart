import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kerupiah_lite_app/widgets/web_view_stack.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:kerupiah_lite_app/widgets/navigation_controls.dart';
import 'package:kerupiah_lite_app/helpers/config.dart' as config;

class ShowTransactionScreen extends StatefulWidget {
  const ShowTransactionScreen({Key? key, required this.id}) : super(key: key);
  final String id;

  @override
  _ShowPageState createState() => _ShowPageState();
}

class _ShowPageState extends State<ShowTransactionScreen> {
  final controller = Completer<WebViewController>();
  String url = '';

  @override
  void initState() {
    super.initState();
    setState(() {
      url = '${config.baseUrl}/invoices/${widget.id}';
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
          leading: IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => context.go('/dashboard'),
          ),
          actions: [NavigationRefreshControl(controller: controller)],
          title: const Text("Detail Transaksi"),
        ),
        body: SafeArea(
          child: WebViewStack(
            controller: controller,
            url: url,
          ),
        ),
      ),
    );
  }
}
