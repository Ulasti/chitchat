import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatPage extends StatefulWidget {
  final IO.Socket socket;
  final String toUser;
  final String fromUser;

  ChatPage({
    required this.socket,
    required this.toUser,
    required this.fromUser,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageController = TextEditingController();
  List<Map<String, String>> messages = [];

  @override
  void initState() {
    super.initState();
    widget.socket.on('receive_message', (data) {
      if (data['from'] == widget.toUser) {
        setState(() {
          messages.add({'from': data['from'], 'message': data['message']});
        });
      }
    });
  }

  void sendMessage() {
    String message = messageController.text.trim();
    if (message.isEmpty) return;

    widget.socket.emit('send_message', {
      'to': widget.toUser,
      'message': message,
    });

    setState(() {
      messages.add({'from': widget.fromUser, 'message': message});
      messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat with ${widget.toUser}')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: messages
                  .map(
                    (msg) => ListTile(
                      title: Text(msg['message']!),
                      subtitle: Text(
                        msg['from'] == widget.fromUser ? 'You' : msg['from']!,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Row(
            children: [
              Expanded(child: TextField(controller: messageController)),
              IconButton(onPressed: sendMessage, icon: Icon(Icons.send)),
            ],
          ),
        ],
      ),
    );
  }
}
