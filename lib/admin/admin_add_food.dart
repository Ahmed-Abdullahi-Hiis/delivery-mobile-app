import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class AdminAddFood extends StatefulWidget {
  final String restaurantId;
  final String restaurantName;

  const AdminAddFood({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
  });

  @override
  State<AdminAddFood> createState() => _AdminAddFoodState();
}

class _AdminAddFoodState extends State<AdminAddFood> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  Uint8List? _pickedImage;
  bool _loading = false;

  // ================= PICK IMAGE =================
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? img = await picker.pickImage(source: ImageSource.gallery);

    if (img != null) {
      _pickedImage = await img.readAsBytes();
      setState(() {});
    }
  }

  // ================= CLOUDINARY UPLOAD =================
  Future<String?> uploadImage(Uint8List bytes, String fileName) async {
    const cloudName = 'dbuzpdgqo';
    const uploadPreset = 'ecommerce3';

    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', url);
    request.fields['upload_preset'] = uploadPreset;

    request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: fileName));

    final response = await request.send();
    final resStr = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(resStr);
      return data['secure_url'];
    } else {
      debugPrint("Upload error: $resStr");
      return null;
    }
  }

  // ================= SAVE FOOD =================
  Future<void> _saveFood() async {
    if (_nameCtrl.text.isEmpty || _priceCtrl.text.isEmpty || _pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields and pick image")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final imageUrl = await uploadImage(
        _pickedImage!,
        "${DateTime.now().millisecondsSinceEpoch}.jpg",
      );

      if (imageUrl == null) throw Exception("Image upload failed");

      await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(widget.restaurantId)
          .collection("menu")
          .add({
        "name": _nameCtrl.text.trim(),
        "price": double.parse(_priceCtrl.text),
        "imageUrl": imageUrl,
        "createdAt": Timestamp.now(),
      });

      _nameCtrl.clear();
      _priceCtrl.clear();
      setState(() => _pickedImage = null);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Food added successfully ✅")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Food — ${widget.restaurantName}")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // IMAGE
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _pickedImage == null
                        ? const Center(child: Text("Tap to pick image"))
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(_pickedImage!, fit: BoxFit.cover),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: "Food name"),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Price"),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _saveFood,
                    icon: const Icon(Icons.save),
                    label: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Save Food"),
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
