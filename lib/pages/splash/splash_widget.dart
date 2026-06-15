import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lottie/lottie.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/theme/app_theme.dart';
import 'splash_model.dart';

export 'splash_model.dart';

class SplashWidget extends StatefulWidget {
  const SplashWidget({super.key});

  static String routeName = 'Splash';
  static String routePath = '/splash';

  @override
  State<SplashWidget> createState() => _SplashWidgetState();
}

class _SplashWidgetState extends State<SplashWidget> {
  late SplashModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, SplashModel.new);

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(
        const Duration(
          milliseconds: 3000,
        ),
      );

      // Check if onboarding has been completed
      final hasCompletedOnboarding = FFAppState().hasCompletedOnboarding;

      if (hasCompletedOnboarding) {
        // Go to sign options if onboarding is done
        context.goNamed(
          SignOptionsWidget.routeName,
          extra: <String, dynamic>{
            '__transition_info__': const TransitionInfo(
              hasTransition: true,
              transitionType: TransitionType.scale,
              alignment: Alignment.bottomCenter,
              duration: Duration(milliseconds: 300),
            ),
          },
        );
      } else {
        // Go to onboarding if first time user
        context.goNamed(
          OnboardingWidget.routeName,
          extra: <String, dynamic>{
            '__transition_info__': const TransitionInfo(
              hasTransition: true,
              transitionType: TransitionType.scale,
              alignment: Alignment.bottomCenter,
              duration: Duration(milliseconds: 300),
            ),
          },
        );
      }
    });
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: AppTheme.of(context).primary,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Lottie.network(
                      'https://lottie.host/602e7112-9c2a-44bc-b6c5-4701c93ed1ca/QNoV3E7bwP.json',
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                      animate: true,
                    ),
                  ],
                ),
              ),
              Lottie.network(
                'https://lottie.host/b5fab63a-5e7f-44c8-81ba-c0ed419a96d5/xrUd8E401V.json',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
                animate: true,
              ),
            ],
          ),
        ),
      ),
    );
}
