import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/utils/utils.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../core/utils/lottie-decoder.dart';
// import 'package:lottie/lottie.dart';
import '../../authentication/logic/bloc/authentication.dart';
import '../../authentication/logic/event-state/authentication-event-state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.circleSize,
  });

  final double circleSize;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _canPlay = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 0), () {
      if (mounted) {
        setState(() => _canPlay = true);
      }
    });
    // After animation completes, navigate based on auth state
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        final authState = context.read<AuthenticationBloc>().state;
        final isLoggedIn = authState is Authenticated;
        
        // Navigate to appropriate screen based on auth state
        if (isLoggedIn) {
          context.go('/mainNavigation/0');
        } else {
          context.go('/onboarding');
        }
      }
    });
  }

  @override

  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(color: Colors.white),
          child: OverflowBox(
            maxHeight: 1000,
            maxWidth: 1000,
            minWidth: 0,
            minHeight: 0,
            child: Stack(
              alignment: Alignment.center,
              children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 1000, end: widget.circleSize),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOutQuint,
                builder: (context, size, _) {
                  return Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: Color(Kontaku.colors[1]),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              ),
              SvgPicture.asset(
                'assets/icons/LogoIcon.svg',
                height: widget.circleSize,
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
