// Importa i pacchetti necessari
import 'package:flutter/material.dart';
import 'dart:async'; // Per gestire Timer e DateTime
import '../../models/steps.dart';

// Definisce la schermata Rewards come Stateful perché deve aggiornare i timer nel tempo
class RewardsPage extends StatefulWidget {
  const RewardsPage({Key? key}) : super(key: key);

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

// Stato della schermata Rewards
class _RewardsPageState extends State<RewardsPage> {
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
        .add(Duration(days: (8 - now.weekday) % 7));

    // Aggiorna lo stato della schermata con i nuovi tempi rimanenti
    setState(() {
      dailyRemaining = nextMidnight.difference(now);
      weeklyRemaining = DateTime(nextMonday.year, nextMonday.month, nextMonday.day)
          .difference(now);
    });
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
    required String title, // Titolo della challenge
    required String description, // Descrizione obiettivo
    required double progress, // Avanzamento (0.0 - 1.0)
    required String rewardText, // Quantità della ricompensa
    required String rewardImage, // Percorso immagine della ricompensa
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
            title,
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
            onPressed: progress >= 1.0 ? () {
              // TODO: Azione quando viene premuto (da implementare)
            } : null,  // Se progress < 1.0, il bottone è disabilitato
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // Centra il contenuto
              children: [
                const Text(
                  'CLAIM REWARD',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                // Quantità della ricompensa (es: "5x")
                Text(
                  rewardText,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 5),
                // Icona della ricompensa
                Image.asset(
                  rewardImage,
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
              // Daily Challenge
              _buildChallenge(
                title: 'Daily Challenge - ${_formatDuration(dailyRemaining)} left',
                description: 'Walk for a total of 2000 steps',
                progress: StepsManager().dailyProgress.clamp(0.0, 1.0),
                rewardText: '5x',
                rewardImage: 'assets/peach.png',
              ),
              // Weekly Challenge
              _buildChallenge(
                title: 'Weekly Challenge - ${_formatDuration(weeklyRemaining)} left',
                description: 'Walk for a total of 10000 steps',
                progress: StepsManager().weeklyProgress.clamp(0.0, 1.0),
                rewardText: '20x',
                rewardImage: 'assets/carrot.png',
              ),
              // Prima challenge "First steps!"
              _buildChallenge(
                title: 'First steps!',
                description: 'Walk for a total of 1000 steps',
                progress: StepsManager().steps / 1000,
                rewardText: '10x',
                rewardImage: 'assets/strawberry.png',
              ),
              // Seconda challenge "Runner"
              _buildChallenge(
                title: 'Runner',
                description: 'Walk for a total of 10000 steps',
                progress: StepsManager().steps / 10000,
                rewardText: '20x',
                rewardImage: 'assets/peach.png',
              ),
              // Terza challenge "workaholic"
              _buildChallenge(
                title: 'Workaholic',
                description: 'Walk for a total of 100000 steps',
                progress: StepsManager().steps / 100000,
                rewardText: '30x',
                rewardImage: 'assets/carrot.png',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
