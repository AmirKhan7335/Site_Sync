import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleMapsScreen extends StatefulWidget {
  const GoogleMapsScreen({super.key});

  @override
  State<GoogleMapsScreen> createState() => _GoogleMapsScreenState();
}

class _GoogleMapsScreenState extends State<GoogleMapsScreen> {
  LatLng? selectedLocation = const LatLng(33.6844, 73.0479);

  @override
  void initState() {
    super.initState();
    _loadSelectedLocation();
  }

  Future<void> _loadSelectedLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? locationString = prefs.getString('selectedLocation');
    if (locationString != null && locationString.isNotEmpty) {
      List<String> locationParts = locationString.split(',');
      double latitude = double.parse(locationParts[0]);
      double longitude = double.parse(locationParts[1]);
      setState(() {
        selectedLocation = LatLng(latitude, longitude);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Office Location        ',
            style: TextStyle(fontSize: 20.0, color: Colors.black),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMapWidget(
              selectedLocation: selectedLocation,
              onLocationSelected: (newLocation) {
                setState(() {
                  selectedLocation = newLocation;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class GoogleMapWidget extends StatefulWidget {
  final LatLng? selectedLocation;
  final Function(LatLng) onLocationSelected;

  const GoogleMapWidget({
    super.key,
    required this.selectedLocation,
    required this.onLocationSelected,
  });

  @override
  GoogleMapWidgetState createState() => GoogleMapWidgetState();
}

class GoogleMapWidgetState extends State<GoogleMapWidget> {
  late GoogleMapController mapController;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (controller) {
            mapController = controller;
            _moveToSelectedLocation();
          },
          initialCameraPosition: CameraPosition(
            target: widget.selectedLocation ?? const LatLng(33.6844, 73.0479),
            zoom: 15,
          ),
          onTap: (latLng) {
            _updateSelectedLocation(latLng);
          },
          markers: {
            if (widget.selectedLocation != null)
              Marker(
                markerId: const MarkerId('selected_location'),
                position: widget.selectedLocation!,
              ),
          },
          myLocationEnabled: true,
          compassEnabled: true,
          mapType: MapType.normal,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          buildingsEnabled: true,
          onCameraMove: (position) {
            // Uncomment the following line to clear selectedLocation on camera move
            // widget.onLocationSelected('');
          },
        ),
        Positioned(
          bottom: 16.0,
          right: 56.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton(
                backgroundColor: Colors.blue,
                onPressed: _moveToCurrentLocation,
                child: const Icon(Icons.my_location),
              ),
              const SizedBox(width: 16),
              FloatingActionButton(
                backgroundColor: Colors.blue,
                onPressed: () async {
                  if (widget.selectedLocation != null) {
                    // Get descriptive address from latitude and longitude
                    String address = await _getAddressFromLatLng(widget.selectedLocation!);
                    // Pass the address to the previous screen
                    Navigator.pop(context, address);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Location not selected'),
                      ),
                    );
                  }
                },
                child: const Text("Done"),
              ),

            ],
          ),
        ),
        Positioned(
          top: 16.0,
          left: 16.0,
          right: 16.0,
          child: Container(
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: Colors.black), // Set text color to black
                      textAlignVertical: TextAlignVertical.center, // Align text vertically in the center
                      decoration: const InputDecoration(
                        hintText: 'Search location',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (value) {
                        _searchLocation(value);
                      },
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  color: Colors.black, // Set icon color to black
                  onPressed: () {
                    _searchLocation(_searchController.text);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _moveToCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // If location services are disabled, prompt the user to enable them
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enable location services'),
        ),
      );
      return;
    }

    // Check if the app has permission to access the device's location
    bool permissionGranted = await _checkLocationPermission();
    if (!permissionGranted) {
      // If location permission is not granted, request permission from the user
      permissionGranted = await _requestLocationPermission();
      if (!permissionGranted) {
        // If permission is still not granted, show a message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission is required to access current location'),
          ),
        );
        return;
      }
    }

    try {
      // Try to get the current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      LatLng currentLocation = LatLng(position.latitude, position.longitude);

      // Update selectedLocation indirectly through the onLocationSelected callback
      widget.onLocationSelected(currentLocation);

      // Animate camera to current location
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(currentLocation, 15),
      );

      // Trigger a rebuild of the GoogleMapWidget to reflect the updated selectedLocation
      setState(() {});
    } catch (e) {
      // Handle any errors that occur during location retrieval
      print('Error getting current location: $e');
      // You might want to show a snackbar or some other feedback to the user
    }
  }

// Function to check if the app has permission to access the device's location
  Future<bool> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

// Function to request permission to access the device's location
  Future<bool> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }



  Future<void> _moveToSelectedLocation() async {
    if (widget.selectedLocation != null) {
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(widget.selectedLocation!, 15),
      );
    }
  }

  Future<String> _getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // Filter out plus codes and prioritize more common address components
        String street = place.street ?? place.thoroughfare ?? place.subLocality ?? place.locality ?? '';
        if (street.contains('+')) { // Check if street contains a plus code
          street = ''; // Clear the street if it has a plus code
        }

        String address = '${street.isNotEmpty ? '$street, ' : ''}'
            '${place.subLocality ?? ''}${place.subLocality != null ? ', ' : ''}'
            '${place.locality ?? ''}${place.locality != null ? ', ' : ''}'
            '${place.country ?? ''}';

        return address.trim();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching address: $e');
      }
    }
    return '';
  }







  void _searchLocation(String query) async {
    List<Location> locations = await locationFromAddress(query);
    if (locations.isNotEmpty) {
      Location location = locations.first;
      widget.onLocationSelected(LatLng(location.latitude, location.longitude));
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(location.latitude, location.longitude),
          15,
        ),
      );
    }
  }

  void _updateSelectedLocation(LatLng latLng) {
    widget.onLocationSelected(latLng);
  }
}
