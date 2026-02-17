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
  static const String baseUrl = 'http://127.0.0.1/fayal_boor_bi';

  // ==========================================================================
  // 2. ENDPOINTS API : construction d’URLs à partir de baseUrl
  // ==========================================================================
  //

           /// DETTES ///

  /// Créer une dette
  static String createDebtUrl() => '$baseUrl/debts/debt_create.php';

  /// Lister toutes les dettes (optionnel : filtrage par userId ou clientId)
  static String listDebtUrl() => '$baseUrl/debts/debt_list.php';
  /// Mettre à jour une dette
  /// → l’ID est envoyé dans le body (POST) plutôt que dans l’URL
  static String updateDebtUrl() => '$baseUrl/debts/debt_update.php';

  /// Supprimer une dette
  static String deleteDebtUrl(int id) => '$baseUrl/debts/debt_delete.php?id=$id';

  /// Marquer une dette comme payée
  static String markDebtAsPaidUrl() => '$baseUrl/debts/debt_pay.php';


            /// CLIENTS ///


  static String listClientUrl()   => '$baseUrl/clients/list_client.php';

  static String listClientByIdUrl(int id)   => '$baseUrl/clients/list_client_byId.php';

  static String createClientUrl()   => '$baseUrl/clients/create_clients.php';

  static String updateClientUrl()   => '$baseUrl/clients/update_client.php';

  static String deleteClientUrl(int id)   => '$baseUrl/clients/delete_client.php';




  /// PAYMENTS ///
  static String createPaymentUrl()  => '$baseUrl/payments/create_payment.php';

  static String listPaymentUrl(int id)   => '$baseUrl/payments/list_payment.php';

  static String deletePaymentUrl(int id) => '$baseUrl/payments/delete_payment.php';

  static String updatePaymentUrl() => '$baseUrl/payments/update_payment.php';


}


