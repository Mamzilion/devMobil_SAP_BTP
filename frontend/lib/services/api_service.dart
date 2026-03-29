import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';

class ApiService {
  static const String baseUrl = AppConfig.baseUrl;

  // --- 1. AUTHENTIFICATION ---
  static Future<http.Response> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    try {
      return await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'mot_de_passe': password,
        }),
      );
    } catch (e) {
      print("Erreur Login : $e");
      rethrow;
    }
  }

  // --- 2. RÉCUPÉRER LES ACHATS ---
  static Future<http.Response> getPurchases(String token, String role, String userId) async {
    Uri url = (role == 'EMPLOYE') 
      ? Uri.parse('$baseUrl/purchases/mes-achats/$userId')
      : Uri.parse('$baseUrl/purchases/tous');

    try {
      return await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'role': role,
          'Authorization': 'Bearer $token', 
        },
      );
    } catch (e) {
      print("Erreur Fetch : $e");
      rethrow;
    }
  }

  // --- 3. CRÉER UNE DEMANDE ---
  static Future<http.Response> createPurchase(Map<String, dynamic> data, String token) async {
    final url = Uri.parse('$baseUrl/purchases/create');
    try {
      return await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );
    } catch (e) {
      print("Erreur Create : $e");
      rethrow;
    }
  }

  // --- 4. VALIDER / CHANGER LE STATUT (Dirigeant) ---
  static Future<http.Response> updateStatus(String purchaseId, String newStatus, String token) async {
    final url = Uri.parse('$baseUrl/purchases/update-status/$purchaseId');
    try {
      return await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'statut': newStatus}),
      );
    } catch (e) {
      print("Erreur Update Status : $e");
      rethrow;
    }
  }

  // --- 5. ENVOYER LE REÇU (Employé) ---
  static Future<http.StreamedResponse> uploadReceipt(String purchaseId, String filePath, String token) async {
    final url = Uri.parse('$baseUrl/purchases/upload-receipt/$purchaseId');
    try {
      var request = http.MultipartRequest('PUT', url);
      
      request.headers['Authorization'] = 'Bearer $token';
      // Le champ 'photo' doit être le même que celui utilisé dans Multer côté Backend
      request.files.add(await http.MultipartFile.fromPath('photo', filePath));

      return await request.send();
    } catch (e) {
      print("Erreur Upload Reçu : $e");
      rethrow;
    }
  }

  // --- 6. VÉRIFICATION MATIÈRE (Vérificateur + Sécurité) ---
  static Future<http.Response> verifyPurchase(String purchaseId, String userId, String token) async {
    final url = Uri.parse('$baseUrl/purchases/verify-purchase/$purchaseId');
    try {
      return await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        // On envoie l'ID de l'utilisateur pour que le backend vérifie qu'il n'est pas l'auteur
        body: jsonEncode({'userId': userId}),
      );
    } catch (e) {
      print("Erreur Verify Purchase : $e");
      rethrow;
    }
  }
}