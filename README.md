[![Codemagic build status](https://api.codemagic.io/apps/6867a3a3bdaba41a4c156bd3/6867a3a3bdaba41a4c156bd2/status_badge.svg)](https://codemagic.io/app/6867a3a3bdaba41a4c156bd3/6867a3a3bdaba41a4c156bd2/latest_build)
# progetto_mobile

Progetto mobile programming

## Getting Started

per importare librerie: da terminale di android studio "flutter pub get";

Librerie usate:
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

# Cosa fa per adesso l'app:
Tocco su “Feed him”:	La fame (non ancora mostrata) si aggiorna internamente
Apri Drawer (anche con swipe):	Vedi voci Bag, Stats, Settings

## Claim rewards
Creata la pagina che mostra una barra di progresso per ogni challenge e "sblocca" il pulsante per 
riscattare la ricompensa al suo completamento, una volta riscattata non sarà più possibile 
riscattarla di nuovo. Solo per le weekly e daily challenge c'è un timer che quando termina permette
di rifare la challenge. Il pulsante in alto a destra permette di aggiornare i timer manualmente, che
vengono comunque aggiornati automaticamente ogni minuto. Il pulsante a sinistra permette di tornare 
indietro alla home page.

## Bag
La pagina presenta una griglia in cui sono visualizzate tutte le ricompense riscattate nel tempo con 
la loro quantità. Nella parte inferiore c'è il mostriciattolo che cerca di incitarti con alcune 
frasi motivazionali.

*L'app NON salva ancora niente, nessun dato*

## Logica di fame e felicità:
Modifichiamo dinamicamente i valori di fame a seconda dei passi reali contati dal contapassi: 
vorrei che la fame scendesse di 2 ogni passo, e che la felicità aumenti di 1 ad ogni passo, 
ma se la fame scende sotto il 50% la felicità scenderà di 1 secondo ogni secondo. 
Ovviamente il sistema di storing dei passi resta lo stesso.
