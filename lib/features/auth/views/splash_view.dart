import 'package:flutter/material.dart';
import 'package:chitchat/core/constants/app_colors.dart';
import 'package:chitchat/features/auth/views/login_view.dart';
import 'package:chitchat/core/extensions/media_query.dart';
import 'package:chitchat/features/auth/views/signup_view.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.appWhite,

      body: Stack(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: NeverScrollableScrollPhysics(),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/splashduo.png',
                  width: screenWidth * 1,
                  height: screenHeight * 1,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 90),
                  child: Image.asset(
                    'assets/images/splashwoman.png',
                    width: screenWidth * 1,
                    height: screenHeight * 1,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
          IgnorePointer(
            child: Container(
              width: double.infinity,
              height: screenHeight * 1,
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
          ),
          Center(
            child: Column(
              children: [
                SizedBox(height: 40),
                Text(
                  'Chit Chat',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.appPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 45,
                  ),
                ),
                SizedBox(height: 380),
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Text(
                    'Gerçek sohbetler için gerçek gizlilik.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.appWhite,
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: 40),
                SizedBox(
                  width: context.screenWidth * 0.8,
                  height: context.screenHeight * 0.045,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SignUpPage()),
                      );
                    },
                    child: Text(
                      'Kayıt Ol',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.appPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: context.screenWidth * 0.8,
                  height: context.screenHeight * 0.045,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => LoginPage()),
                      );
                    },
                    child: Text(
                      'Giriş Yap',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.appPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
