import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'select_location_page.dart';

class ComplaintForm extends StatefulWidget {
  const ComplaintForm({super.key});

  @override
  State<ComplaintForm> createState() => _ComplaintFormState();
}

class _ComplaintFormState extends State<ComplaintForm> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String? _address;

  File? _pickedImage;
  LatLng? _selectedLocation;

  bool _loading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<String?> _uploadToCloudinary(File image) async {
    const cloudName = 'your_cloud_name';
    const uploadPreset = 'your_unsigned_upload_preset';

    final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final jsonResp = json.decode(respStr);
      return jsonResp['secure_url'];
    } else {
      return null;
    }
  }

  Future<void> _submit() async {
    if (_titleController.text.isEmpty ||
        _descController.text.isEmpty ||
        _pickedImage == null ||
        _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill all fields, pick image & location')),
      );
      return;
    }

    setState(() => _loading = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final docRef =
    FirebaseFirestore.instance.collection('complaints').doc();

    final imgUrl = await _uploadToCloudinary(_pickedImage!);

    if (imgUrl == null) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image')),
      );
      return;
    }

    await docRef.set({
      'title': _titleController.text.trim(),
      'description': _descController.text.trim(),
      'imageUrl': imgUrl,
      'status': 'Pending',
      'createdBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'location': GeoPoint(
          _selectedLocation!.latitude, _selectedLocation!.longitude),
      'address': _address ?? '',
    });

    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Complaint submitted!')),
    );

    Navigator.pop(context);
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) => const PinLocationScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedLocation = result;
        _address = null; // clear old address
      });

      final placemarks = await placemarkFromCoordinates(
          result.latitude, result.longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _address =
          '${place.name ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Raise a Complaint')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            if (_pickedImage != null)
              Image.file(_pickedImage!, height: 150),
            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Pick Image'),
            ),
            const SizedBox(height: 12),
            if (_selectedLocation != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_address != null && _address!.isNotEmpty)
                    Text(
                      '📍 Selected Address: $_address',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    )
                  else
                    Text(
                      '📍 Selected Coordinates: ${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}',
                    )
                ],
              ),
            ElevatedButton.icon(
              onPressed: _pickLocation,
              icon: const Icon(Icons.map),
              label: const Text('Select Location'),
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Submit Complaint'),
            ),
          ],
        ),
      ),
    );
  }
}
