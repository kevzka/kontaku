import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:kontaku/core/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../home-screen/ui/home-screen.dart';
import '../../contact-list-screen/ui/contact-list-screen.dart';
import '../../profile-screen/ui/profile-screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _buildSelectedBody(),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildSelectedBody() {
    if (_selectedIndex == 0) {
      // return ListView(
      //   children: [
      //     ContactTile(
      //       pathProfileImage: "assets/images/DonutProfile.jpg",
      //       name: "kevin",
      //       id: 1,
      //     ),
      //   ],
      // );
      return const HomeScreen();
    }

    if (_selectedIndex == 1) {
      return const Contactlistscreen2();
    }

    if (_selectedIndex == 2) {
      return const ProfileScreen();
    }

    return const Center(child: Text("not found"));
  }

  FutureBuilder<List<Contact>> ContactList() {
    return FutureBuilder<List<Contact>>(
      future: fetchContacts(), // Fungsi yang dipanggil
      builder: (context, snapshot) {
        // 1. Kondisi Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        // 2. Kondisi Error
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        // 3. Kondisi Data Ada
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          // for(var i in snapshot.data!){
          // print(i);
          // }
          // print(snapshot.data!.length);
          // print(snapshot.data![1]);
          // return Center(child: Text("Error:"));
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) => ContactTile(
              pathProfileImage: "assets/images/DonutProfile.jpg",
              name: snapshot.data![index].displayName,
              id: index,
            ),
          );
        }

        // 4. PENYELAMAT: Return terakhir jika semua kondisi di atas tidak terpenuhi
        // Ini yang mencegah error "body_might_complete_normally"
        return Center(child: Text("Tidak ada data"));
      },
    );
  }

  ListTile ContactTile({
    required String pathProfileImage,
    required String name,
    required int id,
  }) {
    return ListTile(
      onTap: () {
        // fireStoreRead();
        // firestoreAdd();
      },
      minTileHeight: 72,
      // leading: CircleAvatar(
      //   backgroundColor: Colors.white,
      //   backgroundImage: AssetImage(pathProfileImage),
      // ),
      title: Text(name),
    );
  }

  Future<List<Contact>> fetchContacts() async {
    print("terpanggil");
    if (await FlutterContacts.requestPermission()) {
      print("terpanggil flutter permission");
      // Get all contacts (lightly fetched)
      return await FlutterContacts.getContacts();
    } else {
      return [];
    }
  }
}

class CustomNavBar extends StatelessWidget {
  CustomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  final Color _bgColor = Color(
    Kontaku.colors[0],
  ); // Warna hitam abu gelap navbar
  static const widthNavbar = 80;
  static const heightNavbar = 100;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: heightNavbar
          .toDouble(), // Total tinggi seluruh area navbar (termasuk yang menonjol)
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 1. Base Navbar Gelap (Melengkung di atas)
          Container(
            height: 70,
            width: Kontaku.vw(widthNavbar, context),
            decoration: BoxDecoration(
              color: _bgColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(
                  heightNavbar * 0.7,
                ), // Membuat lengkungan setengah lingkaran
              ),
            ),
          ),

          // 2. Deretan Ikon Menu
          SizedBox(
            height: 100,
            width: Kontaku.vw(widthNavbar, context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, Icons.home_rounded, widthNavbar, heightNavbar),
                _buildNavItem(1, Icons.phone, widthNavbar, heightNavbar),
                _buildNavItem(
                  2,
                  Icons.manage_accounts,
                  widthNavbar,
                  heightNavbar,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk merender masing-masing tombol
  Widget _buildNavItem(
    int index,
    IconData icon,
    int widthNavbar,
    int heightNavbar,
  ) {
    double itemSize =
        heightNavbar * 0.5; // Ukuran ikon relatif terhadap tinggi navbar
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        onItemSelected(index);
      },
      child: SizedBox(
        height: heightNavbar.toDouble(),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeInOutCubicEmphasized,
          // Perpindahan posisi atas-bawah dibuat animasi halus, bukan loncat.
          alignment: isSelected ? Alignment.bottomCenter : Alignment.topCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutCubic,
            // Mengatur posisi vertikal agar pas dengan base navbar
            margin: EdgeInsets.only(
              bottom: isSelected ? 12 : 0,
              top: isSelected ? 0 : 15,
            ),
            width: itemSize,
            height: itemSize,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                18,
              ), // Membuatnya kotak melengkung
              // Trik Ilusi: Border tebal yang menyatu dengan base navbar
              border: isSelected
                  ? null // Hilangkan border saat aktif
                  : Border.all(color: _bgColor, width: 4),
            ),
            child: Icon(
              icon,
              size: 32,
              color: isSelected
                  ? Color(Kontaku.colors[1])
                  : Color(Kontaku.colors[0]),
            ),
          ),
        ),
      ),
    );
  }
}
