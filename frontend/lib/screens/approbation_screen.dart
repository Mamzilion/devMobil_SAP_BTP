import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/purchase_service.dart';

class ApprobationScreen extends StatefulWidget {
  const ApprobationScreen({super.key});

  @override
  State<ApprobationScreen> createState() => _ApprobationScreenState();
}

class _ApprobationScreenState extends State<ApprobationScreen> {
  // Palette de couleurs Dark Premium
  final Color darkBackground = const Color(0xFF0D0D0D);
  final Color cardBackground = const Color(0xFF1A1A1A);
  final Color primaryGold = const Color(0xFF96653A);

  Future<void> _handleDecision(String id, String newStatus) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    bool success = await PurchaseService().updateStatus(
      token: auth.token!,
      purchaseId: id,
      newStatus: newStatus,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus == 'AUTORISE' ? "Achat Autorisé ✅" : "Achat Refusé ❌",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: newStatus == 'AUTORISE' ? Colors.green.shade800 : Colors.red.shade900,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() {}); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        title: const Text("DEMANDES À APPROUVER", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: PurchaseService().getAllPurchasesForAdmin(auth.token!), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryGold));
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Erreur de chargement", style: TextStyle(color: Colors.grey)));
          }

          final aValider = snapshot.data?.where((item) => item['statut'] == 'EN_ATTENTE').toList() ?? [];

          if (aValider.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_user_outlined, size: 60, color: primaryGold.withOpacity(0.3)),
                  const SizedBox(height: 15),
                  const Text("Aucune demande en attente.", style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: aValider.length,
            itemBuilder: (context, index) {
              final item = aValider[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item['libelle'].toString().toUpperCase(), 
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5)
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: primaryGold.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                            child: Text(
                              "${item['montant_estime']} CFA", 
                              style: TextStyle(color: primaryGold, fontWeight: FontWeight.w900, fontSize: 13)
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (item['description'] != null)
                        Text(
                          item['description'], 
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12)
                        ),
                      const Divider(height: 30, color: Colors.white10),
                      Row(
                        children: [
                          // BOUTON REFUSER (OUTLINED)
                          Expanded(
                            child: TextButton(
                              onPressed: () => _handleDecision(item['_id'], 'REFUSE'),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.red.withOpacity(0.5))
                                ),
                              ),
                              child: const Text("REFUSER", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ),
                          const SizedBox(width: 15),
                          // BOUTON AUTORISER (PLEIN GOLD)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _handleDecision(item['_id'], 'AUTORISE'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGold,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                              ),
                              child: const Text("AUTORISER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ),
                        ],
                      )
                    ],
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