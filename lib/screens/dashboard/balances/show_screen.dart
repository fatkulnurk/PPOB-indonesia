import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kerupiah_lite_app/widgets/web_view_render_html.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class ShowBalanceScreen extends StatefulWidget {
  final String balanceId;

  const ShowBalanceScreen({required this.balanceId, Key? key})
      : super(key: key);

  @override
  State<ShowBalanceScreen> createState() => _MyStatefulWidget();
}

class _MyStatefulWidget extends State<ShowBalanceScreen> {
  final controller = Completer<WebViewController>();
  String url = '';

  @override
  void initState() {
    super.initState();
    setState(() {
      url = 'https://kerupiah.com/api/web-views/balances/${widget.balanceId}';
      print(url);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // leading: IconButton(
          //   icon: const Icon(Icons.arrow_back),
          //   onPressed: () => {context.go('/dashboard/balances')},
          // ),
          actions: [
            IconButton(
              onPressed: () {
                context.go('/dashboard');
              },
              icon: Icon(Icons.home_outlined),
            )
          ],
          title: const Text("Detail Saldo"),
        ),
        body: SafeArea(
            child: WebViewRenderHtmlStack(
          controller: controller,
          url: url,
        )));
  }
}
