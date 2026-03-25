import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'parent_auth_service.dart';

class ParentAdminScreen extends StatefulWidget {
  const ParentAdminScreen({super.key});

  @override
  State<ParentAdminScreen> createState() => _ParentAdminScreenState();
}

class _ParentAdminScreenState extends State<ParentAdminScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addDomainController = TextEditingController();
  String? _error;
  bool _loading = false;

  static const _docPath = 'config/allowlist';
  final _docRef = FirebaseFirestore.instance.doc(_docPath);

  Future<void> _signIn() async {
    setState(() { _loading = true; _error = null; });
    final err = await ParentAuthService.signIn(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    setState(() { _loading = false; _error = err; });
  }

  Future<void> _addDomain() async {
    final domain = _addDomainController.text.trim().toLowerCase();
    if (domain.isEmpty) return;
    await _docRef.update({
      'allowed_domains': FieldValue.arrayUnion([domain]),
    });
    _addDomainController.clear();
  }

  Future<void> _removeDomain(String domain) async {
    await _docRef.update({
      'allowed_domains': FieldValue.arrayRemove([domain]),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Controls'),
        actions: [
          if (ParentAuthService.isSignedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await ParentAuthService.signOut();
                setState(() {});
              },
            ),
        ],
      ),
      body: ParentAuthService.isSignedIn
          ? _adminPanel()
          : _loginPanel(),
    );
  }

  Widget _loginPanel() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock, size: 64, color: Colors.indigo),
          const SizedBox(height: 24),
          const Text('Parent Login', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
            obscureText: true,
          ),
          if (_error != null) ...[  
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _signIn,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Sign In'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _adminPanel() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _addDomainController,
                  decoration: const InputDecoration(
                    hintText: 'Add domain (e.g. example.com)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addDomain,
                child: const Text('Add'),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<DocumentSnapshot>(
            stream: _docRef.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final data = snapshot.data!.data() as Map<String, dynamic>?;
              final domains = List<String>.from(data?['allowed_domains'] ?? []);
              if (domains.isEmpty) {
                return const Center(child: Text('No domains allowed yet.'));
              }
              return ListView.builder(
                itemCount: domains.length,
                itemBuilder: (_, i) => ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text(domains[i]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeDomain(domains[i]),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
