import 'package:chitchat/features/chat/viewmodels/chat_logs.dart';
import 'package:flutter/material.dart';
import 'package:chitchat/core/constants/app_colors.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  await Permission.camera.request();
  await Permission.microphone.request();
}

class ChatPage extends StatefulWidget {
  final IO.Socket socket;
  final String toUser;
  final String fromUser;

  const ChatPage({
    super.key,
    required this.socket,
    required this.toUser,
    required this.fromUser,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final _api = ChatApi('http://192.168.1.162:3000');
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    _loadConversation();
    widget.socket.off('receive_message');
    widget.socket.on('receive_message', (data) {
      if (data['from'] == widget.toUser) {
        setState(() {
          messages.add({'from': data['from'], 'message': data['message']});
        });
      }
    });
  }

  Future<void> _loadConversation() async {
    try {
      final history = await _api.fetchHistory(widget.fromUser, widget.toUser);
      setState(() {
        messages = history
            .map(
              (m) => {
                'from': m['from'],
                'message': m['message'],
                'type': m['from'] == widget.fromUser ? 'sent' : 'received',
              },
            )
            .toList();
      });
    } catch (e) {
      //catch
    }
  }

  void sendMessage() {
    String message = messageController.text.trim();
    if (message.isEmpty) return;

    widget.socket.emit('send_message', {
      'to': widget.toUser,
      'from': widget.fromUser,
      'timestamp': DateTime.now().toIso8601String(),
      'message': message,
    });

    setState(() {
      messages.add({'from': widget.fromUser, 'message': message});
    });
    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appWhite,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.appWhite, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: AppColors.appPrimary,
        titleSpacing: 0,
        title: Row(
          children: [
            Image.asset('assets/icons/pp.png', height: 50),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.toUser,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.appWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Online',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.appWhite,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),

        actions: [
          IconButton(
            icon: Icon(Icons.call, color: AppColors.appWhite, size: 30),
            onPressed: () {
              // Handle more options
            },
          ),
          IconButton(
            icon: Icon(
              Icons.video_call_rounded,
              color: AppColors.appWhite,
              size: 35,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: ListView.builder(
                shrinkWrap: true,
                reverse: true,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages.reversed.toList()[index];
                  final isMe = msg['from'] == widget.fromUser;
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: isMe
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.7,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? AppColors.appPrimary
                                  : AppColors.appGrey,
                              borderRadius: BorderRadius.circular(13),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 3,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Text(
                              msg['message']!,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: isMe
                                        ? AppColors.appWhite
                                        : AppColors.appBlack,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            color: AppColors.appPrimary,
            height: 85,
            width: double.infinity,
            padding: const EdgeInsets.only(top: 8, bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.add_rounded,
                    color: AppColors.appWhite,
                    size: 30,
                  ),
                ),
                Expanded(
                  child: TextField(
                    focusNode: _focusNode,
                    cursorColor: AppColors.appBlack.withValues(alpha: 0.5),
                    cursorHeight: 15,
                    controller: messageController,
                    onSubmitted: (value) => {sendMessage()},
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      filled: true,
                      fillColor: AppColors.appWhite.withValues(alpha: 0.5),
                      hintText: 'Bir şeyler yaz...',
                      hintStyle: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(
                            color: AppColors.appBlack.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.mic, color: AppColors.appWhite, size: 25),
                ),
                IconButton(
                  onPressed: sendMessage,
                  icon: Icon(
                    Icons.send_rounded,
                    color: AppColors.appWhite,
                    size: 25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose(); // Don't forget to dispose
    messageController.dispose();
    super.dispose();
  }
}
