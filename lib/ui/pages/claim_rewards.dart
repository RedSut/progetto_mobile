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
  // Timer periodico che aggiorna i countdown ogni minuto
  Timer? timer;

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

  // Calcola i tempi rimanenti per le challenge
    void _updateTimes() {
    final now = DateTime.now(); // Data e ora attuali

    // Prossima mezzanotte per la daily challenge
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);

    // Prossimo lunedì a mezzanotte per la weekly challenge
    final nextMonday = DateTime(now.year, now.month, now.day)
        .add(Duration(days: (8 - now.weekday) % 7 == 0 ? 7 : (8 - now.weekday) % 7));

    // Aggiorna lo stato della schermata con i nuovi tempi rimanenti
    setState(() {
      dailyRemaining = nextMidnight.difference(now);
      weeklyRemaining = DateTime(nextMonday.year, nextMonday.month, nextMonday.day)
          .difference(now);
    });
    // Ottieni challengeManager dal context
    final challengeManager = Provider.of<ChallengeManager>(context, listen: false);

    // Se siamo entro 1 minuto dalla mezzanotte, resetta i claim delle daily e delle weekly
    if (dailyRemaining.inSeconds <= 60) {
      challengeManager.challenges[0].isClaimed = false;
    }
    if (weeklyRemaining.inSeconds <= 60) {
      challengeManager.challenges[1].isClaimed = false;
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
          ElevatedButton(
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
        backgroundColor: Colors.green.shade900, // Colore sfondo AppBar
        title: const Text(
          'Rewards',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.orange,
            fontSize: 26,
          ),
        ),
        actions: [
          // Bottone refresh manuale
          IconButton(
            onPressed: () {
              _updateTimes(); // Aggiorna tempi manualmente
            },
            icon: const Icon(Icons.refresh, color: Colors.orange),
          )
        ],
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
                  final stepsTarget = challenge.getStepsTarget(stepsManager);
                  final description = challenge.getDescription(stepsManager);
                  double progress;
                  String duration = "";
                  if (i == 0) {
                    progress = stepsManager.dailyProgress.clamp(0.0, 1.0);
                    duration = '- ${_formatDuration(dailyRemaining)}';
                  } else if (i == 1) {
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

                      setState(() {
                        challengeManager.claimChallenge(challenge);
                        //challenge.isClaimed = true;
                        _claimedChallenges.add(i);
                        _claimingChallenges.remove(i);
                      });

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Ricompensa riscattata!'),
                          content: Text('Hai ricevuto ${challenge.reward.quantity}x ${challenge.reward.item.name}!'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
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
