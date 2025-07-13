import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class PinLocationScreen extends StatefulWidget {
  const PinLocationScreen({super.key});

  @override
  State<PinLocationScreen> createState() => _PinLocationScreenState();
}

class _PinLocationScreenState extends State<PinLocationScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  bool _locationPermissionGranted = false;
  LatLng? _selectedLatLng;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    var status = await Permission.locationWhenInUse.status;
    if (!status.isGranted) {
      status = await Permission.locationWhenInUse.request();
    }

    if (status.isGranted) {
      setState(() {
        _locationPermissionGranted = true;
      });
      _pinCurrentLocation();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission denied")),
      );
      setState(() {
        _locationPermissionGranted = true; // Still allow map without GPS
      });
    }
  }

  Future<void> _pinCurrentLocation() async {
    if (!_locationPermissionGranted) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final LatLng latLng = LatLng(position.latitude, position.longitude);

      _setMarker(latLng);

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(latLng, 17),
      );
    } catch (e) {
      // fallback to a default location if current not available
      const defaultLatLng = LatLng(20.5937, 78.9629);
      _setMarker(defaultLatLng);

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(defaultLatLng, 5),
      );
    }
  }

  void _setMarker(LatLng latLng) {
    setState(() {
      _markers.clear();
      _markers.add(Marker(
        markerId: const MarkerId('selected_location'),
        position: latLng,
        infoWindow: const InfoWindow(title: 'Selected Location'),
      ));
      _selectedLatLng = latLng;
    });
  }

  void _confirmLocation() {
    if (_selectedLatLng != null) {
      Navigator.pop(context, _selectedLatLng);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No location selected")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_locationPermissionGranted) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Select Location")),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              _mapController = controller;
            },
            initialCameraPosition: const CameraPosition(
              target: LatLng(20.5937, 78.9629), // India center as default
              zoom: 5,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onTap: (latLng) {
              _setMarker(latLng);
            },
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _confirmLocation,
              child: const Text("✅ Use This Location"),
            ),
          )
        ],
      ),
    );
  }
}
