import 'dart:io';
import 'package:arogya/tabs/reportretrive.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

Future<File?> compressImage(File file) async {
  final result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    "${file.path}_compressed.jpg",
    quality: 50,
  );
  return result != null ? File(result.path) : null;
}

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  File? _image;
  String? _uploadedImageUrl;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Future<void> _requestPermissions() async {
    if (await Permission.camera.request().isDenied) {
      print("Camera permission is required");
      return;
    }
    if (await Permission.photos.request().isDenied) {
      print("Gallery access is required");
      return;
    }
  }

  Future<void> _pickImage() async {
    await _requestPermissions();
    try {
      final pickedFile = await ImagePicker()
          .pickImage(source: ImageSource.gallery); // Changed to gallery
      if (pickedFile == null) return;

      File? compressedImage = await compressImage(File(pickedFile.path));
      if (compressedImage != null) {
        setState(() {
          _image = compressedImage;
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> _uploadToCloudinary() async {
    if (_image == null) {
      print("Please select an image first!");
      return;
    }

    String uploadPreset = "alegria";
    var url =
        Uri.parse("https://api.cloudinary.com/v1_1/dhotsqn8t/image/upload");
    var request = http.MultipartRequest("POST", url);

    request.fields['upload_preset'] = uploadPreset;
    request.files.add(await http.MultipartFile.fromPath('file', _image!.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);

      setState(() {
        _uploadedImageUrl = jsonResponse['secure_url'];
      });

      print("Image uploaded: $_uploadedImageUrl");
    } else {
      print("Failed to upload image!");
    }
  }

  void _submitReport() async {
    if (_image == null) {
      print("Please upload an image.");
      return;
    }
    if (_descriptionController.text.isEmpty ||
        _locationController.text.isEmpty) {
      print("Please enter a description and location.");
      return;
    }
    await _uploadToCloudinary();

    if (_uploadedImageUrl != null) {
      // Storing data in Firebase Realtime Database
      DatabaseReference ref = _database.ref("reports").push();
      await ref.set({
        'imageUrl': _uploadedImageUrl,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Clear the fields
      setState(() {
        _image = null;
        _descriptionController.clear();
        _locationController.clear();
      });

      // Show success popup
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Report submitted successfully!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        // Wrap the entire content in a SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Report Pollution Crisis",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _image == null
                      ? Center(
                          child: Text("Upload an image",
                              style: TextStyle(color: Colors.black54)))
                      : Image.file(_image!, fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: 10),
              Text("Description for the image"),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(hintText: "Enter description"),
              ),
              SizedBox(height: 10),
              Text("Enter Your Location"),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(hintText: "Enter location"),
              ),
              SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: double.infinity, // Make the button full width
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: _submitReport,
                    child:
                        Text("Report", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
              ReportsListScreen()
            ],
          ),
        ),
      ),
    );
  }
}
