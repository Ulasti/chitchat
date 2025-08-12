// import 'package:flutter/material.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;

// class CallPage extends StatefulWidget {
//   final String username;
//   final String room;
//   final IO.Socket socket;

//   const CallPage({
//     required this.username,
//     required this.room,
//     required this.socket,
//     super.key,
//   });

//   @override
//   State<CallPage> createState() => _CallPageState();
// }

// class _CallPageState extends State<CallPage> {
//   late IO.Socket socket;
//   RTCPeerConnection? _peerConnection;
//   MediaStream? _localStream;
//   final _localRenderer = RTCVideoRenderer();
//   final _remoteRenderer = RTCVideoRenderer();

//   @override
//   void initState() {
//     super.initState();
//     initRenderers();
//     connectSocket();
//   }

//   Future<void> initRenderers() async {
//     await _localRenderer.initialize();
//     await _remoteRenderer.initialize();
//   }

//   void connectSocket() {
//     socket = IO.io("http://192.168.1.162:3000", <String, dynamic>{
//       "transports": ["websocket"],
//       "autoConnect": false,
//     });
//     socket.connect();

//     socket.onConnect((_) {
//       socket.emit("login", widget.username);
//       socket.emit("join_call", {"room": widget.room});
//     });

//     socket.on("ready", (_) async {
//       await _createOffer();
//     });

//     socket.on("webrtc_offer", (data) async {
//       await _handleOffer(data['sdp']);
//     });

//     socket.on("webrtc_answer", (data) async {
//       await _peerConnection?.setRemoteDescription(
//         RTCSessionDescription(data['sdp'], "answer"),
//       );
//     });

//     socket.on("webrtc_ice_candidate", (data) async {
//       await _peerConnection?.addCandidate(
//         RTCIceCandidate(
//           data['candidate']['candidate'],
//           data['candidate']['sdpMid'],
//           data['candidate']['sdpMLineIndex'],
//         ),
//       );
//     });
//   }

//   Future<void> _createPeerConnection() async {
//     final config = {
//       "iceServers": [
//         {"urls": "stun:stun.l.google.com:19302"},
//       ],
//     };

//     _peerConnection = await createPeerConnection(config);

//     // Get user media
//     _localStream = await navigator.mediaDevices.getUserMedia({
//       "audio": true,
//       "video": true,
//     });
//     _localRenderer.srcObject = _localStream;
//     _localStream?.getTracks().forEach((track) {
//       _peerConnection?.addTrack(track, _localStream!);
//     });

//     // Handle remote stream
//     _peerConnection?.onTrack = (event) {
//       if (event.streams.isNotEmpty) {
//         _remoteRenderer.srcObject = event.streams[0];
//       }
//     };

//     // Send ICE candidates to server
//     _peerConnection?.onIceCandidate = (candidate) {
//       socket.emit("webrtc_ice_candidate", {
//         "room": widget.room,
//         "candidate": {
//           "candidate": candidate.candidate,
//           "sdpMid": candidate.sdpMid,
//           "sdpMLineIndex": candidate.sdpMLineIndex,
//         },
//       });
//     };
//   }

//   Future<void> _createOffer() async {
//     await _createPeerConnection();
//     var offer = await _peerConnection!.createOffer();
//     await _peerConnection!.setLocalDescription(offer);

//     socket.emit("webrtc_offer", {"room": widget.room, "sdp": offer.sdp});
//   }

//   Future<void> _handleOffer(String sdp) async {
//     await _createPeerConnection();

//     await _peerConnection!.setRemoteDescription(
//       RTCSessionDescription(sdp, "offer"),
//     );

//     var answer = await _peerConnection!.createAnswer();
//     await _peerConnection!.setLocalDescription(answer);

//     socket.emit("webrtc_answer", {"room": widget.room, "sdp": answer.sdp});
//   }

//   @override
//   void dispose() {
//     _localRenderer.dispose();
//     _remoteRenderer.dispose();
//     socket.disconnect();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Room: ${widget.room}")),
//       body: Column(
//         children: [
//           Expanded(child: RTCVideoView(_localRenderer, mirror: true)),
//           Expanded(child: RTCVideoView(_remoteRenderer)),
//         ],
//       ),
//     );
//   }
// }
