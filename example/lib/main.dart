import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AgoraClient? client;
  bool _isInitialized = false;
  String? _errorMessage;
  bool _isDisposed = false;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _initializeAgora();
  }

  Future<void> _initializeAgora() async {
    if (_isDisposed || _isInitializing) return;

    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      // Release any existing client first
      if (client != null) {
        await _cleanupAgora();
      }

      // Create new client
      client = AgoraClient(
        agoraConnectionData: AgoraConnectionData(
          appId: "<--Add your App Id here-->",
          channelName: "test",
          username: "user",
        ),
      );

      // Initialize with a delay to ensure proper cleanup
      await Future.delayed(const Duration(milliseconds: 1000));

      if (!_isDisposed) {
        await client!.initialize();

        if (!_isDisposed && mounted) {
          setState(() {
            _isInitialized = true;
            _errorMessage = null;
          });
        }
      }
    } catch (e) {
      print('Error during initialization: $e');
      if (!_isDisposed && mounted) {
        setState(() {
          _errorMessage = 'Error initializing Agora: $e';
          _isInitialized = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _cleanupAgora();
    super.dispose();
  }

  Future<void> _cleanupAgora() async {
    if (client != null) {
      try {
        await client!.release();
      } catch (e) {
        print('Error during cleanup: $e');
      }
      client = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Agora VideoUIKit'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              AgoraVideoViewer(
                client: client!,
                layoutType: Layout.floating,
                enableHostControls: true, // Add this to enable host controls
              ),
              AgoraVideoButtons(
                client: client!,
                addScreenSharing: false, // Add this to enable screen sharing
              ),
            ],
          ),
        ),
      ),
    );
  }
}
