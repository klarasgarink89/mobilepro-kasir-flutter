import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laravel Project Browser',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LaravelBrowser(),
    );
  }
}

class LaravelBrowser extends StatefulWidget {
  const LaravelBrowser({super.key});

  @override
  State<LaravelBrowser> createState() => _LaravelBrowserState();
}

class _LaravelBrowserState extends State<LaravelBrowser> {
  late WebViewController _controller;
  bool _isLoading = true;
  final String _laravelUrl = 'http://192.168.0.6:8000'; // Fixed URL

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
            });
            _showErrorDialog(error.description);
          },
        ),
      )
      ..loadRequest(Uri.parse(_laravelUrl));
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text('Failed to load Laravel project.\n\nError: $message\n\n'
            'Please ensure:\n1. Laravel server is running\n'
            '2. Correct IP address\n3. Device is on the same network'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _reloadPage() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _controller.reload();
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POS - GEMINI CLUB'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reloadPage,
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _reloadPage,
        tooltip: 'Reload',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}