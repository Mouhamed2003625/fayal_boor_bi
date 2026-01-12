// ============================================================================
// FICHIER : lib/config/api_config.dart  (ou lib/services/api_config.dart)
// ============================================================================
//
// Ce fichier définit **toutes les URLs de l’API PHP / MySQL**.
// C’est une “couche de configuration” essentielle pour :
//   - centraliser toutes les adresses de votre backend PHP,
//   - éviter de dupliquer les URLs dans le code Flutter (mauvaise pratique),
//   - faciliter la maintenance (si l’URL change → on ne modifie qu’ici),
//   - structurer une architecture API propre,
//   - garder une logique claire dans votre cours.
//
// Ce fichier est un support pédagogique EXCELLENT pour enseigner :
//   • les environnements réseau (localhost, simulateur Android, iOS, réseau local),
//   • comment organiser une architecture propre client / serveur,
//   • comment factoriser les endpoints d’une API REST,
//   • comment rendre le code plus propre et évolutif.
//
// ============================================================================

class ApiConfig {
  // ==========================================================================
  // 1. URL DE BASE (baseUrl)
  // ==========================================================================
  //
  // Cette URL représente la racine de votre API PHP.
  // Explication pédagogique essentielle :
  //
  //  → Flutter **ne peut pas appeler "localhost" directement** sur Android.
  //     Il faut utiliser des adresses spécifiques selon le device :
  //
  //     • Android Emulator (AVD) :
  //          http://10.0.2.2/api
  //
  //     • iOS Simulator :
  //          http://127.0.0.1/api
  //
  //     • Appareil physique :
  //          http://192.168.X.X/api   (IP du PC sur le réseau WiFi)
  //
  //     • Serveur distant en production :
  //          https://votre-domaine.com/api
  //
  // Le but est d’indiquer clairement dans votre cours **où mettre l’URL**,
  // et pourquoi cette différence existe entre chaque plateforme.
  //
  static const String baseUrl = 'http://localhost/fayal_boor_bi';

  // ==========================================================================
  // 2. ENDPOINTS API : construction d’URLs à partir de baseUrl
  // ==========================================================================
  //
  // Chaque méthode retourne l’URL complète vers un fichier PHP spécifique.
  //
  // BUT pédagogique : éviter de dupliquer les chemins partout dans le code.
  // Ainsi, lorsqu’on changera l’emplacement du backend (ou si on passe sur un
  // serveur en ligne), une seule ligne sera modifiée → baseUrl.
  //

  /// Endpoint pour créer un incident.
  /// Côté serveur : fichier PHP "incident_create.php".
  ///
  /// Utilisation côté Flutter :
  ///    final url = ApiConfig.createIncidentUrl();
  ///
  static String createDebtUrl() => '$baseUrl/debt_create.php';

  /// Endpoint pour lister tous les incidents (JSON).
  /// Côté serveur : fichier "incident_list.php".
  ///
  /// Exemple pédagogique :
  ///   - Flutter fait un GET sur cette URL,
  ///   - PHP récupère les données MySQL,
  ///   - renvoie un JSON,
  ///   - Flutter convertit ce JSON en liste d'objets Incident.
  ///
  static String listDebtUrl()   => '$baseUrl/debt_list.php';

  /// Endpoint pour supprimer un incident.
  /// Côté serveur : fichier "incident_delete.php".
  ///
  /// Exemple pédagogique :
  ///   - Flutter envoie un POST avec un ID,
  ///   - PHP supprime l’entrée MySQL correspondante,
  ///   - renvoie un message de confirmation.
  ///
  static String deleteDebtUrl()  => '$baseUrl/debt_delete.php';


  static String updateDebtUrl()   => '$baseUrl/debt_update.php';
}