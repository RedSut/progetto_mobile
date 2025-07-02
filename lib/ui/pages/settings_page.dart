import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/steps.dart';
import '../../models/storage_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _dailyController = TextEditingController();
  final _weeklyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final daily = await StorageService.getDailyGoal();
    final weekly = await StorageService.getWeeklyGoal();

    setState(() {
      _dailyController.text = daily.toString();
      _weeklyController.text = weekly.toString();
    });
  }

  Future<void> _saveGoals() async {
    final dailyGoal = int.tryParse(_dailyController.text) ?? 2000;
    final weeklyGoal = int.tryParse(_weeklyController.text) ?? 10000;

    await StorageService.saveDailyGoal(dailyGoal);
    await StorageService.saveWeeklyGoal(weeklyGoal);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Goals updated!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _dailyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Dayly Goal (steps)',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _weeklyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Weekly goal (steps)',
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                await _saveGoals();
                // Ricarica i goal nel StepsManager
                final stepsManager = Provider.of<StepsManager>(context, listen: false);
                await stepsManager.loadGoals();
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
