import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kitchen_assistant/views/login/login-and-intro.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kitchen_assistant/views/recipes/suggested_recipes.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'viewmodels/virtualPantry/pantry_viewmodel.dart';
import 'views/home/home_screen.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase an toàn (tránh lỗi duplicate-app)
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    if (!e.toString().contains('duplicate-app')) {
      rethrow;
    }
  }

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690), // kích thước thiết kế chuẩn
      builder: (context, child) {
        return ChangeNotifierProvider(
          create: (_) => PantryViewModel(),
          child: MaterialApp(
            title: 'Bếp Trợ Lý',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: const FirstScreen(),
            initialRoute: '',
            routes: {
              '/home': (context) => const Dashboard(),
              '/home/recipes': (context) => const Recipes(),
            },
          ),
          
        );
      },
    );
  }
}
