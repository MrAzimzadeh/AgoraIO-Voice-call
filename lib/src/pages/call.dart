// import 'dart:async';

// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:agora_rtc_engine/rtc_engine.dart';
// import 'package:agora_voice_app/main.dart';
// import 'package:flutter/material.dart';

// import '../utils/settings.dart';

// class CallPage extends StatefulWidget {
//   final String? channelName;
//   final ClientRole? role;

//   const CallPage({Key? key, this.channelName, this.role}) : super(key: key);

//   @override
//   _CallPageState createState() => _CallPageState();
// }

// class _CallPageState extends State<CallPage> {
//   late RtcEngine _engine;

//   bool muted = false;

//   @override
//   void initState() {
//     super.initState();
//     initialize();
//   }

//   @override
//   void dispose() {
//     _dispose();
//     super.dispose();
//   }

//   Future<void> initialize() async {
//     if (appId.isEmpty) {
//       print('APP_ID is not provided in settings.dart');
//       return;
//     }

//     await _initAgoraRtcEngine();
//     _addAgoraEventHandlers();
//     await _engine.joinChannel(token, widget.channelName!, null, 0);
//   }

//   Future<void> _initAgoraRtcEngine() async {
//     _engine = await RtcEngine.create(appId);
//     await _engine.enableAudio();
//     await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
//     await _engine.setClientRole(widget.role!);
//   }

//   void _addAgoraEventHandlers() {
//     _engine.setEventHandler(RtcEngineEventHandler(
//       error: (code) {
//         print('onError: $code');
//       },
//       joinChannelSuccess: (channel, uid, elapsed) {
//         print('onJoinChannel: $channel, uid: $uid');
//       },
//       leaveChannel: (stats) {
//         print('onLeaveChannel');
//       },
//       userJoined: (uid, elapsed) {
//         print('userJoined: $uid');
//       },
//       userOffline: (uid, elapsed) {
//         print('userOffline: $uid');
//       },
//     ));
//   }

//   Future<void> _dispose() async {
//     await _engine.leaveChannel();
//     await _engine.destroy();
//   }

//   void _onToggleMute() {
//     setState(() {
//       muted = !muted;
//     });
//     _engine.muteLocalAudioStream(muted);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Agora Flutter QuickStart'),
//       ),
//       backgroundColor: Colors.black,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             RawMaterialButton(
//               onPressed: _onToggleMute,
//               child: Icon(
//                 muted ? Icons.mic_off : Icons.mic,
//                 color: muted ? Colors.white : Colors.blueAccent,
//                 size: 35.0,
//               ),
//               shape: CircleBorder(),
//               elevation: 2.0,
//               fillColor: muted ? Colors.blueAccent : Colors.white,
//               padding: const EdgeInsets.all(15.0),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
