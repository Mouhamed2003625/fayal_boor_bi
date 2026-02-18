import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/client_model.dart';
import '../../providers/client_provider.dart';

class EditClientScreen extends ConsumerStatefulWidget {
  final Client client;

  const EditClientScreen({super.key, required this.client});

  @override
  ConsumerState<EditClientScreen> createState() => _EditClientScreenState();
}

class _EditClientScreenState extends ConsumerState<EditClientScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController addressController;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.client.name);
    phoneController = TextEditingController(text: widget.client.phone);
    addressController =
        TextEditingController(text: widget.client.address ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    // Crée une nouvelle instance client avec les valeurs modifiées
    final updatedClient = widget.client.copyWith(
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
      address: addressController.text.trim(),
    );

    // Met à jour le provider
    await ref.read(clientProvider.notifier).updateClient(updatedClient);

    setState(() => isSaving = false);

    // Retour vers la page InfosClient avec le client mis à jour
    if (context.mounted) {
      context.goNamed("infosclients", extra: updatedClient);
    }
  }

  /// Fonction pour gérer le retour à la page précédente
  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed('infosclients', extra: widget.client);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF003366),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _goBack,
          tooltip: 'Retour',
        ),
        title: Text(
          "Modifier ${widget.client.name}",
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: isSaving ? null : saveChanges,
            tooltip: 'Sauvegarder',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, const Color(0xFF003366).withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _buildField(
                  label: "Nom complet",
                  controller: nameController,
                  icon: Icons.person_outline,
                  validator: (value) =>
                  value == null || value.trim().isEmpty
                      ? "Nom requis"
                      : null,
                ),
                const SizedBox(height: 20),
                _buildField(
                  label: "Téléphone",
                  controller: phoneController,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                  value == null || value.trim().isEmpty
                      ? "Téléphone requis"
                      : null,
                ),
                const SizedBox(height: 20),
                _buildField(
                  label: "Adresse (optionnel)",
                  controller: addressController,
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: isSaving ? null : saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003366),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isSaving
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    "Sauvegarder",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF003366)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF003366)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF003366), width: 2),
        ),
      ),
    );
  }
}