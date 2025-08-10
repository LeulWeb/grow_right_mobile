import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// your data/models
import 'package:grow_right_mobile/data/goal_list.dart';
import 'package:grow_right_mobile/data/season_list_data.dart';
import 'package:grow_right_mobile/data/soild_list_data.dart';
import 'package:grow_right_mobile/models/season_model.dart';
import 'package:grow_right_mobile/models/soil_model.dart';

/// -------- Reverse geocoding with fallback (platform → OSM Nominatim → coords) --------
Future<String> reverseGeocodeWithFallback(double lat, double lng) async {
  // 1) Platform geocoder
  try {
    final placemarks = await geo.placemarkFromCoordinates(lat, lng);
    if (placemarks.isNotEmpty) {
      final p = placemarks.first;
      final parts =
          [p.street, p.locality, p.subLocality, p.administrativeArea, p.country]
              .where((e) => e != null && e!.trim().isNotEmpty)
              .map((e) => e!.trim())
              .toList();
      if (parts.isNotEmpty) return parts.join(', ');
    }
  } catch (_) {
    // ignore, try next
  }

  // 2) Nominatim (OpenStreetMap) fallback
  try {
    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lng',
    );
    final res = await http.get(
      uri,
      headers: {
        'User-Agent': 'grow_right_mobile/1.0 (contact: you@example.com)',
      },
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final display = data['display_name'];
      if (display is String && display.trim().isNotEmpty) return display;
    }
  } catch (_) {
    // ignore
  }

  // 3) Fallback to coordinates
  return '(${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)})';
}

/// ==============================================================================
/// AskRecommendationPage
/// ==============================================================================
class AskRecommendationPage extends StatefulWidget {
  const AskRecommendationPage({super.key});

  @override
  State<AskRecommendationPage> createState() => _AskRecommendationPageState();
}

class _AskRecommendationPageState extends State<AskRecommendationPage> {
  final _formKey = GlobalKey<FormState>();

  // Location (required)
  double? _lat;
  double? _lng;
  String? _address;
  final _addressController = TextEditingController();

  // Required selections
  Soil? _selectedSoil;
  Season? _selectedSeason;
  String? _selectedGoalValue;

  bool _hasIrrigation = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  // ---- Permissions & current location ----
  Future<bool> _ensureLocationPermission() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.')),
        );
      }
      return false;
    }

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied.')),
        );
      }
      return false;
    }
    if (perm == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Permission permanently denied. Enable it in Settings.',
            ),
          ),
        );
      }
      return false;
    }
    return true;
  }

  Future<void> _useCurrentLocation() async {
    try {
      final ok = await _ensureLocationPermission();
      if (!ok) return;

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final addr = await reverseGeocodeWithFallback(
        pos.latitude,
        pos.longitude,
      );

      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
        _address = addr;
        _addressController.text = addr;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get current location: $e')),
      );
    }
  }

  // ---- Map picker ----
  Future<void> _openMapPicker() async {
    final result = await Navigator.push<_PickedLocation?>(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickPage(
          initialCenter: LatLng(
            _lat ?? 8.9806,
            _lng ?? 38.7578,
          ), // default near Addis Ababa
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _lat = result.lat;
        _lng = result.lng;
        _address = result.address;
        _addressController.text = result.address;
      });
    }
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (_lat == null ||
        _lng == null ||
        (_address == null || _address!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please set your location.")),
      );
      return;
    }
    if (!isValid) return;

    final payload = {
      "lat": _lat,
      "lng": _lng,
      "address": _address,
      "soil_id": _selectedSoil!.id,
      "season_id": _selectedSeason!.id,
      "goal": _selectedGoalValue, // value string (not the key)
      "has_irrigation": _hasIrrigation,
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(payload);
    debugPrint("Recommendation payload:\n$jsonString");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Payload Logged"),
        content: SingleChildScrollView(child: Text(jsonString)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goalValues = goalList.values.toList(); // submit values only

    return Scaffold(
      appBar: AppBar(
        title: const Text("Find Best Crop"),
        actions: [
          IconButton(
            tooltip: "View Soils",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SoilCatalogPage()),
            ),
            icon: const Icon(Icons.landscape),
          ),
          IconButton(
            tooltip: "View Seasons",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SeasonCatalogPage()),
            ),
            icon: const Icon(Icons.calendar_month),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ---- Location ----
            Text("Location", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _addressController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "Address",
                      hintText: "Use current location or pick on map",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? "Address is required" : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: _openMapPicker,
                  icon: const Icon(Icons.map),
                  label: const Text("Pick on Map"),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ---- Soil ----
            DropdownButtonFormField<Soil>(
              decoration: const InputDecoration(
                labelText: "Soil Type",
                border: OutlineInputBorder(),
              ),
              value: _selectedSoil,
              items: soilLists
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text("${s.nameEn} (${s.nameAm})"),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedSoil = v),
              validator: (v) => v == null ? "Soil type is required" : null,
            ),
            const SizedBox(height: 16),

            // ---- Season ----
            DropdownButtonFormField<Season>(
              decoration: const InputDecoration(
                labelText: "Season",
                border: OutlineInputBorder(),
              ),
              value: _selectedSeason,
              items: seasonsList
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text("${s.nameEn} (${s.nameAm})"),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedSeason = v),
              validator: (v) => v == null ? "Season is required" : null,
            ),
            const SizedBox(height: 16),

            // ---- Goal (submit value) ----
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Goal",
                border: OutlineInputBorder(),
              ),
              value: _selectedGoalValue,
              items: goalValues
                  .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedGoalValue = v),
              validator: (v) =>
                  (v == null || v.isEmpty) ? "Goal is required" : null,
            ),
            const SizedBox(height: 16),

            // ---- Irrigation ----
            SwitchListTile(
              title: const Text("Has Irrigation"),
              value: _hasIrrigation,
              onChanged: (v) => setState(() => _hasIrrigation = v),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),

            // ---- Submit ----
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.agriculture),
                label: const Text("Get Crop Recommendation"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ==============================================================================
/// MapPickPage
/// ==============================================================================
class _PickedLocation {
  final double lat;
  final double lng;
  final String address;
  const _PickedLocation({
    required this.lat,
    required this.lng,
    required this.address,
  });
}

class MapPickPage extends StatefulWidget {
  final LatLng initialCenter;
  const MapPickPage({super.key, required this.initialCenter});

  @override
  State<MapPickPage> createState() => _MapPickPageState();
}

class _MapPickPageState extends State<MapPickPage> {
  LatLng? _picked;
  final MapController _mapController = MapController();
  bool _loadingAddr = false;
  String? _addrPreview;

  void _onMapTap(TapPosition tapPosition, LatLng latlng) async {
    setState(() {
      _picked = latlng;
      _loadingAddr = true;
      _addrPreview = null;
    });
    try {
      final addr = await reverseGeocodeWithFallback(
        latlng.latitude,
        latlng.longitude,
      );
      setState(() => _addrPreview = addr);
    } finally {
      if (mounted) setState(() => _loadingAddr = false);
    }
  }

  Future<void> _useCurrent() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services disabled.')),
          );
        }
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied)
        perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Permission denied.')));
        }
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final center = LatLng(pos.latitude, pos.longitude);
      _mapController.move(center, 15);
      _onMapTap(const TapPosition(Offset.zero, Offset.zero), center);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to get location: $e')));
      }
    }
  }

  void _confirm() {
    if (_picked == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tap on the map to pick a point.')),
      );
      return;
    }
    final addr =
        _addrPreview ??
        '(${_picked!.latitude.toStringAsFixed(5)}, ${_picked!.longitude.toStringAsFixed(5)})';
    Navigator.pop(
      context,
      _PickedLocation(
        lat: _picked!.latitude,
        lng: _picked!.longitude,
        address: addr,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final center = _picked ?? widget.initialCenter;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        actions: [
          IconButton(
            tooltip: 'Use Current',
            onPressed: _useCurrent,
            icon: const Icon(Icons.my_location),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 12,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'grow_right_mobile',
              ),
              if (_picked != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 40,
                      height: 40,
                      point: _picked!,
                      child: const Icon(Icons.location_pin, size: 40),
                    ),
                  ],
                ),
            ],
          ),
          if (_picked != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 90,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _loadingAddr
                      ? const Text('Resolving address…')
                      : Text(
                          _addrPreview ??
                              '(${_picked!.latitude.toStringAsFixed(5)}, ${_picked!.longitude.toStringAsFixed(5)})',
                        ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _confirm,
        icon: const Icon(Icons.check),
        label: const Text('Confirm'),
      ),
    );
  }
}

/// ==============================================================================
/// Catalog pages (unchanged)
/// ==============================================================================
class SoilCatalogPage extends StatelessWidget {
  const SoilCatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Soil Types")),
      body: ListView.separated(
        itemCount: soilLists.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final s = soilLists[i];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(
                s.image,
              ), // ensure assets in pubspec.yaml
              onBackgroundImageError: (_, __) {},
              child: const Icon(Icons.landscape),
            ),
            title: Text("${s.nameEn} (${s.nameAm})"),
            subtitle: Text("ID: ${s.id}  •  ${s.image}"),
          );
        },
      ),
    );
  }
}

class SeasonCatalogPage extends StatelessWidget {
  const SeasonCatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Seasons")),
      body: ListView.separated(
        itemCount: seasonsList.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final s = seasonsList[i];
          return ListTile(
            leading: const Icon(Icons.calendar_month),
            title: Text("${s.nameEn} (${s.nameAm})"),
            subtitle: Text(s.descriptionEn),
          );
        },
      ),
    );
  }
}
