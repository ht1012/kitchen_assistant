import 'package:flutter/material.dart';

import 'views/core/utils/size_utils.dart';
import 'views/main/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Kitchen Assistant',
          theme: ThemeData(),
          home: const MyHome(),
        );
      },
    );
  }
}
