// ============================================================================
//  MODÈLE : Debt (avec clé étrangère vers Client)
// ============================================================================

import 'client_model.dart';

/// Représente une dette associée à un client spécifique.
class Debt {
  /// Identifiant unique de la dette
  final int id;

  /// Clé étrangère vers le client (ID du client)
  final String clientId;

  /// Référence au client (optionnel - pour éviter de charger à chaque fois)
  final Client? client;

  /// Montant de la dette
  final double amount;

  /// Description ou détails de la dette / achat
  final String description;

  /// Date de création de la dette
  final DateTime createdAt;

  /// Date d'échéance de la dette
  final DateTime dueDate;

  /// Date de paiement (null si non payée) - CORRECTION: nullable
  final DateTime? dates;

  /// Statut de paiement (calculé) - CORRECTION: dates peut être null
  bool get isPaid => dates != null;

  /// Méthode de paiement (espèces, mobile money, virement, etc.)
  final String? paymentMethod;

  /// Référence du paiement (numéro de transaction, etc.)
  final String? paymentReference;

  /// Notes supplémentaires
  final String? notes;

  /// Identifiant de l'utilisateur ayant enregistré la dette
  final String? userId;

  /// Constructeur principal - CORRECTION: dates est nullable
  Debt({
    required this.id,
    required this.clientId,
    this.client,
    required this.amount,
    required this.description,
    required this.createdAt,
    required this.dueDate,
    this.dates, // CORRECTION: nullable
    this.paymentMethod,
    this.paymentReference,
    this.notes,
    this.userId,
  });

  // --------------------------------------------------------------------------
  // Factory constructor : création depuis JSON backend
  // --------------------------------------------------------------------------
  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
      id: int.tryParse('${json['id']}') ?? 0,
      // CORRECTION: Le backend envoie 'clientId' mais la DB a 'client_id'
      // Les scripts PHP corrigés enverront 'clientId' dans le JSON
      clientId: (json['clientId'] ?? json['client_id'] ?? '').toString(),
      amount: json['amount'] is num
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount']?.toString() ?? '') ?? 0.0,
      description: (json['description'] ?? '').toString(),
      // CORRECTION: Le backend envoie 'createdAt' mais la DB a 'created_at'
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : (json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now()),
      // CORRECTION: Le backend envoie 'dueDate' mais la DB a 'due_date'
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'].toString()) ?? DateTime.now()
          : (json['due_date'] != null
          ? DateTime.tryParse(json['due_date'].toString()) ?? DateTime.now()
          : DateTime.now()),
      // CORRECTION: dates est nullable
      dates: json['dates'] != null
          ? DateTime.tryParse(json['dates'].toString())
          : null,
      // CORRECTION: Le backend envoie 'paymentMethod' mais la DB a 'payment_method'
      paymentMethod: (json['paymentMethod'] ?? json['payment_method'])?.toString(),
      // CORRECTION: Le backend envoie 'paymentReference' mais la DB a 'payment_reference'
      paymentReference: (json['paymentReference'] ?? json['payment_reference'])?.toString(),
      notes: json['notes']?.toString(),
      // CORRECTION: Le backend envoie 'userId' mais la DB a 'user_id'
      userId: (json['userId'] ?? json['user_id'])?.toString(),
    );
  }

  // Factory constructor avec client joint (pour les requêtes JOIN)
  factory Debt.fromJsonWithClient(Map<String, dynamic> json) {
    // Utiliser le constructeur principal
    final debt = Debt(
      id: int.tryParse('${json['id']}') ?? 0,
      // CORRECTION: Utiliser client_id depuis les données jointes
      clientId: (json['clientId'] ?? json['client_id'] ?? '').toString(),
      amount: json['amount'] is num
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount']?.toString() ?? '') ?? 0.0,
      description: (json['description'] ?? '').toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      dates: json['dates'] != null
          ? DateTime.tryParse(json['dates'].toString())
          : null,
      paymentMethod: json['payment_method']?.toString(),
      paymentReference: json['payment_reference']?.toString(),
      notes: json['notes']?.toString(),
      userId: json['user_id']?.toString(),
    );

    // Si le JSON contient aussi les données du client
    if (json['client_name'] != null || json['client_phone'] != null) {
      final client = Client(
        id: (json['client_id'] ?? '').toString(),
        name: (json['client_name'] ?? '').toString(),
        phone: (json['client_phone'] ?? '').toString(),
        address: (json['client_address'] ?? '').toString(),
        product: (json['client_product'] ?? '').toString(),
        quantity: (json['client_quantity'] ?? '').toString(),
        amountDue: json['client_amountDue'] is num
            ? (json['client_amountDue'] as num).toDouble()
            : null,
        amountPaid: json['client_amountPaid'] is num
            ? (json['client_amountPaid'] as num).toDouble()
            : null,
        paymentDate: json['client_paymentDate'] != null
            ? DateTime.tryParse(json['client_paymentDate'].toString())
            : null,
      );

      return debt.copyWith(client: client);
    }

    return debt;
  }

  // --------------------------------------------------------------------------
  // Conversion vers Map (pour POST vers backend PHP)
  // --------------------------------------------------------------------------
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'amount': amount,
      'description': description,
      // CORRECTION: Les scripts PHP attendent les noms camelCase
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'dates': dates?.toIso8601String(),
      'paymentMethod': paymentMethod,
      'paymentReference': paymentReference,
      'notes': notes,
      'userId': userId,
    };
  }

  // Méthode copyWith pour créer une copie modifiée
  Debt copyWith({
    int? id,
    String? clientId,
    Client? client,
    double? amount,
    String? description,
    DateTime? createdAt,
    DateTime? dueDate,
    DateTime? dates,
    String? paymentMethod,
    String? paymentReference,
    String? notes,
    String? userId,
  }) {
    return Debt(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      client: client ?? this.client,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      dates: dates ?? this.dates,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentReference: paymentReference ?? this.paymentReference,
      notes: notes ?? this.notes,
      userId: userId ?? this.userId,
    );
  }

  // --------------------------------------------------------------------------
  // Méthodes utilitaires
  // --------------------------------------------------------------------------

  /// Vérifie si la dette est en retard
  bool get isOverdue => !isPaid && dueDate.isBefore(DateTime.now());

  /// Nombre de jours de retard
  int get daysOverdue {
    if (!isOverdue) return 0;
    return DateTime.now().difference(dueDate).inDays;
  }

  /// Nombre de jours restants avant échéance
  int get daysRemaining {
    if (isPaid || isOverdue) return 0;
    return dueDate.difference(DateTime.now()).inDays;
  }

  /// Obtient le nom du client (depuis l'objet client ou depuis l'ID)
  String getClientName({required Map<String, Client> clientCache}) {
    if (client != null) return client!.name;
    if (clientCache.containsKey(clientId)) return clientCache[clientId]!.name;
    return 'Client $clientId';
  }

  /// Obtient le téléphone du client
  String getClientPhone({required Map<String, Client> clientCache}) {
    if (client != null) return client!.phone;
    if (clientCache.containsKey(clientId)) return clientCache[clientId]!.phone;
    return '';
  }

  // Méthode toString pour le débogage
  @override
  String toString() {
    return 'Debt{id: $id, clientId: $clientId, amount: $amount, description: $description, isPaid: $isPaid}';
  }
}