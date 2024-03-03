// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kiosk_test_app/main.dart';
import 'package:kiosk_test_app/model/database_helper.dart';
import 'package:platform_device_id_v3/platform_device_id.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';

class VideoPlayerScreen1 extends StatefulWidget {
  final String videoLink;

  const VideoPlayerScreen1({super.key, required this.videoLink});

  @override
  State<VideoPlayerScreen1> createState() => _VideoPlayerScreen1State();
}

class _VideoPlayerScreen1State extends State<VideoPlayerScreen1> {
  late VideoPlayerController _controller;
  late ChewieController _chewieController;
  String? _deviceId;

  late IO.Socket _socket;
  bool _isInitialized = false;
  String _currentVideo = '';
  String _videoLink = '';
  // ignore: non_constant_identifier_names
  final String _device_id = 'deviceId';

  // ignore: non_constant_identifier_names
  _ConnectSocket() {
    _socket.onConnect((data) => print('Connection Establish'));
    _socket.onConnectError((data) => print('Connection error: $data'));
    _socket.onDisconnect((data) => print('Socket.io Disconnected'));
  }

  @override
  void initState() {
    super.initState();
    initPlatformState(); // Move this line to the beginning

    _videoLink = widget.videoLink;
    initializeVideoPlayer(_currentVideo, _videoLink);
  }

  void _handleChatMessage(dynamic data) {
    print('Received message from socket: $data');
    setState(() {
      _currentVideo = data;
    });

    initializeVideoPlayer(_currentVideo, _videoLink);
  }

  void _update(int id) async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnId: '$id',
      DatabaseHelper.columnName: 'pusat',
      DatabaseHelper.columnUrl: _currentVideo
    };
    final rowsAffected = await dbHelper.update(row);
    debugPrint('updated $rowsAffected row(s)');
  }

  Future<void> initPlatformState() async {
    String? deviceId;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      deviceId = await PlatformDeviceId.getDeviceId;
      // _deviceId = deviceId;
      _socket = IO.io(
        'https://kiosk-server.apidev.lol/',
        IO.OptionBuilder().setTransports(['websocket']).setQuery({
          _device_id: deviceId,
        }).build(),
      );
      // Initialize socket after getting device ID

      _ConnectSocket();
      _socket.on('chat message', (data) => _handleChatMessage(data));
    } on PlatformException {
      deviceId = 'Failed to get deviceId.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _deviceId = deviceId;
      print("deviceId->$_deviceId");
    });
  }

  Future<void> initializeVideoPlayer(String videoUrl, String videoLink) async {
    final appDocumentsDirectory = await getApplicationDocumentsDirectory();
    final filePath = '${appDocumentsDirectory.path}/downloaded_video.mp4';
    File file = File(filePath);

    if (videoUrl != videoLink && videoUrl.isNotEmpty) {
      await downloadAndSaveVideo(videoUrl, filePath);
      _update(1);
    }

    if (!file.existsSync()) {
      await downloadAndSaveVideo(videoUrl, filePath);
    }

    _controller = VideoPlayerController.file(file);
    await _controller.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _controller,
      aspectRatio: _controller.value.aspectRatio,
      autoPlay: true,
      looping: true,
    );

    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> downloadAndSaveVideo(String videoUrl, String filePath) async {
    final response = await http.get(Uri.parse(videoUrl));

    if (response.statusCode == 200) {
      File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
    } else {
      throw Exception('Failed to download video');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isInitialized
            ? Chewie(
                controller: _chewieController,
              )
            : const CircularProgressIndicator(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController.dispose();
    super.dispose();
  }
}
