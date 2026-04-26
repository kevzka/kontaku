import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/utils.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool isLastPage = false;
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final isCompact = screenWidth < 380;

    return Scaffold(
      backgroundColor: Color(Kontaku.colors[3]),
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Konten Halaman (PageView)
            PageView(
              controller: _controller,
              onPageChanged: (index) {
                setState(() {
                  isLastPage = index == 3;
                  currentPage = index;
                }); // Cek jika halaman terakhir
              },
              children: [
                page1(),
                page2(),
                page3(),
                Container(
                  width: Kontaku.vw(100, context),
                  height: Kontaku.vh(100, context),
                  color: Color(Kontaku.colors[1]),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        bottom: 0,
                        child: SizedBox(
                          width: Kontaku.vw(100, context),
                          child: Center(
                            child: SvgPicture.asset(
                              "assets/icons/Mascot.svg",
                              width: screenWidth * (isCompact ? 0.74 : 0.8),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: screenHeight * (isCompact ? 0.2 : 0.22),
                        child: SizedBox(
                          width: Kontaku.vw(100, context),
                          child: Center(
                            child: SvgPicture.asset(
                              "assets/icons/Keamananmu prioritas kami!.svg",
                              width: screenWidth * (isCompact ? 0.82 : 0.86),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Tambahkan halaman lainnya di sini
              ],
            ),
            // // Navigasi Terpadu: Dots + Back + Next
            Positioned(
              bottom: isCompact ? 90 : 100,
              right: isCompact ? 6 : 10,
              child: IconButtonNext(),
            ),
            Positioned(
              bottom: isCompact ? 24 : 30,
              left: 0,
              right: 0,
              child: Center(
                child: StepProgressIndicator(
                  totalSteps: 4,
                  currentStep: currentPage,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconButton IconButtonNext() {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 380;

    return IconButton(
      onPressed: () => {
        if (isLastPage)
          {
            // Navigate to login screen after onboarding completion
            context.go('/loginScreen'),
          }
        else
          {
            _controller.nextPage(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            ),
          },
      },
      icon: isLastPage
          ? SvgPicture.asset(
              "assets/icons/NextButtonOnBoardScreenBlack.svg",
              width: isCompact ? 58 : 65,
            )
          : SvgPicture.asset(
              "assets/icons/NextButtonOnBoardScreenOrange.svg",
              width: isCompact ? 58 : 65,
            ),
      hoverColor: Color.from(alpha: 0, red: 0, green: 0, blue: 0),
      highlightColor: Color.from(alpha: 0, red: 0, green: 0, blue: 0),
    );
  }

  Container StepProgressIndicator({int totalSteps = 4, int currentStep = 0}) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 380;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 16 : 26,
        vertical: isCompact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        // color: Colors.black, // Background hitam lonjong
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(totalSteps, (index) {
          return Padding(
            padding: EdgeInsets.only(
              right: index == totalSteps - 1 ? 0 : (isCompact ? 20 : 40),
            ),
            child: Container(
              width: isCompact ? 14 : 20,
              height: isCompact ? 14 : 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index == currentStep
                    ? isLastPage ? Color(Kontaku.colors[0]) : Color(Kontaku.colors[0]) // Warna hijau muda (aktif)
                    : isLastPage ? Color(Kontaku.colors[3]) : Color(Kontaku.colors[1]), // Warna putih (inaktif)
              ),
            ),
          );
        }),
      ),
    );
  }
}

class page2 extends StatelessWidget {
  const page2({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Stack(
      children: [
        Positioned(
          top: 0,
          bottom: screenHeight * 0.47,
          child: SizedBox(
            // width: double.infinity,
            child: SvgPicture.asset(
              'assets/icons/People.svg',
              // fit: BoxFit.contain,
              width: Kontaku.vw(100, context),
            ),
          ),
        ),
        Center(
          child: Container(
            // width: double.infinity,
            width: Kontaku.vw(100, context),
            height: Kontaku.vh(100, context),
            decoration: BoxDecoration(color: const Color(0xFFF5F3E4)),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  bottom: 0,
                  child: SvgPicture.asset(
                    "assets/icons/Vector11.svg",
                    width: Kontaku.vw(100, context),
                  ),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    // Tambahkan ini
                    child: SvgPicture.asset(
                      "assets/icons/Atur kontak dengan mudah!.svg",
                      width: screenWidth * 0.86,
                      fit: BoxFit
                          .contain, // Memastikan gambar tetap proporsional
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class page3 extends StatelessWidget {
  const page3({super.key});
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Stack(
      children: [
        Center(
          child: Container(
            // width: double.infinity,
            width: Kontaku.vw(100, context),
            height: Kontaku.vh(100, context),
            decoration: BoxDecoration(color: const Color(0xFFF5F3E4)),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  bottom: MediaQuery.sizeOf(context).height * 0.56,
                  child: SizedBox(
                    width: Kontaku.vw(100, context),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/Phone.svg',
                        width: Kontaku.vw(30, context),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  child: SvgPicture.asset(
                    "assets/icons/Vector11.svg",
                    width: Kontaku.vw(100, context),
                  ),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    // Tambahkan ini
                    child: SvgPicture.asset(
                      "assets/icons/Pengalaman navigasi optimal.svg",
                      width: screenWidth * 0.86,
                      fit: BoxFit
                          .contain, // Memastikan gambar tetap proporsional
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class page1 extends StatelessWidget {
  const page1({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Kontaku.vw(100, context),
      height: Kontaku.vh(100, context),
      decoration: BoxDecoration(color: const Color(0xFFF5F3E4)),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            child: SvgPicture.asset(
              "assets/icons/Vector11.svg",
              width: Kontaku.vw(100, context),
            ),
          ),
          // Gambar Teks 1 (Ayo)
          Positioned(
            top: MediaQuery.sizeOf(context).height * 0.09,
            left: 20,
            child: SvgPicture.asset(
              "assets/icons/TeksAyo.svg",
              width: MediaQuery.sizeOf(context).width * 0.4,
            ),
          ),
          // Gambar Teks 2 (Jelajahi)
          Positioned(
            top: MediaQuery.sizeOf(context).height * 0.2,
            right: MediaQuery.sizeOf(context).width * 0.12,
            child: SvgPicture.asset(
              "assets/icons/TeksJelajahi.svg",
              width: MediaQuery.sizeOf(context).width * 0.72,
            ),
          ),
          // Gambar Tangan (Tengah ke bawah)
          Positioned(
            bottom: MediaQuery.sizeOf(context).height * 0.12,
            left: 0,
            child: Stack(
              children: [
                SvgPicture.asset(
                  "assets/icons/Hand.svg",
                  height: MediaQuery.of(context).size.height * 0.5,
                ),
                Positioned(
                  bottom: 0,
                  top: 0,
                  left: 100,
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/icons/LogoIcon.svg",
                      width: MediaQuery.of(context).size.height * 0.1,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
