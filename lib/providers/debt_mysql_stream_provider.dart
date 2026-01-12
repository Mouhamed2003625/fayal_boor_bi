// ============================================================================
// COURS COMPLET — StreamProvider avec Polling MySQL (toutes les 3 secondes)
// ============================================================================
//
// Objectif pédagogique :
// ----------------------
// Montrer comment SIMULER du “temps réel” avec une base MySQL classique,
// en utilisant un StreamProvider Riverpod + un polling périodique.
//
// Ce pattern est indispensable lorsqu’on n’a pas de WebSocket / Firebase,
// mais qu’on veut tout de même :
//   ✓ mettre à jour automatiquement l’UI,
//   ✓ rafraîchir la liste à intervalle régulier,
//   ✓ séparer la logique (repo) de la couche présentation (widgets),
//
// Ce fichier est EXCELLENT pour enseigner :
//   - les Streams en Flutter,
//   - StreamController et Timer.periodic,
//   - Riverpod (StreamProvider.autoDispose),
//   - intégration avec un repository MySQL,
//   - gestion propre du cycle de vie (onDispose).
//
// ============================================================================


// -----------------------------------------------------------------------------
// Importation des bibliothèques nécessaires
// -----------------------------------------------------------------------------
import 'dart:async';
// → pour Stream, StreamController, Timer (polling)

import 'package:flutter_riverpod/flutter_riverpod.dart';
// → pour StreamProvider, autoDispose, ref.onDispose

import '../models/debt_model.dart';
// → modèle représentant un incident

import '../repositories/debt_repository.dart';
import '../services/debt_repository_mysql.dart' hide debtRepositoryMySqlProvider;
// → classe responsable d’appeler l’API PHP/MySQL



// ============================================================================
// PROVIDER : incidentsStreamProvider
// ============================================================================
//
// Ce provider expose **un Stream<List<Incident>>** rafraîchi automatiquement.
// L’idée :
//   - Appeler fetchIncidents() sur le backend MySQL,
//   - Toutes les 3 secondes → rafraîchir les données,
//   - Mettre à jour l’UI sans recharger la page,
//   - Auto-nettoyer les ressources si l’écran est quitté.
//
// Ce genre de provider remplace une WebSocket quand le backend n’en propose pas.
//
// ============================================================================

final incidentsStreamProvider =
StreamProvider.autoDispose<List<Debt>>((ref) {

  // ---------------------------------------------------------------------------
  // 1) Récupération du repository MySQL via Riverpod
  // ---------------------------------------------------------------------------
  //
  // incidentRepositoryMySqlProvider est un Provider du Repository.
  // Grâce à ref.read(), nous accédons aux fonctions :
  //   - fetchIncidents()
  //   - addIncident()
  //   - deleteIncident()
  //
  final repo = ref.read(debtRepositoryMySqlProvider);

  // ---------------------------------------------------------------------------
  // 2) Création du StreamController
  // ---------------------------------------------------------------------------
  //
  // Le StreamController permet :
  //   - d’injecter des données dans un Stream (controller.add)
  //   - d’injecter des erreurs (controller.addError)
  //   - de diffuser les données aux widgets via controller.stream
  //
  final controller = StreamController<List<Debt>>();

  // ---------------------------------------------------------------------------
  // 3) Fonction interne : load()
  // ---------------------------------------------------------------------------
  //
  // Cette fonction est appelée :
  //   - au démarrage,
  //   - puis toutes les 3 secondes via Timer.periodic.
  //
  // Elle :
  //   - contacte le backend,
  //   - récupère la liste des incidents,
  //   - l’ajoute dans le Stream.
  //
  Future<void> load() async {
    try {
      // Récupération des données depuis MySQL → via API PHP
      final data = await repo.fetchDebts();

      // Si le flux est toujours ouvert, on envoie les données
      if (!controller.isClosed) {
        controller.add(data);
      }

    } catch (e, st) {
      // Si erreur, on la transmet sous forme d’événement d’erreur dans le Stream
      if (!controller.isClosed) {
        controller.addError(e, st);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // 4) Premier chargement immédiat
  // ---------------------------------------------------------------------------
  //
  // Avant même que le Timer commence, on charge les données une première fois
  // pour éviter un écran vide.
  //
  load();

  // ---------------------------------------------------------------------------
  // 5) Mise en place du polling (toutes les 3 secondes)
  // ---------------------------------------------------------------------------
  //
  // Timer.periodic appelle `load()` à intervalle régulier.
  // Ce mécanisme permet de :
  //   - simuler du push temps réel
  //   - réactualiser les données sans action de l’utilisateur
  //
  final timer = Timer.periodic(
    const Duration(seconds: 3),
        (_) => load(),
  );

  // ---------------------------------------------------------------------------
  // 6) Nettoyage automatique (grâce à autoDispose)
  // ---------------------------------------------------------------------------
  //
  // autoDispose → dès que PLUS AUCUN widget n’écoute ce Provider,
  //               Riverpod le détruit automatiquement.
  //
  // ref.onDispose() est appelé à ce moment :
  //   - on annule le Timer (sinon boucle infinie)
  //   - on ferme le StreamController
  //
  ref.onDispose(() {
    timer.cancel();       // Arrêt du polling
    controller.close();   // Fermeture du Stream
  });

  // ---------------------------------------------------------------------------
  // 7) On expose finalement le Stream au StreamProvider
  // ---------------------------------------------------------------------------
  //
  // Dans l’UI, on utilisera :
  //
  //   final asyncList = ref.watch(incidentsStreamProvider);
  //
  return controller.stream;
});