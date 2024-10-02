import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SplashScr extends StatefulWidget {
  const SplashScr({Key? key, required this.crimeData}) : super(key: key);
  final List<Map<String, dynamic>> crimeData;

  @override
  _SplashScrState createState() => _SplashScrState();
}

class _SplashScrState extends State<SplashScr> {
  final MapController _mapController = MapController();
  int _selectedCrimeIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(23.5937, 78.9629),
              initialZoom: 5.0,
              onTap: (_, __) => setState(() => _selectedCrimeIndex = -1),
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
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
          Positioned(
            top: 16,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'zoomIn',
                  child: Icon(Icons.add),
                  onPressed: () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom + 1,
                    );
                  },
                ),
                SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'zoomOut',
                  child: Icon(Icons.remove),
                  onPressed: () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom - 1,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}