import 'package:flutter/material.dart';
import 'package:pcte_event_management/Providers/login_provider.dart';
import 'package:pcte_event_management/Providers/pass_provider.dart';
import 'package:pcte_event_management/ui/forgot_email.dart';
import 'package:pcte_event_management/ui/home.dart';
import 'package:pcte_event_management/ui/otp.dart';
import 'package:pcte_event_management/ui/splashScreen.dart';
import 'package:provider/provider.dart';

import 'ui/login.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PassProvider(),),
        ChangeNotifierProvider(create: (context) => LoginProvider(),)
      ],
      child: MaterialApp(
        theme: ThemeData.from(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromRGBO(32, 63, 129, 1.0),
          ),
        ),
        home: HomeScreen(),
      ),
    );
  }
}
