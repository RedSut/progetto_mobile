// Importa i pacchetti necessari
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async'; // Per gestire Timer e DateTime
import '../../models/bag.dart';
import '../../models/challenge.dart';
import '../../models/steps.dart';

// Definisce la schermata Rewards come Stateful perché deve aggiornare i timer nel tempo
class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

// Stato della schermata Rewards
class _RewardsPageState extends State<RewardsPage> {
  final Set<int> _claimedChallenges = {};
  final Set<int> _claimingChallenges = {};
  // Durate per il tempo rimanente di daily e weekly challenge
  Duration dailyRemaining = const Duration();
  Duration weeklyRemaining = const Duration();
  Duration hourlyRemaining = const Duration();
  Duration minuteRemaining = const Duration();
  // Timer periodico che aggiorna i countdown ogni minuto
  Timer? timer;
  // Prossima mezzanotte per la daily challenge
  DateTime nextMidnight = DateTime(0);
  // Prossima ora per la hourly challenge
  DateTime nextHour = DateTime(0);
  // Prossimo minuto per la minute challenge
  DateTime next15Minutes = DateTime(0);
  // Prossimo lunedì a mezzanotte per la weekly challenge
  DateTime nextMonday = DateTime(0);

  // Metodo chiamato appena la schermata viene creata
  @override
  void initState() {
    super.initState();
    _updateTimes(); // Prima inizializzazione dei tempi
    // Avvia un timer che ogni secondo aggiorna i tempi rimanenti
    timer = Timer.periodic(const Duration(minutes: 1), (Timer t) {
      _updateTimes();
    });
  }

  void updateTimers(){
    final now = DateTime.now(); // Data e ora attuali
    var diff1 = nextMidnight.difference(now);
    if (nextMidnight.year == 0 || diff1.inSeconds <= 60){
      // Prossima mezzanotte per la daily challenge
      nextMidnight = DateTime(now.year, now.month, now.day + 1);
    }
    var diff2 = nextHour.difference(now);
    if (nextHour.year == 0 || diff2.inSeconds <= 60){
      // Prossima ora per la hourly challenge
      nextHour = DateTime(now.year, now.month, now.day, now.hour + 1);
    }
    var diff3 = next15Minutes.difference(now);
    if (next15Minutes.year == 0 || diff3.inSeconds <= 60){
      // Prossimo minuto per la minute challenge
      int nextQuarterMinute = ((now.minute / 15).ceil() * 15) % 60;
      next15Minutes = DateTime(now.year, now.month, now.day, now.hour + (nextQuarterMinute == 0 ? 1 : 0), nextQuarterMinute);
    }
    var diff4 = nextMonday.difference(now);
    if (nextMonday.year == 0 || diff4.inSeconds <= 60){
      // Prossimo lunedì a mezzanotte per la weekly challenge
      nextMonday = DateTime(now.year, now.month, now.day)
          .add(Duration(days: (8 - now.weekday) % 7 == 0 ? 7 : (8 - now.weekday) % 7));
    }
  }

  // Calcola i tempi rimanenti per le challenge
    void _updateTimes() {
      final now = DateTime.now(); // Data e ora attuali
      updateTimers();

      // Aggiorna lo stato della schermata con i nuovi tempi rimanenti
      setState(() {
        dailyRemaining = nextMidnight.difference(now);
        weeklyRemaining = DateTime(nextMonday.year, nextMonday.month, nextMonday.day)
            .difference(now);
        hourlyRemaining = nextHour.difference(now);
        minuteRemaining = next15Minutes.difference(now);
      });
      // Ottieni challengeManager dal context
      final challengeManager = Provider.of<ChallengeManager>(context, listen: false);
      final stepsManager = Provider.of<StepsManager>(context, listen: false);
      // Se siamo entro 1 minuto dal reset, rimuove i claim sia a livello di
      // ChallengeManager che degli indici salvati localmente per la UI
      void removeClaim(String id) {
        for (var i = 0; i < challengeManager.challenges.length; i++) {
          if (challengeManager.challenges[i].id == id) {
            _claimedChallenges.remove(i);
          }
        }
        challengeManager.unclaimChallengeById(id);
      }
      if (dailyRemaining.inSeconds <= 60) {
        removeClaim('daily');
        removeClaim('daily_leppa');
        removeClaim('daily_rowap');
      }
      if (weeklyRemaining.inSeconds <= 60) {
        removeClaim('weekly');
      }
      if (hourlyRemaining.inSeconds <= 60) {
        removeClaim('hourly');
      }
      if (minuteRemaining.inSeconds <= 60) {
        removeClaim('minute');
      }
    }

  // Converte una Duration in stringa tipo "1d23h59m"
  String _formatDuration(Duration duration) {
    int days = duration.inDays;                                  // Numero di giorni interi
    int hours = duration.inHours.remainder(24);                   // Ore residue dopo i giorni
    int minutes = duration.inMinutes.remainder(60);               // Minuti residui dopo le ore

    String result = '';
    if (days > 0) result += '${days}d';                          // Aggiunge "Nd" se ci sono giorni
    if (hours > 0) result += '${hours}h';                        // Aggiunge "Nh" se ci sono ore
    if (minutes > 0) result += '${minutes}m';                    // Aggiunge "Nm" se ci sono minuti
    if (result.isEmpty) result = '0m';                           // Se tutto zero, mostra "0m"

    return result;
  }


  // Crea il widget grafico per una challenge
  Widget _buildChallenge({
    required Challenge challenge,
    required double progress,
    required VoidCallback onClaimPressed, // Funzione per aggiornare challenge.claimed
    required bool isClaiming,
    required bool isClaimed,
    required String duration,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12), // Spaziatura verticale
      padding: const EdgeInsets.all(16), // Padding interno
      decoration: BoxDecoration(
        color: Colors.green.shade800, // Colore sfondo box
        borderRadius: BorderRadius.circular(16), // Angoli arrotondati
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Allineamento a sinistra
        children: [
          // Titolo
          Text(
            "${challenge.title} $duration",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8), // Spaziatura
          // Descrizione obiettivo
          Text(
            description,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          // Barra di avanzamento
          LinearProgressIndicator(
            value: progress, // Valore di avanzamento
            backgroundColor: Colors.orange.shade100, // Colore sfondo barra
            color: Colors.orange, // Colore avanzamento
            minHeight: 8, // Altezza barra
          ),
          const SizedBox(height: 12),
          // Bottone "Claim Reward"
          AnimatedScale(
            scale: isClaiming ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: progress >= 1.0
                    ? Colors.orange  // Colore normale se attivo
                    : Colors.orange.withAlpha((255 * 0.3).round()), // Colore più trasparente se disabilitato
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Angoli arrotondati
                ),
              ),
              onPressed: (progress >= 1.0 && !isClaimed && !isClaiming)
                  ? onClaimPressed
                  : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // Centra il contenuto
                children: [
                  Text(
                    challenge.isClaimed ? 'CLAIMED' : 'CLAIM REWARD',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  // Quantità della ricompensa (es: "5x")
                  Text(
                    '${challenge.reward.quantity}x',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 5),
                  // Icona della ricompensa
                  Image.asset(
                    challenge.reward.item.imagePath,
                    width: 24,
                    height: 24,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  // Metodo chiamato quando la schermata viene chiusa
  @override
  void dispose() {
    timer?.cancel(); // Ferma il timer periodico
    super.dispose();
  }

  // Metodo che costruisce la schermata grafica
  @override
  Widget build(BuildContext context) {
    final stepsManager = Provider.of<StepsManager>(context);
    final challengeManager = Provider.of<ChallengeManager>(context);
    return Scaffold(
      backgroundColor: Colors.green.shade900, // Colore sfondo schermata
      appBar: AppBar(
        foregroundColor: Colors.orange,
        backgroundColor: Colors.green.shade900, // Colore sfondo AppBar
        title: const Text(
          'Rewards',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.orange,
            fontSize: 26,
          ),
        ),
        elevation: 0, // Nessuna ombra sotto la AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16), // Padding interno pagina
        child: SingleChildScrollView(
          // Permette di scorrere verticalmente se i contenuti superano lo schermo
          child: Column(
            children: [
              for (int i = 0; i < challengeManager.challenges.length; i++)
                (() {
                  final challenge = challengeManager.challenges[i];
                  if (!challenge.isClaimed) {
                    _claimedChallenges.remove(i);
                  }
                  final stepsTarget = challenge.getStepsTarget(stepsManager);
                  final description = challenge.getDescription(stepsManager);
                  double progress;
                  String duration = "";
                  if (challenge.id == 'minute') {
                    progress = stepsManager.minuteProgress.clamp(0.0, 1.0);
                    duration = '- ${_formatDuration(minuteRemaining)}';
                  } else if (challenge.id == 'hourly') {
                    progress = stepsManager.hourlyProgress.clamp(0.0, 1.0);
                    duration = '- ${_formatDuration(hourlyRemaining)}';
                  } else if (challenge.id == 'daily' || challenge.id == 'daily_leppa' || challenge.id == 'daily_rowap') {
                    progress = stepsManager.dailyProgress.clamp(0.0, 1.0);
                    duration = '- ${_formatDuration(dailyRemaining)}';
                  } else if (challenge.id == 'weekly') {
                    progress = stepsManager.weeklyProgress.clamp(0.0, 1.0);
                    duration = '- ${_formatDuration(weeklyRemaining)}';
                  } else {
                    progress = (stepsManager.steps / stepsTarget).clamp(0.0, 1.0);
                  }

                  return _buildChallenge(
                    description: description,
                    duration: duration,
                    challenge: challenge,
                    progress: progress,
                    isClaimed: challenge.isClaimed || _claimedChallenges.contains(i),
                    isClaiming: _claimingChallenges.contains(i),
                    onClaimPressed: () {
                      if (_claimedChallenges.contains(i) || _claimingChallenges.contains(i)) return;

                      setState(() {
                        _claimingChallenges.add(i);
                      });

                      final bag = Provider.of<Bag>(context, listen: false);
                      bag.addItem(challenge.reward.item, challenge.reward.quantity);

                      Future.delayed(const Duration(milliseconds: 300), () {
                      if (!mounted) return;
                      setState(() {
                      challengeManager.claimChallenge(challenge);
                      _claimedChallenges.add(i);
                      _claimingChallenges.remove(i);
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                      content: Text(
                      'You received ${challenge.reward.quantity}x ${challenge.reward.item.name}!',
                      ),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.green.shade600,
                      duration: const Duration(seconds: 3),
                          ),
                      );
                      });
                    },
                  );
                })(),
            ],
          ),
        ),
      ),
    );
  }
}
