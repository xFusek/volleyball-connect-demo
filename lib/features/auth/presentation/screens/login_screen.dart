import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../utils/dialogs.dart';
import '../../../../utils/auth_validator.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';

enum LoginActionLoading { none, login, google }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  LoginActionLoading _loading = LoginActionLoading.none;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    final error = AuthValidator.validateLoginForm(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    setState(() => _loading = LoginActionLoading.login);

    context.read<AuthBloc>().add(
      AuthLoginRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ),
    );
  }

  void _onGooglePressed() {
    setState(() => _loading = LoginActionLoading.google);
    context.read<AuthBloc>().add(AuthGoogleSignInRequested());
  }

  void _resetLoading() {
    if (_loading != LoginActionLoading.none && mounted) {
      setState(() => _loading = LoginActionLoading.none);
    }
  }

  void _showResetPasswordDialog() {
    AppDialogs.showResetPasswordDialog(
      context: context,
      onSubmit: (email) {
        final error = AuthValidator.validateResetEmail(email);
        if (error != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error)));
          return;
        }

        context.read<AuthBloc>().add(AuthPasswordResetRequested(email: email));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'If your email is registered, you will receive a password reset link.',
            ),
            duration: Duration(seconds: 3),
          ),
        );
      },
    );
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
            final isLoginLoading = _loading == LoginActionLoading.login;
            final isGoogleLoading = _loading == LoginActionLoading.google;

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
                    Gap(24.h),
                    Text(
                      'Back on the court,',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Gap(6.h),
                    Text(
                      "your game, your rules. Let's do this!",
                      style: TextStyle(fontSize: 14.sp, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    Gap(24.h),
                    AuthTextField(
                      controller: _emailController,
                      labelText: 'E-mail',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    Gap(16.h),
                    AuthTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      icon: Icons.lock,
                      obscureText: true,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _showResetPasswordDialog,
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Gap(12.h),
                    AuthButton(
                      text: 'LOG IN',
                      type: AuthButtonType.primary,
                      isLoading: isLoginLoading,
                      onPressed: _onLoginPressed,
                    ),
                    Gap(16.h),
                    Text(
                      'OR',
                      style: TextStyle(fontSize: 16.sp, color: Colors.black45),
                      textAlign: TextAlign.center,
                    ),
                    Gap(16.h),
                    AuthButton(
                      text: 'SIGN IN WITH GOOGLE',
                      type: AuthButtonType.google,
                      isLoading: isGoogleLoading,
                      onPressed: _onGooglePressed,
                    ),
                    Gap(24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        TextButton(
                          onPressed: () => context.go('/signup'),
                          child: Text(
                            'SIGN UP',
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
