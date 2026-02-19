import 'debt_model.dart';

class Client {
  final int id;
  String name;
  String phone;
  String? address;
  List<Debt> debts;

  Client({
    required this.id,
    required this.name,
    required this.phone,
    this.address,
    this.debts = const [],
  });

  /// 🔹 Crée un Client depuis un JSON
  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'],
      debts: json['debts'] != null
          ? List<Debt>.from(
          (json['debts'] as List).map((d) => Debt.fromJson(d)))
          : [],
    );
  }

  /// 🔹 Convertit un Client en JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'address': address,
    'debts': debts.map((d) => d.toJson()).toList(),
  };

  /// 🔹 Permet de créer une copie avec des modifications
  Client copyWith({
    String? name,
    String? phone,
    String? address,
    List<Debt>? debts,
  }) {
    return Client(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      debts: debts ?? this.debts,
    );
  }
}
