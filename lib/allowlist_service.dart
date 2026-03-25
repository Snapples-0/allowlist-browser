import 'dart:convert';
import 'package:flutter/services.dart';

class AllowlistService {
  static final AllowlistService _instance = AllowlistService._internal();
  factory AllowlistService() => _instance;
  AllowlistService._internal();

  List<String> _allowedDomains = [];

  /// Load allowlist from assets/allowlist.json
  Future<void> load() async {
    final String raw = await rootBundle.loadString('assets/allowlist.json');
    final Map<String, dynamic> data = jsonDecode(raw);
    _allowedDomains = List<String>.from(data['allowed_domains'] ?? []);
  }

  List<String> get allowedDomains => List.unmodifiable(_allowedDomains);

  /// Returns true if the URL's host matches any allowed domain (including subdomains).
  bool isAllowed(String url) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host.toLowerCase();
      return _allowedDomains.any((domain) {
        final d = domain.toLowerCase();
        return host == d || host.endsWith('.$d');
      });
    } catch (_) {
      return false;
    }
  }

  void addDomain(String domain) {
    final d = domain.toLowerCase().trim();
    if (d.isNotEmpty && !_allowedDomains.contains(d)) {
      _allowedDomains.add(d);
    }
  }

  void removeDomain(String domain) {
    _allowedDomains.remove(domain.toLowerCase().trim());
  }
}
