import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/utils.dart';
import 'package:go_router/go_router.dart';
import '../../utils/LottieDecoder.dart';
import 'package:lottie/lottie.dart';

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
    // Navigate to ContactListScreen after 2 seconds (animation duration + extra time)
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/onboarding');
      }
    });
  }

  @override

  Widget build(BuildContext context) {
    
    return Center(
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
                      color: Color(Kontaku['color']![1]),
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
    );
  }
}
