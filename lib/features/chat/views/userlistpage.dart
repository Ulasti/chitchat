import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:lchat/features/chat/views/chat_page.dart';
import 'package:lchat/core/constants/app_colors.dart';

class UserListPage extends StatefulWidget {
  final IO.Socket socket;
  final String username;

  UserListPage({required this.socket, required this.username});

  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<String> users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();

    widget.socket.on('user_list', (data) {
      setState(() {
        users = List<String>.from(data)..remove(widget.username);
      });
    });
  }

  void fetchUsers() async {
    final res = await http.get(Uri.parse('http://192.168.1.162:3000/users'));
    if (res.statusCode == 200) {
      setState(() {
        users = List<String>.from(jsonDecode(res.body))
          ..remove(widget.username);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Sohbetler',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.appWhite,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: AppColors.appWhite, size: 28),
            onPressed: () {
              widget.socket.emit('logout', widget.username);
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
        backgroundColor: AppColors.appPrimary,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 60,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                onTapOutside: (event) => FocusScope.of(context).unfocus(),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                  hintText: '...',
                  hintStyle: TextStyle(color: AppColors.appBlack),

                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.appBlack,
                  ),
                  fillColor: AppColors.appBlack.withValues(alpha: 0.25),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  // setState(() {
                  //   users = users
                  //       .where((user) => user.contains(value))
                  //       .toList();
                  // });
                },
              ),
            ),
          ),
          SizedBox(
            height: 600,
            width: double.infinity,
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (_, i) => ListTile(
                title: Text(users[i]),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(
                        socket: widget.socket,
                        toUser: users[i],
                        fromUser: widget.username,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          SizedBox(
            height: 20,
            width: double.infinity,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    // Handle add user action
                  },
                ),
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    // Handle remove user action
                  },
                ),
                IconButton(icon: Icon(Icons.refresh), onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
