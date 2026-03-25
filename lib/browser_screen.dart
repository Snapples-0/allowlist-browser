import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'allowlist_service.dart';
import 'blocked_screen.dart';

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
    _allowlist.load().then((_) {
      setState(() => _loaded = true);
    });

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

  void _showManageAllowlist() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AllowlistManager(
        allowlist: _allowlist,
        onChanged: () => setState(() {}),
      ),
    );
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
            icon: const Icon(Icons.list),
            tooltip: 'Manage Allowlist',
            onPressed: _showManageAllowlist,
          ),
        ],
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : _isBlocked
              ? BlockedScreen(blockedUrl: _blockedUrl, onGoBack: () => setState(() => _isBlocked = false))
              : WebViewWidget(controller: _webViewController),
    );
  }
}

class _AllowlistManager extends StatefulWidget {
  final AllowlistService allowlist;
  final VoidCallback onChanged;
  const _AllowlistManager({required this.allowlist, required this.onChanged});

  @override
  State<_AllowlistManager> createState() => _AllowlistManagerState();
}

class _AllowlistManagerState extends State<_AllowlistManager> {
  final _addController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final domains = widget.allowlist.allowedDomains;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Manage Allowlist', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ...domains.map((d) => ListTile(
                title: Text(d),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    widget.allowlist.removeDomain(d);
                    widget.onChanged();
                    setState(() {});
                  },
                ),
              )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addController,
                    decoration: const InputDecoration(
                      hintText: 'Add domain (e.g. example.com)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    widget.allowlist.addDomain(_addController.text);
                    _addController.clear();
                    widget.onChanged();
                    setState(() {});
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
