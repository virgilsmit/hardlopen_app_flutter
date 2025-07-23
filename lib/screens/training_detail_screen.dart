import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/training.dart';
import '../services/training_service.dart';
import '../services/gps_service.dart';

class TrainingDetailScreen extends StatelessWidget {
  final Training training;
  const TrainingDetailScreen({super.key, required this.training});

  @override
  Widget build(BuildContext context) {
    final trainingService = context.read<TrainingService>();
    final gps = context.watch<GPSService>();
    return Scaffold(
      appBar: AppBar(
        title: Text(training.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Datum: ${training.date.toLocal().toString().split(' ')[0]}'),
            const SizedBox(height: 12),
            Text('Warming-up:', style: Theme.of(context).textTheme.titleMedium),
            Text(training.warmup),
            const SizedBox(height: 12),
            Text('Kern:', style: Theme.of(context).textTheme.titleMedium),
            Text(training.core),
            const SizedBox(height: 12),
            Text('Cooling-down:', style: Theme.of(context).textTheme.titleMedium),
            Text(training.cooldown),
            const Spacer(),
            if (gps.isTracking) ...[
              Text('Afstand: ${(gps.distanceMeters / 1000).toStringAsFixed(2)} km'),
              Text('Duur: ${_formatDuration(gps.duration)}'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  await gps.stopTracking();
                  final success = await trainingService.uploadRoute(
                    trainingId: training.id,
                    points: gps.points.map((e) => e.toJson()).toList(),
                    distanceMeters: gps.distanceMeters,
                    durationSeconds: gps.duration.inSeconds,
                  );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(success ? 'Training geüpload!' : 'Upload mislukt')));
                },
                child: const Text('Stop tracking'),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: () {
                  gps.startTracking();
                },
                child: const Text('Start tracking'),
              ),
            ],
            Center(
              child: ElevatedButton(
                onPressed: () {
                  trainingService.toggleAttendance(
                      training.id, !training.isAttending);
                  Navigator.pop(context);
                },
                child: Text(training.isAttending ? 'Afmelden' : 'Aanmelden'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

String _formatDuration(Duration d) {
  final hours = d.inHours;
  final minutes = d.inMinutes.remainder(60);
  final seconds = d.inSeconds.remainder(60);
  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
  return '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
} 