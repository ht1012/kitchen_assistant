import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    // 👉 Đặt màu cho thanh status bar để thấy giờ rõ ràng
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,         
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [const Color(0xFFF0FDF4), Colors.white],
            ),
          ),

          child: Column(
            children: [

              // ----------------------------------------------------
              //                     HEADER
              // ----------------------------------------------------
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                height: 205.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      width: 1.w,
                      color: const Color(0xFFF2F4F6),
                    ),
                  ),
                ),

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ảnh logo
                    Padding(
                      padding: EdgeInsets.only(top: 9.h),
                      child: Image.asset(
                        "assets/images/img_cook.png",
                        width: 77.w,
                        height: 73.h,
                        fit: BoxFit.contain,
                      ),
                    ),

                    SizedBox(width: 12.w),

                    // Texts
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20.h),

                        Text(
                          "Chào buổi sáng",
                          style: TextStyle(
                            color: const Color(0xFF075B33),
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        SizedBox(height: 12.h),

                        Text(
                          "Tình trạng nguyên liệu",
                          style: TextStyle(
                            color: const Color(0xFF697282),
                            fontSize: 14.8.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              // Nội dung bên dưới (tùy bạn thêm sau)
              Expanded(
                child: Center(
                  child: Text(
                    "Nội dung màn hình...",
                    style: TextStyle(fontSize: 18.sp),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
