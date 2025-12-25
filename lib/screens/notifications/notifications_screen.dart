import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Fake notifications (plus tard: Firebase / SQLite)
    final List<Map<String, dynamic>> notifications = [
      {
        "title": "Nouvelle dette ajoutée",
        "message": "Vous avez ajouté une dette pour Ibrahima Ndiaye.",
        "time": "Il y a 2 heures",
        "icon": Icons.add_alert,
        "color": Colors.blue
      },
      {
        "title": "Paiement reçu",
        "message": "Mariama Diop a réglé 5 000 FCFA.",
        "time": "Il y a 5 heures",
        "icon": Icons.check_circle,
        "color": Colors.green
      },
      {
        "title": "Client en retard",
        "message": "Ousmane Sow n'a pas encore payé sa dette.",
        "time": "Hier",
        "icon": Icons.warning_amber_rounded,
        "color": Colors.orange
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: const Text("Notifications"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: (){
            context.go('/dashboard');
          },
        ),
      ),
      body: notifications.isEmpty
          ? const Center(
        child: Text(
          "Aucune notification pour le moment",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(15),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.lightBlue),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icone
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: notif["color"].withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    notif["icon"],
                    size: 24,
                    color: notif["color"],
                  ),
                ),
                const SizedBox(width: 15),
                // Texte
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notif["title"],
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        notif["message"],
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notif["time"],
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
