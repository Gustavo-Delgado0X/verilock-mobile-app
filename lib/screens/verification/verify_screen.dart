import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/api_service.dart';
import '../../widgets/primary_button.dart';
import '../../utils/app_theme.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final _api = ApiService();
  final _audioRecorder = AudioRecorder();

  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isRecording = false;
  bool _isVerifying = false;
  bool _isLoadingProfiles = true;

  // Dropdown Data
  List<String> _profiles = [];
  String? _selectedUser;
  
  // The phrase is still sent to backend for verification, 
  // but we won't show it on screen.
  final String _targetPhrase = "open door"; 

  @override
  void initState() {
    super.initState();
    _initCamera();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final profiles = await _api.getProfiles();
      setState(() {
        _profiles = profiles;
        _isLoadingProfiles = false;
      });

      final prefs = await SharedPreferences.getInstance();
      final lastUser = prefs.getString('last_verified_user');
      
      if (lastUser != null && _profiles.contains(lastUser)) {
        setState(() => _selectedUser = lastUser);
      } else if (_profiles.isNotEmpty) {
        setState(() => _selectedUser = _profiles.first);
      }
    } catch (e) {
      setState(() => _isLoadingProfiles = false);
      debugPrint("Error loading profiles: $e");
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first);

      _cameraController = CameraController(
        firstCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) setState(() => _isCameraInitialized = true);
    } catch (e) {
      debugPrint('Camera error: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startVerification() async {
    if (_selectedUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a user profile first')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_verified_user', _selectedUser!);

    setState(() {
      _isRecording = true;
      _isVerifying = false;
    });

    try {
      final dir = await getApplicationDocumentsDirectory();
      final audioPath = '${dir.path}/verify_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start(const RecordConfig(), path: audioPath);
      }

      await Future.delayed(const Duration(seconds: 3));

      final recordedPath = await _audioRecorder.stop();
      setState(() => _isRecording = false);

      if (_cameraController == null || !_cameraController!.value.isInitialized) {
        throw 'Camera not ready';
      }
      final image = await _cameraController!.takePicture();

      if (mounted) setState(() => _isVerifying = true);
      
      final success = await _api.verifyUser(
        _selectedUser!,
        image.path,          
        recordedPath!,       
        _targetPhrase,
      );

      if (mounted) {
        if (success) {
           Navigator.pop(context);
           ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Access Granted! Door Unlocked.'), backgroundColor: Colors.green)
           );
        } else {
           _showResultDialog(false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  void _showResultDialog(bool success) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: Text(success ? 'Access Granted' : 'Access Denied', style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: success ? Colors.green : Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            const Text("Face or Voice did not match.", style: TextStyle(color: Colors.white70)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('2FA Verification')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Look at the camera and speak clearly.',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 24),
            
            Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.accentBlue, width: 3),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)]
              ),
              child: _isCameraInitialized
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: CameraPreview(_cameraController!),
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
            const SizedBox(height: 24),

            _isLoadingProfiles
                ? const CircularProgressIndicator()
                : DropdownButtonFormField<String>(
                    value: _selectedUser,
                    items: _profiles.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedUser = val),
                    dropdownColor: AppTheme.cardColor,
                    decoration: const InputDecoration(
                      labelText: 'Select User Profile',
                      prefixIcon: Icon(Icons.person, color: AppTheme.accentBlue),
                      border: OutlineInputBorder(),
                    ),
                  ),
            
            const SizedBox(height: 24),

            // --- CHANGED: Generic Instruction ---
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.mic, color: Colors.white70),
                  SizedBox(width: 12),
                  Text(
                    'Speak your secret phrase', 
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            if (_isVerifying)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Verifying with VeriLock...", style: TextStyle(color: Colors.white54))
                ],
              )
            else if (_isRecording)
              const Column(
                children: [
                  Icon(Icons.graphic_eq, color: Colors.redAccent, size: 50),
                  SizedBox(height: 8),
                  Text('Listening...', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              )
            else
              PrimaryButton(
                label: 'Start Verification',
                onPressed: _startVerification,
              ),
          ],
        ),
      ),
    );
  }
}
