import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/login_viewmodel.dart';
import '../../chat/views/userlistpage.dart';
import 'package:chitchat/core/constants/app_colors.dart';
import 'package:chitchat/core/extensions/media_query.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  late LoginViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<LoginViewModel>(context, listen: false);
  }

  Future<void> _handleLogin(
    dynamic controller,
    TextEditingController passwordController,
  ) async {
    if (controller.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter a username')));
      return;
    }

    final success = await viewModel.loginUser(controller.text);

    if (success && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) =>
              UserListPage(socket: viewModel.socket, username: controller.text),
        ),
        (route) => false,
      );
    } else if (viewModel.errorMessage != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(viewModel.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Consumer<LoginViewModel>(
        builder: (context, viewModel, child) {
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppColors.appPrimary,
                      AppColors.appWhite.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  child: SizedBox(
                    height:
                        context.screenHeight -
                        MediaQuery.of(context).viewInsets.bottom,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 35,
                        right: 35,
                        top: 10,
                      ),

                      child: Column(
                        children: [
                          Text(
                            'Chit Chat',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: AppColors.appPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 45,
                                ),
                          ),
                          SizedBox(height: 200),
                          Text(
                            'Giriş Yap',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: AppColors.appBlack,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 24,
                                ),
                          ),
                          SizedBox(height: 25),
                          SizedBox(
                            width: context.screenWidth * 0.8,
                            height: context.screenHeight * 0.045,
                            child: TextField(
                              onTapOutside: (_) =>
                                  FocusScope.of(context).unfocus(),
                              controller: usernameController,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 10,
                                ),
                                prefixIcon: Icon(
                                  Icons.mail_outlined,
                                  color: AppColors.appPrimary.withValues(),
                                ),
                                hintText: 'E-mail',
                                labelStyle: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: AppColors.appBlack.withValues(
                                        alpha: 0.5,
                                      ),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                errorText: viewModel.errorMessage,
                                filled: true,
                                fillColor: AppColors.appWhite,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              enabled: !viewModel.isLoading,
                            ),
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            width: context.screenWidth * 0.80,
                            height: context.screenHeight * 0.045,
                            child: TextField(
                              onTapOutside: (_) =>
                                  FocusScope.of(context).unfocus(),
                              controller: passwordController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                                suffixIcon: Icon(
                                  Icons.visibility_off,
                                  color: AppColors.appBlack.withValues(),
                                  size: 15,
                                ),
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: AppColors.appPrimary.withValues(),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 10,
                                ),
                                hintText: 'Şifre',
                                labelStyle: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: AppColors.appBlack.withValues(
                                        alpha: 0.5,
                                      ),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                errorText: viewModel.errorMessage,
                                filled: true,
                                fillColor: AppColors.appWhite,
                              ),
                              enabled: !viewModel.isLoading,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Checkbox(
                                fillColor: WidgetStateProperty.all<Color>(
                                  Colors.white,
                                ),
                                activeColor: AppColors.appPrimary,
                                checkColor: AppColors.appBlack,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                side: BorderSide(
                                  color: AppColors.appBlack,
                                  width: 2,
                                ),
                                value: viewModel.isChecked,
                                onChanged: (value) {
                                  setState(() {
                                    viewModel.isChecked = value ?? false;
                                  });
                                },
                              ),
                              Text(
                                'Beni Hatırla',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: AppColors.appBlack,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                              ),
                            ],
                          ),
                          SizedBox(height: 180),
                          SizedBox(
                            width: context.screenWidth * 0.8,
                            height: context.screenHeight * 0.045,
                            child: ElevatedButton(
                              onPressed: () => _handleLogin(
                                usernameController,
                                passwordController,
                              ),
                              child: Text(
                                'Giriş Yap',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: AppColors.appBlack,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => UserListPage(
                                      socket: viewModel.socket,
                                      username: usernameController.text,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                'ChitChat Üyeliğin yok mu? Kayıt Ol',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: AppColors.appWhite,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
