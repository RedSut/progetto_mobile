import 'package:flutter/cupertino.dart';
import 'package:progetto_mobile/models/item.dart';
import 'package:progetto_mobile/models/steps.dart';
import 'package:progetto_mobile/models/storage_service.dart';
import 'package:flutter/foundation.dart';

import 'reward.dart';

class Challenge {
  final String id;
  final String title;
  final Reward reward;
  final int? steps;
  bool isClaimed;

  Challenge({
    required this.id,
    required this.title,
    required this.reward,
    this.steps,
    this.isClaimed = false,
  });

  int getStepsTarget(StepsManager stepsManager) {
    if (id == 'daily' || id == 'daily_leppa' || id == 'daily_rowap') {
      return stepsManager.dailyGoal;
    } else if (id == 'weekly') {
      return stepsManager.weeklyGoal;
    } else if (id == 'hourly') {
      return stepsManager.hourlyGoal;
    } else if (id == 'minute') {
      return stepsManager.minuteGoal;
    } else {
      return steps ?? 0;
    }
  }

  String getDescription(StepsManager stepsManager) {
    final target = getStepsTarget(stepsManager);
    if (id == 'daily' || id == 'daily_leppa' || id == 'daily_rowap') {
      return 'Walk for a total of $target steps today.';
    } else if (id == 'weekly') {
      return 'Walk for a total of $target steps this week.';
    } else if (id == 'hourly') {
      return 'Walk for a total of $target steps this hour.';
    } else if (id == 'minute') {
      return 'Walk for a total of $target steps in this 15 minutes.';
    }  else {
      return 'Walk for a total of $target steps.';
    }
  }
}

class ChallengeManager extends ChangeNotifier{
  final List<Challenge> challenges = [
    Challenge(
      id: 'minute',
      title: '15 Minutes Challenge',
      reward: Reward(
        id: 'rew_m1',
        item: ItemManager().getItemById('it_001'),
        quantity: 1,
      ),
    ),
    Challenge(
      id: 'hourly',
      title: 'Hourly Challenge',
      reward: Reward(
        id: 'rew_h1',
        item: ItemManager().getItemById('it_002'),
        quantity: 3,
      ),
    ),
    Challenge(
      id: 'daily',
      title: 'Daily Pecha Challenge',
      reward: Reward(
        id: 'rew_001',
        item: ItemManager().getItemById("it_001"),
        quantity: 5,
      ),
    ),
    Challenge(
      id: 'daily_leppa',
      title: 'Daily Leppa Challenge',
      reward: Reward(
        id: 'rew_003',
        item: ItemManager().getItemById('it_002'),
        quantity: 7,
      ),
    ),
    Challenge(
      id: 'daily_rowap',
      title: 'Daily Rowap Challenge',
      reward: Reward(
        id: 'rew_004',
        item: ItemManager().getItemById('it_003'),
        quantity: 10,
      ),
    ),
    Challenge(
      id: 'weekly',
      title: 'Weekly Challenge',
      reward: Reward(
        id: 'rew_002',
        item: ItemManager().getItemById("it_001"),
        quantity: 35,
      ),
    ),
    Challenge(
      id: 'ch_001',
      title: 'First steps!',
      reward: Reward(
        id: 'rew_002',
        item: ItemManager().getItemById("it_003"),
        quantity: 10,
      ),
      steps: 1000,
    ),
    Challenge(
      id: 'ch_002',
      title: 'Runner',
      reward: Reward(
        id: 'rew_002',
        item: ItemManager().getItemById("it_002"),
        quantity: 25,
      ),
      steps: 10000,
    ),
    Challenge(
      id: 'ch_003',
      title: 'Workaholic',
      reward: Reward(
        id: 'rew_002',
        item: ItemManager().getItemById("it_001"),
        quantity: 50,
      ),
      steps: 100000,
    ),
  ];

  Future<void> loadClaimedStatuses() async {
    final claimedIds = await StorageService.getClaimedChallenges();
    for (var challenge in challenges) {
      challenge.isClaimed = claimedIds.contains(challenge.id);
    }
    notifyListeners();
  }

  void claimChallenge(Challenge challenge) async {
    challenge.isClaimed = true;
    final claimedIds = await StorageService.getClaimedChallenges();
    claimedIds.add(challenge.id);
    await StorageService.saveClaimedChallenges(claimedIds);
    notifyListeners();
  }

  Future<void> unclaimChallengeById(String id) async {
    try {
      final challenge = challenges.firstWhere((c) => c.id == id);
      if (!challenge.isClaimed) return;
      challenge.isClaimed = false;
      await StorageService.removeClaimedChallenge(id);
      notifyListeners();
    } catch (_) {
      // Challenge non trovata
    }
  }

  Future<void> resetClaimedChallenges() async {
    for (var challenge in challenges){
      challenge.isClaimed = false;
    }
    await StorageService.saveClaimedChallenges([]);
    notifyListeners();
  }
}