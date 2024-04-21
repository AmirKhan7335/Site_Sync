import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class SiteCamera extends StatefulWidget {
  SiteCamera({required this.rtspUrl, super.key});
  String rtspUrl;

  @override
  State<SiteCamera> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<SiteCamera> {
  @override
  Widget build(BuildContext context) {
    final VlcPlayerController _videoPlayerController =
    VlcPlayerController.network(
      widget.rtspUrl,
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(
        advanced: VlcAdvancedOptions([
          VlcAdvancedOptions.networkCaching(1000),
        ]),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'RTSP Player',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Center(
        child: VlcPlayer(
          aspectRatio: 16 / 9,
          controller: _videoPlayerController,
          placeholder: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
