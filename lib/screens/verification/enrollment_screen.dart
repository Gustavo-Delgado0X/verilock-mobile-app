import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:http_parser/http_parser.dart'; // 1. Import http_parser
import '../../api/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/primary_button.dart';

class EnrollmentScreen extends StatefulWidget {
  const EnrollmentScreen({super.key});

  @override
  State<EnrollmentScreen> createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends State<EnrollmentScreen> {
  final _nameController = TextEditingController();
  final _phraseController = TextEditingController();
  final _api = ApiService();
  final _audioRecorder = AudioRecorder();

  // Camera
  CameraController? _cameraController;
  Future<void>? _cameraInitFuture;
  XFile? _capturedImage;

  // Audio
  bool _isRecording = false;
  String? _recordedAudioPath;

  // State
  int _currentStep = 0; // 0=Name, 1=Face, 2=Voice
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
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

      _cameraInitFuture = _cameraController!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Camera error: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _nameController.dispose();
    _phraseController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  // --- Actions ---

  Future<void> _takePicture() async {
    try {
      await _cameraInitFuture;
      final image = await _cameraController!.takePicture();
      setState(() => _capturedImage = image);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      // Stop
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _recordedAudioPath = path;
      });
    } else {
      // Start
      if (await _audioRecorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        final path = '${dir.path}/enroll_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _audioRecorder.start(const RecordConfig(), path: path);
        setState(() => _isRecording = true);
      }
    }
  }

  // 2. Refine _submit method
  Future<void> _submit() async {
    if (_nameController.text.isEmpty) {
      _showError('Please enter a name');
      return;
    }
    if (_capturedImage == null) {
      _showError('Please take a photo');
      return;
    }
    if (_recordedAudioPath == null) {
      _showError('Please record voice');
      return;
    }
    if (_phraseController.text.isEmpty) {
      _showError('Please enter the secret phrase used');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      
      // Debug logs to see where it hangs
      debugPrint('Starting enrollment for $name...');
      debugPrint('Uploading Face from: ${_capturedImage!.path}');
      
      // 1. Upload Face
      final faceOk = await _api.enrollFace(name, _capturedImage!.path);
      if (!faceOk) throw 'Face enrollment failed (API returned false)';

      debugPrint('Face OK. Uploading Voice from: $_recordedAudioPath');

      // 2. Upload Voice
      final voiceOk = await _api.enrollVoice(name, _recordedAudioPath!, _phraseController.text.trim());
      if (!voiceOk) throw 'Voice enrollment failed (API returned false)';

      debugPrint('Voice OK. Enrollment complete.');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enrollment Successful!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(); // Go back home
      }
    } catch (e) {
      debugPrint('Enrollment Error: $e');
      _showError('Connection Failed: $e\nCheck IP in Settings.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  // --- UI Steps ---

  Widget _buildNameStep() {
    return Column(
      children: [
        const Text('Who are you?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Enter your name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Next: Face Scan',
          onPressed: () {
            if (_nameController.text.isNotEmpty) setState(() => _currentStep = 1);
          },
        ),
      ],
    );
  }

  Widget _buildFaceStep() {
    if (_cameraController == null || _cameraController?.value.isInitialized == false) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        const Text('Face Enrollment', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Look at the camera and take a clear photo.'),
        const SizedBox(height: 16),
        
        Container(
          height: 300,
          width: 300,
          decoration: BoxDecoration(border: Border.all(color: Colors.blue, width: 3)),
          child: _capturedImage == null 
              ? CameraPreview(_cameraController!) 
              : Image.file(File(_capturedImage!.path), fit: BoxFit.cover),
        ),
        
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (_capturedImage != null)
              TextButton(
                onPressed: () => setState(() => _capturedImage = null),
                child: const Text('Retake'),
              ),
            ElevatedButton.icon(
              onPressed: _capturedImage == null ? _takePicture : () => setState(() => _currentStep = 2),
              icon: Icon(_capturedImage == null ? Icons.camera_alt : Icons.check),
              label: Text(_capturedImage == null ? 'Take Photo' : 'Next: Voice'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVoiceStep() {
    return Column(
      children: [
        const Text('Voice Enrollment', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextField(
          controller: _phraseController,
          decoration: const InputDecoration(
            labelText: 'Secret Phrase (e.g. "Open Door")',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        
        GestureDetector(
          onTap: _toggleRecording,
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: _isRecording ? Colors.red : AppTheme.primaryNavy,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isRecording ? Icons.stop : Icons.mic,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(_isRecording ? 'Recording... Tap to Stop' : (_recordedAudioPath == null ? 'Tap to Record' : 'Audio Recorded!')),
        
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Submit Enrollment',
          loading: _isLoading,
          onPressed: _recordedAudioPath != null ? _submit : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Simple Stepper Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person, color: _currentStep >= 0 ? Colors.blue : Colors.grey),
                const SizedBox(width: 10),
                Container(width: 30, height: 2, color: Colors.grey),
                const SizedBox(width: 10),
                Icon(Icons.camera_alt, color: _currentStep >= 1 ? Colors.blue : Colors.grey),
                const SizedBox(width: 10),
                Container(width: 30, height: 2, color: Colors.grey),
                const SizedBox(width: 10),
                Icon(Icons.mic, color: _currentStep >= 2 ? Colors.blue : Colors.grey),
              ],
            ),
            const SizedBox(height: 32),
            
            if (_currentStep == 0) _buildNameStep(),
            if (_currentStep == 1) _buildFaceStep(),
            if (_currentStep == 2) _buildVoiceStep(),
          ],
        ),
      ),
    );
  }
}
