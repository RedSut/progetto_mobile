import 'package:flutter/cupertino.dart';
import 'package:progetto_mobile/models/item.dart';
import 'package:progetto_mobile/models/storage_service.dart';

import 'reward.dart';

class Challenge {
  final String id;
  final String title;
  final String description;
  final Reward reward;
  final String duration;
  final int steps;
  bool isClaimed;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
    required this.duration,
    required this.steps,
    this.isClaimed = false,
  });
}

class ChallengeManager extends ChangeNotifier{
  final List<Challenge> challenges = [
    Challenge(
      id: 'daily',
      title: 'Daily Challenge',
      description: 'Walk for a total of 2000 steps',
      reward: Reward(
        id: 'rew_001',
        item: const Item(
          id: 'it_001',
          name: 'peach',
          imagePath: 'assets/peach.png',
          feedValue: 20,
        ),
        quantity: 5,
      ),
      duration:'',
      steps: 2000,
    ),
    Challenge(
      id: 'weekly',
      title: 'Weekly Challenge',
      description: 'Walk for a total of 10000 steps',
      reward: Reward(
        id: 'rew_002',
        item: const Item(
          id: 'it_002',
          name: 'carrot',
          imagePath: 'assets/carrot.png',
          feedValue: 15,
        ),
        quantity: 20,
      ),
      duration:'',
      steps: 10000,
    ),
    Challenge(
      id: 'ch_001',
      title: 'First steps!',
      description: 'Walk for a total of 1000 steps',
      reward: Reward(
        id: 'rew_002',
        item: const Item(
          id: 'it_003',
          name: 'strawberry',
          imagePath: 'assets/strawberry.png',
          feedValue: 10,
        ),
        quantity: 10,
      ),
      duration:'',
      steps: 1000,
    ),
    Challenge(
      id: 'ch_002',
      title: 'Runner',
      description: 'Walk for a total of 10000 steps',
      reward: Reward(
        id: 'rew_002',
        item: const Item(
          id: 'it_001',
          name: 'peach',
          imagePath: 'assets/peach.png',
          feedValue: 20,
        ),
        quantity: 20,
      ),
      duration:'',
      steps: 10000,
    ),
    Challenge(
      id: 'ch_003',
      title: 'Workaholic',
      description: 'Walk for a total of 100000 steps',
      reward: Reward(
        id: 'rew_002',
        item: const Item(
          id: 'it_002',
          name: 'carrot',
          imagePath: 'assets/carrot.png',
          feedValue: 15,
        ),
        quantity: 30,
      ),
      duration:'',
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