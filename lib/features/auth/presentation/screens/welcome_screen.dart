import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../widgets/auth_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        children: [
                          Gap(80.h),
                          SvgPicture.asset(
                            'assets/icons/welcome_logo.svg',
                            height: 160.h,
                            fit: BoxFit.contain,
                          ),
                          Gap(24.h),
                          Text(
                            'VolleyballConnect',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Gap(12.h),
                          Text(
                            'Join the ultimate volleyball community where players and fans come together to inspire and be inspired, compete, and share their love for the game.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              height: 1.4,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),

                      Column(
                        children: <Widget>[
                          AuthButton(
                            text: 'LOGIN',
                            type: AuthButtonType.secondary,
                            onPressed: () => context.go('/login'),
                          ),
                          Gap(16.h),
                          AuthButton(
                            text: 'SIGN UP',
                            type: AuthButtonType.primary,
                            onPressed: () => context.go('/signup'),
                          ),
                          Gap(12.h),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}