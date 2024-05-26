import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_voice_app/src/utils/settings.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:proximity_screen_lock/proximity_screen_lock.dart';
import 'package:proximity_sensor/proximity_sensor.dart';

const appId = settings.appId;
const token = settings.token;
const channel = "test";

void main() => runApp(const MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;
  bool _isNear = false;
  late StreamSubscription _streamSubscription;

  @override
  void initState() {
    super.initState();
    initAgora();
    listenSensor();
  }

  Future listenSensor() async {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
    };

    _streamSubscription = ProximitySensor.events.listen((int event) {
      print('Proximity sensor, is near? ${event > 0} $event');
      setState(() {
        _isNear = event > 0;
      });

      if (_isNear) {
        // Ekranı siyahlaştır
        ProximityScreenLock.setActive(true);
        ProximitySensor.setProximityScreenOff(true);
      } else {
        // Ekranı siyahlaştırmayı kaldır
        ProximityScreenLock.setActive(false);

        ProximitySensor.setProximityScreenOff(false);
      }
    });
    _streamSubscription.onError((error) {
      print('Proximity sensor error: $error');
    });
    _streamSubscription.onDone(() {
      print('Proximity sensor done');
    });
    _streamSubscription.resume();
  }

  Future<void> initAgora() async {
    // retrieve permissions
    await [Permission.microphone].request();

    // create the engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    // Register event handler
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          setState(() {
            _remoteUid = null;
          });
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint(
              '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
        },
      ),
    );

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

    // Join channel
    await _engine.joinChannel(
      token: token,
      channelId: channel,
      uid: 0,
      options: const ChannelMediaOptions(),
    );

    // Set audio route to earpiece (ahize)
    await _engine.setEnableSpeakerphone(false);
    await _engine.setDefaultAudioRouteToSpeakerphone(true);
  }

  @override
  void dispose() {
    super.dispose();
    _dispose();
    _streamSubscription.cancel();
  }

  Future<void> _dispose() async {
    await _engine.leaveChannel();
    await _engine.release();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora Voice Call'),
      ),
      body: Center(
        child: _localUserJoined
            ? const Text('Connected')
            : const CircularProgressIndicator(),
      ),
    );
  }
}
