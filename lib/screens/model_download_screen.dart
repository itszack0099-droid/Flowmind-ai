import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';
import '../services/model_downloader.dart';
import '../services/local_llm_service.dart';

class ModelDownloadScreen extends StatefulWidget {
  const ModelDownloadScreen({super.key});

  @override
  State<ModelDownloadScreen> createState() => _ModelDownloadScreenState();
}

class _ModelDownloadScreenState extends State<ModelDownloadScreen> with TickerProviderStateMixin {
  bool _showInitialPopup = true;
  bool _isDownloading = false;
  double _progress = 0.0;
  String _status = "Preparing download...";

  late AnimationController _robotRunController;
  late AnimationController _gameController;
  late Animation<double> _robotRunAnimation;

  double _dinoX = 0.0; // robot position
  double _obstacleX = 400;
  double _velocity = 0;
  bool _isJumping = false;
  int _score = 0;

  final LocalLLMService _llm = LocalLLMService();

  @override
  void initState() {
    super.initState();
    _robotRunController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400))..repeat(reverse: true);
    _robotRunAnimation = Tween<double>(begin: -8, end: 8).animate(_robotRunController);

    _gameController = AnimationController(vsync: this, duration: const Duration(milliseconds: 16))..addListener(_gameLoop);
    _checkIfModelAlreadyDownloaded();
  }

  Future<void> _checkIfModelAlreadyDownloaded() async {
    final dir = await getApplicationDocumentsDirectory();
    final modelFile = File('${dir.path}/qwen2.5-0.5b-q4_k_m.gguf');
    if (await modelFile.exists()) {
      Navigator.pop(context); // already downloaded → skip
    }
  }

  Future<void> _requestPermissions() async {
    await Permission.storage.request();
    await Permission.notification.request();
  }

  void _startDownload() async {
    await _requestPermissions();

    setState(() {
      _showInitialPopup = false;
      _isDownloading = true;
    });

    _gameController.repeat(); // start mini game

    await ModelDownloader.downloadModel(
      onProgress: (progress) {
        if (mounted) setState(() => _progress = progress);
      },
      onStatus: (status) {
        if (mounted) setState(() => _status = status);
      },
      onComplete: () async {
        if (mounted) {
          await _llm.initializeModel(onDownloadProgress: (_) {}, onStatusUpdate: (_) {});
          setState(() => _isDownloading = false);
          Navigator.pop(context); // success
        }
      },
    );
  }

  void _gameLoop() {
    if (!_isDownloading) return;

    setState(() {
      _score++;
      _obstacleX -= 6; // speed

      if (_obstacleX < -50) _obstacleX = 450 + math.Random().nextInt(200).toDouble();

      // simple jump physics
      if (_isJumping) {
        _velocity += 0.8;
        _dinoX += _velocity;
        if (_dinoX >= 0) {
          _dinoX = 0;
          _isJumping = false;
          _velocity = 0;
        }
      }

      // collision
      if (_obstacleX < 80 && _obstacleX > 20 && _dinoX > -30) {
        _gameController.stop();
        _status = "Game Over! Score: $_score";
      }
    });
  }

  void _jump() {
    if (!_isJumping) {
      setState(() {
        _isJumping = true;
        _velocity = -18;
      });
    }
  }