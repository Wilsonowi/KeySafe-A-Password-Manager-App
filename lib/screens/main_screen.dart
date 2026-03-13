import 'package:flutter/material.dart';
import 'add_entry_screen.dart';
import 'dart:convert'; // for jsonEncode/jsonDecode
import 'package:shared_preferences/shared_preferences.dart'; // for storage
import '../services/encryption_service.dart';

// ── Data class — just holds data, like a struct in C ──
class PasswordEntry {
  String siteName;
  String username;
  String password;

  PasswordEntry({
    required this.siteName,
    required this.username,
    required this.password,
  });

  // convert entry → Map (so we can encode to JSON)
  Map<String, dynamic> toJson() {
    return {'siteName': siteName, 'username': username, 'password': password};
  }

  // convert Map → entry (so we can decode from JSON)
  factory PasswordEntry.fromJson(Map<String, dynamic> json) {
    return PasswordEntry(
      siteName: json['siteName'],
      username: json['username'],
      password: json['password'],
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // ── List lives here inside state, not global ──
  List<PasswordEntry> _entries = [];
  List<bool> _passwordVisible = [];

  @override
  void initState() {
    super.initState();
    _loadEntries(); // load saved entries on startup
  }

  // ── Add a new entry ──
  void _addEntry(String siteName, String username, String password) {
    setState(() {
      _entries.add(
        PasswordEntry(
          siteName: siteName,
          username: username,
          password: EncryptionService.encryptPassword(
            password,
          ), // ← encrypt before storing
        ),
      );
      _passwordVisible.add(false);
    });
    _saveEntries();
  }

  void _editEntry(
    int index,
    String siteName,
    String username,
    String password,
  ) {
    setState(() {
      _entries[index].siteName = siteName;
      _entries[index].username = username;
      _entries[index].password = EncryptionService.encryptPassword(
        password,
      ); // ← encrypt
    });
    _saveEntries();
  }

  // ── Delete entry by index ──
  void _deleteEntry(int index) {
    setState(() {
      _entries.removeAt(index);
      _passwordVisible.removeAt(index); // ← add this
    });
    _saveEntries(); // save after deleting
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: const Text(
          'Delete Entry',
          style: TextStyle(color: Color(0xFFE2E8F0)),
        ),
        content: Text(
          'Delete "${_entries[index].siteName}"? This cannot be undone.',
          style: const TextStyle(color: Color(0xFF6B7280)),
        ),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          // Confirm delete button
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog first
              _deleteEntry(index); // then delete
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFF87171)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Save all entries to device ──
  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();

    // convert each entry to JSON, then encode the whole list
    final jsonList = _entries.map((e) => e.toJson()).toList();
    final jsonString = jsonEncode(jsonList);

    await prefs.setString('entries', jsonString);
  }

  // ── Load entries from device ──
  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('entries');

    // if nothing saved yet, do nothing
    if (jsonString == null) return;

    final jsonList = jsonDecode(jsonString) as List;

    setState(() {
      _entries = jsonList
          .map((e) => PasswordEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      _passwordVisible = List.generate(_entries.length, (_) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D14),
        title: const Text(
          'KeySafe',
          style: TextStyle(
            color: Color(0xFFE2E8F0),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _entries.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 64, color: Color(0xFF2E2E45)),
                  SizedBox(height: 16),
                  Text(
                    'No passwords yet',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                  Text(
                    'Tap + to add one',
                    style: TextStyle(color: Color(0xFF3D3D5C)),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _entries.length, // how many items in the list
              itemBuilder: (context, index) {
                // this runs once per item, like a for loop
                // index = current position (0, 1, 2...)
                final entry = _entries[index];
                return _card(entry, index);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // navigate to AddEntryScreen and wait for result
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEntryScreen()),
          );

          // result is the Map we sent back with Navigator.pop
          if (result != null) {
            _addEntry(
              result['siteName'],
              result['username'],
              result['password'],
            );
          }
        },
        backgroundColor: const Color(0xFF6366F1),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _card(PasswordEntry entry, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF13131F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E1E2E)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),

        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF2E2E45),
                borderRadius: BorderRadius.circular(12),
              ),

              child: const Center(
                child: Icon(Icons.language, color: Color(0xFF6366F1), size: 22),
              ),
            ),
            const SizedBox(width: 12),
            //Middle column with site name and username
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.siteName,
                    style: const TextStyle(
                      color: Color(0xFFE2E8F0),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.username,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _passwordVisible[index]
                        ? EncryptionService.decryptPassword(
                            entry.password,
                          ) // ← decrypt when showing
                        : '••••••••',
                    style: const TextStyle(
                      color: Color(0xFF4A4A6A),
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),

            IconButton(
              icon: Icon(
                _passwordVisible[index]
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: const Color(0xFF6B7280),
                size: 20,
              ),
              onPressed: () {
                setState(
                  () => _passwordVisible[index] = !_passwordVisible[index],
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF6B7280), size: 20),
              onPressed: () {
                // TODO: open edit screen
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.delete,
                color: Color(0xFF6B7280),
                size: 20,
              ),
              onPressed: () => _confirmDelete(index),
            ),
          ],
        ),
      ),
    );
  }
}
