import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SplashScr extends StatefulWidget {
  const SplashScr({Key? key, required this.crimeData}) : super(key: key);
  final List<Map<String, dynamic>> crimeData;

  @override
  _SplashScrState createState() => _SplashScrState();
}

class _SplashScrState extends State<SplashScr> {
  final MapController _mapController = MapController();
  int _selectedCrimeIndex = -1;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchCity(String cityName) async {
    if (cityName.isEmpty) return;

    setState(() => _isSearching = true);
    const apiKey = 'oyLqwKTDuilIERXSgG5B';
    final encodedCity = Uri.encodeComponent(cityName);
    final url = 'https://api.maptiler.com/geocoding/$encodedCity.json?key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['features'].isNotEmpty) {
          final coordinates = data['features'][0]['center'];

          // Calculate appropriate zoom level based on place type
          double zoomLevel = 12.0;
          final placeType = data['features'][0]['place_type']?[0];
          if (placeType != null) {
            switch (placeType) {
              case 'country':
                zoomLevel = 5.0;
                break;
              case 'region':
              case 'state':
                zoomLevel = 7.0;
                break;
              case 'city':
                zoomLevel = 12.0;
                break;
              case 'district':
              case 'locality':
                zoomLevel = 14.0;
                break;
              default:
                zoomLevel = 12.0;
            }
          }

          // Move map to the searched location
          _mapController.move(LatLng(coordinates[1], coordinates[0]), zoomLevel);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location not found')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching location: $e')),
      );
    } finally {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const apiKey = 'oyLqwKTDuilIERXSgG5B';

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(23.5937, 78.9629),
              initialZoom: 5.0,
              onTap: (_, __) => setState(() => _selectedCrimeIndex = -1),
              interactionOptions: InteractionOptions(
                enableMultiFingerGestureRace: true,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=$apiKey',
                additionalOptions: const {
                  'apiKey': apiKey,
                },
              ),
              MarkerLayer(
                markers: List.generate(widget.crimeData.length, (index) {
                  final crime = widget.crimeData[index];
                  return Marker(
                    point: LatLng(crime['Latitude'], crime['Longitude']),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCrimeIndex = index),
                      child: Icon(
                        Icons.location_on,
                        color: _selectedCrimeIndex == index ? Colors.red : Colors.blue,
                        size: 40,
                      ),
                    ),
                  );
                }),
              ),
              CircleLayer(
                circles: widget.crimeData.map((crime) {
                  return CircleMarker(
                    point: LatLng(crime['Latitude'], crime['Longitude']),
                    radius: 10,
                    color: Colors.red.withOpacity(0.3),
                    borderColor: Colors.red,
                    borderStrokeWidth: 2,
                  );
                }).toList(),
              ),
            ],
          ),
          // Search Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search location...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        onSubmitted: (value) => _searchCity(value),
                      ),
                    ),
                    if (_isSearching)
                      Container(
                        width: 40,
                        height: 40,
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    else
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () => _searchCity(_searchController.text),
                      ),
                  ],
                ),
              ),
            ),
          ),
          // Crime Information Card
          if (_selectedCrimeIndex != -1)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.crimeData[_selectedCrimeIndex]['title'],
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Location: ${widget.crimeData[_selectedCrimeIndex]['location']}',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Date: ${widget.crimeData[_selectedCrimeIndex]['date']}',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
