import 'dart:async';
import 'dart:developer';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_voice_app/firebase_options.dart';
import 'package:agora_voice_app/src/call_screen.dart';
import 'package:agora_voice_app/src/utils/settings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:proximity_screen_lock/proximity_screen_lock.dart';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'package:signalr_netcore/signalr_client.dart';

const appId = settings.appId;
const token = settings.token;
const channel = "test";

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final fcmToken = await FirebaseMessaging.instance.getToken();
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  log("FCMToken $fcmToken");
  runApp(const MaterialApp(home: FirstClass()));
}

class FirstClass extends StatefulWidget {
  const FirstClass({super.key});

  @override
  State<FirstClass> createState() => _FirstClassState();
}

class _FirstClassState extends State<FirstClass> {
  @override
  Widget build(BuildContext context) {
    return const MyApp();
  }
}

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
  // late HubConnection hubConnection;
  final hubConnection = HubConnectionBuilder()
      .withUrl('https://dev.cafetti.az/api/order/ws/cashboxTrack',
          transportType: HttpTransportType.WebSockets)
      .withAutomaticReconnect()
      .build();
  @override
  void initState() {
    super.initState();
    // hubConnection.start();
    _startHubConnection();
    // connectHub();
    initAgora();
    listenSensor();
    // hubConnection.invoke('GetNickName', args: ["salam"]);
  }

  void _startHubConnection() async {
    try {
      await hubConnection.start();
      hubConnection.onclose(
        ({error}) {
          print('Connection closed with error: $error');
        },
      );
      hubConnection.on('ReceiveMessage', (data) {
        print('GetNickName: $data');
      });
      print('SignalR connection started.');
    } catch (e) {
      print('Error starting SignalR connection: $e');
    }
  }

  void connectHub() async {
    try {
      await hubConnection.start();
      print('w connection started');
      // await hubConnection.invoke('JoinChannel', args: <Object>['test']);
    } on TimeoutException catch (e) {
      print('Error starting connection: TimeoutException: $e');
    } catch (error) {
      print('Error starting connection: $error');
    }
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
      body: Column(
        children: [
          SizedBox(
            child: _localUserJoined
                ? const Text('Connected')
                : const CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }
}

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future initialize(BuildContext context) async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Bildirim alındı: ${message.notification?.title}");

      // Bildirimin veri yükünü kontrol et
      if (message.data['screen'] != null) {
        // Belirli bir sayfayı aç
        _navigateToScreen(context, message.data['screen']);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Uygulama bildirimle açıldı: ${message.notification?.title}');

      // Bildirimin veri yükünü kontrol et
      if (message.data['screen'] != null) {
        // Belirli bir sayfayı aç
        _navigateToScreen(context, message.data['screen']);
      }
    });
  }

  void _navigateToScreen(BuildContext context, String screen) {
    // Belirli bir sayfaya yönlendir
    // Örneğin:
    if (screen == 'message_detail') {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => CallPageTest()));
    }
  }
}
// import 'package:flutter/material.dart';
// import 'package:signalr_netcore/signalr_client.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   final hubConnection = HubConnectionBuilder()
//       .withUrl('https://your-signalr-hub-url')
//       .build();

//   TextEditingController messageController = TextEditingController();
//   List<String> messages = [];

//   @override
//   void initState() {
//     super.initState();

//     // Connect to the SignalR hub
//     _startHubConnection();

//     // Define an event handler for receiving messages
//     hubConnection.on('ReceiveMessage', (List<Object?>? arguments) => _handleReceivedMessage(arguments!));
//   }

//   void _startHubConnection() async {
//     try {
//       await hubConnection.start();
//       print('SignalR connection started.');
//     } catch (e) {
//       print('Error starting SignalR connection: $e');
//     }
//   }

//   void _handleReceivedMessage(List<Object?> arguments) {
//     Object user = arguments[0] ?? '';
//     Object message = arguments[1] ?? '';

//     setState(() {
//       messages.add('$user: $message');
//     });
//   }

//   void _sendMessage() {
//     String user = 'You'; // Replace with the user's name or identifier
//     String message = messageController.text;

//     // Send the message to the SignalR hub
//     hubConnection.invoke('SendMessage', args: [user, message]);

//     // Clear the text input field
//     messageController.text = '';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Flutter Chat with SignalR'),
//         ),
//         body: Column(
//           children: [
//             Expanded(
//               child: ListView.builder(
//                 itemCount: messages.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     title: Text(messages[index]),
//                   );
//                 },
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.all(8.0),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: messageController,
//                       decoration: InputDecoration(
//                         hintText: 'Enter your message',
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.send),
//                     onPressed: _sendMessage,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     // Ensure that the SignalR connection is closed when the app is disposed
//     hubConnection.stop();
//     super.dispose();
//   }
// }