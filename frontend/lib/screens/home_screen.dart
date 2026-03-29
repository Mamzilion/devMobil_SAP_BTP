import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import 'add_purchase_screen.dart';
import 'my_purchases_screen.dart';
import 'verifier_screen.dart'; 
import 'emit_purchase_screen.dart'; 
import 'approbation_screen.dart'; 
import 'history_screen.dart'; 
import 'manage_users_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Palette de couleurs Dark Premium
  final Color darkBackground = const Color(0xFF0D0D0D); // Noir presque pur
  final Color cardBackground = const Color(0xFF1A1A1A); // Gris très foncé pour les cartes
  final Color primaryGold = const Color(0xFF96653A);     // Ton doré

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;
    final bool isAdmin = user?.role == 'ADMIN';

    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        title: Text(isAdmin ? "ADMINISTRATION" : "TABLEAU DE BORD", 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: isAdmin ? Colors.redAccent : Colors.white),
            onPressed: () => auth.logout(),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(isAdmin ? "Bienvenue, Admin" : "Session : ${user?.nom}", 
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24)),
            const SizedBox(height: 5),
            if (!isAdmin) _buildBadge(user?.role ?? "SANS RÔLE"),
            if (isAdmin) const Text("Contrôle total du système et des accès.", 
              style: TextStyle(color: Colors.grey, fontSize: 13)),
            
            const SizedBox(height: 35),

            Expanded(
              child: _buildRoleSpecificUI(context, user?.role),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSpecificUI(BuildContext context, String? role) {
    switch (role) {
      case 'ADMIN': return _adminActions(context);
      case 'DIRIGEANT': return _dirigeantActions(context);
      case 'EMPLOYE': return _employeActions(context);
      case 'VERIFICATEUR': return _verificateurActions(context);
      default: return const Center(child: Text("Accès restreint", style: TextStyle(color: Colors.white)));
    }
  }

  // --- INTERFACE ADMIN (MENU CARD DARK) ---
  Widget _adminActions(BuildContext context) {
    return Column(
      children: [
        _buildMenuCard(
          title: "Gestion des Comptes",
          subtitle: "Gérer les permissions et utilisateurs",
          icon: Icons.people_alt_rounded,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageUsersScreen())),
        ),
      ],
    );
  }

  // --- AUTRES INTERFACES (GRILLE DARK) ---
  Widget _employeActions(BuildContext context) => _baseGrid([
    _actionBtn("NOUVELLE DEMANDE", Icons.post_add, primaryGold, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPurchaseScreen()))),
    _actionBtn("MES REÇUS", Icons.receipt_long, cardBackground, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyPurchasesScreen()))),
  ]);

  Widget _verificateurActions(BuildContext context) => _baseGrid([
    _actionBtn("VÉRIFIER ACHATS", Icons.rule, const Color(0xFF1E3A3A), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VerifierScreen()))),
    _actionBtn("ÉMETTRE BESOIN", Icons.add_shopping_cart, cardBackground, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPurchaseScreen()))),
    _actionBtn("MES ACHATS", Icons.history, primaryGold, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyPurchasesScreen()))),
  ]);

  Widget _dirigeantActions(BuildContext context) => _baseGrid([
    _actionBtn("APPROBATIONS", Icons.how_to_reg, primaryGold, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ApprobationScreen()))),
    _actionBtn("ÉMETTRE REQUÊTE", Icons.add_circle, cardBackground, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmitPurchaseScreen()))),
    _actionBtn("HISTORIQUE GLOBAL", Icons.folder_shared, cardBackground, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()))),
  ]);

  // --- COMPOSANTS DE DESIGN ---

  Widget _buildMenuCard({required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withOpacity(0.05)), // Bordure subtile
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: primaryGold.withOpacity(0.15),
              child: Icon(icon, color: primaryGold, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _baseGrid(List<Widget> children) => GridView.count(
    crossAxisCount: 2, mainAxisSpacing: 15, crossAxisSpacing: 15, children: children,
  );

  Widget _actionBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        decoration: BoxDecoration(
          color: color, 
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 35),
            const SizedBox(height: 12),
            Text(label, textAlign: TextAlign.center, 
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String role) => Container(
    margin: const EdgeInsets.only(top: 8),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    decoration: BoxDecoration(
      color: primaryGold.withOpacity(0.2), 
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: primaryGold.withOpacity(0.3))
    ),
    child: Text(role, style: TextStyle(color: primaryGold, fontSize: 10, fontWeight: FontWeight.bold)),
  );
}