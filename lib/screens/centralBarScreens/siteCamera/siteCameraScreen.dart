import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

// class SiteCamera extends StatefulWidget {
//   SiteCamera({required this.rtspUrl, super.key});
//   String rtspUrl;
//
//   @override
//   State<SiteCamera> createState() => _LiveStreamScreenState();
// }
//
// class _LiveStreamScreenState extends State<SiteCamera> {
//   @override
//   Widget build(BuildContext context) {
//     final VlcPlayerController _videoPlayerController =
//     VlcPlayerController.network(
//       widget.rtspUrl,
//       hwAcc: HwAcc.full,
//       autoPlay: true,
//       options: VlcPlayerOptions(
//         advanced: VlcAdvancedOptions([
//           VlcAdvancedOptions.networkCaching(1000),
//         ]),
//       ),
//     );
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'RTSP Player',
//           style: TextStyle(color: Colors.black),
//         ),
//       ),
//       body: Center(
//         child: VlcPlayer(
//           aspectRatio: 16 / 9,
//           controller: _videoPlayerController,
//           placeholder: Center(child: CircularProgressIndicator()),
//         ),
//       ),
//     );
//   }
// }


class SiteCamera extends StatefulWidget {
  SiteCamera({ super.key});

  @override
  State<SiteCamera> createState() => _SiteCameraState();
}

class _SiteCameraState extends State<SiteCamera> {
final VlcPlayerController _videoPlayerController = VlcPlayerController.network(
  'rtsp://Amir :123456@192.168.137.162/live',
  hwAcc: HwAcc.full,
  autoPlay: true,
  options: VlcPlayerOptions(
    advanced: VlcAdvancedOptions([
      VlcAdvancedOptions.networkCaching(1000),
    ]),
  ),

);

@override
Widget build(BuildContext context) {
  return Scaffold(
      appBar: AppBar(
        title: const Text('Live Camera Stream', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
          child: VlcPlayer(
            aspectRatio: 16 / 9,
            controller: _videoPlayerController,
            placeholder: const Center(child: CircularProgressIndicator()),
          ),
          ),
      );
  }
}
