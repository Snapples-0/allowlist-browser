import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'allowlist_service.dart';
import 'blocked_screen.dart';
import 'parent_admin_screen.dart';

class BrowserScreen extends StatefulWidget {
  const BrowserScreen({super.key});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  final _urlController = TextEditingController();
  final _allowlist = AllowlistService();
  late final WebViewController _webViewController;
  bool _loaded = false;
  bool _isBlocked = false;
  String _blockedUrl = '';

  @override
  void initState() {
    super.initState();
    _allowlist.load().then((_) => setState(() => _loaded = true));

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (!_allowlist.isAllowed(request.url)) {
              setState(() {
                _isBlocked = true;
                _blockedUrl = request.url;
              });
              return NavigationDecision.prevent;
            }
            setState(() {
              _isBlocked = false;
              _urlController.text = request.url;
            });
            return NavigationDecision.navigate;
          },
        ),
      );
  }

  @override
  void dispose() {
    _allowlist.dispose();
    super.dispose();
  }

  void _navigate(String input) {
    String url = input.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    if (!_allowlist.isAllowed(url)) {
      setState(() {
        _isBlocked = true;
        _blockedUrl = url;
      });
      return;
    }
    setState(() => _isBlocked = false);
    _webViewController.loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _urlController,
          decoration: const InputDecoration(
            hintText: 'Enter a URL...',
            border: InputBorder.none,
          ),
          onSubmitted: _navigate,
          keyboardType: TextInputType.url,
          autocorrect: false,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'Parent Controls',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ParentAdminScreen()),
            ),
          ),
        ],
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : _isBlocked
              ? BlockedScreen(
                  blockedUrl: _blockedUrl,
                  onGoBack: () => setState(() => _isBlocked = false),
                )
              : WebViewWidget(controller: _webViewController),
    );
  }
}
