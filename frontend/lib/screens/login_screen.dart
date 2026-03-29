import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import '../services/auth_provider.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscure = true;
  bool _isLoading = false;

  // Palette Dark Premium
  final Color primaryGold = const Color(0xFF96653A);
  final Color darkBackground = const Color(0xFF121212);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              Text(
                "Gestion d'Achats".toUpperCase(),
                style: TextStyle(
                  color: primaryGold, 
                  fontSize: 12, 
                  fontWeight: FontWeight.w900, 
                  letterSpacing: 3
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Bienvenue sur votre\nespace sécurisé",
                style: TextStyle(
                  color: Colors.white, 
                  fontSize: 28, 
                  fontWeight: FontWeight.bold,
                  height: 1.2
                ),
              ),
              const SizedBox(height: 60),

              _buildInput(
                controller: _emailController,
                label: "Identifiant ou Email",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),
              _buildInput(
                controller: _passwordController,
                label: "Mot de passe",
                icon: Icons.lock_outline,
                isPassword: true,
              ),

              const SizedBox(height: 40),

              _isLoading 
                ? Center(child: CircularProgressIndicator(color: primaryGold))
                : SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGold,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                      child: const Text(
                        "SE CONNECTER", 
                        style: TextStyle(
                          color: Colors.white, 
                          fontWeight: FontWeight.bold, 
                          letterSpacing: 1.5,
                          fontSize: 13
                        )
                      ),
                    ),
                  ),

              const SizedBox(height: 50),

              // --- MESSAGE D'INFORMATION (Remplace l'inscription) ---
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.info_outline, color: primaryGold.withOpacity(0.5), size: 20),
                      const SizedBox(height: 10),
                      Text(
                        "Pas encore de compte ?",
                        style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "Veuillez vous rapprocher de l'administrateur\npour la création de vos accès.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white38, fontSize: 11, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }

    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    bool success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (mounted) setState(() => _isLoading = false);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Identifiants incorrects ou compte désactivé"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildInput({
    required TextEditingController controller, 
    required String label, 
    required IconData icon, 
    bool isPassword = false
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _isObscure : false,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
        prefixIcon: Icon(icon, color: primaryGold, size: 20),
        suffixIcon: isPassword 
          ? IconButton(
              icon: Icon(
                _isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, 
                color: Colors.white38, 
                size: 20
              ),
              onPressed: () => setState(() => _isObscure = !_isObscure),
            ) 
          : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), 
          borderSide: BorderSide.none
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), 
          borderSide: BorderSide(color: primaryGold.withOpacity(0.5), width: 1)
        ),
      ),
    );
  }
}