import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'viewmodels/virtualPantry/pantry_viewmodel.dart';
import 'views/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase 1 lần trước runApp
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
        return ChangeNotifierProvider(
          create: (_) => PantryViewModel(),
          child: MaterialApp(
            title: 'Bếp Trợ Lý',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: const Dashboard(), // Dashboard sẽ load dữ liệu async bên trong
          ),
        );
      },
    );
  }
}
