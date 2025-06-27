import 'package:flutter/cupertino.dart';
import 'package:progetto_mobile/models/item.dart';

import 'reward.dart';

class Challenge {
  final String id;
  final String title;
  final String description;
  final Reward reward;
  final String duration;
  final int steps;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
    required this.duration,
    required this.steps,
  });
}

class ChallengeManager extends ChangeNotifier{
  final List<Challenge> challenges = [
    Challenge(
      id: 'daily',
      title: 'Daily Challenge',
      description: 'Walk for a total of 2000 steps',
      reward: Reward(id: 'rew_001', item: Item(id: 'it_001', name: 'peach', imagePath: 'assets/peach.png'), quantity: 5),
      duration:'',
      steps: 2000,
    ),
    Challenge(
      id: 'weekly',
      title: 'Weekly Challenge',
      description: 'Walk for a total of 10000 steps',
      reward: Reward(id: 'rew_002', item: Item(id: 'it_002', name: 'carrot', imagePath: 'assets/carrot.png'), quantity: 20),
      duration:'',
      steps: 10000,
    ),
    Challenge(
      id: 'ch_001',
      title: 'First steps!',
      description: 'Walk for a total of 1000 steps',
      reward: Reward(id: 'rew_002', item: Item(id: 'it_003', name: 'strawberry', imagePath: 'assets/strawberry.png'), quantity: 10),
      duration:'',
      steps: 1000,
    ),
    Challenge(
      id: 'ch_002',
      title: 'Runner',
      description: 'Walk for a total of 10000 steps',
      reward: Reward(id: 'rew_002', item: Item(id: 'it_001', name: 'peach', imagePath: 'assets/peach.png'), quantity: 20),
      duration:'',
      steps: 10000,
    ),
    Challenge(
      id: 'ch_003',
      title: 'Workaholic',
      description: 'Walk for a total of 100000 steps',
      reward: Reward(id: 'rew_002', item: Item(id: 'it_002', name: 'carrot', imagePath: 'assets/carrot.png'), quantity: 30),
      duration:'',
      steps: 100000,
    ),
  ];
}