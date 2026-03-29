import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart'; // Import pour la caméra
import '../services/auth_provider.dart';
import '../services/purchase_service.dart';
import 'edit_purchase_screen.dart';

class MyPurchasesScreen extends StatefulWidget {
  const MyPurchasesScreen({super.key});

  @override
  State<MyPurchasesScreen> createState() => _MyPurchasesScreenState();
}

class _MyPurchasesScreenState extends State<MyPurchasesScreen> {
  
  // --- FONCTION POUR AFFICHER LE REÇU DANS UNE FENÊTRE ---
  void _showReceiptDialog(String? photoPath) {
    if (photoPath == null || photoPath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aucun reçu n'est associé à cet achat.")),
      );
      return;
    }

    // Correction du chemin pour les URLs (remplace les \ par / pour Windows)
    final String formattedPath = photoPath.replaceAll('\\', '/');
    final String imageUrl = "http://10.110.105.169:5000/$formattedPath";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Preuve de l'achat", style: TextStyle(color: Colors.white, fontSize: 16)),
        content: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator(color: Color(0xFF96653A))),
              );
            },
            errorBuilder: (context, error, stackTrace) => const Text(
              "Impossible de charger l'image. Vérifiez votre connexion.",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fermer", style: TextStyle(color: Color(0xFF96653A))),
          ),
        ],
      ),
    );
  }

  // --- FONCTION POUR GÉRER L'APPAREIL PHOTO ET L'ENVOI ---
  Future<void> _handleImagePicker(String purchaseId) async {
    final ImagePicker picker = ImagePicker();
    
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera, 
      imageQuality: 50 
    );

    if (photo != null) {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Envoi de la preuve en cours...")),
      );

      bool success = await PurchaseService().uploadReceipt(
        token: auth.token!,
        purchaseId: purchaseId,
        filePath: photo.path,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Reçu envoyé avec succès !"), backgroundColor: Colors.green),
          );
          setState(() {}); 
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Échec de l'envoi de l'image"), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("MES REQUÊTES", style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF96653A)),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: PurchaseService().getMyPurchases(auth.token!, auth.user!.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF96653A)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucune requête trouvée", style: TextStyle(color: Colors.white54)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              return _buildPurchaseCard(item);
            },
          );
        },
      ),
    );
  }

  Widget _buildPurchaseCard(dynamic item) {
    String statut = item['statut'] ?? 'EN_ATTENTE';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded( 
                child: Text(item['libelle'] ?? 'Sans titre', 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  overflow: TextOverflow.ellipsis),
              ),
              _buildStatusBadge(statut),
            ],
          ),
          const SizedBox(height: 5),
          Text("${item['montant_estime']} CFA", 
            style: const TextStyle(color: Color(0xFF96653A), fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (statut == 'EN_ATTENTE')
                IconButton(
                  icon: const Icon(Icons.edit_note, color: Colors.blue, size: 28),
                  onPressed: () async {
                    bool? refresh = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditPurchaseScreen(purchase: item)),
                    );
                    if (refresh == true) setState(() {}); 
                  },
                ),
              
              if (statut == 'AUTORISE')
                ElevatedButton.icon(
                  onPressed: () => _handleImagePicker(item['_id']), 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF96653A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                  label: const Text("Preuve Image", style: TextStyle(color: Colors.white)),
                ),
                
              // AJOUT DU BOUTON CLIQUABLE POUR VOIR L'IMAGE
              if (statut == 'VERIFIE' || statut == 'EFFECTUE')
                IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green, size: 28),
                  onPressed: () => _showReceiptDialog(item['photo_recu']),
                  tooltip: "Voir le reçu",
                ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'AUTORISE': color = Colors.green; break;
      case 'REFUSE': color = Colors.red; break;
      case 'VERIFIE': color = Colors.blue; break;
      case 'EFFECTUE': color = Colors.teal; break;
      default: color = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
      child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}