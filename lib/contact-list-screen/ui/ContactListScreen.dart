import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactListScreen extends StatelessWidget {
  const ContactListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: ContactList(),
      body: ListView(
        children: [
          ContactTile(
            pathProfileImage: "assets/images/DonutProfile.jpg",
            name: "kevin",
            id: 1,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        shape: const CircleBorder(
          side: BorderSide(color: Colors.white, width: 4),
        ),
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavBar(),
    );
  }

  BottomAppBar BottomNavBar() {
    return BottomAppBar(
      shape:
          const CircularNotchedRectangle(), // Memberikan efek lengkungan untuk FAB
      notchMargin: 8.0, // Jarak antara tombol dan lekukan bar
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.grey),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.star, color: Colors.orange),
            onPressed: () {},
          ),
          const SizedBox(width: 40), // Spasi kosong untuk tempat FAB di tengah
          IconButton(
            icon: const Icon(Icons.phone_outlined, color: Colors.grey),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
    );
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
        firestoreAdd();
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

  Future<void> fireStoreRead() async {
    final db = FirebaseFirestore.instance;
    try{
    await db.collection("category").where("uid", isEqualTo: "1234567890qwertyuiop").get().then((event) {
      for (var doc in event.docs) {
        print("${doc.id} => ${doc.data()}");
      }
    },
    onError: (e) => print("Error fetching data: $e")
    );
    }catch(e){
      print("Error fetching data: $e");
    }
  }

  Future<void> firestoreAdd() async {
    try{
    final db = FirebaseFirestore.instance;
    db
    .collection("category")
    .doc()
    .set({
      "uid": "1234567890qwertyuiop",
      "number": "081234567890",
      "category": "teman",
    })
    .onError((e, _) => print("Error writing document: $e"));
    print("Document successfully written!");
    }catch(e){
      print("Error writing document: $e");
    }
  }
}
