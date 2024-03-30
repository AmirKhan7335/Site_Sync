import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleMapsScreen extends StatefulWidget {
  const GoogleMapsScreen({Key? key}) : super(key: key);

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
            'Office Location',
            style: TextStyle(fontSize: 20.0, color: Colors.black),
          ),
        ),
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
    Key? key,
    required this.selectedLocation,
    required this.onLocationSelected,
  }) : super(key: key);

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
                onPressed: () {
                  widget.onLocationSelected(widget.selectedLocation!);
                  Navigator.pop(context, widget.selectedLocation.toString());
                },
                child: const Text("done"),
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
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search location',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _searchLocation(_searchController.text);
                  },
                ),
              ),
              onSubmitted: (value) {
                _searchLocation(value);
              },
            ),
          ),
        ),
      ],
    );
  }

  void _moveToCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    LatLng currentLocation = LatLng(position.latitude, position.longitude);
    widget.onLocationSelected(currentLocation);
    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(currentLocation, 15),
    );
  }

  Future<void> _moveToSelectedLocation() async {
    if (widget.selectedLocation != null) {
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(widget.selectedLocation!, 15),
      );
    }
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
