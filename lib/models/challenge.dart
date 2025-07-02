import 'package:flutter/cupertino.dart';
import 'package:progetto_mobile/models/item.dart';
import 'package:progetto_mobile/models/steps.dart';
import 'package:progetto_mobile/models/storage_service.dart';

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
    if (id == 'daily') {
      return stepsManager.dailyGoal;
    } else if (id == 'weekly') {
      return stepsManager.weeklyGoal;
    } else {
      return steps ?? 0;
    }
  }

  String getDescription(StepsManager stepsManager) {
    final target = getStepsTarget(stepsManager);
    if (id == 'daily') {
      return 'Walk for a total of $target steps today.';
    } else if (id == 'weekly') {
      return 'Walk for a total of $target steps this week.';
    } else {
      return 'Walk for a total of $target steps.';
    }
  }
}

class ChallengeManager extends ChangeNotifier{
  final List<Challenge> challenges = [
    Challenge(
      id: 'daily',
      title: 'Daily Challenge',
      reward: Reward(
        id: 'rew_001',
        item: ItemManager().getItemById("it_001"),
        quantity: 5,
      ),
    ),
    Challenge(
      id: 'weekly',
      title: 'Weekly Challenge',
      reward: Reward(
        id: 'rew_002',
        item: ItemManager().getItemById("it_002"),
        quantity: 20,
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
        item: ItemManager().getItemById("it_001"),
        quantity: 20,
      ),
      steps: 10000,
    ),
    Challenge(
      id: 'ch_003',
      title: 'Workaholic',
      reward: Reward(
        id: 'rew_002',
        item: ItemManager().getItemById("it_002"),
        quantity: 30,
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

  void resetClaimedChallenges(){
    for (var challenge in challenges){
      challenge.isClaimed = false;
    }
    notifyListeners();
  }
}