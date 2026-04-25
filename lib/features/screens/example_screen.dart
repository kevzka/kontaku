import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';

class TesImgBB extends StatefulWidget {
  const TesImgBB({super.key});

  @override
  State<TesImgBB> createState() => _TesImgBBState();
}

class _TesImgBBState extends State<TesImgBB> {
  Uint8List? _pickedAvatarBytes;

  void _pickProfileImage() async {
    try {
      if (!mounted) {
        return;
      }
      final bytes = await pickAndCompressImage(context);
      setState(() {
        _pickedAvatarBytes = bytes;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memilih gambar: $e')));
    }
  }

  Future<void> _handleUploadImage() async {
    try {
      final uploadedUrl = await uploadImage(_pickedAvatarBytes!);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload berhasil: $uploadedUrl')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload gagal: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tes Imgbb")),
      body: Column(
        children: [
          Center(
            child: _pickedAvatarBytes != null
                ? Image.memory(_pickedAvatarBytes!)
                : Text("Belum ada gambar yang dipilih"),
          ),
          Center(
            child: ElevatedButton(
              onPressed: _pickProfileImage,
              child: Text("Pick Image"),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: _pickedAvatarBytes == null
                  ? null
                  : () => _handleUploadImage(),
              child: Text("Upload Image"),
            ),
          ),
        ],
      ),
    );
  }
}

Future<String> uploadImage(Uint8List imageBytes) async {
  try {
    const String IMGBB_API_KEY = "aced5b107ad1946e43cc4880c1d114fc";
    final String IMGBB_API_URL =
        "https://api.imgbb.com/1/upload?key=$IMGBB_API_KEY";

    final request = http.MultipartRequest('POST', Uri.parse(IMGBB_API_URL));
    request.files.add(
      http.MultipartFile.fromBytes('image', imageBytes, filename: 'upload.jpg'),
    );

    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    final Map<String, dynamic> resJson = jsonDecode(responseData);

    if (response.statusCode == 200 && resJson['success'] == true) {
      final url = resJson['data']?['url'] as String?;
      if (url != null && url.trim().isNotEmpty) {
        print("Image uploaded successfully: $url");
        return url;
      }
      throw Exception("Response tidak berisi URL");
    } else {
      throw Exception(
        "Failed to upload image: ${response.statusCode} - ${resJson['error']?['message'] ?? responseData}",
      );
    }
  } catch (e) {
    print("Error uploading image: $e");
    rethrow;
  }
}

Future<Uint8List?> pickAndCompressImage(BuildContext context) async {
  final ImagePicker Picker = ImagePicker();
  final XFile? pickedImage = await Picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 85,
  );
  if (pickedImage == null) {
    return null;
  }
  // Compress image before upload
  final XFile? compressedFile = await testCompressAndGetFile(pickedImage);
  final Uint8List bytes = await compressedFile!.readAsBytes();
  return bytes;
}

Future<XFile?> testCompressAndGetFile(XFile? file) async {
    if (file == null) return null;

    final File imageFile = File(file.path);
    final String targetPath =
        '${imageFile.parent.path}/compressed_${file.name}';

    try {
      final result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        quality: 80,
      );

      if (result == null) return null;

      // Convert result to String if it's XFile
      final String filePath = result is XFile ? result.path : result.toString();
      return XFile(filePath);
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }
