import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/purchase_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EmitPurchaseScreen extends StatefulWidget {
  const EmitPurchaseScreen({super.key});

  @override
  State<EmitPurchaseScreen> createState() => _EmitPurchaseScreenState();
}

class _EmitPurchaseScreenState extends State<EmitPurchaseScreen> {
  final _titreController = TextEditingController();
  final _montantController = TextEditingController();
  final _descController = TextEditingController();
  
  String? selectedEmployeeId;
  List<dynamic> employees = [];
  bool isLoading = true;

  // Palette de couleurs Dark Premium
  final Color darkBackground = const Color(0xFF0D0D0D);
  final Color cardBackground = const Color(0xFF1A1A1A);
  final Color primaryGold = const Color(0xFF96653A);

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final response = await http.get(
        Uri.parse("http://10.110.105.169:5000/api/users"), 
        headers: {
          "Authorization": "Bearer ${auth.token}",
          "role": "DIRIGEANT",
          "Content-Type": "application/json",
        },
      );
      
      if (response.statusCode == 200) {
        setState(() {
          employees = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _emettreAction() async {
    if (selectedEmployeeId == null || _titreController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir les champs obligatoires")),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    bool success = await PurchaseService().createPurchase(
      token: auth.token!,
      userId: selectedEmployeeId!,
      titre: _titreController.text,
      montant: _montantController.text,
      description: _descController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Mission d'achat envoyée ! 🚀"), 
          backgroundColor: primaryGold,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        title: const Text("NOUVELLE MISSION", 
          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading 
        ? Center(child: CircularProgressIndicator(color: primaryGold))
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: primaryGold.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.assignment_add, size: 35, color: primaryGold),
                  ),
                ),
                const SizedBox(height: 30),
                
                _buildLabel("ASSIGNER À L'EMPLOYÉ"),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  dropdownColor: cardBackground,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  value: selectedEmployeeId,
                  items: employees.map((emp) => DropdownMenuItem<String>(
                    value: emp['_id'].toString(),
                    child: Text(emp['nom'].toString().toUpperCase(), style: const TextStyle(fontSize: 13)),
                  )).toList(),
                  onChanged: (val) => setState(() => selectedEmployeeId = val),
                  decoration: _inputDecoration("Choisir un destinataire"),
                ),

                const SizedBox(height: 25),
                _buildLabel("OBJET DE LA MISSION"),
                const SizedBox(height: 10),
                TextField(
                  controller: _titreController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Ex: Fournitures de bureau"),
                ),

                const SizedBox(height: 25),
                _buildLabel("BUDGET ESTIMÉ (CFA)"),
                const SizedBox(height: 10),
                TextField(
                  controller: _montantController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Montant maximum"),
                ),

                const SizedBox(height: 25),
                _buildLabel("INSTRUCTIONS"),
                const SizedBox(height: 10),
                TextField(
                  controller: _descController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Détails supplémentaires..."),
                ),

                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _emettreAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGold,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("ENVOYER LA MISSION", 
                        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                      SizedBox(width: 12),
                      Icon(Icons.send_rounded, size: 18),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: primaryGold,
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 13),
      filled: true,
      fillColor: cardBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: primaryGold.withOpacity(0.5), width: 1.5),
      ),
    );
  }
}