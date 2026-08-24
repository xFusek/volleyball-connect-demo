import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../utils/auth_validator.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';

enum SignupActionLoading { none, signup, google }

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;

  SignupActionLoading _loading = SignupActionLoading.none;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignupPressed() {
    final String? errorMessage = AuthValidator.validateSignupForm(
      fullName: _fullNameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
    );

    if (errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }

    setState(() => _loading = SignupActionLoading.signup);

    context.read<AuthBloc>().add(
      AuthSignUpRequested(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text.trim(),
      ),
    );
  }

  void _onGooglePressed() {
    setState(() => _loading = SignupActionLoading.google);
    context.read<AuthBloc>().add(AuthGoogleSignInRequested());
  }

  void _resetLoading() {
    if (_loading != SignupActionLoading.none) {
      setState(() => _loading = SignupActionLoading.none);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go('/');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              _resetLoading();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.error)));
            } else if (state is Authenticated) {
              _resetLoading();
              context.go('/home');
            } else if (state is Unauthenticated) {
              _resetLoading();
            }
          },
          builder: (context, state) {
            final bool isSignupLoading = _loading == SignupActionLoading.signup;
            final bool isGoogleLoading = _loading == SignupActionLoading.google;

            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Gap(10.h),
                    Center(
                      child: SvgPicture.asset(
                        'assets/icons/textWithlogo.svg',
                        height: 180.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Gap(16.h),
                    Text(
                      'Get On Board!',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Gap(6.h),
                    Text(
                      'Create your profile to start your journey',
                      style: TextStyle(fontSize: 14.sp, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    Gap(12.h),
                    AuthTextField(
                      controller: _fullNameController,
                      labelText: 'Full Name',
                      icon: Icons.person,
                    ),
                    Gap(16.h),
                    AuthTextField(
                      controller: _emailController,
                      labelText: 'E-Mail',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    Gap(16.h),
                    AuthTextField(
                      controller: _phoneController,
                      labelText: 'Phone Number',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    Gap(16.h),
                    AuthTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      icon: Icons.lock,
                      obscureText: true,
                    ),
                    Gap(24.h),
                    AuthButton(
                      text: 'SIGN UP',
                      type: AuthButtonType.primary,
                      isLoading: isSignupLoading,
                      onPressed: _onSignupPressed,
                    ),
                    Gap(8.h),
                    Text(
                      'OR',
                      style: TextStyle(fontSize: 16.sp, color: Colors.black45),
                      textAlign: TextAlign.center,
                    ),
                    Gap(8.h),
                    AuthButton(
                      text: 'SIGN UP WITH GOOGLE',
                      type: AuthButtonType.google,
                      isLoading: isGoogleLoading,
                      onPressed: _onGooglePressed,
                    ),
                    Gap(12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an Account?',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: Text(
                            'LOGIN',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}