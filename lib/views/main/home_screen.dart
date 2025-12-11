import 'package:flutter/material.dart';

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0FDF4),
              Color(0xFFFFFFFF),
            ],
            stops: [0.0, 1.0],
          )
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeaderSection(context),
                    _buildQuestionSection(context),
                    _buildRecipeListSection(context),
                  ],
                ),
              )
            )
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }
}

Widget _buildHeaderSection(BuildContext context) {
  return Container(
  );
}
Widget _buildQuestionSection(BuildContext context) {
  return Container(
  );
}
Widget _buildRecipeListSection(BuildContext context) {
  return Container(
  );
}
Widget _buildBottomNavigation(BuildContext context) {
  return Container(
  );
}