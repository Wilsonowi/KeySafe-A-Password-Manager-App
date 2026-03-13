import 'package:flutter/material.dart';
import 'dart:async';
import 'main_screen.dart';

//Stateful widget for lock screen(Screen can change and update itself based on user interaction)
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  // ── Variables ──
  String _enteredPin = '';
  List<bool> _revealed = [false, false, false, false];
  final _hardcodedPin = '1234';
  String _message = 'Enter your PIN to continue';
  int _failedAttempts = 0;
  bool _isLockedOut = false;
  int _lockoutRemaining = 0;
  Timer? _lockoutTimer; // ? means this variable can be null

  // ── Called when a digit key is tapped ──
  void _onKeyTap(String digit) {
    if (_enteredPin.length >= 4) return;

    int index = _enteredPin.length;

    setState(() {
      _enteredPin += digit;
      _revealed[index] = true; // show number briefly
    });

    // after 600ms, hide it behind a dot
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _revealed[index] = false;
        });
      }
    });
    if (_enteredPin.length == 4) {
      Future.delayed(const Duration(milliseconds: 300), _verifyPin);
    }
  }

  void _verifyPin() {
    if (_enteredPin == _hardcodedPin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      _failedAttempts++;

      if (_failedAttempts >= 3) {
        _startLockout(); // outside setState ✅
      } else {
        setState(() {
          // only setState for message update
          _message =
              'Incorrect PIN. Remaining attempts: ${3 - _failedAttempts}';
          _enteredPin = '';
          _revealed = [false, false, false, false];
        });
      }
    }
  }

  void _startLockout() {
    setState(() {
      _isLockedOut = true;
      _lockoutRemaining = 300; // 300 seconds = 5 minutes
      _enteredPin = '';
      _revealed = [false, false, false, false];
      _message = 'Locked out due to multiple failed attempts. Try again later';
    });

    // tick every second
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _lockoutRemaining--);

      if (_lockoutRemaining <= 0) {
        timer.cancel(); // stop the timer
        _endLockout();
      }
    });
  }

  void _endLockout() {
    setState(() {
      _isLockedOut = false;
      _failedAttempts = 0;
      _lockoutRemaining = 0;
      _message = 'Enter your PIN to continue';
    });
  }

  // ── Called when backspace is tapped ──
  void _onDelete() {
    if (_enteredPin.isEmpty) return;
    setState(() {
      int index = _enteredPin.length - 1;
      _enteredPin = _enteredPin.substring(0, index);
      _revealed[index] = false;
    });
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel(); // cancel timer if screen is closed
    super.dispose();
  }

  // ── Builds a row of 3 keys ──
  Widget _buildKeyRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: digits.asMap().entries.map((e) {
        return Row(
          children: [
            _buildKey(e.value),
            if (e.key < digits.length - 1) const SizedBox(width: 12),
          ],
        );
      }).toList(),
    );
  }

  // ── Builds a single key button ──
  Widget _buildKey(String digit) {
    return SizedBox(
      width: 80,
      height: 80,
      child: TextButton(
        onPressed: () => _onKeyTap(digit),
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFF13131F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF1E1E2E)),
          ),
        ),
        child: Text(
          digit,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Color(0xFFE2E8F0),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D14),
      body: SafeArea(
        child: _isLockedOut ? _buildLockoutView() : _buildNormalView(),
      ),
    );
  }

  Widget _buildLockoutView() {
    // format seconds into MM:SS
    int minutes = _lockoutRemaining ~/ 60;
    int seconds = _lockoutRemaining % 60;
    String timer = '$minutes:${seconds.toString().padLeft(2, '0')}';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔒', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 24),
            const Text(
              'App Locked',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFFF87171),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Too many incorrect attempts.\nPlease wait before trying again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.6, // line height, like line-height in CSS
              ),
            ),
            const SizedBox(height: 32),
            // timer box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF130F0F),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2A1A1A)),
              ),
              child: Text(
                timer,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFFF87171),
                  letterSpacing: 6,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'App will unlock automatically',
              style: TextStyle(fontSize: 13, color: Color(0xFF4A4A6A)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNormalView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Logo ──
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2E),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF2E2E45)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/logo.png',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'KeySafe',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFFE2E8F0),
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            _message,
            style: TextStyle(
              fontSize: 14,
              color: _failedAttempts > 0
                  ? const Color(0xFFF87171) // red if error
                  : const Color(0xFF6B7280), // grey normally
            ),
          ),

          const SizedBox(height: 40),

          // ── PIN dots ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              bool filled = i < _enteredPin.length;
              bool revealed = filled && _revealed[i];
              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled ? const Color(0xFF6366F1) : Colors.transparent,
                  border: Border.all(
                    color: filled
                        ? const Color(0xFF6366F1)
                        : const Color(0xFF2E2E45),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    revealed
                        ? _enteredPin[i]
                        : filled
                        ? '●'
                        : '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 48),

          // ── Keypad ──
          Column(
            children: [
              _buildKeyRow(['1', '2', '3']),
              const SizedBox(height: 12),
              _buildKeyRow(['4', '5', '6']),
              const SizedBox(height: 12),
              _buildKeyRow(['7', '8', '9']),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 80),
                  const SizedBox(width: 12),
                  _buildKey('0'),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: TextButton(
                      onPressed: _onDelete,
                      child: const Icon(
                        Icons.backspace_outlined,
                        color: Color(0xFF6B7280),
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
