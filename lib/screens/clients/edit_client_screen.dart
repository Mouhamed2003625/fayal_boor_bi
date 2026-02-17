import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/client_model.dart';

class EditClientScreen extends StatefulWidget {
  final Client client;

  const EditClientScreen({
    super.key,
    required this.client,
  });

  @override
  State<EditClientScreen> createState() => _EditClientScreenState();
}

class _EditClientScreenState extends State<EditClientScreen> {
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

  void saveChanges() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    // Simulation sauvegarde (remplacer par appel API)
    Future.delayed(const Duration(milliseconds: 500), () {
      widget.client
        ..name = nameController.text.trim()
        ..phone = phoneController.text.trim()
        ..address = addressController.text.trim();

      setState(() => isSaving = false);

      context.go('/infosclients');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Modifier ${widget.client.name}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: isSaving ? null : saveChanges,
          )
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFF3B82F6),
          onPressed: () {
            context.goNamed("infosclients"); // revient à la page précédente
          },
        ),
      ),
      body: Padding(
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
                child: isSaving
                    ? const CircularProgressIndicator()
                    : const Text("Sauvegarder"),
              ),
            ],
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
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
