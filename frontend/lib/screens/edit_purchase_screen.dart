import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/purchase_service.dart';

class EditPurchaseScreen extends StatefulWidget {
  final dynamic purchase; 

  const EditPurchaseScreen({super.key, required this.purchase});

  @override
  State<EditPurchaseScreen> createState() => _EditPurchaseScreenState();
}

class _EditPurchaseScreenState extends State<EditPurchaseScreen> {
  late TextEditingController _titreCtrl;
  late TextEditingController _montantCtrl;
  late TextEditingController _descCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pré-remplissage avec les données reçues
    _titreCtrl = TextEditingController(text: widget.purchase['libelle']);
    _montantCtrl = TextEditingController(text: widget.purchase['montant_estime'].toString());
    _descCtrl = TextEditingController(text: widget.purchase['description']);
  }

  void _update() async {
    // 1. Vérification locale des champs
    if (_titreCtrl.text.isEmpty || _montantCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      print("🚀 Envoi de la mise à jour pour l'ID: ${widget.purchase['_id']}");

      bool success = await PurchaseService().updatePurchase(
        token: auth.token!,
        purchaseId: widget.purchase['_id'], 
        titre: _titreCtrl.text.trim(),
        montant: _montantCtrl.text.trim(),
        description: _descCtrl.text.trim(),
      );

      if (mounted) setState(() => _isLoading = false);

      if (success) {
        print("✅ Mise à jour réussie");
        // On ferme l'écran et on renvoie 'true' pour que la liste se rafraîchisse
        Navigator.pop(context, true); 
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Modification enregistrée"), backgroundColor: Colors.blue),
        );
      } else {
        print("❌ Échec de la mise à jour (StatusCode différent de 200)");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Le serveur a refusé la modification. Vérifiez que la demande est toujours EN ATTENTE."), 
            backgroundColor: Colors.red
          ),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      print("🔥 Erreur critique lors de l'update: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de connexion : $e"), backgroundColor: Colors.orange),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("MODIFIER LA REQUÊTE", style: TextStyle(color: Colors.white, fontSize: 14)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF96653A)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            _buildInput(controller: _titreCtrl, label: "Libellé", icon: Icons.edit),
            const SizedBox(height: 20),
            _buildInput(
              controller: _montantCtrl, 
              label: "Montant (CFA)", 
              icon: Icons.payments, 
              keyboardType: TextInputType.number
            ),
            const SizedBox(height: 20),
            _buildInput(
              controller: _descCtrl, 
              label: "Description", 
              icon: Icons.description, 
              maxLines: 3
            ),
            const SizedBox(height: 40),
            _isLoading 
              ? const CircularProgressIndicator(color: Color(0xFF96653A))
              : SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _update,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF96653A)),
                    child: const Text("METTRE À JOUR", style: TextStyle(color: Colors.white)),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller, 
    required String label, 
    required IconData icon, 
    TextInputType keyboardType = TextInputType.text, 
    int maxLines = 1
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: const Color(0xFF96653A)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}