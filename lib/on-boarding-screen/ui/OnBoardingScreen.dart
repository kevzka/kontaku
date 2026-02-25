import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../utils/utils.dart';
import '../../screens/page3.dart';

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
    return Scaffold(
      backgroundColor: Color(Kontaku['color']![3]),
      body: Stack(
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
                width: vw(100, context),
                height: vh(100, context),
                color: Color(Kontaku['color']![1]),
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      bottom: 0,
                      child: SizedBox(
                        width: vw(100, context),
                        child: Center(
                          child: SvgPicture.asset(
                            "assets/icons/Mascot.svg",
                            // width: vw(100, context),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 180,
                      child: SizedBox(
                        width: vw(100, context),
                        child: Center(
                          child: SvgPicture.asset(
                            "assets/icons/Keamananmu prioritas kami!.svg",
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
          Positioned(bottom: 100, right: 10, child: IconButtonNext()),
          Positioned(
            bottom: 30,
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
    );
  }

  IconButton IconButtonNext() {
    return IconButton(
      onPressed: () => {
        if (isLastPage)
          {
            // Aksi saat klik di halaman terakhir (misal: Ke Home) route ke /ContachtList
            Navigator.pushReplacementNamed(context, '/contact-list'),
          }
        else
          {
            _controller.nextPage(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            ),
          },
      },
      icon: isLastPage ? SvgPicture.asset(
        "assets/icons/NextButtonOnBoardScreenBlack.svg",
        width: 65,
      ) : SvgPicture.asset(
        "assets/icons/NextButtonOnBoardScreenOrange.svg",
        width: 65,
      ),
      hoverColor: Color.from(alpha: 0, red: 0, green: 0, blue: 0),
      highlightColor: Color.from(alpha: 0, red: 0, green: 0, blue: 0),
    );
  }

  Container StepProgressIndicator({int totalSteps = 4, int currentStep = 0}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 5),
      decoration: BoxDecoration(
        // color: Colors.black, // Background hitam lonjong
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(totalSteps, (index) {
          return Padding(
            padding: EdgeInsets.only(
              right: index == totalSteps - 1 ? 0 : 40, // Jarak antar titik
            ),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index == currentStep
                    ? isLastPage ? Color(Kontaku['color']![0]) : Color(Kontaku['color']![0]) // Warna hijau muda (aktif)
                    : isLastPage ? Color(Kontaku['color']![3]) : Color(Kontaku['color']![1]), // Warna putih (inaktif)
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
    return Stack(
      children: [
        Positioned(
          top: 0,
          bottom: 380,
          child: SizedBox(
            // width: double.infinity,
            child: SvgPicture.asset(
              'assets/icons/People.svg',
              // fit: BoxFit.contain,
              width: vw(100, context),
            ),
          ),
        ),
        Center(
          child: Container(
            // width: double.infinity,
            width: vw(100, context),
            height: vh(100, context),
            decoration: BoxDecoration(color: const Color(0xFFF5F3E4)),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  bottom: 0,
                  child: SvgPicture.asset(
                    "assets/icons/Vector11.svg",
                    width: vw(100, context),
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
                      width: 340,
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
    return Stack(
      children: [
        Center(
          child: Container(
            // width: double.infinity,
            width: vw(100, context),
            height: vh(100, context),
            decoration: BoxDecoration(color: const Color(0xFFF5F3E4)),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  bottom: 450,
                  child: SizedBox(
                    width: vw(100, context),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/Phone.svg',
                        width: vw(30, context),
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
                    width: vw(100, context),
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
                      width: 340,
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
      width: vw(100, context),
      height: vh(100, context),
      decoration: BoxDecoration(color: const Color(0xFFF5F3E4)),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            child: SvgPicture.asset(
              "assets/icons/Vector11.svg",
              width: vw(100, context),
            ),
          ),
          // Gambar Teks 1 (Ayo)
          Positioned(
            top: 80,
            left: 20,
            child: SvgPicture.asset("assets/icons/TeksAyo.svg", width: 160),
          ),
          // Gambar Teks 2 (Jelajahi)
          Positioned(
            top: 180,
            right: 60,
            child: SvgPicture.asset(
              "assets/icons/TeksJelajahi.svg",
              width: 300,
            ),
          ),
          // Gambar Tangan (Tengah ke bawah)
          Positioned(
            bottom: 100,
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
