// ============================================================================
//  MODÈLE : Debt (équivalent Incident PHP/MySQL)
// ============================================================================

/// Représente une dette ou un incident tel qu’il circule entre Flutter et PHP/MySQL.
/// Ce modèle est typé, structuré et sécurisé contre les données malformées.
class Debt {

  /// Identifiant unique de la dette (MySQL)
  final int id;

  /// Nom du client
  final String clientName;

  /// Numéro de téléphone du client
  final String phoneNumber;

  /// Montant de la dette
  final double amount;

  /// Description ou détails de la dette / achat
  final String description;

  final DateTime dates;

  /// Statut de paiement
  final bool isPaid;

  /// Identifiant de l’utilisateur ayant enregistré la dette
  final String? userId;

  /// Constructeur principal
  Debt({
    required this.id,
    required this.clientName,
    required this.phoneNumber,
    required this.amount,
    required this.description,
    required this.dates,
    required this.isPaid,
    this.userId,
  });

  // --------------------------------------------------------------------------
  // Factory constructor : création depuis JSON backend
  // --------------------------------------------------------------------------
  factory Debt.fromJson(Map<String, dynamic> j) => Debt(

    // ID : conversion robuste vers int
    id: int.tryParse('${j['id']}') ?? 0,

    // Nom client
    clientName: (j['clientName'] ?? '').toString(),

    // Numéro de téléphone
    phoneNumber: (j['phoneNumber'] ?? '').toString(),

    // Montant : conversion robuste vers double
    amount: j['amount'] is num
        ? (j['amount'] as num).toDouble()
        : double.tryParse(j['amount']?.toString() ?? '') ?? 0.0,

    // Description
    description: (j['description'] ?? '').toString(),

    // Date
    dates: j['dates'] != null
        ? DateTime.tryParse(j['dates'].toString()) ?? DateTime.now()
        : DateTime.now(),

    // Statut paiement : conversion bool
    isPaid: j['isPaid'] == true || j['isPaid'] == 1,

    // User ID optionnel
    userId: j['userId']?.toString(),
  );

  // --------------------------------------------------------------------------
  // Conversion vers Map (pour POST vers backend PHP)
  // --------------------------------------------------------------------------
  Map<String, dynamic> toMap() => {
    'id': id,
    'clientName': clientName,
    'phoneNumber': phoneNumber,
    'amount': amount,
    'description': description,
    'dates' : dates.toIso8601String(),
    'isPaid': isPaid ? 1 : 0,
    'userId': userId,
  };
}
