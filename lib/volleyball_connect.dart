import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/app_route.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/home/bloc/home_bloc.dart';
import 'features/home/data/repository/home_repository.dart';
import 'features/matches/bloc/matches_bloc.dart';
import 'features/matches/bloc/matches_event.dart';
import 'features/matches/data/repository/matches_repository.dart';

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
            BlocProvider<HomeBloc>(
              create: (context) => HomeBloc(HomeRepository()),
            ),
            BlocProvider<MatchesBloc>(
              create: (context) =>
                  MatchesBloc(MatchesRepository())
                    ..add(MatchesSubscriptionRequested()),
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
