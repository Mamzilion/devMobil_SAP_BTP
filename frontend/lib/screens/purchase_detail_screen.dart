/*import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/purchase_model.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../constants.dart';

class PurchaseDetailScreen extends StatefulWidget {
  final PurchaseModel purchase;
  const PurchaseDetailScreen({super.key, required this.purchase});

  @override
  State<PurchaseDetailScreen> createState() => _PurchaseDetailScreenState();
}

class _PurchaseDetailScreenState extends State<PurchaseDetailScreen> {
  bool _isUpdating = false;
  final ImagePicker _picker = ImagePicker();

  void _changeStatus(String newStatus) async {
    setState(() => _isUpdating = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    try {
      final response = await ApiService.updateStatus(widget.purchase.id, newStatus, auth.user!.token);
      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Statut : $newStatus")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  void _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70); // Qualité 70 pour ton TECNO
    
    if (photo != null) {
      setState(() => _isUpdating = true);
      final auth = Provider.of<AuthProvider>(context, listen: false);
      
      try {
        final response = await ApiService.uploadReceipt(widget.purchase.id, photo.path, auth.user!.token);
        if (response.statusCode == 200) {
          if (!mounted) return;
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Reçu enregistré !")));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur upload : $e")));
      } finally {
        if (mounted) setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userRole = Provider.of<AuthProvider>(context).user?.role ?? 'USER';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F2),
      appBar: AppBar(
        title: const Text("Détails Demande", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // --- CARTE PRINCIPALE (NOIRE) ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121212),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.purchase.statut.toUpperCase(), 
                          style: TextStyle(color: widget.purchase.getStatusColor(), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        const SizedBox(height: 10),
                        Text(widget.purchase.description ?? "Sans titre", 
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 25),
                        _infoTile("Quantité", "${widget.purchase.quantite ?? 0}"),
                        _infoTile("Budget", "${widget.purchase.budget ?? 0} €"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // --- SECTION IMAGE DU REÇU ---
                  if (widget.purchase.photo_recu != null && widget.purchase.photo_recu!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("JUSTIFICATIF", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            "${AppConfig.baseUrl.replaceAll('/api', '')}/${widget.purchase.photo_recu}",
                            width: double.infinity,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(child: CircularProgressIndicator());
                            },
                            errorBuilder: (context, error, stackTrace) => 
                              const Text("Image non disponible"),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // --- BARRE D'ACTIONS DYNAMIQUE ---
          _buildActionSection(userRole),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionSection(String role) {
    if (_isUpdating) return const Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: Color(0xFF96653A)));

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: _getActionsByRole(role),
    );
  }

  Widget _getActionsByRole(String role) {
    // DIRIGEANT : Approuver ou Refuser
    if (role == 'DIRIGEANT' && widget.purchase.statut == 'EN_ATTENTE') {
      return Row(
        children: [
          Expanded(child: _actionBtn("REFUSER", Colors.red[50]!, Colors.red, () => _changeStatus('REFUSE'))),
          const SizedBox(width: 15),
          Expanded(child: _actionBtn("APPROUVER", const Color(0xFF96653A), Colors.white, () => _changeStatus('APPROUVE'))),
        ],
      );
    }

    // EMPLOYÉ : Scanner le reçu après approbation
    if (role == 'EMPLOYE' && widget.purchase.statut == 'APPROUVE') {
      return _actionBtn("SCANNER LE REÇU", const Color(0xFF121212), Colors.white, _takePhoto, icon: Icons.camera_alt_outlined);
    }

    // VÉRIFICATEUR : Valider l'achat effectué
    if (role == 'VERIFICATEUR' && widget.purchase.statut == 'EFFECTUE') {
      return _actionBtn("MARQUER COMME VÉRIFIÉ", Colors.teal, Colors.white, () => _changeStatus('VERIFIE'), icon: Icons.check_circle_outline);
    }

    return const Text("Aucune action requise", style: TextStyle(color: Colors.grey));
  }

  Widget _actionBtn(String label, Color bg, Color text, VoidCallback onTap, {IconData? icon}) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: text,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon), const SizedBox(width: 10)],
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}*/