import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/purchase_service.dart';

class VerifierScreen extends StatefulWidget {
  const VerifierScreen({super.key});

  @override
  State<VerifierScreen> createState() => _VerifierScreenState();
}

class _VerifierScreenState extends State<VerifierScreen> {
  
  // --- ACTION : MARQUER COMME VERIFIE ---
  Future<void> _confirmerConformite(String purchaseId) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    bool success = await PurchaseService().updateStatus(
      token: auth.token!,
      purchaseId: purchaseId,
      newStatus: 'VERIFIE',
    );

    if (success && mounted) {
      Navigator.pop(context); // Ferme le dialogue
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Achat marqué comme CONFORME ✅"), backgroundColor: Colors.green),
      );
      setState(() {}); // Rafraîchit la liste
    }
  }

  // --- DIALOGUE D'EXAMEN ---
  void _showVerifyDialog(dynamic item) {
    String? photoPath = item['photo_recu'];
    final String imageUrl = "http://10.110.105.169:5000/${photoPath?.replaceAll('\\', '/')}";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(item['libelle'], style: const TextStyle(color: Colors.white, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox(
                    height: 150,
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF96653A))),
                  );
                },
                errorBuilder: (context, error, stackTrace) => const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Image non disponible", style: TextStyle(color: Colors.red)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text("Montant : ${item['montant_estime']} CFA", style: const TextStyle(color: Colors.white70)),
          ],
        ),
        actions: [
          // 1. VALIDER
          TextButton(
            onPressed: () => _confirmerConformite(item['_id']),
            child: const Text("VALIDER", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),

          // 2. IMAGE FLOUE (Utilise la nouvelle route)
          TextButton(
            onPressed: () async {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              bool ok = await PurchaseService().rejeterPreuve(auth.token!, item['_id']);
              if (ok && mounted) {
                Navigator.pop(context);
                setState(() {}); 
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Image rejetée (Relance employé) ⚠️")));
              }
            },
            child: const Text("IMAGE FLOUE", style: TextStyle(color: Colors.orange)),
          ),

          // 3. FRAUDE (Utilise la nouvelle route)
          TextButton(
            onPressed: () async {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              bool ok = await PurchaseService().marquerFraude(auth.token!, item['_id']);
              if (ok && mounted) {
                Navigator.pop(context);
                setState(() {}); 
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Marqué comme FRAUDE ❌"), backgroundColor: Colors.red));
              }
            },
            child: const Text("FRAUDE", style: TextStyle(color: Colors.red)),
          ),

          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Fermer")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("VÉRIFICATIONS EN ATTENTE", style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: PurchaseService().getPurchasesToVerify(auth.token!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF96653A)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Rien à vérifier", style: TextStyle(color: Colors.white54)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              bool estMonAchat = item['id_demandeur'] == auth.user!.id;

              return Container(
                margin: const EdgeInsets.only(bottom: 10), 
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05), 
                  borderRadius: BorderRadius.circular(12)
                ),
                child: ListTile(
                  leading: const Icon(Icons.receipt_long, color: Color(0xFF96653A)),
                  title: Text(item['libelle'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text("${item['montant_estime']} CFA", style: const TextStyle(color: Colors.white70)),
                  trailing: estMonAchat 
                    ? const Text("Auto-Verif Interdite", style: TextStyle(color: Colors.redAccent, fontSize: 10))
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[800]),
                        onPressed: () => _showVerifyDialog(item),
                        child: const Text("Vérifier", style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}