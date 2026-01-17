import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class AdminRestaurant extends StatefulWidget {
  const AdminRestaurant({super.key});

  @override
  State<AdminRestaurant> createState() => _AdminRestaurantState();
}

class _AdminRestaurantState extends State<AdminRestaurant> {
  final _nameCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _ratingCtrl = TextEditingController();

  bool _freeDelivery = true;
  bool _loading = false;
  Uint8List? _pickedImageBytes;

  // ================= PICK IMAGE =================
  Future<void> _pickImage() async {
    try {
      final img = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (img != null) {
        final bytes = await img.readAsBytes();
        setState(() {
          _pickedImageBytes = bytes;
        });
      }
    } catch (e) {
      _showError("Image pick failed: $e");
    }
  }

  // ================= UPLOAD TO CLOUDINARY =================
  Future<String?> uploadImage(Uint8List bytes) async {
    const cloudName = 'dbuzpdgqo';
    const uploadPreset = 'ecommerce3';

    final url =
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    try {
      final req = http.MultipartRequest('POST', url);
      req.fields['upload_preset'] = uploadPreset;
      req.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: "upload.jpg",
        ),
      );

      final res = await req.send().timeout(const Duration(seconds: 30));
      final text = await res.stream.bytesToString();

      if (res.statusCode == 200) {
        final data = jsonDecode(text);
        return data['secure_url'];
      } else {
        debugPrint(text);
        return null;
      }
    } catch (e) {
      debugPrint("Upload error: $e");
      return null;
    }
  }

  // ================= SAVE RESTAURANT =================
  Future<void> _saveRestaurant() async {
    if (_loading) return;

    if (_pickedImageBytes == null ||
        _nameCtrl.text.isEmpty ||
        _categoryCtrl.text.isEmpty ||
        _ratingCtrl.text.isEmpty) {
      _showError("Fill all fields and pick image");
      return;
    }

    setState(() => _loading = true);

    try {
      // 1️⃣ Upload image
      final imageUrl = await uploadImage(_pickedImageBytes!);

      if (imageUrl == null) {
        throw Exception("Image upload failed");
      }

      // 2️⃣ Save to Firestore
      await FirebaseFirestore.instance.collection("restaurants").add({
        "name": _nameCtrl.text.trim(),
        "category": _categoryCtrl.text.trim(),
        "rating": double.parse(_ratingCtrl.text),
        "freeDelivery": _freeDelivery,
        "imageUrl": imageUrl,
        "createdAt": Timestamp.now(),
      });

      // 3️⃣ Reset form
      _nameCtrl.clear();
      _categoryCtrl.clear();
      _ratingCtrl.clear();

      setState(() {
        _pickedImageBytes = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Restaurant added successfully ✅")),
      );
    } catch (e) {
      _showError("Failed: $e");
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Add Restaurant",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // IMAGE PICKER
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _pickedImageBytes == null
                        ? const Center(child: Text("Tap to pick image"))
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              _pickedImageBytes!,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: _nameCtrl,
                  decoration:
                      const InputDecoration(labelText: "Restaurant name"),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _categoryCtrl,
                  decoration: const InputDecoration(labelText: "Category"),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _ratingCtrl,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: "Rating (e.g 4.5)"),
                ),
                const SizedBox(height: 12),

                SwitchListTile(
                  value: _freeDelivery,
                  onChanged: (v) => setState(() => _freeDelivery = v),
                  title: const Text("Free Delivery"),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _saveRestaurant,
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Save Restaurant"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
