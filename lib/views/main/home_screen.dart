import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF0FDF4), Colors.white],
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              _Header(),
              SizedBox(height: 16),
              //_IngredientStatus(),
              SizedBox(height: 24),
              //_SuggestSection(),
            ],
          ),
        ),
      )
      //bottomNavigationBar: _BottomNav(),
    );
  }
}

class _Header extends StatefulWidget {
  const _Header({super.key});

  @override
  State<_Header> createState() => __HeaderState();
}

class __HeaderState extends State<_Header> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/images/img_cook.png',
          width: 77,
          height: 73,
        ),
        const SizedBox(width: 12),
        const Text(
          'Chào buổi sáng',
          style: TextStyle(
            fontSize: 28,
            color: Color(0xFF075B33),
          ),
        ),
      ],
    );
  }
}