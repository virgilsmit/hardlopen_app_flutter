import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/training.dart';
import 'auth_service.dart';

class TrainingService extends ChangeNotifier {
  final AuthService authService;

  TrainingService({required this.authService});

  List<Training>? _trainings;
  bool _isLoading = false;
  String? _error;

  List<Training>? get trainings => _trainings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTrainings() async {
    if (authService.token == null) {
      _error = 'Niet ingelogd';
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    const baseUrl = 'https://hardlopen.metvirgil.nl';
    final url = Uri.parse('$baseUrl/api/trainings');

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer ${authService.token}',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final list = (jsonDecode(response.body) as List)
            .map((e) => Training.fromJson(e as Map<String, dynamic>))
            .toList();
        _trainings = list;
        _error = null;
      } else {
        _error = 'Fout bij ophalen trainings';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Fetch trainings error: $e');
      }
      _error = 'Netwerkfout';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleAttendance(int trainingId, bool attend) async {
    if (authService.token == null) return;

    const baseUrl = 'https://hardlopen.metvirgil.nl';
    final url = Uri.parse('$baseUrl/api/trainings/$trainingId/attendance');

    try {
      final response = await http.post(url,
          headers: {
            'Authorization': 'Bearer ${authService.token}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'attending': attend}));

      if (response.statusCode == 200) {
        // Update local list
        final idx = _trainings?.indexWhere((t) => t.id == trainingId);
        if (idx != null && idx >= 0) {
          final old = _trainings![idx];
          _trainings![idx] = Training(
            id: old.id,
            date: old.date,
            title: old.title,
            warmup: old.warmup,
            core: old.core,
            cooldown: old.cooldown,
            isAttending: attend,
          );
          notifyListeners();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Toggle attendance error: $e');
      }
    }
  }

  Future<bool> uploadRoute({
    required int trainingId,
    required List<Map<String, dynamic>> points,
    required double distanceMeters,
    required int durationSeconds,
  }) async {
    if (authService.token == null) return false;

    const baseUrl = 'https://hardlopen.metvirgil.nl';
    final url = Uri.parse('$baseUrl/api/trainings/$trainingId/route');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${authService.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'distance': distanceMeters,
          'duration': durationSeconds,
          'points': points,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Upload route error: $e');
      }
      return false;
    }
  }
} 