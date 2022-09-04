import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kerupiah_lite_app/widgets/web_view_render_html.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:kerupiah_lite_app/helpers/config.dart' as config;

class ShowDepositScreen extends StatefulWidget {
  final String id;

  const ShowDepositScreen({required this.id, Key? key}) : super(key: key);

  @override
  State<ShowDepositScreen> createState() => _MyStatefulWidget();
}

class _MyStatefulWidget extends State<ShowDepositScreen> {
  final controller = Completer<WebViewController>();
  String url = '';

  @override
  void initState() {
    super.initState();
    setState(() {
      url = '${config.baseUrl}/api/web-views/deposits/${widget.id}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard/deposits'),
        ),
        actions: [
          IconButton(
            onPressed: () => context.go('/dashboard'),
            icon: const Icon(Icons.home_outlined),
          )
        ],
        title: const Text("Rincian Deposit"),
      ),
      body: SafeArea(
        child: WebViewRenderHtmlStack(
          controller: controller,
          url: url,
        ),
      ),
    );
  }
}
