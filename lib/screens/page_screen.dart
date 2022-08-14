import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kerupiah_lite_app/widgets/web_view_stack.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PageWebviewScreen extends StatefulWidget {
  const PageWebviewScreen({super.key, required this.url, required this.title});

  final String url;
  final String title;

  @override
  State<StatefulWidget> createState() => _PageWebviewState();
}

class _PageWebviewState extends State<PageWebviewScreen> {
  final controller = Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => {
            context.go('/dashboard')
          },
        ),
        title: Text(widget.title),
      ),
      body: WebViewStack(controller: controller, url: widget.url),
    );
  }
}
