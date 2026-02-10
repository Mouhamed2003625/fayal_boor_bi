

import 'debt_model.dart';

class Client {
  String id;                 // ID unique du client (varchar 36)
  String name;               // Nom complet
  String phone;              // Numéro de téléphone
  String? address;           // Adresse (nullable)
  String? product;           // Produit vendu (nullable)
  String? quantity;          // Quantité du produit (nullable)
  double? amountDue;         // Montant total à payer (nullable)
  double? amountPaid;        // Montant déjà payé (nullable)
  DateTime? paymentDate;     // Date du versement (nullable)
  DateTime? created_at;      // Date de création (nullable)
  DateTime? updated_at;      // Date de mise à jour (nullable)
  List<Debt> debts;          // Historique des dettes (optionnel, non stocké en DB)

  Client({
    required this.id,
    required this.name,
    required this.phone,
    this.address,
    this.product,
    this.quantity,
    this.amountDue,
    this.amountPaid,
    this.paymentDate,
    this.created_at,
    this.updated_at,
    this.debts = const [],
  });

  // Factory constructor pour créer un Client depuis JSON
  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      address: json['address']?.toString(),
      product: json['product']?.toString(),
      quantity: json['quantity']?.toString(),
      amountDue: json['amountDue'] is num
          ? (json['amountDue'] as num).toDouble()
          : (json['amountDue'] != null
          ? double.tryParse(json['amountDue'].toString())
          : null),
      amountPaid: json['amountPaid'] is num
          ? (json['amountPaid'] as num).toDouble()
          : (json['amountPaid'] != null
          ? double.tryParse(json['amountPaid'].toString())
          : null),
      paymentDate: json['paymentDate'] != null
          ? DateTime.tryParse(json['paymentDate'].toString())
          : null,
      // Gestion des timestamps
      created_at: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updated_at: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      // Les dettes sont généralement chargées séparément
      debts: [],
    );
  }

  // Factory constructor pour les données avec statistiques de dettes
  factory Client.fromJsonWithDebtStats(Map<String, dynamic> json) {
    final client = Client(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      address: json['address']?.toString(),
      product: json['product']?.toString(),
      quantity: json['quantity']?.toString(),
      amountDue: json['amountDue'] is num
          ? (json['amountDue'] as num).toDouble()
          : null,
      amountPaid: json['amountPaid'] is num
          ? (json['amountPaid'] as num).toDouble()
          : null,
      paymentDate: json['paymentDate'] != null
          ? DateTime.tryParse(json['paymentDate'].toString())
          : null,
      created_at: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updated_at: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      debts: [],
    );

    // Ajouter les statistiques de dettes si présentes dans le JSON
    if (json['totalDebt'] != null || json['debtCount'] != null) {
      // Elles ne sont pas des attributs de la classe Client mais peuvent être utilisées
    }

    return client;
  }

  // Conversion vers Map (pour POST/PUT vers backend PHP)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'product': product,
      'quantity': quantity,
      'amountDue': amountDue,
      'amountPaid': amountPaid,
      'paymentDate': paymentDate?.toIso8601String(),
      // Les timestamps sont généralement gérés automatiquement par MySQL
      // 'created_at' et 'updated_at' ne sont pas inclus dans toMap()
      // sauf si besoin spécifique
    };
  }

  // Copie avec modifications
  Client copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    String? product,
    String? quantity,
    double? amountDue,
    double? amountPaid,
    DateTime? paymentDate,
    DateTime? created_at,
    DateTime? updated_at,
    List<Debt>? debts,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      amountDue: amountDue ?? this.amountDue,
      amountPaid: amountPaid ?? this.amountPaid,
      paymentDate: paymentDate ?? this.paymentDate,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
      debts: debts ?? this.debts,
    );
  }

  // ============================================================================
  // PROPRIÉTÉS CALCULÉES
  // ============================================================================

  // Total des dettes impayées (calculé depuis la liste des dettes)
  double get totalDebt {
    return debts
        .where((d) => !d.isPaid)
        .fold(0.0, (sum, d) => sum + d.amount);
  }

  // Montant total payé (calculé depuis la liste des dettes)
  double get totalPaid {
    return debts
        .where((d) => d.isPaid)
        .fold(0.0, (sum, d) => sum + d.amount);
  }

  // Solde restant à payer
  double get balance {
    return totalDebt - totalPaid;
  }

  // Pourcentage de paiement
  double get paymentPercentage {
    final total = totalDebt + totalPaid;
    if (total == 0) return 0.0;
    return (totalPaid / total) * 100;
  }

  // Vérifie si le client a des dettes
  bool get hasDebts => debts.isNotEmpty;

  // Nombre de dettes impayées
  int get unpaidDebtsCount => debts.where((d) => !d.isPaid).length;

  // Nombre de dettes payées
  int get paidDebtsCount => debts.where((d) => d.isPaid).length;

  // Dette la plus ancienne non payée
  Debt? get oldestUnpaidDebt {
    final unpaid = debts.where((d) => !d.isPaid).toList();
    if (unpaid.isEmpty) return null;
    unpaid.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return unpaid.first;
  }

  // Vérifie si le client a des dettes en retard
  bool get hasOverdueDebts => debts.any((d) => d.isOverdue);

  // Dettes en retard
  List<Debt> get overdueDebts => debts.where((d) => d.isOverdue).toList();

  // ============================================================================
  // MÉTHODES UTILITAIRES
  // ============================================================================

  // Formate les informations du client pour l'affichage
  String get displayInfo => '$name - $phone';

  // Vérifie si le client correspond à une recherche
  bool matchesSearch(String query) {
    final lowerQuery = query.toLowerCase();
    return name.toLowerCase().contains(lowerQuery) ||
        phone.toLowerCase().contains(lowerQuery) ||
        (address?.toLowerCase() ?? '').contains(lowerQuery) ||
        (product?.toLowerCase() ?? '').contains(lowerQuery);
  }

  // Ajoute une dette à la liste
  void addDebt(Debt debt) {
    debts.add(debt);
  }

  // Supprime une dette de la liste
  void removeDebt(Debt debt) {
    debts.remove(debt);
  }

  // Trie les dettes par date d'échéance
  void sortDebtsByDueDate({bool ascending = true}) {
    debts.sort((a, b) => ascending
        ? a.dueDate.compareTo(b.dueDate)
        : b.dueDate.compareTo(a.dueDate));
  }

  // Méthode toString pour le débogage
  @override
  String toString() {
    return 'Client{id: $id, name: $name, phone: $phone, hasDebts: ${debts.length}}';
  }

  // Comparaison pour l'égalité
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Client &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}