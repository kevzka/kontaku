import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:kontaku/core/utils/utils.dart';
import '../../home-screen/ui/home-screen.dart';
import '../../contact-list-screen/ui/contact-list-screen.dart';
import '../../profile-screen/ui/profile-screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: _buildSelectedBody(),
      ),
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

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).shortestSide < 380;
    final widthPercent = isCompact ? 88 : 80;
    final navHeight = isCompact ? 86.0 : 100.0;
    final baseHeight = isCompact ? 62.0 : 70.0;

    return SizedBox(
      height: navHeight,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 1. Base Navbar Gelap (Melengkung di atas)
          Container(
            height: baseHeight,
            width: Kontaku.vw(100, context),
            decoration: BoxDecoration(
              color: _bgColor,
            ),
          ),

          // 2. Deretan Ikon Menu
          SizedBox(
            height: baseHeight,
            width: Kontaku.vw(widthPercent, context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildNavItem(0, Icons.home_rounded, widthPercent, navHeight),
                _buildNavItem(1, Icons.message, widthPercent, navHeight),
                _buildNavItem(1, Icons.phone, widthPercent, navHeight),
                _buildNavItem(
                  2,
                  Icons.manage_accounts,
                  widthPercent,
                  navHeight,
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
    double heightNavbar,
  ) {
    bool isSelected = selectedIndex == index;
    final activeColor = Color(Kontaku.colors[1]);
    final inactiveColor = Color(Kontaku.colors[2]);

    return GestureDetector(
      onTap: () {
        onItemSelected(index);
      },
      child: Container(
        width: 42,
        height: 42,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<Color?>(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOut,
              tween: ColorTween(
                begin: isSelected ? inactiveColor : activeColor,
                end: isSelected ? activeColor : inactiveColor,
              ),
              builder: (context, color, child) {
                return Icon(icon, color: color);
              },
            ),
            Text(
              ["Home", "Chat", "Call", "Profile"][index],
              style: TextStyle(
                fontSize: 10,
                color: Color(Kontaku.colors[2]),
              ),
            ),
          ],
        ),
      )
    );
  }
}
