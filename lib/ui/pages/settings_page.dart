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

    Navigator.pop(context); // chiude il drawer se è aperto
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Goals updated!',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.orange.shade200,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.orange.shade200;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set Your Goals',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _dailyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Daily Goal (steps)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
                prefixIcon: const Icon(Icons.directions_walk),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _weeklyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Weekly Goal (steps)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
                prefixIcon: const Icon(Icons.calendar_view_week),
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  await _saveGoals();
                  final stepsManager = Provider.of<StepsManager>(context, listen: false);
                  await stepsManager.loadGoals();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  backgroundColor: primaryColor,
                  elevation: 4,
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
