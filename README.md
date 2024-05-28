# agora_voice_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
#   A g o r a I O - V o i c e - c a l l 
 
 

//

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
