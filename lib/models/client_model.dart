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

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: int.parse(json['id'].toString()),
      name: json['name'],
      phone: json['phone'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'address': address,
  };
}
