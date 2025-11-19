import 'package:flutter/material.dart';
import '../api/api_service.dart';

class LockProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLocked = true;
  bool get isLocked => _isLocked;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _statusMessage = 'Connecting...';
  String get statusMessage => _statusMessage;

  // Helper to update loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> refreshStatus() async {
    _setLoading(true);
    try {
      final status = await _apiService.getStatus();
      _isLocked = status.locked;
      _statusMessage = status.lockState; // e.g., "LOCKED"
    } catch (e) {
      _statusMessage = 'Offline';
      debugPrint(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> lock() async {
    _setLoading(true);
    try {
      final res = await _apiService.lock();
      if (res.ok) {
        _statusMessage = res.state;
        if (res.state == 'LOCKED') _isLocked = true;
      }
    } catch (e) {
      _statusMessage = 'Error: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> unlock() async {
    _setLoading(true);
    try {
      final res = await _apiService.unlock();
      if (res.ok) {
        _statusMessage = res.state;
        if (res.state == 'UNLOCKED') _isLocked = false;
      }
    } catch (e) {
      _statusMessage = 'Error: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> keyOverride() async {
    _setLoading(true);
    try {
      final res = await _apiService.keyOverride();
      if (res.ok) {
        _statusMessage = res.state; // Should be "KEY_OVERRIDE"
        // Usually override implies unlocking temporarily, so we update UI to show unlocked
        if (res.state == 'KEY_OVERRIDE') _isLocked = false;
      }
    } catch (e) {
      _statusMessage = 'Error: $e';
    } finally {
      _setLoading(false);
    }
  }
}
