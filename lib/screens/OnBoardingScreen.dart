import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import './page3.dart';


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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Konten Halaman (PageView)
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                isLastPage = index == 5;
                currentPage = index;
              }); // Cek jika halaman terakhir
            },
            children: [
              page1(),
              page2(),
              page3(),
              // Tambahkan halaman lainnya di sini
            ],
          ),
          // Navigasi Terpadu: Dots + Back + Next
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
            // Aksi saat klik di halaman terakhir (misal: Ke Home)
          }
        else
          {
            _controller.nextPage(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            ),
          },
      },
      icon: SvgPicture.asset("assets/icons/Group-4.svg", width: 65),
      hoverColor: Color.from(alpha: 0, red: 0, green: 0, blue: 0),
      highlightColor: Color.from(alpha: 0, red: 0, green: 0, blue: 0),
    );
  }

  Container StepProgressIndicator({int totalSteps = 4, int currentStep = 0}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black, // Background hitam lonjong
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
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index == currentStep
                    ? const Color(0xFF99FF99) // Warna hijau muda (aktif)
                    : Colors.white, // Warna putih (inaktif)
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
          child: SizedBox(
            width: double.infinity,
            child: Image.asset(
              'assets/images/image 2 (2).png',
              // fit: BoxFit.contain,
              // height: MediaQuery.of(context).size.height * 0.7,
            ),
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          left: 0,
          child: Container(
            width: double.infinity,
            child: Stack(
              children: [
                SvgPicture.asset("assets/icons/Vector11.svg", width: MediaQuery.of(context).size.width,),
                Positioned(
                  top: 100,
                  left: 30,
                  child: SvgPicture.asset("assets/icons/Atur kontak dengan mudah!.svg", width: 300),
                ),
              ],
            ),
          )
        ),
      ],
    );
  }
}

class page1 extends StatelessWidget {
  const page1({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gambar Teks 1 (Ayo)
        Positioned(
          top: 80,
          left: 20,
          child: Image.asset("assets/images/Group-8.png", width: 200),
        ),
        // Gambar Teks 2 (Jelajahi)
        Positioned(
          top: 180,
          right: 60,
          child: Image.asset("assets/images/Group-9.png", width: 300),
        ),
        // Gambar Tangan (Tengah ke bawah)
        Positioned(
          bottom: 100,
          left: 0,
          child: Image.asset(
            'assets/images/Hand.png',
            fit: BoxFit.contain,
            height: MediaQuery.of(context).size.height * 0.5,
          ),
        ),
      ],
    );
  }
}
