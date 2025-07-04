import 'dart:async';
import 'dart:isolate';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:pedometer/pedometer.dart';

class StepForegroundTaskHandler extends TaskHandler {
  StreamSubscription<StepCount>? _stepSub;
  int _steps = 0;

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    _stepSub = Pedometer.stepCountStream.listen((e) {
      _steps = e.steps;
      sendPort?.send(_steps);
      FlutterForegroundTask.updateService(
        notificationText: 'Passi: $_steps',
      );
    }, onError: (_) {});
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    await _stepSub?.cancel();
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    // Qui puoi fare qualcosa ogni intervallo (es. log, check)
  }

}
