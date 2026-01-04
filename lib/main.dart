import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kitchen_assistant/views/login/login-and-intro.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';  
import 'views/home/home_screen.dart';
void main() async{
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690), // kích thước thiết kế chuẩn
      builder: (context, child) {
        return MaterialApp(
          title: 'Bếp Trợ Lý',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const FirstScreen(),
          routes: {
            '/login': (context) => const FirstScreen(),
            '/home': (context) => const Dashboard(),
            
          },
        );
      },
    );
  }
}
