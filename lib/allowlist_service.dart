import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllowlistService {
  static final AllowlistService _instance = AllowlistService._internal();
  factory AllowlistService() => _instance;
  AllowlistService._internal();

  static const _cacheKey = 'cached_allowlist';
  static const _firestoreDoc = 'config/allowlist';

  List<String> _allowedDomains = [];
  StreamSubscription? _subscription;

  List<String> get allowedDomains => List.unmodifiable(_allowedDomains);

  /// Load from Firestore with real-time updates.
  /// Falls back to local cache if offline.
  Future<void> load() async {
    await _loadFromCache();
    _subscribeToFirestore();
  }

  Future<void> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw != null) {
      _allowedDomains = List<String>.from(jsonDecode(raw));
    }
  }

  void _subscribeToFirestore() {
    final docRef = FirebaseFirestore.instance.doc(_firestoreDoc);
    _subscription = docRef.snapshots().listen((snapshot) async {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        _allowedDomains = List<String>.from(data['allowed_domains'] ?? []);
        // Persist latest list to cache for offline use
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheKey, jsonEncode(_allowedDomains));
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
  }

  /// Strict exact-match only — subdomains are NOT allowed automatically.
  bool isAllowed(String url) {
    try {
      final host = Uri.parse(url).host.toLowerCase();
      return _allowedDomains.any((d) => host == d.toLowerCase());
    } catch (_) {
      return false;
    }
  }
}
