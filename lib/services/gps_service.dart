import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../models/route_point.dart';

class GPSService extends ChangeNotifier {
  bool _isTracking = false;
  List<RoutePoint> _points = [];
  StreamSubscription<Position>? _sub;
  double _distanceMeters = 0;
  DateTime? _startTime;

  bool get isTracking => _isTracking;
  List<RoutePoint> get points => List.unmodifiable(_points);
  double get distanceMeters => _distanceMeters;
  Duration get duration => _startTime == null ? Duration.zero : DateTime.now().difference(_startTime!);

  Future<bool> _ensurePermission() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    return perm == LocationPermission.always || perm == LocationPermission.whileInUse;
  }

  Future<void> startTracking() async {
    if (_isTracking) return;
    final ok = await _ensurePermission();
    if (!ok) return;

    _isTracking = true;
    _points = [];
    _distanceMeters = 0;
    _startTime = DateTime.now();

    _sub = Geolocator.getPositionStream(locationSettings: const LocationSettings(accuracy: LocationAccuracy.best)).listen((pos) {
      if (pos.latitude == 0 && pos.longitude == 0) return;
      final point = RoutePoint(latitude: pos.latitude, longitude: pos.longitude, timestamp: DateTime.now());
      if (_points.isNotEmpty) {
        final prev = _points.last;
        _distanceMeters += Geolocator.distanceBetween(prev.latitude, prev.longitude, point.latitude, point.longitude);
      }
      _points.add(point);
      notifyListeners();
    });
    notifyListeners();
  }

  Future<void> stopTracking() async {
    if (!_isTracking) return;
    await _sub?.cancel();
    _sub = null;
    _isTracking = false;
    notifyListeners();
  }

  void reset() {
    _points = [];
    _distanceMeters = 0;
    _startTime = null;
    notifyListeners();
  }
} 