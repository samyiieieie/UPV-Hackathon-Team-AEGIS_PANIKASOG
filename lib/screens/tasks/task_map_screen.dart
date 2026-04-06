import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../models/task_model.dart';
import '../../services/location_service.dart';

class TaskMapScreen extends StatefulWidget {
  final TaskModel task;
  const TaskMapScreen({super.key, required this.task});

  @override
  State<TaskMapScreen> createState() => _TaskMapScreenState();
}

class _TaskMapScreenState extends State<TaskMapScreen> {
  final LocationService _locationService = LocationService();
  LatLng? _taskLocation;
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _getTaskLocation();
  }

  Future<void> _getTaskLocation() async {
    final address = '${widget.task.barangay}, ${widget.task.city}';
    final coords = await _locationService.getCoordinatesFromAddress(address);
    if (coords != null && mounted) {
      setState(() {
        _taskLocation = LatLng(coords['latitude']!, coords['longitude']!);
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
        _error = 'Location not found for this address.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Location'),
        backgroundColor: AppColors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_off, size: 48, color: AppColors.hintGrey),
                      const SizedBox(height: 12),
                      Text(_error, style: AppTextStyles.bodyMedium),
                    ],
                  ),
                )
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _taskLocation!,
                    zoom: 16,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('task'),
                      position: _taskLocation!,
                      infoWindow: InfoWindow(
                        title: widget.task.title,
                        snippet: '${widget.task.barangay}, ${widget.task.city}',
                      ),
                    ),
                  },
                ),
    );
  }
}