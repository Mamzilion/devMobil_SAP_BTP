import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/purchase_service.dart';

class AddPurchaseScreen extends StatefulWidget {
  const AddPurchaseScreen({super.key});

  @override
  State<AddPurchaseScreen> createState() => _AddPurchaseScreenState();
}

class _AddPurchaseScreenState extends State<AddPurchaseScreen> {
  final _titreCtrl = TextEditingController();
  final _montantCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _isLoading = false;

  void _submit() async {
    print("🔵 1. Bouton cliqué");

    // 1. Validation locale
    if (_titreCtrl.text.isEmpty || _montantCtrl.text.isEmpty) {
      print("❌ 2. Erreur : Champs vides");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Champs obligatoires manquants")),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);
      print("🔵 3. Chargement activé");

      final auth = Provider.of<AuthProvider>(context, listen: false);
      
      print("🔵 4. Appel du service avec Token: ${auth.token != null ? 'OK' : 'NULL'}");
      print("🔵 5. ID Utilisateur: ${auth.user?.id}");

      // 2. Appel du service
      bool success = await PurchaseService().createPurchase(
        token: auth.token!,
        userId: auth.user!.id, 
        titre: _titreCtrl.text.trim(),
        montant: _montantCtrl.text.trim(),
        description: _descCtrl.text.trim(),
      );

      print("🔵 6. Réponse du service success = $success");

      if (mounted) setState(() => _isLoading = false);

      // 3. Feedback
      if (success) {
        print("✅ 7. Succès total !");
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Demande envoyée avec succès"),
            backgroundColor: Color(0xFF96653A),
          ),
        );
      } else {
        print("⚠️ 8. Échec côté serveur (StatusCode != 201)");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Échec du serveur"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print("🔥 9. ERREUR CRITIQUE : $e");
      if (mounted) setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _titreCtrl.dispose();
    _montantCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("NOUVELLE REQUÊTE", 
          style: TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF96653A)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Détails du besoin",
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              height: 3,
              width: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF96653A),
                borderRadius: BorderRadius.circular(10)
              ),
            ),
            const SizedBox(height: 40),
            
            _buildPremiumInput(
              controller: _titreCtrl,
              label: "Objet de la demande",
              icon: Icons.shopping_bag_outlined,
            ),
            const SizedBox(height: 25),
            
            _buildPremiumInput(
              controller: _montantCtrl,
              label: "Montant estimé (CFA)",
              icon: Icons.payments_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 25),
            
            _buildPremiumInput(
              controller: _descCtrl,
              label: "Justification détaillée",
              icon: Icons.notes_outlined,
              maxLines: 4,
            ),
            
            const SizedBox(height: 50),
            
            _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF96653A)))
              : SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF96653A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 8,
                      shadowColor: const Color(0xFF96653A).withOpacity(0.3),
                    ),
                    child: const Text(
                      "SOUMETTRE LA REQUÊTE",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF96653A), size: 22),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF96653A), width: 1.5),
        ),
      ),
    );
  }
}