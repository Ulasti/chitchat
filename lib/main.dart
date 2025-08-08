import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/viewmodels/login_viewmodel.dart';
import 'features/auth/views/splash_view.dart';
import 'features/chat/views/userlistpage.dart';
import 'core/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: MaterialApp(
        title: 'Chit Chat',
        theme: ThemeData(
          textTheme: GoogleFonts.nunitoTextTheme(
            Theme.of(context).textTheme.apply(
              bodyColor: AppColors.appBlack,
              displayColor: AppColors.appBlack,
            ),
          ),
        ),
        home: AppInitializer(),
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  _AppInitializerState createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    final loginViewModel = Provider.of<LoginViewModel>(context, listen: false);

    await Future.delayed(Duration(seconds: 2));

    final hasAutoLogin = await loginViewModel.checkSavedLogin();

    if (hasAutoLogin && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => UserListPage(
            socket: loginViewModel.socket,
            username: loginViewModel.savedUsername,
          ),
        ),
      );
    } else if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SplashPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appPrimary,
      body: Center(
        child: Image.asset(
          'assets/icons/chitchatlogo.png',
          width: 183,
          height: 165,
        ),
      ),
    );
  }
}
