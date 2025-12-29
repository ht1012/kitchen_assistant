import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'viewmodels/virtualPantry/pantry_viewmodel.dart';
import 'views/home/home_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // === FIX: Chỉ initialize nếu chưa có app ===
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
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
          key: const ValueKey('pantry_provider'),
          create: (_) => PantryViewModel(),
          child: MaterialApp(
            title: 'Bếp Trợ Lý',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: const Dashboard(),
          ),
        );
      },
    );
  }
}
