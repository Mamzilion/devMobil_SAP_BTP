import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/user_service.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  List<dynamic> users = [];
  bool isLoading = true;
  final UserService _userService = UserService();

  // Palette Dark Premium
  final Color darkBackground = const Color(0xFF0D0D0D);
  final Color cardBackground = const Color(0xFF1A1A1A);
  final Color primaryGold = const Color(0xFF96653A);

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      if (auth.token == null || auth.user == null) return;
      final data = await _userService.getAllUsers(auth.token!, auth.user!.role);
      setState(() {
        users = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _showUserForm({Map<String, dynamic>? user}) {
    final nomController = TextEditingController(text: user?['nom']);
    final emailController = TextEditingController(text: user?['email']);
    final passwordController = TextEditingController();
    String selectedRole = user?['role'] ?? 'EMPLOYE';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardBackground, // Fond sombre pour le formulaire
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 25, right: 25, top: 15
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 25),
            Text(user == null ? "CRÉER UN COMPTE" : "MODIFIER LE COMPTE", 
              style: TextStyle(color: primaryGold, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12)),
            const SizedBox(height: 25),
            
            _buildField(nomController, "Nom Complet", Icons.person_outline),
            const SizedBox(height: 15),
            _buildField(emailController, "Email Professionnel", Icons.alternate_email, isEmail: true),
            
            if (user == null) ...[
              const SizedBox(height: 15),
              _buildField(passwordController, "Mot de passe temporaire", Icons.lock_outline, isPassword: true),
            ],
            
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              dropdownColor: cardBackground,
              value: selectedRole,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              items: ['EMPLOYE', 'DIRIGEANT', 'VERIFICATEUR', 'ADMIN']
                  .map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (val) => selectedRole = val!,
              decoration: _inputDecoration("Rôle", Icons.shield_outlined),
            ),
            const SizedBox(height: 35),
            
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGold,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 0,
              ),
              onPressed: () async {
                final auth = Provider.of<AuthProvider>(context, listen: false);
                bool success;
                
                if (user == null) {
                  success = await _userService.createUser(auth.token!, auth.user!.role, {
                    "nom": nomController.text.trim(),
                    "email": emailController.text.trim(),
                    "role": selectedRole,
                    "password": passwordController.text.trim(),
                  });
                } else {
                  success = await _userService.updateUser(auth.token!, auth.user!.role, user['_id'], {
                    "nom": nomController.text.trim(),
                    "role": selectedRole,
                  });
                }

                if (success && mounted) {
                  Navigator.pop(context);
                  _loadUsers();
                }
              },
              child: const Text("ENREGISTRER LES MODIFICATIONS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        title: const Text("GESTION DES COMPTES", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5)),
        backgroundColor: Colors.transparent, elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryGold,
        elevation: 4,
        child: const Icon(Icons.add_moderator_rounded, color: Colors.white),
        onPressed: () => _showUserForm(),
      ),
      body: isLoading 
        ? Center(child: CircularProgressIndicator(color: primaryGold))
        : users.isEmpty 
          ? const Center(child: Text("Aucun compte trouvé.", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    leading: CircleAvatar(
                      backgroundColor: primaryGold.withOpacity(0.1), 
                      child: Text(user['nom'][0].toUpperCase(), style: TextStyle(color: primaryGold, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(user['nom'].toString().toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text("Rôle: ${user['role']}\n${user['email']}", style: TextStyle(fontSize: 11, color: Colors.grey.shade500, height: 1.5)),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: Icon(Icons.edit_outlined, color: Colors.grey.shade400, size: 20), onPressed: () => _showUserForm(user: user)),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                          onPressed: () => _confirmDelete(user),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _confirmDelete(dynamic user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Supprimer le compte ?", style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Text("Cette action est irréversible pour l'utilisateur ${user['nom']}.", style: const TextStyle(color: Colors.grey, fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ANNULER", style: TextStyle(color: Colors.white30))),
          TextButton(
            onPressed: () async {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              if (await _userService.deleteUser(auth.token!, auth.user!.role, user['_id'])) {
                Navigator.pop(context);
                _loadUsers();
              }
            }, 
            child: const Text("SUPPRIMER", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {bool isPassword = false, bool isEmail = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      decoration: _inputDecoration(label, icon),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryGold, size: 18),
      labelStyle: const TextStyle(fontSize: 12, color: Colors.grey),
      filled: true, 
      fillColor: darkBackground.withOpacity(0.5),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: primaryGold.withOpacity(0.5))),
    );
  }
}