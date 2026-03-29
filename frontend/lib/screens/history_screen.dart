import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/purchase_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Palette Dark Premium
  final Color darkBackground = const Color(0xFF0D0D0D);
  final Color cardBackground = const Color(0xFF1A1A1A);
  final Color primaryGold = const Color(0xFF96653A);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        title: const Text("ARCHIVES & REFUS", 
          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: PurchaseService().getAllPurchasesForAdmin(auth.token!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryGold));
          }

          final historique = snapshot.data?.where((item) {
            return item['statut'] == 'REFUSE' || item['statut'] == 'VERIFIE';
          }).toList() ?? [];

          if (historique.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 60, color: Colors.white.withOpacity(0.1)),
                  const SizedBox(height: 15),
                  Text("AUCUN HISTORIQUE CLOS", 
                    style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: historique.length,
            itemBuilder: (context, index) {
              final item = historique[index];
              final String statut = item['statut'];
              final bool isVerified = statut == 'VERIFIE';

              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(18),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (isVerified ? Colors.green : Colors.red).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isVerified ? Icons.check_rounded : Icons.close_rounded,
                      color: isVerified ? Colors.greenAccent : Colors.redAccent,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    item['libelle'].toString().toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Par : ${item['id_demandeur']?['nom'] ?? 'N/A'}",
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                        const SizedBox(height: 6),
                        Text("${item['montant_estime']} CFA", 
                            style: TextStyle(color: primaryGold, fontWeight: FontWeight.w900, fontSize: 15)),
                      ],
                    ),
                  ),
                  trailing: _buildFinalBadge(statut),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFinalBadge(String status) {
    bool isVerified = status == 'VERIFIE';
    Color statusColor = isVerified ? Colors.greenAccent : Colors.redAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: Text(
        isVerified ? "TERMINÉ" : "REJETÉ",
        style: TextStyle(
          color: statusColor,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}