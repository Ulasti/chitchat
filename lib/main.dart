import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/viewmodels/login_viewmodel.dart';
import 'features/auth/views/launch_view.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => LoginViewModel())],
      child: MaterialApp(
        home: LaunchScreen(),
        theme: ThemeData().copyWith(
          textTheme: GoogleFonts.nunitoTextTheme(),
          colorScheme: ColorScheme.fromSwatch(),
        ),
      ),
    );
  }
}
