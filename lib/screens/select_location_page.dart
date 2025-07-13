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
      // fallback to default
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
      appBar: AppBar(
        title: const Text(
          "Select Location",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          /// Google Map
          GoogleMap(
            onMapCreated: (controller) {
              _mapController = controller;
            },
            initialCameraPosition: const CameraPosition(
              target: LatLng(20.5937, 78.9629),
              zoom: 5,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onTap: (latLng) {
              _setMarker(latLng);
            },
          ),

          /// Optional overlay at center
          if (_selectedLatLng != null)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Selected: ${_selectedLatLng!.latitude.toStringAsFixed(4)}, ${_selectedLatLng!.longitude.toStringAsFixed(4)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),

          /// Confirm Button
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _confirmLocation,
                icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                label: const Text("Use This Location", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
