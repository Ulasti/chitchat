import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:chitchat/features/chat/views/chat_page.dart';
import 'package:chitchat/core/constants/app_colors.dart';
import 'package:chitchat/features/auth/viewmodels/login_viewmodel.dart';
import 'package:chitchat/features/auth/views/splash_view.dart';
import 'package:provider/provider.dart';

class UserListPage extends StatefulWidget {
  final IO.Socket socket;
  final String username;

  const UserListPage({super.key, required this.socket, required this.username});

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

  Future<void> performLogout() async {
    final vm = Provider.of<LoginViewModel>(context, listen: false);
    try {
      if (widget.socket.connected) {
        widget.socket.emit('logout', widget.username);
        widget.socket.disconnect();
        widget.socket.close();
      }

      await vm.clearSavedData(); // removes remember_me + saved_username

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => SplashPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
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
            onPressed: () => performLogout(),
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
                  fillColor: AppColors.appGrey,
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
            height: 560,
            width: double.infinity,
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (_, i) => GestureDetector(
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
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(width: 10),
                        CircleAvatar(
                          radius: 35,
                          backgroundImage: AssetImage('assets/images/pp.png'),
                          backgroundColor: Colors.transparent,
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              users[i],
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: AppColors.appPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 24,
                                  ),
                            ),
                            Text(
                              '${users[i]} ile sohbet',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.appBlack,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                            ),
                            SizedBox(height: 12),
                          ],
                        ),
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Text(
                            '00.00',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.appPrimary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 20,
                      ),
                      child: Divider(
                        height: 1,
                        color: AppColors.appBlack.withValues(alpha: 0.15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: AppColors.appPrimary,
        child: SizedBox(
          height: 86,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Image.asset(
                  'assets/icons/status.png',
                  width: 27,
                  height: 27,
                ),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: () {},
              ),
              SizedBox(width: 10),
              IconButton(
                icon: Image.asset(
                  'assets/icons/chats.png',
                  width: 27,
                  height: 27,
                ),
                onPressed: () {
                  //xd
                },
              ),
              SizedBox(width: 10),
              IconButton(
                icon: Image.asset(
                  'assets/icons/callhistory.png',
                  width: 27,
                  height: 27,
                ),
                onPressed: () {
                  //xd
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
