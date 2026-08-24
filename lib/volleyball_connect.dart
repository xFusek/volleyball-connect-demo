import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/app_route.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';

class VolleyballConnect extends StatelessWidget {
  const VolleyballConnect({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(
              create: (context) => AuthBloc()..add(AuthCheckRequested()),
            ),
          ],
          child: MaterialApp.router(
            routerConfig: AppRoute.router,
            debugShowCheckedModeBanner: false,
            title: 'VolleyballConnect',
            theme: ThemeData(
              useMaterial3: true,
              scaffoldBackgroundColor: Colors.white,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFFC84E4E),
              ),
            ),
          ),
        );
      },
    );
  }
}