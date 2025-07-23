import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/training_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<TrainingService>().fetchTrainings());
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final trainingService = context.watch<TrainingService>();

    if (!auth.isAuthenticated) {
      return const Scaffold(body: Center(child: Text('Niet ingelogd')));
    }

    if (trainingService.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Trainingen')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (trainingService.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Trainingen')),
        body: Center(child: Text(trainingService.error!)),
      );
    }

    final trainings = trainingService.trainings ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainingen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => trainingService.fetchTrainings(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              auth.logout();
              Navigator.of(context).pushReplacementNamed('/');
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: trainings.length,
        itemBuilder: (context, index) {
          final t = trainings[index];
          return ListTile(
            leading: Icon(
              t.isAttending ? Icons.check_circle : Icons.circle_outlined,
              color: t.isAttending ? Colors.green : null,
            ),
            title: Text(t.title),
            subtitle: Text(DateFormat.yMMMd().format(t.date)),
            onTap: () {
              Navigator.pushNamed(context, '/training', arguments: t);
            },
          );
        },
      ),
    );
  }
} 